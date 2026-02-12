DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` PROCEDURE `jhu_sap_awd_upd_awd_rprtng_tb`(av_award_id DECIMAL(22,0)
  ,av_award_number VARCHAR(12)
  ,av_sequence_number INT(4)
  ,av_template_code INT(1)
  ,av_update_timestamp  DATE
  )
BEGIN
DECLARE li_counter INT(5) DEFAULT 0;
DECLARE li_report_row_count INT(3) DEFAULT 0;
DECLARE DONE1 INT DEFAULT FALSE;
DECLARE ls_report_class_code VARCHAR(3);
DECLARE ls_report_code VARCHAR(3);
DECLARE ls_frequency_code VARCHAR(3);
DECLARE ls_frequency_base_code VARCHAR(3);
DECLARE ls_osp_distribution_code VARCHAR(3);
DECLARE li_contact_type_code INT(3);
DECLARE li_rolodex_id INT(6);
DECLARE ld_due_date DATE;
declare ls_error_msg varchar(4000);
DECLARE  report_cur CURSOR FOR
SELECT report_class_code
	,report_code
	,frequency_code
	,frequency_base_code
	,osp_distribution_code
	,contact_type_code
	,rolodex_id
	,due_date
FROM template_report_terms
WHERE template_code = av_template_code;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE1 = TRUE;
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
		BEGIN
			GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
			 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
			SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
			SELECT @full_error INTO LS_ERROR_MSG;
            insert into integration_error_log (SECTION, ERROR_MESSAGE, AWARD_NUMBER, sequence_number)
				values('AWARD REPORTING', LS_ERROR_MSG, av_award_number, av_sequence_number);
		END;
SET SQL_SAFE_UPDATES= 0;
SELECT count(*)
INTO  li_report_row_count
FROM award_reporting
WHERE AWARD_NUMBER = av_award_number;
IF li_report_row_count = 0 THEN
  OPEN report_cur;
	report_cur_loop : LOOP
			FETCH report_cur INTO ls_report_class_code
									,ls_report_code
									,ls_frequency_code
									,ls_frequency_base_code
									,ls_osp_distribution_code
									,li_contact_type_code
									,li_rolodex_id
									,ld_due_date;
			IF DONE1 THEN
				LEAVE report_cur_loop;
			END IF;
			  SET li_counter = li_counter + 1;
			  INSERT INTO award_report_terms (AWARD_ID
			  ,award_number
												 ,sequence_number
												 ,report_class_code
												 ,report_code
												 ,frequency_code
												 ,frequency_base_code
												 ,osp_distribution_code
												 ,due_date
												 ,update_timestamp
												 ,update_user
												 )
			  VALUES(av_award_id
					,av_award_number
					,av_sequence_number
					,ls_report_class_code
					,ls_report_code
					,ls_frequency_code
					,ls_frequency_base_code
					,ls_osp_distribution_code
					,ld_due_date
					,av_update_timestamp
					,'INTRFACE');	commit;
			END LOOP;
	CLOSE report_cur;
END IF;
COMMIT;
END
$$
DELIMITER ;
