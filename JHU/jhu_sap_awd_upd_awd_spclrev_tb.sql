DELIMITER $$
CREATE  PROCEDURE `jhu_sap_awd_upd_awd_spclrev_tb`(av_award_id INT
  ,av_award_number  VARCHAR(12)
  ,av_sequence_number  INT(4)
  ,av_proposal_number  VARCHAR(20)
  ,av_update_timestamp  DATE
  )
BEGIN
  DECLARE li_spec_rev_row_count INT(3) DEFAULT 0;
    declare ls_error_msg varchar(4000);
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
		BEGIN
			GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
			 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
			SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
			SELECT @full_error INTO LS_ERROR_MSG;
			select concat(LS_ERROR_MSG,'awd_splrvw: ',av_award_number, ' - ' , av_sequence_number) from dual;
		END;
  SET SQL_SAFE_UPDATES= 0;
  SELECT count(*)
  INTO  li_spec_rev_row_count
  FROM award_special_review
  WHERE award_number = av_award_number
  AND sequence_number = av_sequence_number ;
  IF li_spec_rev_row_count = 0  THEN
	SET @row_number = (SELECT IFNULL(MAX(award_special_review_id),0)+1 FROM award_special_review);
	INSERT INTO award_special_review (award_special_review_id
	                                     ,award_id
                                         ,award_number
										 ,sequence_number
										 ,special_review_code
										 ,approval_type_code
										 ,protocol_number
										 ,application_date
										 ,approval_date
										 ,comments
										 ,update_timestamp
										 ,update_user
										 )
	SELECT (@row_number:=@row_number + 1)
	      ,av_award_id
          ,av_award_number
		  ,av_sequence_number
		  ,psr.special_review_code
		  ,800
		  ,psr.protocol_number
		  ,psr.application_date
		  ,psr.approval_date
		  ,NULL
		  ,av_update_timestamp
		  ,'INTRFACE'
	FROM proposal_special_review psr
	WHERE psr.proposal_number = av_proposal_number
	AND psr.sequence_number in (SELECT MAX(sequence_number)
							   FROM proposal_special_review
							   WHERE proposal_number = av_proposal_number);
	COMMIT;
  END IF;
UPDATE award_special_review_id_generator SET NEXT_VAL = (SELECT IFNULL(MAX(award_special_review_id),0)+1   FROM award_special_review);
COMMIT;
END
$$
DELIMITER ;
