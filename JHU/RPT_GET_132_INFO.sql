DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `RPT_GET_132_INFO`( IN unit  VARCHAR(8)
                                   ,IN before_date  VARCHAR(50)
                                   ,IN after_date  VARCHAR(50)
                                  )
BEGIN
   SELECT distinct
		  fn_get_unit_snum(CONCAT(SUBSTR(u.sort_value, 1,3),'000000000000000000000000000')) ENTITY
         ,fn_get_unit_snum(CONCAT(SUBSTR(u.sort_value, 1,6),'000000000000000000000000')) SCHOOL
         ,fn_get_unit_snum(CONCAT(SUBSTR(u.sort_value, 1,9),'000000000000000000000')) DEPT_1
         ,fn_get_unit_snum(CONCAT(SUBSTR(u.sort_value, 1,12),'000000000000000000')) DEPT_2
         ,fn_get_unit_snum(CONCAT(SUBSTR(u.sort_value, 1,15),'000000000000000')) DEPT_3
         ,NULL AS DEPT_4
         ,NULL AS DEPT_5
         ,fn_get_unit_sname(CONCAT(SUBSTR(u.sort_value, 1,3),'000000000000000000000000000')) ENTITY_NAME
         ,fn_get_unit_sname(CONCAT(SUBSTR(u.sort_value, 1,6),'000000000000000000000000')) SCHOOL_NAME
         ,fn_get_unit_sname(CONCAT(SUBSTR(u.sort_value, 1,9),'000000000000000000000')) DEPT_1_NAME
         ,fn_get_unit_sname(CONCAT(SUBSTR(u.sort_value, 1,12),'000000000000000000')) DEPT_2_NAME
         ,fn_get_unit_sname(CONCAT(SUBSTR(u.sort_value, 1,15),'000000000000000')) DEPT_3_NAME
         ,NULL AS DEPT_4_NAME
         ,NULL AS DEPT_5_NAME
         ,u.UNIT_NAME
         ,r.AWARD_NUMBER
         ,r.FULL_NAME PERSON_NAME
         ,r.TITLE
         ,r.SPONSOR_NAME
         ,r.SPONSOR
         ,r.AWARD_TYPE
         ,r.PURPOSE
         ,r.STATUS
         ,r.START_DATE
         ,r.END_DATE
         ,r.DIRECT
         ,r.INDIRECT
         ,r.AWARD_ID
         ,h.PARENT_UNIT_NUMBER
         ,u.UNIT_NUMBER
   FROM   rpt_mv_awards r
         ,jhu_unit u
         ,unit h
   WHERE  r.start_date BETWEEN STR_TO_DATE(before_date,'%m/%d/%Y') AND STR_TO_DATE(after_date,'%m/%d/%Y')
   AND    (r.direct + r.indirect) >= 250000
   AND    FIND_IN_SET(r.lead_unit_number,fn_get_temp_unit(unit))
   AND    FIND_IN_SET(r.home_unit,fn_get_temp_unit(unit))
   AND    r.lead_unit_number = u.unit_number
   AND    h.unit_number = u.unit_number;
 END
$$
DELIMITER ;
