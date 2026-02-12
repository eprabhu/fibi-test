DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` PROCEDURE `jhu_sap_awd_upd_awd_comment_tb`(av_award_id INT
	  ,av_award_number  VARCHAR(12)
      ,av_sequence_number  INT(4)
      ,av_comments  LONGTEXT
      ,av_update_timestamp  DATE
      )
BEGIN
DECLARE LI_COMMENT_ROW_COUNT INT(3) DEFAULT NULL;
DECLARE LS_ERROR_MSG VARCHAR(4000);
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
		BEGIN
			GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
			 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
			SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
			SELECT @full_error INTO LS_ERROR_MSG;
            insert into integration_error_log (SECTION, ERROR_MESSAGE, AWARD_NUMBER, sequence_number)
				values('AWARD COMMENT', LS_ERROR_MSG, av_award_number, av_sequence_number);
		END;
SET SQL_SAFE_UPDATES= 0;
INSERT INTO award_comment (award_id
							   ,award_number
							   ,sequence_number
							   ,comment_type_code
							   ,comments
							   ,update_timestamp
							   ,update_user
							   )
VALUES (av_award_id
	   ,av_award_number
	   ,av_sequence_number
	   ,800
	   ,av_comments
	   ,av_update_timestamp
	   ,'INTRFACE'
	   );
COMMIT;
END
$$
DELIMITER ;
