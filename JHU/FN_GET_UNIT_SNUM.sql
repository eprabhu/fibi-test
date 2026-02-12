DELIMITER $$
CREATE  FUNCTION `FN_GET_UNIT_SNUM`(sort_value_in  VARCHAR(30)) RETURNS varchar(8) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
declare unit_number_out varchar(8) default NULL;
select (unit_number) into unit_number_out from JHU_UNIT where sort_value =sort_value_in ;
return UNIT_NUMBER_OUT;
END
$$
DELIMITER ;
