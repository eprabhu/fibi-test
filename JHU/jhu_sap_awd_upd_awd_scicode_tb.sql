DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` PROCEDURE `jhu_sap_awd_upd_awd_scicode_tb`(av_award_number VARCHAR(12)
      ,av_sequence_number INT(4)
      ,av_proposal_number VARCHAR(10)
      ,av_update_timestamp  DATE
      )
BEGIN
  DECLARE li_sci_code_row_count INT(3) DEFAULT 0;
  DECLARE li_award_science_keyword_id DECIMAL(22,0);
  DECLARE li_award_id DECIMAL(22,0);
  declare ls_error_msg varchar(4000);
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
		BEGIN
			GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
			 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
			SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
			SELECT @full_error INTO LS_ERROR_MSG;
			 insert into integration_error_log (SECTION, ERROR_MESSAGE, AWARD_NUMBER, sequence_number)
				values('AWARD SCIENCE CODE', LS_ERROR_MSG, av_award_number, av_proposal_number);
		END;
  SET SQL_SAFE_UPDATES= 0;
  SELECT award_id  INTO li_award_id
  FROM award
  WHERE award_number = av_award_number
  AND sequence_number = av_sequence_number;
  SELECT count(*)
  INTO  li_sci_code_row_count
  FROM award_science_keyword
  WHERE award_id IN (  SELECT award_id
						  FROM award
						  WHERE award_number = av_award_number);
  IF li_sci_code_row_count = 0 THEN
	INSERT INTO award_science_keyword (award_id
									   ,science_keyword_code
									   ,update_timestamp
									   ,update_user
									   )
	SELECT li_award_id
		  ,psc.science_keyword_code
		  ,av_update_timestamp
		  ,'INTRFACE'
	FROM proposal_keywords psc
	WHERE psc.proposal_number = av_proposal_number
	AND psc.sequence_number = (SELECT MAX(sequence_number)
							   FROM proposal_keywords
							   WHERE proposal_number = av_proposal_number);
  COMMIT;
  END IF;
END
$$
DELIMITER ;
