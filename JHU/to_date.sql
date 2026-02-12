DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` FUNCTION `to_date`(
  date_string VARCHAR(20)
 ,format_string VARCHAR(20)
) RETURNS date
    DETERMINISTIC
BEGIN
  DECLARE return_date DATE;
  SET return_date = STR_TO_DATE(date_string, '%m/%d/%Y');
  RETURN return_date;
END
$$
DELIMITER ;
