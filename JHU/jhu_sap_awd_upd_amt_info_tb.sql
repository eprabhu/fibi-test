DELIMITER $$
CREATE  PROCEDURE `jhu_sap_awd_upd_amt_info_tb`(av_award_id DECIMAL(22,0)
									  ,av_award_number VARCHAR(12)
									  ,av_sequence_number INT(4)
									  ,av_obligated  DECIMAL(12,2)
									  ,av_anticipated  DECIMAL(12,2)
									  ,av_start_date VARCHAR(10)
									  ,av_end_date VARCHAR(10)
									  ,av_update_timestamp  DATE
									  )
BEGIN
	DECLARE ls_coeus_transaction_id VARCHAR(22) DEFAULT NULL;
	DECLARE li_award_amount_info_count INT(4) DEFAULT NULL;
	DECLARE li_expiration_date_count INT(4) DEFAULT NULL;
	DECLARE li_current_amount_sequence_number INT(4) DEFAULT 0;
	DECLARE li_current_anticipated DECIMAL(12,2) DEFAULT 0;
	DECLARE li_current_obligated DECIMAL(12,2) DEFAULT 0;
	DECLARE ld_current_obli_exp_date DATE DEFAULT NULL;
	DECLARE ld_current_start_date DATE DEFAULT NULL;
	DECLARE ld_current_end_date DATE DEFAULT NULL;
	DECLARE li_coeus_anticipated DECIMAL(12,2) DEFAULT av_anticipated;
	DECLARE li_coeus_obli_distrib_amount DECIMAL(12,2) DEFAULT 0;
	DECLARE ld_coeus_obli_expiration_date DATE DEFAULT DATE_FORMAT(av_end_date, '%Y-%m-%d');
	DECLARE li_coeus_ant_total_direct DECIMAL(12,2) DEFAULT 0;
	DECLARE li_coeus_ant_total_indirect DECIMAL(12,2) DEFAULT 0;
	DECLARE li_coeus_obl_total_direct DECIMAL(12,2) DEFAULT 0;
	DECLARE li_coeus_obl_total_indirect DECIMAL(12,2) DEFAULT 0;
	DECLARE li_current_ant_total_direct DECIMAL(12,2) DEFAULT 0;
	DECLARE li_current_ant_total_indirect DECIMAL(12,2) DEFAULT 0;
	DECLARE li_current_obl_total_direct DECIMAL(12,2) DEFAULT 0;
	DECLARE li_current_obl_total_indirect DECIMAL(12,2) DEFAULT 0;
	DECLARE li_award_amount_info_id DECIMAL(22,0);
	DECLARE li_award_amount_transaction_id	decimal(12,0);
	declare ls_error_msg varchar(4000);
	DECLARE LI_MAX_TRANS_ID BIGINT;
	DECLARE LI_TRNSCTN_HISTRY_ID BIGINT;
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
		BEGIN
			GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
			 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
			SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
			SELECT @full_error INTO LS_ERROR_MSG;
            insert into integration_error_log (SECTION, ERROR_MESSAGE, AWARD_NUMBER, sequence_number)
				values('AWARD AMOUNT INFO', LS_ERROR_MSG, av_award_number, av_sequence_number);
			-- select concat(LS_ERROR_MSG,'awd_amount_info: ',av_award_number, ' - ' , av_sequence_number) from dual;
		END;
    SET SQL_SAFE_UPDATES= 0;
	DELETE FROM award_amt_fna_distribution
	WHERE AWARD_NUMBER = av_award_number
	AND   sequence_number = av_sequence_number;
	SELECT COUNT(*)
	INTO li_award_amount_info_count
	FROM award_amount_info
	WHERE award_number = av_award_number
	AND sequence_number = av_sequence_number;
	SELECT COUNT(*)
	INTO li_expiration_date_count
	FROM sap_grant_award
	WHERE grant_number = SUBSTR(av_award_number, 1, 6)
	AND DATE_FORMAT(GRANT_BUDGET_START_DATE, '%Y-%m-%d') <= DATE_FORMAT(UTC_TIMESTAMP(), '%Y-%m-%d')
	AND DATE_FORMAT(GRANT_BUDGET_END_DATE,  '%Y-%m-%d') >= DATE_FORMAT(UTC_TIMESTAMP(), '%Y-%m-%d');
	IF ((av_award_number LIKE '%00001') AND (li_expiration_date_count > 0)) THEN
	  SELECT MAX(DATE_FORMAT(GRANT_BUDGET_END_DATE,  '%Y-%m-%d'))
	  INTO   ld_coeus_obli_expiration_date
	  FROM   sap_grant_award
	  WHERE grant_number = SUBSTR(av_award_number, 1, 6)
	  AND DATE_FORMAT(GRANT_BUDGET_START_DATE, '%Y-%m-%d') <= DATE_FORMAT(UTC_TIMESTAMP(), '%Y-%m-%d')
	  AND DATE_FORMAT(GRANT_BUDGET_END_DATE,  '%Y-%m-%d') >= DATE_FORMAT(UTC_TIMESTAMP(), '%Y-%m-%d');
	  SELECT SUM(CAST(grant_budget_direct as DECIMAL(12,2)))
	  INTO   li_coeus_ant_total_direct
	  FROM   sap_grant_award
	  WHERE grant_number = SUBSTR(av_award_number, 1, 6);
	  SELECT SUM(CAST(grant_budget_indirect  as DECIMAL(12,2)))
	  INTO   li_coeus_ant_total_indirect
	  FROM   sap_grant_award
	  WHERE grant_number = SUBSTR(av_award_number, 1, 6);
	  SELECT SUM(CAST(grant_budget_direct  as DECIMAL(12,2)))
	  INTO   li_coeus_obl_total_direct
	  FROM   sap_grant_award
	  WHERE grant_number = SUBSTR(av_award_number, 1, 6)
	  AND   (DATE_FORMAT(grant_budget_start_date, '%Y-%m-%d')) <= DATE_FORMAT(UTC_TIMESTAMP(), '%Y-%m-%d');
	  SELECT SUM(CAST(grant_budget_indirect  as DECIMAL(12,2) ))
	  INTO   li_coeus_obl_total_indirect
	  FROM   sap_grant_award
	  WHERE grant_number = SUBSTR(av_award_number, 1, 6)
	  AND   (DATE_FORMAT(grant_budget_start_date, '%Y-%m-%d')) <= DATE_FORMAT(UTC_TIMESTAMP(), '%Y-%m-%d');
	END IF;
	IF (av_award_number NOT LIKE '%00001') THEN
		SET li_coeus_obli_distrib_amount = av_obligated;
	END IF;
	IF (av_sequence_number in(0, 1) and li_award_amount_info_count = 0) THEN
				/*SELECT IFNULL(MAX(AWARD_AMOUNT_TRANSACTION_ID),0)+1 INTO LI_AWARD_AMOUNT_TRANSACTION_ID
				FROM AWARD_AMOUNT_TRANSACTION;*/
			    SET ls_coeus_transaction_id = CONCAT(DATE_FORMAT(NOW(),'%y%d%m'), DATE_FORMAT(NOW(6),'%f'),av_award_id);
				INSERT INTO  AWARD_AMOUNT_TRANSACTION(-- AWARD_AMOUNT_TRANSACTION_ID,
													AWARD_NUMBER,
													TRANSACTION_ID,
													TRANSACTION_TYPE_CODE,
													COMMENTS,
													SOURCE_AWARD_NUMBER,
													DESTINATION_AWARD_NUMBER,
                                                    TRANSACTION_STATUS_CODE,
													UPDATE_TIMESTAMP,
													UPDATE_USER)
				VALUES(-- LI_AWARD_AMOUNT_TRANSACTION_ID,
						av_award_number,
						ls_coeus_transaction_id,
						3,
						'Migrated Award',
						'EXTERNAL',
						av_award_number,
                        'A',
						utc_timestamp(),
						'INTRFACE'
				);
				COMMIT;
			/*			SELECT IFNULL(MAX(award_amount_info_id),0) +1 INTO li_award_amount_info_id
		      FROM award_amount_info;*/
			  INSERT INTO award_amount_info (-- award_amount_info_id,
												award_id,award_number
												,sequence_number
												,anticipated_total_amount
												,ant_distributable_amount
												,final_expiration_date
												,current_fund_effective_date
												,amount_obligated_to_date
												,obli_distributable_amount
												,obligation_expiration_date
												,transaction_id
												,anticipated_change
												,obligated_change
												,obligated_change_direct
												,obligated_change_indirect
												,anticipated_change_direct
												,anticipated_change_indirect
												,anticipated_total_direct
												,anticipated_total_indirect
												,obligated_total_direct
												,obligated_total_indirect
												,update_timestamp
												,update_user
												)
			  VALUES (-- li_award_amount_info_id,
					 av_award_id,av_award_number
					 ,av_sequence_number
					 ,li_coeus_anticipated
					 ,0
					 ,DATE_FORMAT(av_end_date, '%Y-%m-%d')
					 ,DATE_FORMAT(av_start_date, '%Y-%m-%d')
					 ,av_obligated
					 ,li_coeus_obli_distrib_amount
					 ,ld_coeus_obli_expiration_date
					 ,ls_coeus_transaction_id
					 ,0
					 ,0
					 ,0
					 ,0
					 ,0
					 ,0
					 ,li_coeus_ant_total_direct
					 ,li_coeus_ant_total_indirect
					 ,li_coeus_obl_total_direct
					 ,li_coeus_obl_total_indirect
					 ,av_update_timestamp
					 ,'INTRFACE'
					 ); COMMIT;
	ELSE
					  SELECT max(sequence_number)
					  INTO li_current_amount_sequence_number
					  FROM award_amount_info
					  WHERE award_number = av_award_number
					  AND sequence_number = av_sequence_number;
					  IF li_current_amount_sequence_number IS NULL THEN
						SET li_current_amount_sequence_number = 1;
					  END IF;
					  SELECT a.anticipated_total_amount
							,a.amount_obligated_to_date
							,TRIM(a.obligation_expiration_date)
							,TRIM(a.current_fund_effective_date)
							,TRIM(a.final_expiration_date)
							,a.anticipated_total_direct
							,a.anticipated_total_indirect
							,a.obligated_total_direct
							,a.obligated_total_indirect
					  INTO li_current_anticipated
						  ,li_current_obligated
						  ,ld_current_obli_exp_date
						  ,ld_current_start_date
						  ,ld_current_end_date
						  ,li_current_ant_total_direct
						  ,li_current_ant_total_indirect
						  ,li_current_obl_total_direct
						  ,li_current_obl_total_indirect
					  FROM award_amount_info a
					  WHERE a.award_number = av_award_number
					  AND a.transaction_id = (SELECT MAX(transaction_id)
											  FROM award_amount_info
											  WHERE award_number = a.award_number);
					  IF (li_current_anticipated  <>  li_coeus_anticipated OR
						 li_current_obligated  <>  av_obligated OR
						 li_current_ant_total_direct  <>  li_coeus_ant_total_direct OR
						 li_current_ant_total_indirect  <>  li_coeus_ant_total_indirect OR
						 li_current_obl_total_direct  <>  li_coeus_obl_total_direct OR
						 li_current_obl_total_indirect  <>  li_coeus_obl_total_indirect OR
						 ld_current_start_date IS NULL OR
						 ld_current_end_date IS NULL OR
						 TRIM(DATE_FORMAT(ld_current_obli_exp_date, '%Y-%m-%d'))  <>  DATE_FORMAT(ld_coeus_obli_expiration_date, '%Y-%m-%d') OR
						 TRIM(DATE_FORMAT(av_start_date, '%Y-%m-%d'))  <>  DATE_FORMAT(ld_current_start_date, '%Y-%m--%d') OR
						 TRIM(DATE_FORMAT(av_end_date, '%Y-%m-%d'))  <>  DATE_FORMAT(ld_current_end_date, '%Y-%m-%d'))  THEN
-- SET ls_coeus_transaction_id = CONCAT(DATE_FORMAT(NOW(),'%y%d%m'), DATE_FORMAT(NOW(6),'%f'),av_award_id);
 IF av_sequence_number > 0 THEN
									/*SELECT IFNULL(MAX(AWARD_AMOUNT_TRANSACTION_ID),0)+1 INTO LI_AWARD_AMOUNT_TRANSACTION_ID
									FROM AWARD_AMOUNT_TRANSACTION;*/
									 SET ls_coeus_transaction_id = CONCAT(DATE_FORMAT(NOW(),'%y%d%m'), DATE_FORMAT(NOW(6),'%f'),av_award_id);
									INSERT INTO  AWARD_AMOUNT_TRANSACTION(-- AWARD_AMOUNT_TRANSACTION_ID,
																		AWARD_NUMBER,
																		TRANSACTION_ID,
																		TRANSACTION_TYPE_CODE,
																		COMMENTS,
																		SOURCE_AWARD_NUMBER,
																		DESTINATION_AWARD_NUMBER,
                                                                        TRANSACTION_STATUS_CODE,
																		UPDATE_TIMESTAMP,
																		UPDATE_USER)
									VALUES(-- LI_AWARD_AMOUNT_TRANSACTION_ID,
											av_award_number,
											ls_coeus_transaction_id,
											3,
											'Migrated Award',
											'EXTERNAL',
											av_award_number,
                                            'A',
											utc_timestamp(),
											'INTRFACE'
									);
									COMMIT;
									/*SELECT IFNULL(MAX(award_amount_info_id),0) +1 INTO li_award_amount_info_id
									FROM award_amount_info;*/
									INSERT INTO award_amount_info (/*award_amount_info_id
																	,*/ award_number
																	  ,sequence_number
																		, award_id
																	  ,anticipated_total_amount
																	  ,ant_distributable_amount
																	  ,final_expiration_date
																	  ,current_fund_effective_date
																	  ,amount_obligated_to_date
																	  ,obli_distributable_amount
																	  ,obligation_expiration_date
																	  ,transaction_id
																	  ,anticipated_change
																	  ,obligated_change
																	  ,obligated_change_direct
																	  ,obligated_change_indirect
																	  ,anticipated_change_direct
																	  ,anticipated_change_indirect
																	  ,anticipated_total_direct
																	  ,anticipated_total_indirect
																	  ,obligated_total_direct
																	  ,obligated_total_indirect
																	  ,update_timestamp
																	  ,update_user
																	  )
									VALUES (/*li_award_amount_info_id
											,*/ av_award_number
										   ,av_sequence_number
										,av_award_id
										   ,li_coeus_anticipated
										   ,0
										   ,DATE_FORMAT(av_end_date, '%Y-%m-%d')
										   ,DATE_FORMAT(av_start_date, '%Y-%m-%d')
										   ,av_obligated
										   ,li_coeus_obli_distrib_amount
										   ,ld_coeus_obli_expiration_date
										   ,ls_coeus_transaction_id
										   ,(IFNULL(av_anticipated,0) - IFNULL(li_current_anticipated,0))
										   ,(IFNULL(av_obligated ,0)- IFNULL(li_current_obligated,0))
										   ,(IFNULL(li_coeus_obl_total_direct,0) - IFNULL(li_current_obl_total_direct,0))
										   ,(IFNULL(li_coeus_obl_total_indirect,0) - IFNULL(li_current_obl_total_indirect,0))
										   ,(IFNULL(li_coeus_ant_total_direct,0) - IFNULL(li_current_ant_total_direct,0))
										   ,(IFNULL(li_coeus_ant_total_indirect,0) - IFNULL(li_current_ant_total_indirect,0))
										   ,li_coeus_ant_total_direct
										   ,li_coeus_ant_total_indirect
										   ,li_coeus_obl_total_direct
										   ,li_coeus_obl_total_indirect
										   ,av_update_timestamp
										   ,'INTRFACE'
										   ); COMMIT;
END IF;
					  END IF;
	END IF;
IF av_sequence_number > 0 THEN
select max(transaction_id) into LI_MAX_TRANS_ID from award_amount_info
 WHERE award_id = av_award_id
and  award_number = av_award_number
and sequence_number = av_sequence_number;
delete from award_amt_trnsctn_history
where   award_id = av_award_id
and  award_number = av_award_number
and sequence_number = av_sequence_number;
INSERT INTO award_amt_trnsctn_history(
										/*TRNSCTN_HISTORY_ID
                                        , */ TRANSACTION_ID
                                        , UPDATE_TIMESTAMP
                                        , UPDATE_USER
                                        , AWARD_ID
                                        , AWARD_NUMBER
                                        , SEQUENCE_NUMBER
                                    )Value(
										/*LI_TRNSCTN_HISTRY_ID
										, */ LI_MAX_TRANS_ID
										, utc_timestamp()
										, 'INTRFACE'
										, av_award_id
										, av_award_number
										, av_sequence_number
                                        );
				END IF;
-- UPDATE AWARD_AMOUNT_INFO_ID_GENERATOR SET NEXT_VAL = (SELECT IFNULL(MAX(AWARD_AMOUNT_INFO_ID),0)+1   FROM AWARD_AMOUNT_INFO);
-- UPDATE AWARD_AMOUNT_TRANSACTION_ID_GENERATOR  SET NEXT_VAL = (SELECT IFNULL(MAX(AWARD_AMOUNT_TRANSACTION_ID),0)+1   FROM AWARD_AMOUNT_TRANSACTION);
-- UPDATE SEQ_AWD_AMT_TRNSCTN_HSTRY_ID_GNRTR set NEXT_VAL = (select IFNULL(max(TRNSCTN_HISTORY_ID),0)+1 from award_amt_trnsctn_history);
COMMIT;
END
$$
DELIMITER ;
