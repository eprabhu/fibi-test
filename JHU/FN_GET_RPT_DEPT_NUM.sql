DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` FUNCTION `FN_GET_RPT_DEPT_NUM`(UNIT_NUMBER_IN VARCHAR(8),SORT_VALUE_IN VARCHAR(30) ) RETURNS varchar(200) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE L_CHR_UNIT_NUM VARCHAR(8);
 (SELECT MAX(CAST(unit_number AS  DECIMAL)) INTO L_CHR_UNIT_NUM
                          FROM   jhu_unit
                          WHERE  unit_number IN (SELECT unit_number
                                                 FROM   unit u
                                                 WHERE  (u.parent_unit_number = UNIT_NUMBER_IN
												 AND    (select count(*)
                                                                from unit
                                                                where parent_unit_number=u.unit_number)>0
                                                 AND    UPPER(u.unit_number) NOT LIKE '%DNC%')
                                                 OR     u.unit_number = UNIT_NUMBER_IN)
                          AND   (sort_value = SORT_VALUE_IN
                          OR     sort_value = concat(SUBSTR(SORT_VALUE_IN, 1, 3) , '000000000000000000000000000')
                          OR     sort_value = concat(SUBSTR(SORT_VALUE_IN, 1, 6) , '000000000000000000000000')
                          OR     sort_value = concat(SUBSTR(SORT_VALUE_IN, 1, 9) , '000000000000000000000')
                          OR     sort_value = concat(SUBSTR(SORT_VALUE_IN, 1, 12) , '000000000000000000')
                          OR     sort_value = concat(SUBSTR(SORT_VALUE_IN, 1, 15) , '000000000000000')
                          OR     sort_value = concat(SUBSTR(SORT_VALUE_IN, 1, 18) , '000000000000'))
 );
RETURN L_CHR_UNIT_NUM;
END
$$
DELIMITER ;
