DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` FUNCTION `FN_GET_UNIT_NAME`( AW_UNIT_NUMBER  varchar(8)) RETURNS varchar(200) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
declare var_unit_name varchar(200);
   SELECT distinct(unit_name)
	INTO	 var_unit_name
	FROM   unit
	WHERE  unit_number = AW_UNIT_NUMBER ;
	RETURN (var_unit_name) ;
END
$$
DELIMITER ;
