DELIMITER $$
CREATE  FUNCTION `FN_GET_UNIT_SNAME`(sort_value_in  VARCHAR(30)) RETURNS varchar(60) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
Declare unit_name_out varchar(60) default NULL;
select (unit_name) into unit_name_out from JHU_UNIT where sort_value =sort_value_in limit 1;
return UNIT_NAME_OUT;
END
$$
DELIMITER ;
