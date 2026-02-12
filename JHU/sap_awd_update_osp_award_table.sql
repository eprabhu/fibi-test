DELIMITER $$
CREATE  PROCEDURE `sap_awd_update_osp_award_table`(av_award_number  VARCHAR(10)
      ,av_sequence_number  INT(4)
      ,av_sponsored_program_number  VARCHAR(8)
      ,av_award_id  VARCHAR(22)
      ,av_status  VARCHAR(3)
      ,av_template_code  INT(1)
      ,av_start_date  VARCHAR(10)
      ,av_sponsor_code  VARCHAR(10)
      ,av_coeus_update_timestamp DATE)
BEGIN
  DECLARE ls_coeus_account_number VARCHAR(8) DEFAULT av_sponsored_program_number;
  DECLARE li_award_row_count INT(3) DEFAULT NULL;
  BEGIN
	SELECT count(*)
	INTO  li_award_row_count
	FROM award
	WHERE award_number = av_award_number
	AND   sequence_number = av_sequence_number;
	IF li_award_row_count = 0 THEN
	  INSERT INTO award ( award_number
							,sequence_number
							,sponsor_award_number
							,status_code
							,award_effective_date
							,begin_date
							,sponsor_code
							,account_number
							,update_timestamp
							,update_user)
	  VALUES (av_award_number
			 ,av_sequence_number
			 ,av_award_id
			 ,av_status
			 ,DATE_FORMAT(av_start_date, '%Y%m%d')
			 ,DATE_FORMAT(av_start_date, '%Y%m%d')
			 ,av_sponsor_code
			 ,ls_coeus_account_number
			 ,av_coeus_update_timestamp
			 ,'INTRFACE');
	ELSE
	  UPDATE award SET sponsor_award_number = av_award_id,
						   status_code = av_status,
						   award_effective_date = DATE_FORMAT(av_start_date, '%Y%m%d'),
						   begin_date = DATE_FORMAT(av_start_date,  '%Y%m%d'),
						   sponsor_code = av_sponsor_code,
						   account_number = ls_coeus_account_number,
						   update_timestamp = av_coeus_update_timestamp,
						   update_user = 'INTRFACE'
	  WHERE award_number = av_award_number
	  AND   sequence_number = av_sequence_number;
	END IF;
  END;
END
$$
DELIMITER ;
