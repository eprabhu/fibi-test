DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_sap_award_changes_split`(LS_GRANT_NUMBER VARCHAR(6))
BEGIN
    DECLARE last_run_date DATE;
    DECLARE LI_GRANTS_COMPLETED INT;
    DECLARE LI_REMAINING_GRANTS INT;
    declare ls_error_msg varchar(4000);
	BEGIN
			DECLARE DONE1 INT DEFAULT FALSE;
      DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
		BEGIN
			GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
			 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
			SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
			SELECT @full_error INTO LS_ERROR_MSG;
            insert into integration_error_log (SECTION, ERROR_MESSAGE, AWARD_NUMBER)
				values('sap_award_changes_new', LS_ERROR_MSG, LS_GRANT_NUMBER );
		END;
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE1 = TRUE;
			SET last_run_date = NULL;
			set sql_safe_updates = 0;
			UPDATE sap_sponsored_program
			SET    sponsored_program_type = 'SU'
			WHERE  sponsored_program_type IS NULL
			AND    sponsored_program_number LIKE '96%';
			UPDATE sap_sponsored_program
			SET    sponsored_program_type = 'CS'
			WHERE  sponsored_program_type IS NULL
			AND    sponsored_program_number LIKE '98%';
			SELECT MIN(coeus_award_update)
			INTO   last_run_date
			FROM   sap_interfaces;
			UPDATE sap_interfaces
			SET    coeus_award_update = utc_timestamp();
            set sql_safe_updates = 1;
insert into sap_award_time_log (section, Execution_start_time )values(concat('Grant Number : ',LS_GRANT_NUMBER), UTC_TIMESTAMP());
set sql_safe_updates = 0;
set foreign_key_checks = 0;
delete from award_comment where substr(award_number,1,6)= LS_GRANT_NUMBER;
delete from award_idc_rate where substr(award_number,1,6)= LS_GRANT_NUMBER;
delete from award_amt_fna_distribution where substr(award_number,1,6)= LS_GRANT_NUMBER;
delete from award_person_unit where substr(award_number,1,6)= LS_GRANT_NUMBER;
delete from award_persons  where substr(award_number,1,6)= LS_GRANT_NUMBER;
delete from award_budget_period where budget_header_id in(select budget_header_id from award_budget_header where substr(award_number,1,6)= LS_GRANT_NUMBER);
delete from award_budget_header where substr(award_number,1,6)= LS_GRANT_NUMBER;
delete from award_amount_info where substr(award_number,1,6)= LS_GRANT_NUMBER;
delete from award_amt_trnsctn_history  where substr(award_number,1,6)= LS_GRANT_NUMBER;
delete from award_amount_transaction where substr(award_number,1,6)= LS_GRANT_NUMBER;
delete from award_amount_info where substr(award_number,1,6)= LS_GRANT_NUMBER;
delete from award_sponsor_term where substr(award_number,1,6)= LS_GRANT_NUMBER;
delete from award_report_terms where substr(award_number,1,6)= LS_GRANT_NUMBER;
delete from award_hierarchy where substr(award_number,1,6)= LS_GRANT_NUMBER;
delete from award_science_keyword where award_id in(select award_id from award where substr(award_number,1,6)= LS_GRANT_NUMBER);
delete from award_funding_proposals where award_id in(select award_id from award where substr(award_number,1,6)= LS_GRANT_NUMBER);
delete from award_research_areas where substr(award_number,1,6)= LS_GRANT_NUMBER;
delete from award_history_log where substr(award_number,1,6)= LS_GRANT_NUMBER;
delete from award where substr(award_number,1,6)= LS_GRANT_NUMBER;
set foreign_key_checks = 1;
commit;
			CALL  jhu_sap_awd_update_proc(LS_GRANT_NUMBER);
	END;
END
$$
DELIMITER ;
