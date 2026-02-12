DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` FUNCTION `fn_jhu_sap_awd_prim_sponprg_c`(av_grant_number  VARCHAR(6) ) RETURNS int
    DETERMINISTIC
BEGIN
DECLARE li_primary_count INT(3) DEFAULT 0;
SELECT COUNT(*)
INTO   li_primary_count
FROM   sap_sponsored_program
WHERE  grant_number = av_grant_number
AND    sponsored_program_type = 'PM';
RETURN li_primary_count;
END
$$
DELIMITER ;
