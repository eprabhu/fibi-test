DELIMITER $$
CREATE  FUNCTION `fn_sr_assoc_type_need_check`(
  AV_SR_HEADER_ID   INT
) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
  DECLARE LI_COUNT INT;
  DECLARE CATE_CODE INT;
  DECLARE SR_CATE_CODE INT DEFAULT 20;  -- avoid magic number
  DECLARE MATCH_FOUND INT DEFAULT 0;
  DECLARE RETURN_STRING VARCHAR(5) DEFAULT 'FALSE';
  -- Get category code
  SELECT CATEGORY_CODE
  INTO CATE_CODE
  FROM SR_HEADER
  WHERE SR_HEADER_ID = AV_SR_HEADER_ID;
  -- If category is service (20)
  IF CATE_CODE = SR_CATE_CODE THEN
    -- Check if assoc_sr has any entry
    SELECT COUNT(*)
    INTO MATCH_FOUND
    FROM ASSOC_SR
    WHERE sr_header_id = AV_SR_HEADER_ID;
    IF MATCH_FOUND > 0 THEN
	 SET RETURN_STRING ='TRUE';
    END IF;
  ELSE
    -- Check how many distinct module codes exist
    SELECT COUNT(DISTINCT MODULE_CODE)
    INTO LI_COUNT
    FROM assoc_sr
    WHERE sr_header_id = AV_SR_HEADER_ID;
    -- More than one distinct module = mismatch
    IF LI_COUNT > 1 THEN
      SET RETURN_STRING = 'TRUE';
    -- Exactly one distinct module, check if it matches category
    ELSEIF LI_COUNT = 1 THEN
      SELECT COUNT(*)
      INTO MATCH_FOUND
      FROM assoc_sr
      WHERE sr_header_id = AV_SR_HEADER_ID
        AND MODULE_CODE = CATE_CODE;
      IF MATCH_FOUND = 0 THEN
        SET RETURN_STRING = 'TRUE';
      END IF;
    END IF;
  END IF;
  RETURN RETURN_STRING;
END
$$
DELIMITER ;
