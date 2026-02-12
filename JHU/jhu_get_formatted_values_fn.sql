DELIMITER $$
CREATE  FUNCTION `jhu_get_formatted_values_fn`() RETURNS varchar(2000) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE return_string VARCHAR(2000) DEFAULT ' ';
DECLARE column_val  VARCHAR(200) DEFAULT ' ';
DECLARE done INT DEFAULT FALSE;
DECLARE value_cursor CURSOR FOR
  SELECT column_value FROM jhu_value_proc_view;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
OPEN value_cursor;
read_values: LOOP
    FETCH value_cursor INTO column_val;
    IF done THEN
      LEAVE read_values;
    END IF;
    SET return_string = CONCAT(return_string, column_val, '; ');
END LOOP;
CLOSE value_cursor;
RETURN return_string;
END
$$
DELIMITER ;
