DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GET_202_MV_DATA_SORT`(
  IN UNIT  VARCHAR(50)
, IN BEFORE_DATE  varchar(50)
, IN AFTER_DATE   varchar(50)
)
BEGIN
   select distinct
    fn_get_unit_snum(CONCAT(SUBSTR(u.sort_value, 1,3),'000000000000000000000000000')) ENTITY
   ,fn_get_unit_snum(CONCAT(SUBSTR(u.sort_value, 1,6),'000000000000000000000000')) SCHOOL
   ,fn_get_unit_snum(CONCAT(SUBSTR(u.sort_value, 1,9),'000000000000000000000')) DEPT_1
   ,fn_get_unit_snum(CONCAT(SUBSTR(u.sort_value, 1,12),'000000000000000000')) DEPT_2
   ,fn_get_unit_snum(CONCAT(SUBSTR(u.sort_value, 1,15),'000000000000000')) DEPT_3
   ,NULL as DEPT_4
   ,NULL as DEPT_5
   ,fn_get_unit_sname(CONCAT(SUBSTR(u.sort_value, 1,3),'000000000000000000000000000')) ENTITY_NAME
   ,fn_get_unit_sname(CONCAT(SUBSTR(u.sort_value, 1,6),'000000000000000000000000')) SCHOOL_NAME
   ,fn_get_unit_sname(CONCAT(SUBSTR(u.sort_value, 1,9),'000000000000000000000')) DEPT_1_NAME
   ,fn_get_unit_sname(CONCAT(SUBSTR(u.sort_value, 1,12),'000000000000000000')) DEPT_2_NAME
   ,fn_get_unit_sname(CONCAT(SUBSTR(u.sort_value, 1,15),'000000000000000'))DEPT_3_NAME
   ,NULL as DEPT_4_NAME
   ,NULL as DEPT_5_NAME
   ,u.UNIT_NAME
   ,r.AWARD_NUMBER
   , r.full_name AS  PERSON_NAME
   , r.TITLE
   , r.SPONSOR_NAME
   , r.SPONSOR
   , r.AWARD_TYPE
   , r.PURPOSE
   , r.STATUS
   , r.START_DATE
   , r.END_DATE
   , r.DIRECT
   , r.INDIRECT
   , r.AWARD_ID
   , h.PARENT_UNIT_NUMBER
   ,u.UNIT_NUMBER
   from
   rpt_mv_awards r
   ,jhu_unit u
   ,unit h
   where
   r.start_date between str_to_date(before_date,'%m/%d/%Y')  and str_to_date(after_date,'%m/%d/%Y')
   and find_in_set(r.lead_unit_number,fn_get_temp_unit(unit))
   and find_in_set(r.home_unit ,fn_get_temp_unit(unit))
   and r.lead_unit_number =u.unit_number
   and h.unit_number = u.unit_number;
 END
$$
DELIMITER ;
