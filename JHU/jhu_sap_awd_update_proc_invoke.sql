DELIMITER $$
CREATE  PROCEDURE `jhu_sap_awd_update_proc_invoke`(ls_coeus_award_number VARCHAR(12)
												,li_coeus_sequence_number INT(4)
												,ls_sponsored_program_number VARCHAR(8)
												,ls_award_id VARCHAR(20)
												,li_coeus_status INT(3)
												,li_template_code  INT(1)
												,ls_validated_start_date VARCHAR(10)
												,ls_validated_end_date VARCHAR(10)
												,ls_validated_sponsor_code VARCHAR(10)
												,ld_coeus_update_timestamp DATE
												,ls_proposal_number  VARCHAR(20)
												,ls_validated_title VARCHAR(150)
												,ls_validated_award_type VARCHAR(3)
												,li_validated_obligated DECIMAL(12,2)
												,li_validated_anticipated DECIMAL(12,2)
												,ls_validated_val_start_date VARCHAR(10)
												,ls_cfda_number VARCHAR(8)
												,ls_sub_award_flag VARCHAR(1)
												,ls_validated_sponsor_prime_code VARCHAR(10)
												,ls_validated_billing_rule VARCHAR(4)
												,ls_validated_payment_method VARCHAR(4)
												,ls_validated_fa_function VARCHAR(25)
												,ls_validated_spon_prog_type VARCHAR(15)
												,ls_validation_comments LONGTEXT
												,ls_validated_rcc VARCHAR(10)
												,ls_validated_fa_rate VARCHAR(7)
												,ls_validated_location  VARCHAR(5)
												,ls_validated_val_end_date VARCHAR(10)
)
BEGIN
	DECLARE LI_latest_sequence_number decimal(22,0);
	DECLARE li_root_award_count INT(4) DEFAULT NULL;
    DECLARE LS_ERROR_MSG VARCHAR(4000);
	DECLARE li_award_id  DECIMAL(22,0) DEFAULT NULL;
    -- Exception Block
		DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
		BEGIN
			GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
			 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
			SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
			SELECT @full_error INTO LS_ERROR_MSG;
		END;
    BEGIN
/************************************************************************
  ** Update the AWARD table 							               **
  ************************************************************************/
		CALL jhu_sap_awd_update_award_table(
								ls_coeus_award_number,
								 li_coeus_sequence_number,
								 ls_sponsored_program_number,
								 ls_award_id,
								 li_coeus_status,
								 li_template_code,
								 ls_validated_start_date,
								 ls_validated_end_date,
								 ls_validated_sponsor_code,
								 ld_coeus_update_timestamp,
								 ls_proposal_number,
								  ls_validated_title,
								  ls_validated_award_type,
								  li_validated_obligated,
								  ls_validated_val_start_date,
								  ls_cfda_number,
								  ls_sub_award_flag,
								  ls_validated_sponsor_prime_code,
								  ls_validated_billing_rule,
								  ls_validated_payment_method,
								  ls_validated_fa_function,
								  ls_validated_spon_prog_type
								 );
SELECT award_id
		INTO li_award_id
		FROM award
		WHERE award_number = ls_coeus_award_number
		AND   sequence_number = li_coeus_sequence_number;
	/************************************************************************
  ** Update the AWARD_FUNDING_PROPOSALS table                        **
  ************************************************************************/
	  CALL jhu_sap_awd_upd_fund_prop_tb(   li_award_id,
										   ls_coeus_award_number,
										   li_coeus_sequence_number,
										   ls_proposal_number,
										   ld_coeus_update_timestamp
										   );
/**************************************************************************
** Check for the existance of this record to determine if and INSERT     **
** or UPDATE should be performed                                         **
**************************************************************************/
  SELECT COUNT(*)
  INTO li_root_award_count
  FROM award
  WHERE award_number = ls_coeus_award_number;
		IF li_root_award_count = 1 THEN
			/************************************************************************
			** Update the AWARD_HIERARCHY table                                **
			************************************************************************/
			CALL jhu_sap_awd_upd_awd_hrchy_tb(ls_coeus_award_number,
												 ld_coeus_update_timestamp
												 );
			/************************************************************************
			** Update the AWARD_REPORTING table                                **
			************************************************************************/
			CALL jhu_sap_awd_upd_awd_rprtng_tb(li_award_id,
											  ls_coeus_award_number,
											  li_coeus_sequence_number,
											  li_template_code,
											  ld_coeus_update_timestamp
											  );
	END IF;
		/************************************************************************
		** Update the research_area table                             **
		************************************************************************/
				CALL jhu_sap_awd_upd_awd_researcharea_tb(li_award_id,
									ls_coeus_award_number,
									li_coeus_sequence_number,
									ls_proposal_number,
									ld_coeus_update_timestamp
									);
		/************************************************************************
		** Update the custom_data table                             **
		************************************************************************/
				CALL jhu_sap_awd_upd_awd_customdata_tb(li_award_id,
									ls_proposal_number,
									ld_coeus_update_timestamp
									);
		/************************************************************************
		** Update the AWARD_TEMPLATE tables                                **
		************************************************************************/
		CALL jhu_sap_awd_upd_awd_tmplt_tb(li_award_id,
								   ls_coeus_award_number,
								   li_coeus_sequence_number,
								   li_template_code,
								   ld_coeus_update_timestamp
								   );
			/************************************************************************
		** Update the AWARD_AMOUNT_INFO table                              **
		************************************************************************/
        CALL jhu_sap_awd_upd_amt_info_tb(li_award_id,
								   ls_coeus_award_number,
								  li_coeus_sequence_number,
								  li_validated_obligated,
								  li_validated_anticipated,
								  ls_validated_start_date,
								  ls_validated_end_date,
								  ld_coeus_update_timestamp
								 );
			/************************************************************************
			** Update the AWARD_BUDGET table                                   **
			************************************************************************/
			CALL jhu_sap_awd_upd_awd_budget_tb(li_award_id,
								   ls_coeus_award_number,
										li_coeus_sequence_number,
										li_validated_obligated,
										li_validated_anticipated,
                                        ls_validated_start_date,
										ls_validated_end_date,
										ld_coeus_update_timestamp
										);
			/************************************************************************
			** Update the AWARD_INVESTIGATORS table                            **
			************************************************************************/
             IF li_coeus_sequence_number != 0 THEN
             select award_id into li_award_id FROM AWARD
             where award_number = ls_coeus_award_number
             and sequence_number = li_coeus_sequence_number;
            CALL jhu_sap_awd_upd_awd_inv_tb(li_award_id,
										   ls_coeus_award_number,
										   li_coeus_sequence_number,
										   ls_sponsored_program_number,
										   ld_coeus_update_timestamp,
										   ls_validation_comments
										   );
             END IF;
             IF li_coeus_sequence_number = 0 THEN
			 select award_id into li_award_id FROM AWARD
             where award_number = ls_coeus_award_number
             and sequence_number = 0;
             SELECT max(sequence_number) into LI_latest_sequence_number
             FROM award
			WHERE award_number = ls_coeus_award_number;
			call jhu_sap_awd_upd_awd_inv_actv(li_award_id,
										ls_coeus_award_number,
										   LI_latest_sequence_number);
			 END IF;
			/************************************************************************
			** Update the AWARD_UNITS table                                    **
			************************************************************************/
			CALL jhu_sap_awd_upd_awd_units_tb (li_award_id,
										ls_coeus_award_number,
								   li_coeus_sequence_number,
								   ls_validated_rcc,
								   ld_coeus_update_timestamp
								   );
			IF (ls_coeus_award_number LIKE '%00001') THEN
			/************************************************************************
			** Update the OSP$AWARD_AMT_FNA_DISTRIBUTION table                     **
			************************************************************************/
				CALL jhu_sap_awd_upd_fna_tbl(ls_coeus_award_number
										,li_coeus_sequence_number
										,ld_coeus_update_timestamp
										   );
				/************************************************************************
				** Update the OSP$AWARD_SPECIAL_REVIEW table                           **
				************************************************************************/
			   CALL jhu_sap_awd_upd_awd_spclrev_tb(li_award_id,
										ls_coeus_award_number
									   ,li_coeus_sequence_number
									   ,ls_proposal_number
									   ,ld_coeus_update_timestamp
									   );
			ELSE
				/************************************************************************
				** Update the OSP$AWARD_COST_SHARING table                             **
				************************************************************************/
				  CALL jhu_sap_awd_upd_idc_rate_tb(ls_coeus_award_number,
													  ls_sponsored_program_number,
													  li_coeus_sequence_number,
													  7,
													  ls_validated_fa_rate,
													  ls_validated_location,
													  ls_validated_val_start_date,
													  ls_validated_val_end_date,
													  ld_coeus_update_timestamp
													  );
			END IF;
			/************************************************************************
			** Update the OSP$AWARD_COMMENTS  table                                **
			************************************************************************/
			IF LENGTH(TRIM(ls_validation_comments)) > 0 THEN
				CALL jhu_sap_awd_upd_awd_comment_tb(li_award_id,
													ls_coeus_award_number,
												  li_coeus_sequence_number,
												  ls_validation_comments,
												  ld_coeus_update_timestamp
												  );
			END IF;
			CALL jhu_sap_awd_set_indicators(li_award_id,
								ls_coeus_award_number,
								li_coeus_sequence_number
								);
END;
END
$$
DELIMITER ;
