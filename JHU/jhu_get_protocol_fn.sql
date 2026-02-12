DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` FUNCTION `jhu_get_protocol_fn`(
  GRANT_NUMBER_IN   int(10)
) RETURNS varchar(2000) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE return_string VARCHAR(2000) DEFAULT ' ';
DECLARE protocol VARCHAR(20) DEFAULT ' ';
DECLARE protocol_cursor CURSOR FOR
 SELECT DISTINCT(protocol_number)
 FROM award_special_review
 WHERE proposal_number LIKE CONCAT(grant_number_in, '%');
OPEN protocol_cursor;
read_protocols: LOOP
    FETCH protocol_cursor INTO protocol;
    IF done THEN
      LEAVE read_protocols;
    END IF;
    SET return_string = CONCAT(return_string, protocol, '\n');
END LOOP;
IF LI_COUNT > 0 THEN
   SET RETURN_STRING = 'TRUE';
END IF;
RETURN RETURN_STRING;
END
$$
DELIMITER ;
