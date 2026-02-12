DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` PROCEDURE `jhu_update_sap_grant_person`(IN proc_grant_number VARCHAR(6)
                                      ,IN proc_person_id VARCHAR(20)
                                      ,IN proc_update_column VARCHAR(50)
                                      ,IN proc_new_value VARCHAR(1000)
                                      ,IN proc_update_timestamp DATETIME
                                      )
BEGIN
        /* *** *******************************************************
        ** Declare needed local variables                                        **
        **************************************************************************/
        DECLARE row_count SMALLINT  DEFAULT  NULL;
        DECLARE update_statement VARCHAR(1000)  DEFAULT  NULL;
        DECLARE LS_ERROR VARCHAR(4000);
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
	GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
		 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
		 SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
		 SELECT @full_error INTO LS_ERROR;
        -- SET ls_file_text = concat('Invalid Dataset \n', IFNULL(ls_message_text,'\n'));
			INSERT INTO `jhufibi`.`jhu_sap_award_interface_log`
			(`TABLE_NAME`,`GRANT_NUMBER`,`RESULT_TYPE`,`ERROR_MESSAGE`,`FILE_TEXT`,`FILE_INTEFACE_STATUS`,
			`MAIL_TEXT`,`MAIL_SUBJECT`,`MAIL_RECIPIENT`,`MAIL_SENDER`,`MAIL_SENT_STAUS`,`UPDATE_TIMESTAMP`,`UPDATE_USER`)
			VALUES
			('SAP_GRANT_PERSON',proc_grant_number,'SQLEXCEPTION',LS_ERROR,NULL,'N',null,null,NULL,NULL,'N',now(),'JHU_ADMIN');
	END;
      BEGIN
        DELETE FROM sap_grant_person
        WHERE grant_number = proc_grant_number
        AND   update_timestamp != proc_update_timestamp;
        IF proc_person_id != 'X' THEN
			SELECT COUNT(*)
			INTO row_count
			FROM sap_grant_person
			WHERE grant_number = proc_grant_number
			AND person_id = proc_person_id;
			IF row_count = 0
			THEN
				INSERT INTO sap_grant_person (grant_number, person_id, update_timestamp)
				VALUES (proc_grant_number, proc_person_id, proc_update_timestamp);
			END IF;
			IF proc_update_column IS NOT NULL AND proc_update_column = 'responsibility_code' THEN
				UPDATE sap_grant_person SET RESPONSIBILITY_CODE = proc_new_value
				WHERE grant_number = proc_grant_number
				AND person_id = proc_person_id;
			END IF;
        END IF;
      END;
    END
$$
DELIMITER ;
