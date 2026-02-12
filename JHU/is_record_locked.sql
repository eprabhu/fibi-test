DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` FUNCTION `is_record_locked`(av_grant_number  VARCHAR(6)) RETURNS varchar(1) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE ls_return_number VARCHAR(1) DEFAULT NULL;
	SELECT COUNT(*)
	INTO   ls_return_number
	FROM   osp_lock
	WHERE  lock_id = CONCAT('osp$Award_', av_grant_number, '-00001');
	RETURN ls_return_number;
END
$$
DELIMITER ;
