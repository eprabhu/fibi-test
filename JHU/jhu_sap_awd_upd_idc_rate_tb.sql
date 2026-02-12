DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` PROCEDURE `jhu_sap_awd_upd_idc_rate_tb`(av_award_number  VARCHAR(12)
      ,av_sponsored_program_number  VARCHAR(8)
      ,av_sequence_number  INT(4)
      ,av_fa_base  VARCHAR(1)
      ,av_fa_rate  INT(7)
      ,av_location  VARCHAR(5)
      ,av_validity_start_date  VARCHAR(10)
      ,av_validity_end_date  VARCHAR(10)
      ,av_update_timestamp  DATE
      )
BEGIN
     DECLARE li_coeus_idc_rate_type INT(3) DEFAULT NULL;
	 DECLARE ls_coeus_fiscal_year VARCHAR(4) DEFAULT YEAR(DATE_ADD(UTC_TIMESTAMP(), INTERVAL 6 MONTH));
	 DECLARE ls_coeus_on_campus_flag VARCHAR(1) DEFAULT NULL;
	 DECLARE ls_coeus_destination_account VARCHAR(8) DEFAULT '9999999';
	 DECLARE li_idc_count INT(5) DEFAULT NULL;
     declare ls_error_msg varchar(4000);
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
		BEGIN
			GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
			 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
			SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
			SELECT @full_error INTO LS_ERROR_MSG;
            insert into integration_error_log (SECTION, ERROR_MESSAGE, AWARD_NUMBER, sequence_number)
				values('AWARD IDC RATE', LS_ERROR_MSG, av_award_number, av_sequence_number);
		END;
     SET SQL_SAFE_UPDATES= 0;
	SELECT COUNT(*)
	INTO li_idc_count
	FROM award_idc_rate
	WHERE AWARD_NUMBER = av_award_number
	AND sequence_number = av_sequence_number
	AND applicable_idc_rate = av_fa_rate
	AND idc_rate_type_code = av_fa_base
	AND fiscal_year = ls_coeus_fiscal_year;
	IF av_location = 'ON' THEN
	  SET ls_coeus_on_campus_flag = 'Y';
	ELSE
	  SET ls_coeus_on_campus_flag = 'N';
	END IF;
	IF av_sponsored_program_number IS NOT NULL THEN
	  SET ls_coeus_destination_account = av_sponsored_program_number;
	END IF;
	IF li_idc_count = 0 THEN
	  INSERT INTO award_idc_rate (AWARD_NUMBER
									 ,sequence_number
									 ,applicable_idc_rate
									 ,idc_rate_type_code
									 ,fiscal_year
									 ,on_campus_flag
									 ,underrecovery_of_idc
									 ,source_account
									 ,destination_account
									 ,start_date
									 ,end_date
									 ,update_timestamp
									 ,update_user)
	  VALUES (av_award_number
			 ,av_sequence_number
			 ,av_fa_rate
			 ,av_fa_base
			 ,ls_coeus_fiscal_year
			 ,ls_coeus_on_campus_flag
			 ,NULL
			 ,'9999999'
			 ,ls_coeus_destination_account
			 ,DATE_FORMAT(av_validity_start_date, '%Y-%m-%d')
			 ,DATE_FORMAT(av_validity_end_date, '%Y-%m-%d')
			 ,av_update_timestamp
			 ,'INTRFACE'); COMMIT;
	END IF;
END
$$
DELIMITER ;
