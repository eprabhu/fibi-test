DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` FUNCTION `fn_jhu_sap_awd_get_null_spgmtp`(av_grant_number  VARCHAR(6)) RETURNS int
    DETERMINISTIC
BEGIN
DECLARE li_null_type_count INT(3) DEFAULT 0;
SELECT COUNT(*)
INTO   li_null_type_count
FROM   sap_sponsored_program
WHERE  grant_number = av_grant_number
AND    sponsored_program_type IS NULL;
RETURN li_null_type_count;
END
$$
DELIMITER ;
