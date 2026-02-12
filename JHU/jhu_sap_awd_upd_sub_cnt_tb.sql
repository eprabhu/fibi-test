DELIMITER $$
CREATE  PROCEDURE `jhu_sap_awd_upd_sub_cnt_tb`(av_sponsored_program_number  VARCHAR(8)
								  ,av_coeus_update_timestamp  DATE
								  )
BEGIN
DECLARE li_subcontract_row_count INT(3) DEFAULT NULL;
DECLARE li_subcontract_sequence_number INT(3) DEFAULT 1;
SET SQL_SAFE_UPDATES= 0;
SELECT count(*)
INTO li_subcontract_row_count
FROM subcontract_contact
WHERE subcontract_code = av_sponsored_program_number;
IF li_subcontract_row_count = 0 THEN
  INSERT INTO subcontract_contact (subcontract_code
									  ,sequence_number
									  ,contact_type_code
									  ,rolodex_id
									  ,update_timestamp
									  ,update_user
									  )
  VALUES (av_sponsored_program_number
		 ,li_subcontract_sequence_number
		 ,800
		 ,999999
		 ,av_coeus_update_timestamp
		 ,'INTRFACE'
		 ); COMMIT;
END IF;
END
$$
DELIMITER ;
