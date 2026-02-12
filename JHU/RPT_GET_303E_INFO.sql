DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` PROCEDURE `RPT_GET_303E_INFO`(
                                 IN report_unit VARCHAR(8)
                             )
BEGIN
 select all_proposal_data.INST_PROPOSAL,
all_proposal_data.ACTIVITY_TYPE,
all_proposal_data.ANTICIPATED_AWARD_TYPE,
all_proposal_data.PROPOSAL_STATUS,
all_proposal_data.DEPARTMENT,
all_proposal_data.AGGREGATED_DIVISION,
all_proposal_data.TITLE,
all_proposal_data.SPONSOR,
all_proposal_data.CRITICAL_SPONSOR,
all_proposal_data.SPONSOR_TYPE,
all_proposal_data.PRINCIPAL_INV,
all_proposal_data.PROPOSED_START,
all_proposal_data.PROPOSED_END,
all_proposal_data.REQUEST_TOTAL_PERIOD_DIRECT,
all_proposal_data.REQUEST_TOTAL_PERIOD_INDIRECT,
all_proposal_data.REQUEST_TOTAL_PERIOD_TOTAL,
all_proposal_data.SUBMISSION_DATE,
fa.grant_number AWARD_NUMBER ,
 DATE_FORMAT(STR_TO_DATE(g.grant_start_date, 'YYYYMMDD'), '%m/%d/%Y') ACTUAL_START ,
 DATE_FORMAT(STR_TO_DATE(g.grant_end_date, 'YYYYMMDD'), '%m/%d/%Y')   ACTUAL_END ,
 fa.direct_amount ANTICIPATED_DIRECT_TOTAL ,
 fa.indirect_amount ANTICIPATED_INDIRECT_TOTAL ,
 (fa.direct_amount + fa.indirect_amount) ANTICIPATED_TOTAL ,
 DATE_FORMAT(fa.award_date, '%m/%d/%Y') AWARD_DATE,
all_proposal_data.REPORT_NUMBER,
all_proposal_data.REPORT_TITLE,all_proposal_data. PARAMETER_ENTETRED_3,
all_proposal_data.RUN_TIME,
all_proposal_data.status_code
                       from (
with SH as (
                                               SELECT
                                                      sponsor_code sponsor_code
                                                    , parent_name  hierarchy_name
                                               FROM
                                                      report_sponsor_hierarchy
                                               UNION
                                               SELECT
                                                      isp.sponsor_code sponsor_code
                                                    , CASE
                                                             WHEN isp.sponsor_type_code= '2'
                                                                    THEN 'State/Local Government'
                                                             WHEN isp.sponsor_type_code= '3'
                                                                    THEN 'Private Profit'
                                                             WHEN isp.sponsor_type_code= '0'
                                                                    THEN 'Other Federal'
                                                             WHEN isp.sponsor_type_code= '1'
                                                                    THEN 'State/Local Government'
                                                             WHEN isp.sponsor_type_code= '4'
                                                                    THEN 'Foundation/Non-Profit'
                                                             WHEN isp.sponsor_type_code= '5'
                                                                    THEN 'Foundation/Non-Profit'
                                                             WHEN isp.sponsor_type_code= '6'
                                                                    THEN 'Institution of Higher Education'
                                                             WHEN isp.sponsor_type_code= '10'
                                                                    THEN 'Foreign'
                                                             WHEN isp.sponsor_type_code= '11'
                                                                    THEN 'Foreign'
                                                             WHEN isp.sponsor_type_code= '12'
                                                                    THEN 'Foreign'
                                                             WHEN isp.sponsor_type_code= '13'
                                                                    THEN 'Foreign'
                                                             WHEN isp.sponsor_type_code= '14'
                                                                    THEN 'Foreign'
                                                             WHEN isp.sponsor_type_code= '15'
                                                                    THEN 'Foreign'
                                                             WHEN isp.sponsor_type_code= '16'
                                                                    THEN 'Foreign'
                                                             WHEN isp.sponsor_type_code= '99'
                                                                    THEN 'Other'
                                                      END hierarchy_name
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
                                       )
SELECT
                        p.proposal_number                                                    INST_PROPOSAL
                      , at.description                                                      ACTIVITY_TYPE
                      , awt.description                                                      ANTICIPATED_AWARD_TYPE
                      , ps.description                                                       PROPOSAL_STATUS
                      , get_999_department(u.unit_number)                                    DEPARTMENT
                      , rs.unit_name                                                        AGGREGATED_DIVISION
                      , REPLACE(p.title,'','')                                               TITLE
                      , s.sponsor_name                                                       SPONSOR
                      , (CASE WHEN (  SELECT COUNT(1)
                                               FROM
                                                      development_sponsor
                                        WHERE
                                                        sponsor_code = s.sponsor_code) >0 THEN 'Y' END) CRITICAL_SPONSOR
                      , st.description                                                       SPONSOR_TYPE
                      , pr.full_name                                                         PRINCIPAL_INV
                      , DATE_FORMAT(p.start_date, '%m/%d/%Y')                                PROPOSED_START
                      , DATE_FORMAT(p.end_date, '%m/%d/%Y')                                  PROPOSED_END
                      , ibh.TOTAL_DIRECT_COST                                                REQUEST_TOTAL_PERIOD_DIRECT
                      , ibh.TOTAL_INDIRECT_COST                                              REQUEST_TOTAL_PERIOD_INDIRECT
                      , ibh.TOTAL_COST                         								 REQUEST_TOTAL_PERIOD_TOTAL
                      , DATE_FORMAT(p.create_timestamp, '%m/%d/%Y')                          SUBMISSION_DATE
                      ,'303e'                                                                REPORT_NUMBER
                      ,'Development Analysis'                                                REPORT_TITLE
                      , report_unit                                                         PARAMETER_ENTETRED_3
                      , SYSDATE()                                                            RUN_TIME
                      , p.status_code  status_code
         FROM
                        proposal p
					  LEFT JOIN ip_budget_header ibh ON p.PROPOSAL_ID = ibh.PROPOSAL_ID
                        JOIN            proposal_persons pi
                                        ON
                                                        pi.proposal_number = p.proposal_number
                                        AND pi.pi_flag         = 'Y'
										AND pi.sequence_number =
										(
											   SELECT
													  MAX(sequence_number)
											   FROM
													  proposal_persons
											   WHERE
													  proposal_number = pi.proposal_number
										)
					   JOIN
                                        prop_person_units pu
                                        ON
                                                        pu.PROPOSAL_PERSON_ID = pi.PROPOSAL_PERSON_ID
                                        AND pu.lead_unit_flag = 'Y'
										AND
										(
														pu.unit_number           != '00000002'
														AND pu.unit_number       != 'JHHSDNC'
														AND pu.unit_number NOT LIKE '4%'
														AND pu.unit_number NOT LIKE '5%'
														AND pu.unit_number NOT LIKE '6%'
														AND pu.unit_number NOT LIKE '7%'
														AND pu.unit_number NOT LIKE '8%'
														AND pu.unit_number NOT LIKE '9%'
										)
										AND FIND_IN_SET(pu.unit_number,fn_get_temp_unit (report_unit))
                         JOIN
                                        proposal_status ps
                                        ON
                                                        ps.status_code = p.status_code
                                        AND ps.status_code != 8
                         JOIN
                                        proposal_type pt
                                        ON
                                                        pt.type_code = p.type_code
                         JOIN
                                        activity_type at
                                        ON
                                                        at.activity_type_code = p.activity_type_code
                         JOIN
                                        unit u
                                        ON
                                                        u.unit_number = pu.unit_number
                         JOIN
                                        sponsor s
                                        ON
                                                        s.sponsor_code = p.sponsor_code
                                        AND s.sponsor_type_code IN (4
                                                  , 5
                                                  , 14
                                                  , 15)
                         JOIN
                                        sponsor_type st
                                        ON
                                                        st.sponsor_type_code = s.sponsor_type_code
                         JOIN
                                        person pr
                                        ON
                                                        pr.person_id = pi.person_id
                        LEFT OUTER JOIN
                                        award_type awt
                                        ON
                                                        awt.award_type_code = p.award_type_code
                         JOIN
                                        report_sponsor_type rst
                                        ON
                                                        rst.sponsor_type_code = s.sponsor_type_code
					JOIN
                                        report_school RS
                                        ON
                                                        rs.business_area=SUBSTR(pu.unit_number, 1, 3)
                         JOIN
                                        sh
                                        ON
                                                        sh.sponsor_code=p.sponsor_code
        WHERE
                        p.type_code NOT IN (3
                                          , 91
                                          , 92
                                          , 93
                                          , 94
                                          , 96
                                          , 97)
                        AND p.sequence_number =
                        (
                               SELECT
                                      MAX(sequence_number)
                               FROM
                                      proposal
                               WHERE
                                      proposal_number = p.proposal_number
                        )
                        ) all_proposal_data
left join sap_grant g
		 on all_proposal_data.INST_PROPOSAL=g.proposal_number
LEFT OUTER JOIN
                                        (
                                                 SELECT
                                                          iisga1.grant_number
                                                        , ROUND(SUM(REPLACE(REPLACE(iisga1.grant_budget_direct, '$',''), ',','')))   direct_amount
                                                        , ROUND(SUM(REPLACE(REPLACE(iisga1.grant_budget_indirect, '$',''), ',',''))) indirect_amount
                                                        , STR_TO_DATE(MIN(iisga1.award_effective_date), '%Y%m%d')                    award_date
                                                 FROM
                                                          sap_grant_award iisga1
                                                 GROUP BY
                                                          iisga1.grant_number
                                        )
                                        fa
                                        ON
                                                        fa.grant_number = g.grant_number
LEFT OUTER JOIN
                                        (
                                               SELECT
                                                      SUBSTR(ia.award_number, 1, 6) grant_number
                                                    , ia.status_code             award_status
                                               FROM
                                                      award        ia
                                               WHERE
                                                 ia.award_number like '%-00001'
                                                      AND ia.sequence_number =
                                                      (
                                                             SELECT
                                                                    MAX(sequence_number)
                                                             FROM
                                                                    award
                                                             WHERE
                                                                    award_number = ia.award_number
                                                      )
                                                   )
                                        cas
                                        ON
                                                        cas.grant_number = g.grant_number
   where (cas.award_status='1' or all_proposal_data.status_code=1)
   order by 1 desc;
END
$$
DELIMITER ;
