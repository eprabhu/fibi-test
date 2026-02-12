DELIMITER $$
CREATE  PROCEDURE `GET_101_MV_DATA_1`(IN UNIT VARCHAR(8))
BEGIN
SELECT DISTINCT  FN_GET_UNIT_SNUM(concat(SUBSTR(u.sort_value, 1,3),'000000000000000000000000000')) ENTITY
         , FN_GET_UNIT_SNUM(concat(SUBSTR(u.sort_value, 1,6),'000000000000000000000000')) SCHOOL
         , FN_GET_UNIT_SNUM(concat(SUBSTR(u.sort_value, 1,9),'000000000000000000000')) DEPT_1
         , FN_GET_UNIT_SNUM(concat(SUBSTR(u.sort_value, 1,12),'000000000000000000')) DEPT_2
         , FN_GET_UNIT_SNUM(concat(SUBSTR(u.sort_value, 1,15),'000000000000000'))    DEPT_3
         , NULL                        as DEPT_4
         , NULL                        as DEPT_5
         , FN_GET_UNIT_SNAME(concat(SUBSTR(u.sort_value, 1,3),'000000000000000000000000000')) ENTITY_NAME
         , FN_GET_UNIT_SNAME(concat(SUBSTR(u.sort_value, 1,6),'000000000000000000000000')) SCHOOL_NAME
         , FN_GET_UNIT_SNAME(concat(SUBSTR(u.sort_value, 1,9),'000000000000000000000')) DEPT_1_NAME
         , FN_GET_UNIT_SNAME(concat(SUBSTR(u.sort_value, 1,12),'000000000000000000')) DEPT_2_NAME
         , FN_GET_UNIT_SNAME(concat(SUBSTR(u.sort_value, 1,15),'000000000000000'))    DEPT_3_NAME
         , NULL                        as DEPT_4_NAME
         , NULL   					   as DEPT_5_NAME
         , u.UNIT_NAME
         , pi.FULL_NAME as INV_NAME
         , p.TITLE
         , p.SPONSOR_CODE as SPONSOR
         , s.SPONSOR_NAME
         , at.DESCRIPTION as AWARD_TYPE
         , act.DESCRIPTION as PURPOSE
         , pt.DESCRIPTION as PROPOSAL_TYPE
         , p.START_DATE
         , CASE WHEN pi.PI_FLAG = 'Y' THEN ibh.TOTAL_DIRECT_COST ELSE NULL END AS DIRECT_AMOUNT
         , CASE WHEN pi.PI_FLAG = 'Y' THEN ibh.TOTAL_INDIRECT_COST ELSE NULL END AS INDIRECT_AMOUNT
         , CASE WHEN pi.PI_FLAG = 'Y' THEN ibh.TOTAL_COST ELSE NULL END AS TOTAL_AMOUNT
		 , p.PROPOSAL_NUMBER
		 , h.PARENT_UNIT_NUMBER
         , u.UNIT_NUMBER
         , p.PROPOSAL_ID
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
 find_in_set(u.unit_number,fn_get_temp_unit (UNIT)) AND pi.ROLODEX_ID IS NULL
           ;
END
$$
DELIMITER ;
