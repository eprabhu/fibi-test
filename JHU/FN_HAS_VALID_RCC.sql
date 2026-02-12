DELIMITER $$
CREATE  FUNCTION `FN_HAS_VALID_RCC`(
  AV_PROPOSAL_ID   varchar(6)
) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE LI_COUNT int;
DECLARE RETURN_STRING VARCHAR(5) DEFAULT 'FALSE';
 SELECT COUNT(*)
 INTO LI_COUNT
 FROM eps_proposal p
     ,custom_data c
     ,custom_data_elements cde
 WHERE p.proposal_id = AV_PROPOSAL_ID
 AND   cde.column_label = 'SAP RESP COST CENTER'
 AND   TRIM(p.home_unit_number) = TRIM(SUBSTRING(c.value, 1, 8))
 AND   LENGTH(c.value) = 10
 AND   c.value REGEXP '[0-9]+$'
 AND   p.proposal_id = c.module_item_key
 AND   c.custom_data_elements_id = cde.custom_data_elements_id;
IF LI_COUNT > 0 THEN
   SET RETURN_STRING = 'TRUE';
END IF;
RETURN RETURN_STRING;
END
$$
DELIMITER ;
