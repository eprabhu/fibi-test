DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` PROCEDURE `jhu_update_sap_sponsored_program`(IN proc_grant_number VARCHAR(6)
                                           ,IN proc_sponsored_program_number VARCHAR(20)
                                           ,IN proc_sponsored_program_type VARCHAR(100)
                                           ,IN proc_update_column VARCHAR(50)
                                           ,IN proc_new_value VARCHAR(1000)
                                           ,IN proc_update_timestamp DATETIME
                                           )
BEGIN
        /* *** *******************************************************
        ** Declare needed local variables                                        **
        **************************************************************************/
        DECLARE row_count SMALLINT  DEFAULT  NULL;
        DECLARE update_statement VARCHAR(1000)  DEFAULT  null;
        DECLARE sap_sponsored_program_type VARCHAR(2)  DEFAULT  proc_sponsored_program_type;
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
			('SAP_SPONSORED_PROGRAM',proc_grant_number,'SQLEXCEPTION',LS_ERROR,NULL,'N',null,null,NULL,NULL,'N',now(),'JHU_ADMIN');
	END;
      BEGIN
        IF proc_sponsored_program_number LIKE '96%'
        THEN
          SET sap_sponsored_program_type = 'SU';
        ELSEIF proc_sponsored_program_number LIKE '98%'
        THEN
          SET sap_sponsored_program_type = 'CS';
        END IF;
        SELECT COUNT(*)
        INTO row_count
        FROM sap_sponsored_program
        WHERE sponsored_program_number = proc_sponsored_program_number;
        IF row_count = 0
        THEN
          INSERT INTO sap_sponsored_program (grant_number, sponsored_program_number, sponsored_program_type, update_timestamp)
          VALUES (proc_grant_number, proc_sponsored_program_number, sap_sponsored_program_type, proc_update_timestamp);
        END IF;
		IF sap_sponsored_program_type IS  NULL THEN
			IF proc_update_column IS NOT NULL AND proc_update_column = 'description' THEN
				UPDATE sap_sponsored_program SET
				DESCRIPTION = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'responsible_cost_center' THEN
				UPDATE sap_sponsored_program SET
				RESPONSIBLE_COST_CENTER = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'sponsored_program_value' THEN
				UPDATE sap_sponsored_program SET
				SPONSORED_PROGRAM_VALUE = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'sponsored_program_asa' THEN
				UPDATE sap_sponsored_program SET
				SPONSORED_PROGRAM_ASA = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'location' THEN
				UPDATE sap_sponsored_program SET
				LOCATION = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'rate_type' THEN
				UPDATE sap_sponsored_program SET
				RATE_TYPE = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'receipt_tax' THEN
				UPDATE sap_sponsored_program SET
				RECEIPT_TAX = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'fa_base' THEN
				UPDATE sap_sponsored_program SET
				FA_BASE = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'fa_function' THEN
				UPDATE sap_sponsored_program SET
				FA_FUNCTION = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'fa_rate' THEN
				UPDATE sap_sponsored_program SET
				FA_RATE = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'fa_start_date' THEN
				UPDATE sap_sponsored_program SET
				FA_START_DATE = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'fa_end_date' THEN
				UPDATE sap_sponsored_program SET
				FA_END_DATE = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'recharge_rate' THEN
				UPDATE sap_sponsored_program SET
				RECHARGE_RATE = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'project_type' THEN
				UPDATE sap_sponsored_program SET
				PROJECT_TYPE = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'sponsored_program_status' THEN
				UPDATE sap_sponsored_program SET
				SPONSORED_PROGRAM_STATUS = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'region' THEN
				UPDATE sap_sponsored_program SET
				REGION = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'country' THEN
				UPDATE sap_sponsored_program SET
				COUNTRY = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'program' THEN
				UPDATE sap_sponsored_program SET
				PROGRAM = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'internal_order_start_date' THEN
				UPDATE sap_sponsored_program SET
				INTERNAL_ORDER_START_DATE = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'internal_order_end_date' THEN
				UPDATE sap_sponsored_program SET
				INTERNAL_ORDER_END_DATE = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			END IF;
		ELSE
			IF proc_update_column IS NOT NULL AND proc_update_column = 'description' THEN
				UPDATE sap_sponsored_program SET
				DESCRIPTION = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				SPONSORED_PROGRAM_TYPE = sap_sponsored_program_type,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'responsible_cost_center' THEN
				UPDATE sap_sponsored_program SET
				RESPONSIBLE_COST_CENTER = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				SPONSORED_PROGRAM_TYPE = sap_sponsored_program_type,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'sponsored_program_value' THEN
				UPDATE sap_sponsored_program SET
				SPONSORED_PROGRAM_VALUE = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				SPONSORED_PROGRAM_TYPE = sap_sponsored_program_type,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'sponsored_program_asa' THEN
				UPDATE sap_sponsored_program SET
				SPONSORED_PROGRAM_ASA = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				SPONSORED_PROGRAM_TYPE = sap_sponsored_program_type,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'location' THEN
				UPDATE sap_sponsored_program SET
				LOCATION = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				SPONSORED_PROGRAM_TYPE = sap_sponsored_program_type,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'rate_type' THEN
				UPDATE sap_sponsored_program SET
				RATE_TYPE = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				SPONSORED_PROGRAM_TYPE = sap_sponsored_program_type,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'receipt_tax' THEN
				UPDATE sap_sponsored_program SET
				RECEIPT_TAX = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				SPONSORED_PROGRAM_TYPE = sap_sponsored_program_type,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'fa_base' THEN
				UPDATE sap_sponsored_program SET
				FA_BASE = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				SPONSORED_PROGRAM_TYPE = sap_sponsored_program_type,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'fa_function' THEN
				UPDATE sap_sponsored_program SET
				FA_FUNCTION = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				SPONSORED_PROGRAM_TYPE = sap_sponsored_program_type,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'fa_rate' THEN
				UPDATE sap_sponsored_program SET
				FA_RATE = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				SPONSORED_PROGRAM_TYPE = sap_sponsored_program_type,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'fa_start_date' THEN
				UPDATE sap_sponsored_program SET
				FA_START_DATE = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				SPONSORED_PROGRAM_TYPE = sap_sponsored_program_type,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'fa_end_date' THEN
				UPDATE sap_sponsored_program SET
				FA_END_DATE = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				SPONSORED_PROGRAM_TYPE = sap_sponsored_program_type,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'recharge_rate' THEN
				UPDATE sap_sponsored_program SET
				RECHARGE_RATE = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				SPONSORED_PROGRAM_TYPE = sap_sponsored_program_type,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'project_type' THEN
				UPDATE sap_sponsored_program SET
				PROJECT_TYPE = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				SPONSORED_PROGRAM_TYPE = sap_sponsored_program_type,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'sponsored_program_status' THEN
				UPDATE sap_sponsored_program SET
				SPONSORED_PROGRAM_STATUS = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				SPONSORED_PROGRAM_TYPE = sap_sponsored_program_type,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'region' THEN
				UPDATE sap_sponsored_program SET
				REGION = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				SPONSORED_PROGRAM_TYPE = sap_sponsored_program_type,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'country' THEN
				UPDATE sap_sponsored_program SET
				COUNTRY = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				SPONSORED_PROGRAM_TYPE = sap_sponsored_program_type,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'program' THEN
				UPDATE sap_sponsored_program SET
				PROGRAM = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				SPONSORED_PROGRAM_TYPE = sap_sponsored_program_type,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'internal_order_start_date' THEN
				UPDATE sap_sponsored_program SET
				INTERNAL_ORDER_START_DATE = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				SPONSORED_PROGRAM_TYPE = sap_sponsored_program_type,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'internal_order_end_date' THEN
				UPDATE sap_sponsored_program SET
				INTERNAL_ORDER_END_DATE = proc_new_value,
				GRANT_NUMBER = proc_grant_number,
				SPONSORED_PROGRAM_TYPE = sap_sponsored_program_type,
				UPDATE_TIMESTAMP = proc_update_timestamp
				WHERE SPONSORED_PROGRAM_NUMBER = proc_sponsored_program_number;
			END IF;
		END IF;
      END;
    END
$$
DELIMITER ;
