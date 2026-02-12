DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `jhu_sap_awd_upd_sub_amt_inf_tb`(av_sponsored_program_number  VARCHAR(8)
                                               ,av_obligated  DECIMAL(12,2)
                                               ,av_start_date  VARCHAR(10)
                                               ,av_coeus_update_timestamp  DATE
                                            )
BEGIN
DECLARE li_subcontract_row_count INT(3) DEFAULT NULL;
DECLARE li_subcontract_sequence_number INT(3) DEFAULT 1;
DECLARE li_current_line_number INT(4) DEFAULT  NULL;
DECLARE li_current_obligated_amount DECIMAL(12,2) DEFAULT NULL;
SET SQL_SAFE_UPDATES= 0;
SELECT COUNT(*)
INTO li_subcontract_row_count
FROM subcontract_amount_info
WHERE subcontract_code = av_sponsored_program_number;
IF (li_subcontract_row_count = 0) THEN
  INSERT INTO subcontract_amount_info (subcontract_code
										  ,sequence_number
										  ,line_number
										  ,obligated_amount
										  ,obligated_change
										  ,anticipated_amount
										  ,anticipated_change
										  ,effective_date
										  ,update_timestamp
										  ,update_user
										  )
  VALUES (av_sponsored_program_number
		 ,li_subcontract_sequence_number
		 ,1
		 ,av_obligated
		 ,av_obligated
		 ,av_obligated
		 ,av_obligated
		 ,DATE_FORMAT(av_start_date, '%Y%m%d')
		 ,av_coeus_update_timestamp
		 ,'INTRFACE'
		 ); COMMIT;
ELSE
  SELECT MAX(sequence_number)
  INTO li_subcontract_sequence_number
  FROM subcontract_amount_info
  WHERE subcontract_code = av_sponsored_program_number;
  SELECT MAX(line_number)
  INTO li_current_line_number
  FROM subcontract_amount_info
  WHERE subcontract_code = av_sponsored_program_number
  AND sequence_number = li_subcontract_sequence_number;
  SELECT SUM(obligated_amount)
  INTO li_current_obligated_amount
  FROM subcontract_amount_info
  WHERE subcontract_code = av_sponsored_program_number
  AND sequence_number = li_subcontract_sequence_number
  AND line_number = li_current_line_number;
  IF (av_obligated <> li_current_obligated_amount) THEN
	INSERT INTO subcontract_amount_info (subcontract_code
											,sequence_number
											,line_number
											,obligated_amount
											,obligated_change
											,anticipated_amount
											,anticipated_change
											,effective_date
											,update_timestamp
											,update_user
											)
	VALUES (av_sponsored_program_number
		   ,li_subcontract_sequence_number
		   ,li_current_line_number + 1
		   ,av_obligated
		   ,(ifnull(av_obligated,0) - ifnull(li_current_obligated_amount,0))
		   ,av_obligated
		   ,(ifnull(av_obligated,0) - ifnull(li_current_obligated_amount,0))
		   ,UTC_TIMESTAMP()
		   ,av_coeus_update_timestamp
		   ,'INTRFACE'
		   ); COMMIT;
  END IF;
END IF;
END
$$
DELIMITER ;
