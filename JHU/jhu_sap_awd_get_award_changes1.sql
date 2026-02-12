DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` PROCEDURE `jhu_sap_awd_get_award_changes1`()
BEGIN
    DECLARE last_run_date DATE;
	DECLARE LS_GRANT_NUMBER VARCHAR(6);
	BEGIN
			DECLARE DONE1 INT DEFAULT FALSE;
			DECLARE grant_cur CURSOR FOR
             select grant_number from sap_grant where grant_number in ('134429',
             '135768',
             '135999',
             '136804',
             '139274',
             '139684',
             '140102',
             '142281',
             '142572',
             '142720');
			DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE1 = TRUE;
			SET SQl_safe_updates = 0;
			SET last_run_date = NULL;
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
		insert into sap_award_time_log (section,Execution_start_time) values('Integration Started in server 1', utc_timestamp());
			OPEN grant_cur;
					grant_cur_loop : LOOP
							FETCH grant_cur INTO LS_GRANT_NUMBER;
							IF DONE1 THEN
								LEAVE grant_cur_loop;
							END IF;
							insert into sap_award_time_log (section,Execution_start_time) values (concat('Grant_NumberD1 :',LS_GRANT_NUMBER), utc_timestamp());
							delete from award_amount_info where substr(award_number,1,6) = LS_GRANT_NUMBER;
							CALL  jhu_sap_awd_update_proc(LS_GRANT_NUMBER);
							insert into sap_award_time_log (section) values (LS_GRANT_NUMBER);
					END LOOP;
                    SET SQl_safe_updates = 1;
					insert into sap_award_time_log (section,Execution_start_time) values('Integration Completed in server 1', utc_timestamp());
			CLOSE grant_cur;
	END;
END
$$
DELIMITER ;
