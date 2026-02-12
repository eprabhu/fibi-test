DELIMITER $$
CREATE  PROCEDURE `RPT_GET_302E_INFO`(IN report_start_date VARCHAR(50)
									 ,IN report_end_date VARCHAR(50)
                                     ,IN report_unit VARCHAR(50))
BEGIN
WITH all_data AS (
    SELECT
        DATE_FORMAT(p1.create_timestamp + INTERVAL 6 MONTH, '%y') AS FISCAL_YEAR,
        LPAD(MOD(MONTH(p1.create_timestamp) + 6 - 1, 12) + 1, 2, '0') AS FISCAL_MONTH,
        p.proposal_number AS INST_PROPOSAL,
        pt.description AS PROPOSAL_TYPE,
        at.description AS ACTIVITY_TYPE,
        awt.description AS ANTICIPATED_AWARD_TYPE,
        ps.description AS PROPOSAL_STATUS,
        SUBSTR(pu.unit_number, 1, 3) AS BUSINESS_AREA,
        pu.unit_number AS UNIT_NUMBER,
        u.unit_name AS UNIT_NAME,
        get_999_department(u.unit_number) AS DEPARTMENT,
        REPLACE(p.title, '\n', '') AS TITLE,
        p.sponsor_code AS SPONSOR_CODE,
        s.sponsor_name AS SPONSOR,
        st.description AS SPONSOR_TYPE,
        p.prime_sponsor_code AS PRIME_SPONSOR_CODE,
        sp.sponsor_name AS PRIME_SPONSOR_NAME,
        pst.description AS PRIME_SPONSOR_TYPE,
        pr.full_name AS PRINCIPAL_INV,
        pr.person_id AS EMPLOYEE_ID,
        DATE_FORMAT(p.START_DATE, '%m/%d/%Y') AS REQUEST_FIRST_PERIOD_START,
        DATE_FORMAT(p.START_DATE, '%m/%d/%Y') AS REQUEST_TOTAL_PERIOD_START,
        DATE_FORMAT(p.END_DATE, '%m/%d/%Y') AS REQUEST_FIRST_PERIOD_END,
        DATE_FORMAT(p.END_DATE, '%m/%d/%Y') AS REQUEST_TOTAL_PERIOD_END,
        ibh.total_direct_cost AS REQUEST_FIRST_PERIOD_DIRECT,
        ibh.total_direct_cost AS REQUEST_TOTAL_PERIOD_DIRECT,
        ibh.total_indirect_cost AS REQUEST_FIRST_PERIOD_INDIRECT,
        ibh.total_indirect_cost AS REQUEST_TOTAL_PERIOD_INDIRECT,
        (ibh.total_direct_cost + ibh.total_indirect_cost) AS REQUEST_FIRST_PERIOD_TOTAL,
        (ibh.total_direct_cost + ibh.total_indirect_cost) AS REQUEST_TOTAL_PERIOD_TOTAL,
        '' AS ANNOUNCEMENT_NUMBER,
        '' AS SUBCONTRACT_FLAG,
        (CASE WHEN EXISTS (
            SELECT 1 FROM proposal_resrch_areas ipsc
            WHERE ipsc.RESRCH_TYPE_AREA_CODE = '14'
            AND p.proposal_ID = ipsc.proposal_ID) THEN 'Y' ELSE '' END) AS ARRA_PROPOSAL,
        date_format(p1.create_timestamp, '%m/%d/%Y')  AS SUBMISSION_DATE,
        -- New field for Research Area
        GROUP_CONCAT(DISTINCT rt.STYLED_AREA_OF_RESEARCH ORDER BY rt.description SEPARATOR ', ') AS RESEARCH_AREAS,
        '302e' AS REPORT_NUMBER,
        'Funding Analysis' AS REPORT_TITLE
    FROM proposal p
    LEFT JOIN (
        SELECT proposal_number, create_timestamp
        FROM proposal WHERE sequence_number = 1
    ) p1 ON p.proposal_number = p1.proposal_number
    LEFT JOIN ip_budget_header ibh ON ibh.proposal_id = p.proposal_id
    JOIN proposal_persons pi ON p.PROPOSAL_ID = pi.PROPOSAL_ID
        AND pi.PI_FLAG = 'Y'
    JOIN prop_person_units pu ON pu.PROPOSAL_PERSON_ID = pi.PROPOSAL_PERSON_ID
        AND pu.lead_unit_flag = 'Y'
        AND
								(
												pu.unit_number           <> '00000002'
												AND pu.unit_number       <> 'JHHSDNC'
												AND pu.unit_number NOT LIKE '4%'
												AND pu.unit_number NOT LIKE '5%'
												AND pu.unit_number NOT LIKE '6%'
												AND pu.unit_number NOT LIKE '7%'
												AND pu.unit_number NOT LIKE '8%'
												AND pu.unit_number NOT LIKE '9%'
								)
                                     AND find_in_set(pu.unit_number,fn_get_temp_unit(report_unit))
    JOIN proposal_status ps ON p.status_code = ps.status_code AND ps.status_code != 7
    JOIN proposal_type pt ON p.type_code = pt.type_code
    JOIN activity_type at ON p.activity_type_code = at.activity_type_code
    JOIN unit u ON pu.unit_number = u.unit_number
    JOIN sponsor s ON p.sponsor_code = s.sponsor_code
    JOIN sponsor_type st ON s.sponsor_type_code = st.sponsor_type_code
    JOIN person pr ON pi.person_id = pr.person_id
    LEFT JOIN award_type awt ON p.award_type_code = awt.award_type_code
    LEFT JOIN sponsor sp ON p.prime_sponsor_code = sp.sponsor_code
    LEFT JOIN sponsor_type pst ON sp.sponsor_type_code = pst.sponsor_type_code
    LEFT JOIN proposal_resrch_areas pra ON pra.PROPOSAL_ID = p.PROPOSAL_ID
    LEFT JOIN research_type_area rt ON pra.RESRCH_TYPE_AREA_CODE = rt.RESRCH_TYPE_AREA_CODE
    WHERE p.type_code IN (1, 4, 5, 6, 9)
    AND p.sequence_number = (SELECT MAX(sequence_number) FROM proposal WHERE proposal_number = p.proposal_number)
    AND p1.create_timestamp  >= STR_TO_DATE(report_start_date, '%m/%d/%Y') + INTERVAL -1 YEAR
    AND p1.create_timestamp <= STR_TO_DATE(report_end_date, '%m/%d/%Y') + INTERVAL 1 DAY
    GROUP BY p.proposal_number  -- Ensures one row per proposal
    ORDER BY p.proposal_number DESC
),
fa as (
                                       SELECT
                                              ijs1.institute_proposal_number               proposal_number
                                            , ijs1.grant_number                            grant_number
                                            , (ijs1.funded_amount)                         grant_funded_amount
                                            , ijs1.award_date                              award_date
                                            , str_to_date(isg0.grant_start_date, '%Y%m%d') grant_start_date
                                            , str_to_date(isg0.grant_end_date, '%Y%m%d')   grant_end_date
                                       FROM
                                              jhu_supplement ijs1
                                            , sap_grant      isg0
                                       WHERE
                                              ijs1.grant_number = isg0.grant_number
                                       UNION
                                       SELECT
                                                       isg1.proposal_number                         proposal_number
                                                     , isg1.grant_number                            grant_number
                                                     , (isg1.grant_funded_amount)                   grant_funded_amount
                                                     , isga1.award_date                             award_date
                                                     , str_to_date(isg1.grant_start_date, '%Y%m%d') grant_start_date
                                                     , str_to_date(isg1.grant_end_date, '%Y%m%d')   grant_end_date
                                       FROM
                                                       sap_grant isg1
                                                       left outer join
                                                                       (
                                                                                SELECT
                                                                                         iisga1.grant_number
                                                                                       ,(SUM(REPLACE(REPLACE(iisga1.grant_budget_direct, '$',''), ',','')) + SUM(REPLACE(REPLACE(iisga1.grant_budget_indirect, '$',''), ',',''))) grant_funded_amount
                                                                                       , str_to_date(MIN(iisga1.award_effective_date), '%Y%m%d')                                                                                  award_date
                                                                                FROM
                                                                                         sap_grant       iisg1
                                                                                       , sap_grant_award iisga1
                                                                                WHERE
                                                                                         iisg1.proposal_number != '00000000'
                                                                                         AND iisg1.grant_number = iisga1.grant_number
                                                                                GROUP BY
                                                                                         iisga1.grant_number
                                                                       )
                                                                       isga1
                                                                       on
                                                                                       isg1.grant_number = isga1.grant_number
                                       WHERE
                                                       isg1.grant_number NOT IN
                                                       (
                                                              SELECT
                                                                     grant_number
                                                              FROM
                                                                     jhu_supplement
                                                       )
                                                       AND isg1.proposal_number NOT IN
                                                       (
                                                              SELECT
                                                                     ORIGINAL_IP_NUMBER
                                                              FROM
                                                                     jhu_multiple_grant
                                                       )
                                       UNION
                                       SELECT
                                                 isg2.proposal_number                                  proposal_number
                                               , isg2.grant_number                                     grant_number
                                               , (ifnull(isg2.grant_funded_amount,0) - ifnull(ijs2.grant_funded_amount,0)) grant_funded_amount
                                               , iga2.award_date                                       award_date
                                               , str_to_date(isg2.grant_start_date, '%Y%m%d')          grant_start_date
                                               , str_to_date(isg2.grant_end_date, '%Y%m%d')            grant_end_date
                                       FROM
                                                 sap_grant isg2
                                                 ,
                                                           (
                                                                    SELECT
                                                                             grant_number
                                                                           , SUM(funded_amount) grant_funded_amount
                                                                    FROM
                                                                             jhu_supplement
                                                                    GROUP BY
                                                                             grant_number
                                                           )
                                                           ijs2
                                                 ,
                                                           (
                                                                    SELECT
                                                                             grant_number
                                                                           , MIN(str_to_date(award_effective_date, '%Y%m%d')) award_date
                                                                    FROM
                                                                             sap_grant_award
                                                                    GROUP BY
                                                                             grant_number
                                                           )
                                                           iga2
                                       WHERE
                                                 isg2.grant_number NOT IN
                                                 (
                                                        SELECT
                                                               original_grant_number
                                                        FROM
                                                               jhu_multiple_grant
                                                 )
									   and isg2.grant_number = ijs2.grant_number
                                       and isg2.grant_number = iga2.grant_number
                                       UNION
                                       SELECT
                                                       isg4.proposal_number                                    proposal_number
                                                     , isg3.grant_number                                       grant_number
                                                     , (isg3.grant_funded_amount + (isg4.grant_funded_amount)) grant_funded_amount
                                                     , iga3.award_date                                         award_date
                                                     , str_to_date(isg4.grant_start_date, '%Y%m%d')            grant_start_date
                                                     , str_to_date(isg3.grant_end_date, '%Y%m%d')              grant_end_date
                                       FROM
                                                       sap_grant isg3
                                                       left outer join
                                                                       jhu_multiple_grant ijmg
                                                                       on
                                                                                       isg3.grant_number = ijmg.new_grant_number
                                                                                     , sap_grant isg4
                                                                                     , (
                                                                                                SELECT
                                                                                                         iisga2.grant_number
                                                                                                       , str_to_date(MIN(iisga2.award_effective_date), '%Y%m%d') award_date
                                                                                                FROM
                                                                                                         sap_grant       iisg2
                                                                                                       , sap_grant_award iisga2
                                                                                                WHERE
                                                                                                         iisg2.proposal_number != '00000000'
                                                                                                         AND iisg2.grant_number = iisga2.grant_number
                                                                                                GROUP BY
                                                                                                         iisga2.grant_number
                                                                                       )
                                                                                       iga3
                                       WHERE
                                                       isg3.grant_number NOT IN
                                                       (
                                                              SELECT
                                                                     grant_number
                                                              FROM
                                                                     jhu_supplement
                                                       )
                                                       AND isg4.grant_number NOT IN
                                                       (
                                                              SELECT
                                                                     grant_number
                                                              FROM
                                                                     jhu_supplement
                                                       )
                                                       AND isg4.grant_number = ijmg.original_grant_number
                                                       AND isg4.grant_number = iga3.grant_number
                                       UNION
                                       SELECT
                                                       isg4.proposal_number                                                                                                                  proposal_number
                                                     , isg3.grant_number                                                                                                                     grant_number
                                                     , (isg3.grant_funded_amount + isg4.grant_funded_amount) - ((ifnull(ijs3.grant_funded_amount, 0) + ifnull(ijs4.grant_funded_amount, 0))) grant_funded_amount
                                                     , iga3.award_date                                                                                                                       award_date
                                                     , str_to_date(isg4.grant_start_date, '%Y%m%d')                                                                                          grant_start_date
                                                     , str_to_date(isg3.grant_end_date, '%Y%m%d')                                                                                            grant_end_date
                                       FROM
                                                       sap_grant isg4
                                                       left join
                                                                       (
                                                                                SELECT
                                                                                         iisga2.grant_number
                                                                                       , str_to_date(MIN(iisga2.award_effective_date), '%Y%m%d') award_date
                                                                                FROM
                                                                                         sap_grant       iisg2
                                                                                       , sap_grant_award iisga2
                                                                                WHERE
                                                                                         iisg2.proposal_number != '00000000'
                                                                                         AND iisg2.grant_number = iisga2.grant_number
                                                                                GROUP BY
                                                                                         iisga2.grant_number
                                                                       )
                                                                       iga3
                                                                       on
                                                                                       iga3.grant_number=isg4.grant_number
                                                       left outer join
                                                                       (
                                                                                SELECT
                                                                                         grant_number
                                                                                       , SUM(funded_amount) grant_funded_amount
                                                                                FROM
                                                                                         jhu_supplement
                                                                                WHERE
                                                                                         grant_number IN
                                                                                         (
                                                                                                SELECT
                                                                                                       original_grant_number
                                                                                                FROM
                                                                                                       jhu_multiple_grant
                                                                                         )
                                                                                GROUP BY
                                                                                         grant_number
                                                                       )
                                                                       ijs4
                                                                       on
                                                                                       isg4.grant_number = ijs4.grant_number
                                                                                     , sap_grant isg3
                                                       left outer join
                                                                       (
                                                                                SELECT
                                                                                         grant_number
                                                                                       , SUM(funded_amount) grant_funded_amount
                                                                                FROM
                                                                                         jhu_supplement
                                                                                WHERE
                                                                                         grant_number IN
                                                                                         (
                                                                                                SELECT
                                                                                                       new_grant_number
                                                                                                FROM
                                                                                                       jhu_multiple_grant
                                                                                         )
                                                                                GROUP BY
                                                                                         grant_number
                                                                       )
                                                                       ijs3
                                                                       on
                                                                                       ijs3.grant_number = isg3.grant_number
                                                                                     , jhu_multiple_grant ijmg
                                       WHERE
                                                       (
                                                                       isg3.grant_number    = ijs3.grant_number
                                                                       OR isg4.grant_number = ijs4.grant_number
                                                       )
                                                       AND isg3.grant_number = ijmg.new_grant_number
                                                       AND isg4.grant_number = ijmg.original_grant_number
                              ),
cas as (  SELECT
                                              SUBSTR(ia.award_number, 1, 6) grant_number
                                            ,  (select icas.description from award_status icas where  ia.status_code = icas.status_code) award_status
											, ( CASE WHEN (SELECT COUNT(*) FROM award_research_areas iasc WHERE iasc.award_id=ia.award_id AND iasc.RESRCH_TYPE_AREA_CODE = '14' ) >0 THEN 'Y' END ) AS arra_value
                                       FROM
                                              award        ia
                                       WHERE
                                              ia.award_number     like '%-00001'
                                              AND exists ( select 1 from fa
                                              where grant_number= SUBSTR(ia.award_number, 1, 6) )
                                              AND ia.sequence_number =
                                              (
                                                     SELECT
                                                            MAX(sequence_number)
                                                     FROM
                                                            award
                                                     WHERE
                                                            award_number = ia.award_number
                                              )
                                ),
SH AS (
                                       SELECT
                                              sponsor_code sponsor_code
                                            , parent_name  hierarchy_name
                                       FROM
                                              report_sponsor_hierarchy
                                       UNION
                                       SELECT
                                              isp.sponsor_code sponsor_code
                                            ,
                                              (
                                                     case
                                                            when isp.sponsor_type_code= '2'
                                                                   then 'State/Local Government'
                                                            when isp.sponsor_type_code='3'
                                                                   then 'Private Profit'
                                                            when isp.sponsor_type_code='0'
                                                                   then 'Other Federal'
                                                            when isp.sponsor_type_code='1'
                                                                   then 'State/Local Government'
                                                            when isp.sponsor_type_code='4'
                                                                   then 'Foundation/Non-Profit'
                                                            when isp.sponsor_type_code='5'
                                                                   then 'Foundation/Non-Profit'
                                                            when isp.sponsor_type_code='6'
                                                                   then 'Institution of Higher Education'
                                                            when isp.sponsor_type_code='10'
                                                                   then 'Foreign'
                                                            when isp.sponsor_type_code='11'
                                                                   then 'Foreign'
                                                            when isp.sponsor_type_code='12'
                                                                   then 'Foreign'
                                                            when isp.sponsor_type_code='13'
                                                                   then 'Foreign'
                                                            when isp.sponsor_type_code='14'
                                                                   then 'Foreign'
                                                            when isp.sponsor_type_code='15'
                                                                   then 'Foreign'
                                                            when isp.sponsor_type_code='16'
                                                                   then 'Foreign'
                                                            when isp.sponsor_type_code='99'
                                                                   then 'Other'
                                                     end
                                              )
                                              hierarchy_name
                                       FROM
                                              sponsor isp
                                       WHERE
                                              isp.sponsor_code NOT IN
                                              (
                                                     SELECT
                                                            sponsor_code
                                                     FROM
                                                            report_sponsor_hierarchy
                                              )
                                ),
sc as ( SELECT
        SUBSTR(UNIT_NUMBER, 1, 3) AS business_area,
        (unit_name) AS unit_name
    FROM
        unit
    WHERE
        ((UNIT_NUMBER LIKE '%00000')
            AND (UNIT_NUMBER <> '000001')
            AND (UNIT_NUMBER <> '000000')))
select distinct all_data.FISCAL_YEAR,
all_data.FISCAL_MONTH,
all_data.INST_PROPOSAL,
all_data.PROPOSAL_TYPE,
all_data. ACTIVITY_TYPE,
all_data.ANTICIPATED_AWARD_TYPE,
all_data.PROPOSAL_STATUS,
all_data.BUSINESS_AREA,
all_data.UNIT_NUMBER,
all_data. UNIT_NAME,
all_data.DEPARTMENT,
sc.unit_name DIVISION,
rs.unit_name AGGREGATED_DIVISION,
all_data.TITLE,
 all_data.SPONSOR_CODE,
all_data.SPONSOR,
all_data.SPONSOR_TYPE,
sh.hierarchy_name AGGREGATED_SPONSOR_TYPE,
all_data.PRIME_SPONSOR_CODE,
all_data.PRIME_SPONSOR_NAME,
all_data.PRIME_SPONSOR_TYPE,
all_data.PRINCIPAL_INV,
all_data.EMPLOYEE_ID,
all_data.REQUEST_FIRST_PERIOD_START,
all_data.REQUEST_TOTAL_PERIOD_START,
all_data.REQUEST_FIRST_PERIOD_END,
all_data.REQUEST_TOTAL_PERIOD_END,
all_data.REQUEST_FIRST_PERIOD_DIRECT,
all_data.REQUEST_TOTAL_PERIOD_DIRECT,
all_data.REQUEST_FIRST_PERIOD_INDIRECT,
all_data.REQUEST_TOTAL_PERIOD_INDIRECT,
all_data.REQUEST_FIRST_PERIOD_TOTAL,
all_data.REQUEST_TOTAL_PERIOD_TOTAL,
all_data.ANNOUNCEMENT_NUMBER,
all_data.SUBCONTRACT_FLAG,
all_data.ARRA_PROPOSAL,
rs.ora_office ORA,
all_data.SUBMISSION_DATE,
fa.grant_number AWARD_NUMBER,
cas.award_status                             AWARD_STATUS,
date_format(fa.grant_start_date, '%m/%d/%Y') AWARD_START,
date_format(fa.grant_end_date, '%m/%d/%Y')   AWARD_END,
fa.grant_funded_amount                       ANTICIPATED_TOTAL,
date_format(fa.award_date, '%m/%d/%Y')       AWARD_DATE,
cas.arra_value ARRA_AWARD,
all_data.RESEARCH_AREAS                    RESEARCH_AREAS,
'302e'  REPORT_NUMBER,
'Funding Analysis' REPORT_TITLE,
DATE_FORMAT(STR_TO_DATE(report_start_date, '%m/%d/%Y') + INTERVAL -1 YEAR,'%m/%d/%Y') PARAMETER_ENTETRED_1,
report_end_date PARAMETER_ENTETRED_2,
report_unit PARAMETER_ENTETRED_3,
utc_timestamp() RUN_TIME,
 @@hostname HOST_NAME
      from all_data
      left join fa on all_data.INST_PROPOSAL=fa.proposal_number
left join cas on   cas.grant_number = fa.grant_number
join sh on sh.sponsor_code=all_data.SPONSOR_CODE
join sc on all_data.BUSINESS_AREA = sc.business_area
join report_school rs  on all_data.BUSINESS_AREA = rs.business_area
;
END
$$
DELIMITER ;
