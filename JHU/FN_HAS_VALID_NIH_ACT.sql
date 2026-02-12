DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` FUNCTION `FN_HAS_VALID_NIH_ACT`(
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
     ,custom_data_elements cde
 WHERE p.proposal_id = AV_PROPOSAL_ID
 AND   c.custom_data_elements_id = 120
 AND   UPPER(c.value) IN (SELECT UPPER(activity_code) FROM jhu_nih_activity)
 AND   p.proposal_id = c.module_item_key
 AND   c.custom_data_elements_id = cde.custom_data_elements_id;
IF LI_COUNT > 0 THEN
   SET RETURN_STRING = 'TRUE';
END IF;
RETURN RETURN_STRING;
END
$$
DELIMITER ;
