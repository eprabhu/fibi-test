DELIMITER $$
CREATE  FUNCTION `FN_ARCI_ORA_NOTIFICATION`(
  AV_PROPOSAL_ID   int(10)
) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE LI_COUNT int;
DECLARE RETURN_STRING VARCHAR(5) DEFAULT 'FALSE';
 SELECT COUNT(*)
 INTO LI_COUNT
 FROM eps_proposal p
     ,custom_data c
 WHERE p.proposal_id = AV_PROPOSAL_ID
 AND   c.custom_data_elements_id = 119
 AND   c.description = 'Yes'
 AND   p.proposal_id = c.module_item_key;
IF LI_COUNT > 0 THEN
   SET RETURN_STRING = 'TRUE';
END IF;
RETURN RETURN_STRING;
END
$$
DELIMITER ;
