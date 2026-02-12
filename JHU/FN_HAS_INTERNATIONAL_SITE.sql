DELIMITER $$
CREATE  FUNCTION `FN_HAS_INTERNATIONAL_SITE`(
  AV_PROPOSAL_ID   int(10)
) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE site_count int;
DECLARE RETURN_STRING VARCHAR(5) DEFAULT 'FALSE';
SELECT  count(*)
INTO    site_count
FROM    eps_proposal_organization o
       ,rolodex r
WHERE   o.proposal_id = AV_PROPOSAL_ID
AND     r.country_code IS NOT NULL
AND     r.country_code NOT IN ('US', 'USA')
AND     o.rolodex_id = r.rolodex_id;
IF site_count > 0
THEN
   SET RETURN_STRING = 'TRUE';
END IF;
RETURN RETURN_STRING;
END
$$
DELIMITER ;
