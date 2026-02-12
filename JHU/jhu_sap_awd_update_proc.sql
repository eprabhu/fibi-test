DELIMITER $$
CREATE  PROCEDURE `jhu_sap_awd_update_proc`(av_changed_grant_number  VARCHAR(10))
BEGIN
	DECLARE file_path VARCHAR(33) DEFAULT '/var/www/tomcat/webapps/coeus/log';
	DECLARE out_file_name VARCHAR(25) DEFAULT 'cufs_award_update.log';
	DECLARE mail_host VARCHAR(30) DEFAULT 'smtp.johnshopkins.edu';
	DECLARE sender VARCHAR(50) DEFAULT 'award_update@prcoeus.johnshopkins.edu';
	DECLARE recipient VARCHAR(50) DEFAULT 'ret@jhu.edu';
	DECLARE interface_flag INT(1) DEFAULT NULL;
	DECLARE li_unit_row_count INT(3) DEFAULT NULL;
	DECLARE action_performed VARCHAR(8) DEFAULT NULL;
	DECLARE ls_process_record VARCHAR(8) DEFAULT NULL;
	DECLARE ls_message_text VARCHAR(4000) DEFAULT 'Text Goes Here.';
	DECLARE ld_coeus_update_timestamp DATE DEFAULT NOW();
	DECLARE ls_coeus_award_number VARCHAR(12) DEFAULT NULL;
	DECLARE li_coeus_sequence_number INT(4) DEFAULT NULL;
	DECLARE coeus_subcontract_code VARCHAR(20) DEFAULT NULL;
	DECLARE ls_validated_sponsor_code VARCHAR(10) DEFAULT NULL;
	DECLARE ls_validated_sponsor_prime_code VARCHAR(10) DEFAULT NULL;
	DECLARE ls_validated_title VARCHAR(150) DEFAULT NULL;
	DECLARE li_validated_obligated DECIMAL(12,2) DEFAULT NULL;
	DECLARE li_validated_anticipated DECIMAL(12,2) DEFAULT NULL;
	DECLARE li_coeus_status INT(3) DEFAULT NULL;
    DECLARE ls_sap_status VARCHAR(5) DEFAULT NULL;
	DECLARE ls_validated_spon_prog_type VARCHAR(15) DEFAULT NULL;
	DECLARE ls_validated_rcc VARCHAR(10) DEFAULT NULL;
	DECLARE ls_validated_location VARCHAR(5) DEFAULT NULL;
	DECLARE ls_validated_fa_rate VARCHAR(7) DEFAULT NULL;
	DECLARE ls_validated_fa_function VARCHAR(25) DEFAULT NULL;
	DECLARE validated_fa_base VARCHAR(10) DEFAULT NULL;
	DECLARE ls_validated_payment_method VARCHAR(4) DEFAULT NULL;
	DECLARE ls_validated_billing_rule VARCHAR(4) DEFAULT NULL;
	DECLARE ls_validated_start_date VARCHAR(10) DEFAULT NULL;
	DECLARE ls_validated_end_date VARCHAR(10) DEFAULT NULL;
	DECLARE ls_validated_val_start_date VARCHAR(10) DEFAULT NULL;
	DECLARE ls_validated_val_end_date VARCHAR(10) DEFAULT NULL;
	DECLARE ls_validated_grant_type VARCHAR(3) DEFAULT NULL;
	DECLARE ls_validated_award_type VARCHAR(3) DEFAULT NULL;
	DECLARE ls_validation_comments LONGTEXT DEFAULT NULL;
	DECLARE li_award_year_sum DECIMAL(12,2) DEFAULT NULL;
	DECLARE li_sponsored_program_sum DECIMAL(12,2) DEFAULT NULL;
    DECLARE ls_max_effective_date VARCHAR(8) DEFAULT NULL;
	DECLARE ls_grant_number     VARCHAR(6);
	DECLARE ls_sponsored_program_number     VARCHAR(8);
	DECLARE ls_sponsor_code     VARCHAR(10);
	DECLARE ls_prime_sponsor_code     VARCHAR(10);
	DECLARE ls_award_id     VARCHAR(20);
	DECLARE ls_project_title     VARCHAR(80);
	DECLARE ls_obligated     VARCHAR(15);
	DECLARE ls_anticipated     VARCHAR(15);
	DECLARE ls_status     VARCHAR(6);
	DECLARE ls_user_status     VARCHAR(5);
	DECLARE ls_billing_rule     VARCHAR(4);
	DECLARE ls_payment_method     VARCHAR(4);
	DECLARE ls_start_date     VARCHAR(10);
	DECLARE ls_end_date     VARCHAR(10);
	DECLARE ls_validity_start_date     VARCHAR(10);
	DECLARE ls_validity_end_date     VARCHAR(10);
	DECLARE ls_proposal_number     VARCHAR(20);
	DECLARE ls_cfda_number     VARCHAR(8);
	DECLARE li_template_code     INT(1);
	DECLARE ls_grant_type     VARCHAR(3);
	DECLARE ls_award_type     VARCHAR(3);
	DECLARE ls_cost_sharing_flag     VARCHAR(1);
	DECLARE ls_sub_award_flag     VARCHAR(1);
	DECLARE ls_rate_type     VARCHAR(10);
	DECLARE ls_fa_base     VARCHAR(10);
	DECLARE ls_fa_function     VARCHAR(25);
	DECLARE ls_fa_rate     VARCHAR(7);
	DECLARE ls_location     VARCHAR(5);
	DECLARE ls_responsible_cost_center     VARCHAR(10);
	DECLARE ls_sponsored_program_type     VARCHAR(15);
	DECLARE ls_description            VARCHAR(30);
	DECLARE LI_ROWCOUNT INT(12) DEFAULT 0;
    DECLARE LI_PENDING_SEQ_NUM  INT(4) DEFAULT NULL;
    DECLARE LI_PENDING_AWD_EXIST INT DEFAULT NULL;
    DECLARE li_award_id decimal(22,0);
    DECLARE LS_UPDATE_TIMESTAMP DATETIME;
	DECLARE LS_ERROR_MSG VARCHAR(4000);
	DECLARE DONE1 INT DEFAULT FALSE;
		  DECLARE award_cur CURSOR FOR
		  SELECT T.grant_number,
				T.sponsored_program_number,
				T.sponsor_code,
				T.prime_sponsor_code,
				T.award_id,
				T.project_title,
				T.obligated,
				T.anticipated,
				T.status,
				T.user_status,
				T.billing_rule,
				T.payment_method,
				T.start_date,
				T.end_date,
				T.validity_start_date,
				T.validity_end_date,
				T.proposal_number,
				T.cfda_number,
				T.template_code,
				T.grant_type,
				T.award_type,
				T.cost_sharing_flag,
				T.sub_award_flag,
				T.rate_type,
				T.fa_base,
				T.fa_function,
				T.fa_rate,
				T.location,
				T.responsible_cost_center,
				T.sponsored_program_type,
				T.description,
                T.update_timestamp
		FROM (
      SELECT TRIM(g.grant_number) AS grant_number,
             NULL AS sponsored_program_number,
             SUBSTR(g.sponsor_code, 5, 6) AS sponsor_code,
             SUBSTR(g.prime_sponsor_code, 5, 6) AS prime_sponsor_code,
             TRIM(g.award_id) AS award_id,
             TRIM(g.project_title) AS project_title,
             ROUND(CAST(REPLACE(REPLACE(g.grant_value, '$',''), ',','') AS DECIMAL(12,2))) AS obligated,
             ROUND(CAST(REPLACE(REPLACE(g.grant_funded_amount, '$',''), ',','') AS DECIMAL(12,2))) AS anticipated,
             TRIM(g.grant_status) AS status,
             TRIM(g.user_status) AS user_status,
             CAST(TRIM(g.billing_rule) AS DECIMAL(12,2)) AS billing_rule,
             g.payment_method AS payment_method,
             TRIM(g.grant_start_date) AS start_date,
             TRIM(g.grant_end_date) AS end_date,
             TRIM(g.validity_start_date) AS validity_start_date,
             TRIM(g.validity_end_date) AS validity_end_date,
             TRIM(g.proposal_number) AS proposal_number,
             TRIM(g.cfda_number) AS cfda_number,
             1 AS template_code,
             TRIM(g.grant_type) AS grant_type,
             TRIM(g.award_type) AS award_type,
             g.grant_cost_sharing_flag AS cost_sharing_flag,
             g.grant_subaward_flag AS sub_award_flag,
             TRIM(s.rate_type) AS rate_type,
             TRIM(s.fa_base) AS fa_base,
             TRIM(s.fa_function) AS fa_function,
             CAST(s.fa_rate AS DECIMAL(12,2)) AS fa_rate,
             TRIM(s.location) AS location,
             TRIM(SUBSTR(s.responsible_cost_center, 1, 8)) AS responsible_cost_center,
             'GR' AS sponsored_program_type,
             CONCAT('Grant ',g.grant_number)  AS description,
             g.update_timestamp as update_timestamp
      FROM sap_grant g INNER JOIN sap_sponsored_program s ON  g.grant_number = s.grant_number
      WHERE g.grant_number = av_changed_grant_number
      AND s.sponsored_program_type = 'PM'
      UNION
      SELECT TRIM(s.grant_number) AS grant_number,
             TRIM(s.sponsored_program_number) AS sponsored_program_number,
             SUBSTR(g.sponsor_code, 5, 6) AS sponsor_code,
             SUBSTR(g.prime_sponsor_code, 5, 6) AS prime_sponsor_code,
             TRIM(g.award_id) AS award_id,
             CONCAT(TRIM(g.project_title) , ':  ' , s.description) AS project_title,
             ROUND(CAST(REPLACE(REPLACE(s.sponsored_program_value, '$',''), ',','') AS DECIMAL(12,2))) AS obligated,
             ROUND(CAST(REPLACE(REPLACE(s.sponsored_program_value, '$',''), ',','') AS DECIMAL(12,2))) AS anticipated,
             TRIM(s.sponsored_program_status) AS status,
             TRIM(g.user_status) AS user_status,
             CAST(TRIM(g.billing_rule) AS  DECIMAL(12,2)) AS billing_rule,
             TRIM(g.payment_method) AS payment_method,
             TRIM(s.internal_order_start_date) AS start_date,
             TRIM(s.internal_order_end_date) AS end_date,
             TRIM(g.validity_start_date) AS validity_start_date,
             TRIM(g.validity_end_date) AS validity_end_date,
             TRIM(g.proposal_number) AS proposal_number,
             TRIM(g.cfda_number) AS cfda_number,
             1 AS template_code,
             TRIM(g.grant_type) AS grant_type,
             TRIM(g.award_type) AS award_type,
             g.grant_cost_sharing_flag AS cost_sharing_flag,
             g.grant_subaward_flag AS sub_award_flag,
             TRIM(s.rate_type) AS rate_type,
             TRIM(s.fa_base) AS fa_base,
             TRIM(s.fa_function) AS fa_function,
             CAST(s.fa_rate AS  DECIMAL(12,2)) AS fa_rate,
             TRIM(s.location) AS location,
             TRIM(SUBSTR(s.responsible_cost_center, 1, 8)) AS responsible_cost_center,
             TRIM(s.sponsored_program_type) AS sponsored_program_type,
             s.description AS description,
             s.update_timestamp as update_timestamp
      FROM sap_grant g INNER JOIN sap_sponsored_program s ON  g.grant_number = s.grant_number
      WHERE g.grant_number = av_changed_grant_number
      AND   s.sponsored_program_type <> 'CS')T
      ORDER BY T.grant_number,T.UPDATE_TIMESTAMP, T.sponsored_program_number;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE1 = TRUE;
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
		BEGIN
			GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
			 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
			SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
			SELECT @full_error INTO LS_ERROR_MSG;
            insert into integration_error_log (SECTION, ERROR_MESSAGE, AWARD_NUMBER, sequence_number)
				values('AWARD UPDATE PROC', concat(IFNULL(LS_ERROR_MSG,''),' GrantNumber: ',ls_grant_number, '\n SponsoredProgramNumber: ', ls_sponsored_program_number,'\n SponsoredProgramType: ',ls_sponsored_program_type), ls_coeus_award_number, li_coeus_sequence_number);
		END;
	SET SQL_SAFE_UPDATES= 0;
	BEGIN
			OPEN award_cur;
			award_cur_loop : LOOP
					FETCH award_cur INTO ls_grant_number,
										ls_sponsored_program_number,
										ls_sponsor_code,
										ls_prime_sponsor_code,
										ls_award_id,
										ls_project_title,
										ls_obligated,
										ls_anticipated,
										ls_status,
										ls_user_status,
										ls_billing_rule,
										ls_payment_method,
										ls_start_date,
										ls_end_date,
										ls_validity_start_date,
										ls_validity_end_date,
										ls_proposal_number,
										ls_cfda_number,
										li_template_code,
										ls_grant_type,
										ls_award_type,
										ls_cost_sharing_flag,
										ls_sub_award_flag,
										ls_rate_type,
										ls_fa_base,
										ls_fa_function,
										ls_fa_rate,
										ls_location,
										ls_responsible_cost_center,
										ls_sponsored_program_type,
										ls_description,
                                        LS_UPDATE_TIMESTAMP;
					IF DONE1 THEN
						LEAVE award_cur_loop;
					END IF;
							SET LI_ROWCOUNT = LI_ROWCOUNT+1;
							IF LI_ROWCOUNT = 1  THEN
								CALL jhu_sap_awd_cleanup_data(ls_grant_number);
							END IF;
							SET ls_process_record = 'TRUE';
							SET ls_sap_status = ls_status;
							SET li_coeus_status = fn_jhu_sap_awd_set_coeus_stats(ls_status,ls_user_status,ls_end_date);
							SET ls_validation_comments = NULL;
							SET ls_message_text = CONCAT('\nGrant Number = ', ls_grant_number);
							SET li_award_year_sum = fn_jhu_sap_awd_sum_of_awd_yrs(ls_grant_number);
							SET li_sponsored_program_sum =  fn_jhu_sap_awd_sum_spnsrd_prgm(ls_grant_number);
							SET ls_max_effective_date =  fn_jhu_sap_awd_get_max_effv_dt(ls_grant_number);
							 IF (ls_grant_number IS NULL OR LENGTH(ls_grant_number) <> 6) THEN
								SET ls_process_record = 'FALSE';
							 END IF;
							IF (ls_sponsored_program_type <> 'GR'
									AND(ls_sponsored_program_number IS NULL
									OR LENGTH(ls_sponsored_program_number) <> 8)) THEN
								SET ls_process_record = 'FALSE';
							 END IF;
							IF fn_jhu_sap_awd_prim_sponprg_c(ls_grant_number) <> 1 THEN
								SET ls_validation_comments = CONCAT(ls_validation_comments , 'This award does not have exactly 1 primary sponsored program.\n' );
							END IF;
							IF (ls_sponsored_program_type = 'GR'
								AND fn_jhu_sap_awd_get_null_spgmtp(ls_grant_number)  > 0) THEN
								SET ls_validation_comments = CONCAT(ls_validation_comments , 'This award has sponsored programs with no type NULL.\n');
						   END IF;
						  IF (ls_sponsored_program_type = 'GR' AND fn_jhu_sap_awd_has_val_prop_typ(ls_proposal_number) <> 0) THEN
							SET ls_validation_comments = CONCAT(ls_validation_comments,'The proposal associated with this award has an invalid proposal type.\n');
						  END IF;
						  IF (ls_sponsor_code IS NULL OR LENGTH(ls_sponsor_code) <> 6) THEN
							SET ls_validated_sponsor_code = '-1';
							SET ls_validation_comments = CONCAT(ls_validation_comments,'The sponsor code received from SAP is missing or invalid\n');
						  ELSE
							SET ls_validated_sponsor_code = TRIM(ls_sponsor_code);
						  END IF;
						  IF (LENGTH(ls_prime_sponsor_code) <> 6)  THEN
							SET ls_validated_sponsor_prime_code = '-1';
							SET ls_validation_comments = CONCAT(ls_validation_comments, 'The prime sponsor code received from SAP is invalid\n');
						  ELSE
							SET ls_validated_sponsor_prime_code = ls_prime_sponsor_code;
						  END IF;
						  IF (ls_project_title IS NULL) THEN
								SET ls_validated_title = 'The title is not required for Pre-Award accounts in SAP';
								IF (li_coeus_status <> 3) THEN
								  SET ls_validated_title = 'The title needs to re-sent from SAP';
								  SET ls_validation_comments = CONCAT(ls_validation_comments ,'The title was not sent from SAP\n');
								END IF;
						  ELSE
								SET ls_validated_title = TRIM(SUBSTR(ls_project_title, 1, 150));
						  END IF;
						  IF (ls_obligated IS NULL) THEN
								SET li_validated_obligated = 0;
								IF (li_coeus_status <> 3) THEN
									SET ls_validation_comments = CONCAT(ls_validation_comments ,'The project value was not sent from SAP\n');
								END IF;
						  ELSE
								SET li_validated_obligated = ls_obligated;
						  END IF;
						IF (ls_anticipated IS NULL) THEN
							SET li_validated_anticipated = 0;
							IF (li_coeus_status <> 3) THEN
								SET ls_validation_comments = CONCAT(ls_validation_comments ,'The project value was not sent from SAP\n');
							END IF;
						ELSE
							SET li_validated_anticipated = ls_anticipated;
						END IF;
						IF (ls_status IS NULL) THEN
							SET ls_validation_comments = CONCAT(ls_validation_comments ,'The status value was not sent from SAP\n');
						END IF;
						IF (ls_user_status IS NULL) THEN
							SET ls_validation_comments = CONCAT(ls_validation_comments ,'The user status value was not sent from SAP\n');
						END IF;
						IF (ls_billing_rule IS NULL) THEN
							SET ls_validated_billing_rule = '8';
							SET ls_validation_comments = CONCAT(ls_validation_comments ,'The billing rule was not sent from SAP\n');
						ELSE
							SET ls_validated_billing_rule = ls_billing_rule;
						END IF;
						IF (ls_sponsored_program_type IS NULL) THEN
							SET ls_validated_spon_prog_type = 'OT';
							SET ls_validation_comments = CONCAT(ls_validation_comments ,'The sponsored program type was not sent from SAP\n');
						ELSE
							SET ls_validated_spon_prog_type = ls_sponsored_program_type;
						END IF;
						IF (ls_validated_spon_prog_type = 'GR') THEN
								IF (ls_obligated <> li_sponsored_program_sum AND ls_obligated > 1) THEN
									  SET ls_validation_comments = CONCAT(ls_validation_comments ,'The grant value ('
																							, TRIM(concat('$',FORMAT(ls_obligated, 2)))
																							,') does not equal the sum of the sponsored programs ('
                                                                                             , TRIM(CONCAT('$', FORMAT(li_sponsored_program_sum, 2)))
																							, ')\n');
								END IF;
								IF (ls_anticipated <> li_award_year_sum AND li_coeus_status <> 3) THEN
									  SET ls_validation_comments = CONCAT(ls_validation_comments ,'The funded amount (' , TRIM(concat('$',FORMAT(ls_anticipated, 2)))
																					,') does not equal the sum of the award years ('
																					,TRIM(concat('$',FORMAT(li_award_year_sum, 2)))
																					,')\n');
								END IF;
								IF (TRIM(DATE_FORMAT(ls_max_effective_date, '%Y-%m-%d')) > DATE(UTC_TIMESTAMP())) THEN
									   SET ls_validation_comments = CONCAT(ls_validation_comments ,'Award date ('
																		, SUBSTR(ls_max_effective_date,5,2)
																		, '/'
																		, SUBSTR(ls_max_effective_date,7,2)
																		, '/'
																		, SUBSTR(ls_max_effective_date,1,4)
																		, ') is a future date\n');
								END IF;
								IF (li_coeus_status = 3) THEN
									  IF (ls_obligated IS NOT NULL AND ls_obligated > 0) THEN
										SET li_validated_obligated = 0;
										SET ls_validation_comments = CONCAT(ls_validation_comments ,'The pre-award grant value is greater than 0.\n');
									  END IF;
									  IF (ls_anticipated IS NOT NULL AND ls_anticipated > 0) THEN
										SET li_validated_anticipated = 0;
										SET ls_validation_comments = CONCAT(ls_validation_comments ,'The pre-award funded amount is greater than 0.\n');
									  END IF;
								END IF;
						END IF;
						IF (ls_responsible_cost_center IS NULL) THEN
								SET ls_validated_rcc = '000001';
								SET ls_validation_comments = CONCAT(ls_validation_comments ,'The responsible cost center was not sent from SAP\n');
						ELSE
								SET ls_validated_rcc = fn_jhu_sap_awd_get_unit_number(ls_responsible_cost_center);
								SELECT count(*)
								INTO li_unit_row_count
								FROM unit
								WHERE unit_number = ls_validated_rcc;
								IF li_unit_row_count = 0 THEN
								  SET ls_validated_rcc = '000001';
								  SET ls_validation_comments = CONCAT(ls_validation_comments ,'The responsible cost center sent from SAP is not on file.\n');
								END IF;
						END IF;
						IF (ls_location IS NULL OR ls_location ='BLANK') THEN
							SET ls_validated_location = 'ON';
							SET ls_validation_comments = CONCAT(ls_validation_comments ,'The location was not sent from SAP or is invalid\n');
						ELSE
							SET ls_validated_location = ls_location;
						END IF;
						IF (ls_fa_rate IS NULL) THEN
							SET ls_validated_fa_rate = '0';
							SET ls_validation_comments = CONCAT(ls_validation_comments ,'The F and A rate was not sent from SAP\n');
						ELSE
							SET ls_validated_fa_rate = ls_fa_rate;
						END IF;
						IF (ls_fa_function IS NULL) THEN
							SET ls_validated_fa_function = 'OTHER SPONSORED ACTIVITY';
							SET ls_validation_comments = CONCAT(ls_validation_comments ,'The F and A function was not sent from SAP\n');
						ELSE
							SET ls_validated_fa_function = ls_fa_function;
						END IF;
						IF (ls_payment_method IS NULL) THEN
							SET ls_validated_payment_method = 'UNKN';
							IF (li_coeus_status <> 3) THEN
							  SET ls_validation_comments = CONCAT(ls_validation_comments ,'The payment method was not sent from SAP\n');
							END IF;
						ELSE
							SET ls_validated_payment_method = ls_payment_method;
						END IF;
						IF (ls_start_date IS NULL OR ls_start_date = '19000101') THEN
							IF (li_coeus_status <> 3) THEN
								SET ls_validation_comments = CONCAT(ls_validation_comments ,'The start date was not sent from SAP\n');
							END IF;
								SET ls_validated_start_date = '19000101';
						ELSE
							SET ls_validated_start_date = ls_start_date;
						END IF;
						IF (ls_end_date IS NULL OR ls_end_date = '19000101') THEN
							IF (li_coeus_status <> 3) THEN
								SET ls_validation_comments = CONCAT(ls_validation_comments ,'The end date was not sent from SAP\n');
							END IF;
							SET ls_validated_end_date = '19000101';
						ELSE
							SET ls_validated_end_date = ls_end_date;
						END IF;
						IF (ls_validity_start_date IS NULL OR ls_validity_start_date = '19000101') THEN
							SET ls_validation_comments = CONCAT(ls_validation_comments ,'The validity start date was not sent from SAP\n');
						END IF;
						SET ls_validated_val_start_date = ls_validity_start_date;
						IF (ls_validity_end_date IS NULL OR ls_validity_end_date = '19000101') THEN
							SET ls_validation_comments = CONCAT(ls_validation_comments ,'The validity end date was not sent from SAP\n');
						END IF;
						SET ls_validated_val_end_date = ls_validity_end_date;
						IF (ls_proposal_number IS NULL) THEN
							SET ls_process_record = 'FALSE';
						END IF;
						IF (ls_grant_type IS NULL) THEN
							SET ls_validated_grant_type = 'ZZ';
							SET ls_validation_comments = CONCAT(ls_validation_comments ,'The grant type was not sent from SAP\n');
						ELSE
							SET ls_validated_grant_type = ls_grant_type;
						END IF;
						IF (ls_award_type IS NULL) THEN
							SET ls_validated_award_type = 'GT';
							SET ls_validation_comments = CONCAT(ls_validation_comments ,'The award type was not sent from SAP\n');
						ELSE
							SET  ls_validated_award_type = ls_award_type;
						END IF;
						SET ls_coeus_award_number = fn_jhu_sap_awd_get_awdnum(ls_grant_number,
									 ls_sponsored_program_number,
																			 ls_validated_spon_prog_type);
								  SET li_coeus_sequence_number = fn_jhu_sap_awd_get_seq_num(ls_coeus_award_number
																							,ls_sponsored_program_number
																							,ls_validated_end_date
																							,li_validated_obligated
																							,li_validated_anticipated
																							 );
			CALL jhu_sap_awd_update_proc_invoke(ls_coeus_award_number
												,li_coeus_sequence_number
												,ls_sponsored_program_number
												,ls_award_id
												,li_coeus_status
												,li_template_code
												,ls_validated_start_date
												,ls_validated_end_date
												,ls_validated_sponsor_code
												,ld_coeus_update_timestamp
												,ls_proposal_number
												,ls_validated_title
												,ls_validated_award_type
												,li_validated_obligated
												,li_validated_anticipated
												,ls_validated_val_start_date
												,ls_cfda_number
												,ls_sub_award_flag
												,ls_validated_sponsor_prime_code
												,ls_validated_billing_rule
												,ls_validated_payment_method
												,ls_validated_fa_function
												,ls_validated_spon_prog_type
												,ls_validation_comments
												,ls_validated_rcc
												,ls_validated_fa_rate
												,ls_validated_location
												,ls_validated_val_end_date
												);
            CALL jhu_sap_awd_update_proc_invoke(ls_coeus_award_number
											, 0
												,ls_sponsored_program_number
												,ls_award_id
												,li_coeus_status
												,li_template_code
												,ls_validated_start_date
												,ls_validated_end_date
												,ls_validated_sponsor_code
												,ld_coeus_update_timestamp
												,ls_proposal_number
												,ls_validated_title
												,ls_validated_award_type
												,li_validated_obligated
												,li_validated_anticipated
												,ls_validated_val_start_date
												,ls_cfda_number
												,ls_sub_award_flag
												,ls_validated_sponsor_prime_code
												,ls_validated_billing_rule
												,ls_validated_payment_method
												,ls_validated_fa_function
												,ls_validated_spon_prog_type
												,ls_validation_comments
												,ls_validated_rcc
												,ls_validated_fa_rate
												,ls_validated_location
												,ls_validated_val_end_date
												);
						DELETE FROM coeus_award_update_log
						WHERE TRIM(AWARD_NUMBER) = TRIM(ls_coeus_award_number);
               END LOOP;
			CLOSE award_cur;
            end;
		   CALL jhu_sap_awd_upd_proposal_tb(ld_coeus_update_timestamp);
		  COMMIT;
	END
$$
DELIMITER ;
