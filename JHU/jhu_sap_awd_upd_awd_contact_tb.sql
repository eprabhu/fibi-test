DELIMITER $$
CREATE  PROCEDURE `jhu_sap_awd_upd_awd_contact_tb`(av_award_number VARCHAR(12)
  ,av_sequence_number INT(4)
  ,av_template_number INT(1)
  ,av_update_timestamp  DATE
  )
BEGIN
  DECLARE li_contact_row_count INT(3) DEFAULT NULL;
  DECLARE li_award_id DECIMAL(22,0) DEFAULT NULL;
  DECLARE li_award_sponsor_contact_id  decimal(22,0);
       declare ls_error_msg varchar(4000);
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
		BEGIN
			GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
			 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
			SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
			SELECT @full_error INTO LS_ERROR_MSG;
            insert into integration_error_log (SECTION, ERROR_MESSAGE, AWARD_NUMBER, sequence_number)
				values('AWARD CONTACT', LS_ERROR_MSG, av_award_number, av_sequence_number);
		END;
  SET SQL_SAFE_UPDATES= 0;
  SELECT count(*)
  INTO  li_contact_row_count
  FROM award_contact
  WHERE award_number = av_award_number;
  IF (li_contact_row_count = 0) THEN
		SELECT award_id  INTO li_award_id
		FROM award
		WHERE award_number = av_award_number
		AND sequence_number = av_sequence_number;
		SET @row_number =  (SELECT IFNULL(MAX(award_sponsor_contact_id),0)+1
							FROM award_contact);
		INSERT INTO award_contact (award_sponsor_contact_id
									  ,award_id
									  ,award_number
									  ,sequence_number
									  ,contact_type_code
									  ,rolodex_id
									  ,full_name
									  ,update_timestamp
									  ,update_user
									  )
		SELECT (@row_number:=@row_number + 1)
			  ,li_award_id
			  ,av_award_number
			  ,av_sequence_number
			  ,tc.contact_type_code
			  ,tc.rolodex_id
			  ,r.full_name
			  ,av_update_timestamp
			  ,'INTRFACE'
		FROM template_contact tc
		INNER JOIN rolodex r ON tc.rolodex_id = r.rolodex_id
		WHERE tc.template_code = 1;
      COMMIT;
  END IF;
UPDATE award_contact_id_generator  SET NEXT_VAL = (SELECT IFNULL(MAX(award_sponsor_contact_id),0)+1   FROM award_contact);
COMMIT;
END
$$
DELIMITER ;
