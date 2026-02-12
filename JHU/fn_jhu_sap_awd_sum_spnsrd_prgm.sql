DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` FUNCTION `fn_jhu_sap_awd_sum_spnsrd_prgm`(av_grant_number VARCHAR(6)) RETURNS decimal(12,2)
    DETERMINISTIC
BEGIN
  DECLARE li_return_number  DECIMAL(12,2) DEFAULT NULL;
	SELECT ROUND(SUM(CAST(REPLACE(REPLACE(sponsored_program_value, '$',''), ',','') AS DECIMAL(12,2))))
	INTO   li_return_number
	FROM   sap_sponsored_program
	WHERE  grant_number = av_grant_number;
	RETURN li_return_number;
END
$$
DELIMITER ;
