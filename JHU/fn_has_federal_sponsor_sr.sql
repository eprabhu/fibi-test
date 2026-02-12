DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` FUNCTION `fn_has_federal_sponsor_sr`(
  AV_SR_HEADER_ID   int(10)
) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE LI_COUNT int;
DECLARE RETURN_STRING VARCHAR(5) DEFAULT 'FALSE';
 SELECT COUNT(*)
 INTO   li_count
 FROM   sr_header sr
       ,award a
       ,sponsor s
 WHERE  sr.sr_header_id = AV_SR_HEADER_ID
 AND    s.sponsor_type_code = 0
 AND    sr.module_code = 1
 AND    sr.module_item_key = a.award_id
 AND    a.sponsor_code = s.sponsor_code;
IF LI_COUNT > 0 THEN
   SET RETURN_STRING = 'TRUE';
END IF;
RETURN RETURN_STRING;
END
$$
DELIMITER ;
