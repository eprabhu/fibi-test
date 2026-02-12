DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GET_101_MV_DATA_R`(  IN UNIT  VARCHAR(500))
BEGIN
   select DISTINCT
   u.UNIT_NAME
   , u.UNIT_NUMBER
   , pi.FULL_NAME as PRINCIPAL_INV
   , p.TITLE
   , s.SPONSOR_NAME as SPONSOR
   , at.DESCRIPTION AS AWARD_TYPE
   , act.DESCRIPTION as ACTIVITY_TYPE
   , pt.DESCRIPTION AS PROPOSAL_TYPE
   , p.START_DATE
   , CASE WHEN pi.PI_FLAG = 'Y' THEN ibh.TOTAL_DIRECT_COST ELSE NULL END AS DIRECT_AMOUNT
   , CASE WHEN pi.PI_FLAG = 'Y' THEN ibh.TOTAL_INDIRECT_COST ELSE NULL END AS INDIRECT_AMOUNT
   , CASE WHEN pi.PI_FLAG = 'Y' THEN ibh.TOTAL_COST ELSE NULL END AS TOTAL_AMOUNT
   , p.PROPOSAL_NUMBER as INST_PROPOSAL_NUMBER
   ,'300e' as REPORT_NUMBER
   ,unit as PARAM_ENTERED_1
   ,utc_timestamp() as RUN_TIME
   ,'Pending Proposals' as REPORT_TITLE
   from PROPOSAL P
LEFT JOIN
	ip_budget_header ibh ON ibh.proposal_id=p.proposal_id
        LEFT OUTER JOIN
    sponsor s ON p.sponsor_code = s.sponsor_code
        LEFT OUTER JOIN
    activity_type act ON p.activity_type_code = act.activity_type_code
        LEFT OUTER JOIN
    award_type at ON p.AWARD_TYPE_CODE = at.AWARD_TYPE_CODE
        LEFT OUTER JOIN
    proposal_type pt ON P.TYPE_CODE = PT.TYPE_CODE
        LEFT OUTER JOIN
    proposal_persons pi ON p.proposal_id = pi.proposal_id
     left join jhu_unit u on u.unit_number =p.HOME_UNIT_NUMBER
          left join  unit h on  h.unit_number = u.unit_number
WHERE P.STATUS_CODE = 1 AND P.PROPOSAL_SEQUENCE_STATUS = 'ACTIVE' AND
 find_in_set(u.unit_number,fn_get_temp_unit (UNIT)) AND pi.ROLODEX_ID IS NULL ORDER BY pi.PI_FLAG,p.PROPOSAL_NUMBER DESC
           ;
 END
$$
DELIMITER ;
