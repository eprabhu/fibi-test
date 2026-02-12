DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` PROCEDURE `jhu_update_sap_grant`(IN proc_grant_number VARCHAR(6)
                               ,IN proc_update_column VARCHAR(50)
                               ,IN proc_new_value VARCHAR(1000)
                               ,IN proc_update_timestamp DATETIME
                               )
BEGIN
        /*  *** *******************************************************
        ** Declare needed local variables                                        **
        **************************************************************************/
        DECLARE row_count SMALLINT  DEFAULT  NULL;
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
			('SAP_GRANT',proc_grant_number,'SQLEXCEPTION',LS_ERROR,NULL,'N',null,null,NULL,NULL,'N',now(),'JHU_ADMIN');
	END;
     BEGIN
        SELECT COUNT(*)
        INTO row_count
        FROM sap_grant
        WHERE grant_number = proc_grant_number;
        IF row_count = 0 THEN
			INSERT INTO sap_grant (grant_number, update_timestamp, create_timestamp)
			VALUES (proc_grant_number, proc_update_timestamp, proc_update_timestamp);
        END IF;
		IF proc_update_column IS NOT NULL AND proc_update_column = 'project_title' THEN
			UPDATE sap_grant SET PROJECT_TITLE = proc_new_value,
			update_timestamp = proc_update_timestamp
			WHERE grant_number = proc_grant_number;
		ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'sponsor_code' THEN
			UPDATE sap_grant SET SPONSOR_CODE = proc_new_value,
			update_timestamp = proc_update_timestamp
			WHERE grant_number = proc_grant_number;
		ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'prime_sponsor_code' THEN
			UPDATE sap_grant SET PRIME_SPONSOR_CODE = proc_new_value,
			update_timestamp = proc_update_timestamp
			WHERE grant_number = proc_grant_number;
		ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'award_id' THEN
			UPDATE sap_grant SET AWARD_ID = proc_new_value,
			update_timestamp = proc_update_timestamp
			WHERE grant_number = proc_grant_number;
		ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'grant_value' THEN
			UPDATE sap_grant SET GRANT_VALUE = proc_new_value,
			update_timestamp = proc_update_timestamp
			WHERE grant_number = proc_grant_number;
		ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'grant_funded_amount' THEN
			UPDATE sap_grant SET GRANT_FUNDED_AMOUNT = proc_new_value,
			update_timestamp = proc_update_timestamp
			WHERE grant_number = proc_grant_number;
		ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'grant_status' THEN
			UPDATE sap_grant SET GRANT_STATUS = proc_new_value,
			update_timestamp = proc_update_timestamp
			WHERE grant_number = proc_grant_number;
		ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'billing_rule' THEN
			UPDATE sap_grant SET BILLING_RULE = proc_new_value,
			update_timestamp = proc_update_timestamp
			WHERE grant_number = proc_grant_number;
		ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'payment_method' THEN
			UPDATE sap_grant SET PAYMENT_METHOD = proc_new_value,
			update_timestamp = proc_update_timestamp
			WHERE grant_number = proc_grant_number;
		ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'grant_start_date' THEN
			UPDATE sap_grant SET GRANT_START_DATE = proc_new_value,
			update_timestamp = proc_update_timestamp
			WHERE grant_number = proc_grant_number;
		ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'grant_end_date' THEN
			UPDATE sap_grant SET GRANT_END_DATE = proc_new_value,
			update_timestamp = proc_update_timestamp
			WHERE grant_number = proc_grant_number;
		ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'validity_start_date' THEN
			UPDATE sap_grant SET VALIDITY_START_DATE = proc_new_value,
			update_timestamp = proc_update_timestamp
			WHERE grant_number = proc_grant_number;
		ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'validity_end_date' THEN
			UPDATE sap_grant SET VALIDITY_END_DATE = proc_new_value,
			update_timestamp = proc_update_timestamp
			WHERE grant_number = proc_grant_number;
		ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'proposal_number' THEN
			UPDATE sap_grant SET PROPOSAL_NUMBER = proc_new_value,
			update_timestamp = proc_update_timestamp
			WHERE grant_number = proc_grant_number;
		ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'cfda_number' THEN
			UPDATE sap_grant SET CFDA_NUMBER = proc_new_value,
			update_timestamp = proc_update_timestamp
			WHERE grant_number = proc_grant_number;
		ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'template_code' THEN
			UPDATE sap_grant SET TEMPLATE_CODE = proc_new_value,
			update_timestamp = proc_update_timestamp
			WHERE grant_number = proc_grant_number;
		ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'grant_type' THEN
			UPDATE sap_grant SET GRANT_TYPE = proc_new_value,
			update_timestamp = proc_update_timestamp
			WHERE grant_number = proc_grant_number;
		ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'award_type' THEN
			UPDATE sap_grant SET AWARD_TYPE = proc_new_value,
			update_timestamp = proc_update_timestamp
			WHERE grant_number = proc_grant_number;
		ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'grant_cost_sharing_flag' THEN
			UPDATE sap_grant SET GRANT_COST_SHARING_FLAG = proc_new_value,
			update_timestamp = proc_update_timestamp
			WHERE grant_number = proc_grant_number;
		ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'grant_subaward_flag' THEN
			UPDATE sap_grant SET GRANT_SUBAWARD_FLAG = proc_new_value,
			update_timestamp = proc_update_timestamp
			WHERE grant_number = proc_grant_number;
		ELSEIF proc_update_column IS NOT NULL AND proc_update_column = 'user_status' THEN
			UPDATE sap_grant SET USER_STATUS = proc_new_value,
			update_timestamp = proc_update_timestamp
			WHERE grant_number = proc_grant_number;
		END IF;
      END;
    END
$$
DELIMITER ;
