DELIMITER $$
CREATE  FUNCTION `fn_pd_is_nih`(
  AV_PROPOSAL_ID   int(10)
) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE LI_COUNT int;
DECLARE RETURN_STRING VARCHAR(5) DEFAULT 'FALSE';
 SELECT COUNT(*)
 INTO LI_COUNT
 FROM eps_proposal p
 WHERE p.PROPOSAL_ID=AV_PROPOSAL_ID
 AND  (p.sponsor_code IN (SELECT sponsor_code from sponsor_hierarchy where sponsor_group_name = 'NIH')
 OR    p.prime_sponsor_code IN (SELECT sponsor_code from sponsor_hierarchy where sponsor_group_name = 'NIH'));
IF LI_COUNT > 0 THEN
   SET RETURN_STRING = 'TRUE';
END IF;
RETURN RETURN_STRING;
END
$$
DELIMITER ;
