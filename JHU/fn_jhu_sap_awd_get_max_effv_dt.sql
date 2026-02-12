DELIMITER $$
CREATE  FUNCTION `fn_jhu_sap_awd_get_max_effv_dt`(av_grant_number  VARCHAR(6)) RETURNS varchar(8) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE ls_return_char  VARCHAR(8) DEFAULT NULL;
SELECT MAX(award_effective_date)
INTO   ls_return_char
FROM   sap_grant_award
WHERE  grant_number = av_grant_number;
RETURN ls_return_char;
END
$$
DELIMITER ;
