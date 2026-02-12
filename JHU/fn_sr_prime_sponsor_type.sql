DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` FUNCTION `fn_sr_prime_sponsor_type`(
  AV_SR_HEADER_ID INT,
  AV_TYPE VARCHAR(10)
) RETURNS varchar(10) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE  LI_FLAG INT;
    DECLARE  LI_MODULE_CODE INT DEFAULT 0;
    DECLARE  LI_MODULE_ITEM_ID INT DEFAULT 0;
    DECLARE  RETURN_STRING VARCHAR(10);
    DECLARE CONTINUE HANDLER FOR NOT FOUND
    SET LI_MODULE_ITEM_ID = 0;
   SELECT module_code
         ,module_item_id
   INTO   LI_MODULE_CODE
         ,LI_MODULE_ITEM_ID
   FROM   assoc_sr
   WHERE  sr_header_id = AV_SR_HEADER_ID
   ORDER BY update_timestamp ASC LIMIT 1;
  IF LI_MODULE_ITEM_ID IS NULL OR LI_MODULE_ITEM_ID = 0 THEN
    RETURN 'FALSE';
  END IF;
  IF LI_MODULE_CODE = 3 THEN
    SELECT COUNT(1)
    INTO   LI_FLAG
    FROM   eps_proposal pd
          ,sponsor s
    WHERE  pd.proposal_id = LI_MODULE_ITEM_ID
    AND    s.sponsor_type_code = AV_TYPE
    AND    pd.prime_sponsor_code = s.sponsor_code;
  ELSEIF LI_MODULE_CODE = 1 THEN
    SELECT COUNT(1)
    INTO   LI_FLAG
    FROM   award a
          ,sponsor s
    WHERE  a.award_id = LI_MODULE_ITEM_ID
    AND    s.sponsor_type_code = AV_TYPE
    AND    a.prime_sponsor_code = s.sponsor_code;
  ELSEIF LI_MODULE_CODE = 2 THEN
    SELECT COUNT(1)
    INTO   LI_FLAG
    FROM   proposal ip
          ,sponsor s
    WHERE  ip.proposal_id = LI_MODULE_ITEM_ID
    AND    s.sponsor_type_code = AV_TYPE
    AND    ip.prime_sponsor_code = s.sponsor_code;
  END IF;
  IF LI_FLAG > 0 THEN
    SET RETURN_STRING = 'TRUE';
  ELSE
    SET RETURN_STRING = 'FALSE';
  END IF;
  RETURN RETURN_STRING;
END
$$
DELIMITER ;
