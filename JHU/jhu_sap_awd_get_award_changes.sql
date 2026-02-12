DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` PROCEDURE `jhu_sap_awd_get_award_changes`()
BEGIN
    DECLARE last_run_date DATE;
    DECLARE LI_INTEGRATION_IN_PROGRESS INT;
	DECLARE LS_GRANT_NUMBER VARCHAR(6);
	BEGIN
			DECLARE DONE1 INT DEFAULT FALSE;
			DECLARE grant_cur CURSOR FOR
			SELECT DISTINCT grant_number
			FROM (
			WITH max_seq AS (
					SELECT award_number,
						   MAX(sequence_number) AS sequence_number
					FROM award
					GROUP BY award_number
				),
				max_trans_id AS (
					SELECT award_id,
						   MAX(AWARD_AMOUNT_INFO_ID) AS AWARD_AMOUNT_INFO_ID
					FROM award_amount_info
					GROUP BY award_id
				)
				SELECT g.grant_number
				FROM sap_grant g
				INNER JOIN award_amount_info a ON a.award_number = CONCAT(g.grant_number, '-00001')
				AND EXISTS (
					SELECT 1
					FROM max_seq p
					WHERE p.award_number = a.award_number
					  AND p.sequence_number = a.sequence_number
				)
				AND EXISTS (
					SELECT 1
					FROM max_trans_id p
					WHERE p.award_id = a.award_id
					  AND p.AWARD_AMOUNT_INFO_ID = a.AWARD_AMOUNT_INFO_ID
				)
				AND (
					ROUND(CAST(g.grant_value AS DECIMAL)) <> a.amount_obligated_to_date
					OR TRIM(g.grant_end_date) <> TRIM(DATE_FORMAT(a.final_expiration_date, '%Y%m%d'))
					OR ROUND(CAST(g.grant_funded_amount AS DECIMAL)) <> a.anticipated_total_amount
				)
				WHERE g.proposal_number NOT IN ('00000000', '05011234')
				AND EXISTS (
					SELECT 1
					FROM proposal p
					WHERE p.proposal_number = g.proposal_number
				)
				UNION
				SELECT DISTINCT TRIM(g.grant_number) AS grant_number
				FROM sap_grant g
				INNER JOIN sap_sponsored_program s ON g.grant_number = s.grant_number
				LEFT JOIN award a ON a.award_number = CONCAT(g.grant_number, '-00001')
				AND a.sequence_number = (
					SELECT MAX(inner_a.sequence_number)
					FROM award inner_a
					WHERE inner_a.award_number = a.award_number
				)
				WHERE (
					g.update_timestamp > last_run_date
					OR a.award_number IS NULL
					OR EXISTS (
						SELECT 1
						FROM staged_awards sa
						WHERE sa.grant_number = g.grant_number
						  AND sa.sponsored_program_number IS NULL
					)
					OR s.update_timestamp > last_run_date
					OR (a.update_timestamp < s.update_timestamp
						OR a.update_timestamp < g.update_timestamp)
				)
				AND g.proposal_number NOT IN ('00000000', '05011234')
				AND EXISTS (
					SELECT 1
					FROM proposal p
					WHERE p.proposal_number = g.proposal_number
				)
				UNION
				SELECT g.grant_number
				FROM sap_grant g
				INNER JOIN award a ON g.grant_number = SUBSTR(a.award_number, 1, 6)
				WHERE TRIM(g.grant_start_date) <> TRIM(DATE_FORMAT(a.begin_date, '%Y%m%d'))
				AND a.award_number LIKE '%-00001'
				AND a.sequence_number = (
					SELECT MAX(sequence_number)
					FROM award
					WHERE award_number = a.award_number
				)
				AND g.proposal_number NOT IN ('00000000', '05011234')
				AND g.proposal_number IN (
					SELECT proposal_number
					FROM proposal
				)
			) SAP
			WHERE grant_number NOT IN ('144452', '142291');
			DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE1 = TRUE;
			set sql_safe_updates = 0;
			SELECT in_progress
			INTO   LI_INTEGRATION_IN_PROGRESS
			FROM   sap_fibi_integration;
		IF (LI_INTEGRATION_IN_PROGRESS = 0 or (time(now()) between '06:00:00' and '07:00:00') = 1 ) then
			UPDATE sap_fibi_integration
			SET    in_progress = 1;
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
			SET    coeus_award_update = now();
				insert into sap_award_time_log (section,Execution_start_time) values('Integration Started', now());
			OPEN grant_cur;
					grant_cur_loop : LOOP
							FETCH grant_cur INTO LS_GRANT_NUMBER;
							IF DONE1 THEN
								LEAVE grant_cur_loop;
							END IF;
							insert into sap_award_time_log (section,Execution_start_time) values (concat('Grant_Number :',LS_GRANT_NUMBER), now());
							CALL  jhu_sap_awd_update_proc(LS_GRANT_NUMBER);
					END LOOP;
					insert into sap_award_time_log (section,Execution_start_time) values('Integration Completed', now());
			CLOSE grant_cur;
            UPDATE sap_fibi_integration
			SET    in_progress = 0;
            END IF;
	END;
END
$$
DELIMITER ;
