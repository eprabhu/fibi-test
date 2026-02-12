DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` PROCEDURE `jhu_sap_awd_upd_awd_researcharea_tb`(av_award_id INT
	  ,av_award_number VARCHAR(12)
      ,av_sequence_number INT(4)
      ,av_proposal_number VARCHAR(10)
      ,av_update_timestamp  DATE
      )
BEGIN
  DECLARE li_sci_code_row_count INT(3) DEFAULT 0;
  DECLARE LS_ERROR_MSG varchar(4000);
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
		BEGIN
			GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
			 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
			SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
			SELECT @full_error INTO LS_ERROR_MSG;
            insert into integration_error_log (SECTION, ERROR_MESSAGE, AWARD_NUMBER, sequence_number)
				values('AWARD RESEARCH AREA', LS_ERROR_MSG, av_award_number, av_sequence_number);
		END;
  SET SQL_SAFE_UPDATES= 0;
  SELECT count(*)
  INTO  li_sci_code_row_count
  FROM award_research_areas
  WHERE award_id IN (  SELECT award_id
						  FROM award
						  WHERE award_number = av_award_number
						  AND sequence_number = av_sequence_number);
  IF li_sci_code_row_count = 0 THEN
	INSERT INTO award_research_areas (	AWARD_ID,
										AWARD_NUMBER,
										SEQUENCE_NUMBER,
										UPDATE_TIMESTAMP,
										UPDATE_USER,
										RESRCH_TYPE_CODE,
										RESRCH_TYPE_AREA_CODE
									   )
									SELECT av_award_id
										  , av_award_number
										  , av_sequence_number
										  ,av_update_timestamp
										  ,'INTRFACE'
										  ,RESRCH_TYPE_CODE
										   ,RESRCH_TYPE_AREA_CODE
									FROM proposal_resrch_areas pra
									WHERE pra.proposal_number = av_proposal_number
									AND pra.sequence_number = (SELECT MAX(sequence_number)
															   FROM proposal_resrch_areas
															   WHERE proposal_number = av_proposal_number);
  COMMIT;
  END IF;
COMMIT;
END
$$
DELIMITER ;
