DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` PROCEDURE `jhu_sap_awd_upd_awd_hrchy_tb`(av_award_number VARCHAR(12)
  ,av_update_timestamp  DATE
  )
BEGIN
  DECLARE ls_root_award_number VARCHAR(12) DEFAULT NULL;
  DECLARE ls_parent_award_number VARCHAR(12) DEFAULT NULL;
       declare ls_error_msg varchar(4000);
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
		BEGIN
			GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
			 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
			SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
			SELECT @full_error INTO LS_ERROR_MSG;
            insert into integration_error_log (SECTION, ERROR_MESSAGE, AWARD_NUMBER, sequence_number)
				values('AWARD HIERARCHY', LS_ERROR_MSG, av_award_number, NULL);
		END;
  SET SQL_SAFE_UPDATES= 0;
	IF av_award_number LIKE '%00001' THEN
	  SET ls_parent_award_number = '000000-00000';
	  SET ls_root_award_number = av_award_number;
	ELSE
	  SET ls_parent_award_number = CONCAT(SUBSTR(av_award_number, 1, 7),'00001');
	  SET ls_root_award_number = ls_parent_award_number;
	END IF;
	INSERT INTO award_hierarchy (root_award_number
									,award_number
									,parent_award_number
									,update_timestamp
									,update_user
                                    ,ORIGINATING_AWARD_NUMBER
									)
	VALUES (ls_root_award_number
		   ,av_award_number
		   ,ls_parent_award_number
		   ,av_update_timestamp
		   ,'INTRFACE',ls_root_award_number
		   ); COMMIT;
COMMIT;
END
$$
DELIMITER ;
