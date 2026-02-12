DELIMITER $$
CREATE  FUNCTION `FN_HAS_SUBAWARD`(
  AV_PROPOSAL_ID   int(10)
) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE subaward_count int;
DECLARE RETURN_STRING VARCHAR(5) DEFAULT 'FALSE';
SELECT  count(*)
INTO    subaward_count
FROM    eps_proposal_organization o
WHERE   o.proposal_id = AV_PROPOSAL_ID
AND     o.organization_type_code = 5;
IF subaward_count > 0
THEN
   SET RETURN_STRING = 'TRUE';
END IF;
RETURN RETURN_STRING;
END
$$
DELIMITER ;
