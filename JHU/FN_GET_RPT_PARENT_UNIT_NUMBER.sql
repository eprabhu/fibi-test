DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` FUNCTION `FN_GET_RPT_PARENT_UNIT_NUMBER`( PROP_UNIT_IN VARCHAR(8)) RETURNS varchar(8) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
 DECLARE RPT_PARENT_UNIT_NUMBER VARCHAR(8);
 DECLARE JHU_3 varchar(3);
select distinct(substr(sort_value, 1,3)) into JHU_3 from jhu_unit where unit_number=PROP_UNIT_IN ;
if (JHU_3 ='001')then
  select distinct(IF(COUNT(unit_number) > 0,
        unit_number,
        NULL)) into RPT_PARENT_UNIT_NUMBER from jhu_unit where sort_value =(select distinct(CONCAT(substr(sort_value, 1,12),'000000000000000000')) from jhu_unit where unit_number=PROP_UNIT_IN) ;
else
  select distinct(IF(COUNT(unit_number) > 0,
        unit_number,
        NULL)) into RPT_PARENT_UNIT_NUMBER from jhu_unit where sort_value =(select distinct(CONCAT(substr(sort_value, 1,9),'000000000000000000000')) from jhu_unit where unit_number=PROP_UNIT_IN) ;
end if;
RETURN RPT_PARENT_UNIT_NUMBER ;
END
$$
DELIMITER ;
