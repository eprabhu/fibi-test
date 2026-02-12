DELIMITER $$
CREATE  FUNCTION `jhu_sap_awd_sum_of_spnsrd_prgs`(av_grant_number VARCHAR(6)) RETURNS decimal(12,2)
    DETERMINISTIC
BEGIN
  DECLARE return_number  DECIMAL(12,2) DEFAULT NULL;
	SELECT ROUND(SUM(CAST(REPLACE(REPLACE(sponsored_program_value, '$',''), ',','') AS DECIMAL(12,2))))
	INTO   return_number
	FROM   cufs_sponsored_program
	WHERE  grant_number = av_grant_number;
	RETURN return_number;
END
$$
DELIMITER ;
