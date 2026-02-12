DELIMITER $$
CREATE  FUNCTION `fn_jhu_sap_awd_is_recrd_locked`(av_grant_number  VARCHAR(6)) RETURNS int
    DETERMINISTIC
BEGIN
    DECLARE li_return_number VARCHAR(1) DEFAULT NULL;
	SELECT COUNT(*)
	INTO   li_return_number
	FROM   osp_lock
	WHERE  lock_id = CONCAT('osp$Award_', av_grant_number, '-001');
	RETURN li_return_number;
END
$$
DELIMITER ;
