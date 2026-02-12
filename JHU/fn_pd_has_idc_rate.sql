DELIMITER $$
CREATE  FUNCTION `fn_pd_has_idc_rate`(
  AV_PROPOSAL_ID   int(10)
) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE LI_COUNT int;
DECLARE RETURN_STRING VARCHAR(5) DEFAULT 'FALSE';
 SELECT COUNT(*)
 INTO   LI_COUNT
 FROM   budget_header
 WHERE  proposal_id = AV_PROPOSAL_ID
 AND   (on_campus_rates REGEXP '^[0-9]+$'
 OR     off_campus_rates  REGEXP '^[0-9]+$');
 /*
 AND   (LENGTH(TRIM(on_campus_rates)) > 0
 OR     LENGTH(TRIM(off_campus_rates)) > 0);
*/
IF LI_COUNT > 0 THEN
   SET RETURN_STRING = 'TRUE';
END IF;
RETURN RETURN_STRING;
END
$$
DELIMITER ;
