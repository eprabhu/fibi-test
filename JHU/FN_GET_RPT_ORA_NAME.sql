DELIMITER $$
CREATE  FUNCTION `FN_GET_RPT_ORA_NAME`( PROP_UNIT_IN  varchar(200)) RETURNS varchar(200) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
Declare RPT_ORA_NAME  varchar(200);
Declare JHU_3 varchar(3);
select substr(sort_value, 1,3) into JHU_3 from jhu_unit where unit_number=PROP_UNIT_IN ;
if (JHU_3 ='001')then
   select unit_name into RPT_ORA_NAME from jhu_unit where sort_value =(select concat(substr(sort_value, 1,6),'000000000000000000000000') from jhu_unit where unit_number=PROP_UNIT_IN) ;
end if;
RETURN RPT_ORA_NAME ;
END
$$
DELIMITER ;
