DELIMITER $$
CREATE  PROCEDURE `jhu_sap_awd_upd_subcontract_tb`(av_grant_number  VARCHAR(6)
									  ,av_sponsored_program_number  VARCHAR(8)
									  ,av_start_date  VARCHAR(10)
									  ,av_end_date  VARCHAR(10)
									  ,av_title  VARCHAR(150)
									  ,av_unit  VARCHAR(10)
									  ,av_award_type VARCHAR(3)
									  ,av_status VARCHAR(5)
									  ,av_coeus_update_timestamp DATE
									  )
BEGIN
    DECLARE li_subcontract_row_count INT(3) DEFAULT NULL;
	DECLARE li_pi_row_count INT(3) DEFAULT NULL;
	DECLARE ls_pi_id VARCHAR(9) DEFAULT NULL;
	DECLARE ls_subcontract_subcontractor_id VARCHAR(8) DEFAULT NULL;
	DECLARE li_subcontract_sequence_number INT(3) DEFAULT 1;
	DECLARE li_subcontract_status_code INT(3) DEFAULT 5;
	DECLARE li_subcontract_award_type INT(3) DEFAULT NULL;
	DECLARE ls_coeus_requisitioner_unit VARCHAR(8) DEFAULT '000001';
    DECLARE ls_coeus_award_type VARCHAR(3) DEFAULT NULL;
    SET SQL_SAFE_UPDATES= 0;
    SELECT coeus_award_type_code
	INTO  ls_coeus_award_type
	FROM sap_award_type
	WHERE sap_award_type_code = av_award_type;
	IF ls_coeus_award_type IN (3, 14, 15, 17) THEN
	  SET li_subcontract_award_type = 17;
	ELSE
	  SET li_subcontract_award_type = 16;
	END IF;
	IF av_status = 'A' THEN
	  SET li_subcontract_status_code = 1;
	END IF;
	SELECT count(*)
	INTO li_pi_row_count
	FROM sap_sponsored_program_person
	WHERE sponsored_program_number = av_sponsored_program_number
	AND   responsibility_code = 'PRIN';
	IF li_pi_row_count = 0 THEN
	  SET ls_pi_id = '00008851';
	ELSE
	  SELECT MAX(person_id)
	  INTO ls_pi_id
	  FROM sap_sponsored_program_person
	  WHERE sponsored_program_number = av_sponsored_program_number
	  AND   responsibility_code = 'PRIN';
	END IF;
	SELECT count(*)
	INTO li_subcontract_row_count
	FROM subcontract
	WHERE subcontract_code = av_sponsored_program_number;
	IF li_subcontract_row_count = 0 THEN
	  SELECT home_unit
	  INTO ls_coeus_requisitioner_unit
	  FROM person
	  WHERE person_id = ls_pi_id;
	  INSERT INTO subcontract (subcontract_code
                                      ,sequence_number
                                      ,subcontractor_id
                                      ,start_date
                                      ,end_date
                                      ,subaward_type_code
                                      ,purchase_order_num
                                      ,title
                                      ,status_code
                                      ,account_number
                                      ,vendor_number
                                      ,requisitioner_id
                                      ,requisitioner_unit
                                      ,closeout_indicator
                                      ,funding_source_indicator
                                      ,update_timestamp
                                      ,update_user
								  )
	  VALUES (av_sponsored_program_number
			 ,li_subcontract_sequence_number
			 ,'99999999'
			 ,DATE_FORMAT(av_start_date, '%Y%m%d')
			 ,DATE_FORMAT(av_end_date, '%Y%m%d')
			 ,li_subcontract_award_type
			 ,'UNKNOWN'
			 ,av_title
			 ,li_subcontract_status_code
			 ,av_sponsored_program_number
			 ,'99999999'
			 ,ls_pi_id
			 ,ls_coeus_requisitioner_unit
			 ,'N0'
			 ,'P0'
			 ,DATE(av_coeus_update_timestamp)
			 ,'INTRFACE'
			 ); COMMIT;
	ELSE
	  SELECT MAX(sequence_number)
	  INTO li_subcontract_sequence_number
	  FROM subcontract
	  WHERE subcontract_code = av_sponsored_program_number;
	  UPDATE subcontract
	  SET start_date = DATE_FORMAT(av_start_date,  '%Y%m%d')
		 ,end_date = DATE_FORMAT(av_end_date,  '%Y%m%d')
		 ,title = av_title
		 ,status_code = li_subcontract_status_code
		 ,account_number = av_sponsored_program_number
		 ,update_timestamp = DATE(av_coeus_update_timestamp)
		 ,update_user = 'INTRFACE'
	  WHERE subcontract_code = av_sponsored_program_number
	  AND   sequence_number = li_subcontract_sequence_number;
       COMMIT;
	END IF;
  END
$$
DELIMITER ;
