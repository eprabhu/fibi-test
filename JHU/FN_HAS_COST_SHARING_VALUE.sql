DELIMITER $$
CREATE  FUNCTION `FN_HAS_COST_SHARING_VALUE`(
  AV_PROPOSAL_ID   int(10)
) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE LI_COUNT int;
DECLARE RETURN_STRING VARCHAR(5) DEFAULT 'FALSE';
 SELECT COUNT(*)
 INTO LI_COUNT
 FROM budget_header b
 WHERE b.proposal_id = AV_PROPOSAL_ID
 AND   b.version_number = (SELECT MAX(version_number)
                           FROM   budget_header
                           WHERE  proposal_id = AV_PROPOSAL_ID)
 AND   b.cost_share_type_code IS NOT NULL;
IF LI_COUNT > 0 THEN
   SET RETURN_STRING = 'TRUE';
END IF;
RETURN RETURN_STRING;
END
$$
DELIMITER ;
