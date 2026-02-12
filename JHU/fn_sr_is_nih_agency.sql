DELIMITER $$
CREATE  FUNCTION `fn_sr_is_nih_agency`(
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
 WHERE  sr.sr_header_id = AV_SR_HEADER_ID
 AND    a.sponsor_code IN (SELECT sponsor_code
                           FROM   sponsor_hierarchy
                           WHERE  sponsor_group_name = 'NIH')
 AND    sr.module_code = 1
 AND    sr.module_item_key = a.award_id;
IF LI_COUNT > 0 THEN
   SET RETURN_STRING = 'TRUE';
END IF;
RETURN RETURN_STRING;
END
$$
DELIMITER ;
