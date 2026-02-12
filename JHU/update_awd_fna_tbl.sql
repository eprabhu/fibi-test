DELIMITER $$
CREATE  PROCEDURE `update_awd_fna_tbl`(av_grant_number  VARCHAR(12)
                                    ,av_sequence_number  INT(4)
                                    ,av_coeus_update_timestamp  DATE
                                    )
BEGIN
DECLARE ls_validation_comments LONGTEXT;
DECLARE li_fna_budget_period_counter INT(3) DEFAULT 0;
DECLARE li_fna_sequence_number INT(4) DEFAULT 1;
DECLARE li_fna_amount_sequence_number INT(4) DEFAULT 1;
DECLARE DONE1 INT DEFAULT FALSE;
DECLARE ls_grant_number varchar(6);
DECLARE ls_budget_period varchar(4);
DECLARE li_coeus_period int(3);
DECLARE ld_effective_date varchar(10);
DECLARE ls_direct_cost varchar(15);
DECLARE ls_indirect_cost varchar(15);
DECLARE ls_start_date varchar(8);
DECLARE ls_end_date varchar(8);
DECLARE ls_grant_award_action varchar(20);
  DECLARE  fna_cur CURSOR FOR
	  SELECT TRIM(concat(g.grant_number,'-001')) AS grant_number,
			 cast(TRIM(g.award_year) as decimal)  AS budget_period,
			 g.coeus_period AS  coeus_period,
			 TRIM(g.award_effective_date)  AS effective_date,
			 ROUND((cast(REPLACE(REPLACE(g.grant_budget_direct, '$',''), ',','') as decimal(12,2)) * 100) / 100) AS  direct_cost,
			 ROUND((cast(REPLACE(REPLACE(g.grant_budget_indirect, '$',''), ',','')as decimal(12,2)) * 100) / 100)  AS indirect_cost,
			 TRIM(g.grant_budget_start_date) AS  start_date,
			 TRIM(g.grant_budget_end_date)  AS end_date,
			 TRIM(g.grant_award_action)  AS grant_award_action
	  FROM sap_grant_award g INNER JOIN  sap_sponsored_program s ON  g.grant_number = s.grant_number
	  WHERE g.grant_number = SUBSTR(av_grant_number, 1, 6)
	  AND   s.sponsored_program_type = 'PM'
	  ORDER BY grant_number, grant_budget_start_date, grant_budget_end_date;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE1 = TRUE;
  BEGIN
	IF av_sequence_number <> 1 THEN
	  SELECT MAX(sequence_number)
	  INTO   li_fna_sequence_number
	  FROM   award_amount_info
	  WHERE  award_number = av_grant_number;
	END IF;
	DELETE FROM award_amt_fna_distribution
	WHERE mit_award_number = av_grant_number
	AND   sequence_number >= li_fna_sequence_number;
			OPEN fna_cur;
			fna_cur_loop : LOOP
					FETCH fna_cur INTO ls_grant_number,
										ls_budget_period ,
										li_coeus_period,
										ld_effective_date,
										ls_direct_cost,
										ls_indirect_cost,
										ls_start_date,
										ls_end_date,
										ls_grant_award_action;
					IF DONE1 THEN
						LEAVE fna_cur_loop;
					END IF;
					  IF (ls_start_date IS NULL OR TRIM(ls_start_date) = '19000101') THEN
						SET ls_validation_comments = CONCAT(ls_validation_comments ,'The AYB tab Budget Begin Date is invalid\n');
					  END IF;
					  IF (ls_end_date IS NULL OR TRIM(ls_end_date) = '19000101')THEN
						SET ls_validation_comments = CONCAT(ls_validation_comments , 'The AYB tab Budget End Date is invalid\n');
					  END IF;
					  SELECT count(*)
					  INTO li_fna_amount_sequence_number
					  FROM award_amount_info
					  WHERE award_number = av_grant_number
					  AND   sequence_number = li_fna_sequence_number;
					  IF li_fna_amount_sequence_number IS NULL THEN
						SET li_fna_amount_sequence_number = 1;
					  ELSE
						SET li_fna_amount_sequence_number = li_fna_amount_sequence_number;
					  END IF;
					  SET li_fna_budget_period_counter = li_fna_budget_period_counter + 1;
					  INSERT INTO award_amt_fna_distribution (mit_award_number
																 ,sequence_number
																 ,amount_sequence_number
																 ,budget_period
																 ,start_date
																 ,end_date
																 ,direct_cost
																 ,indirect_cost
																 ,update_timestamp
																 ,update_user
																 )
					  VALUES (av_grant_number
							 ,li_fna_sequence_number
							 ,li_fna_amount_sequence_number
							 ,li_coeus_period
							 ,date_format(ls_start_date, 'YYYY-MM-DD')
							 ,date_format(ls_end_date, 'YYYY-MM-DD')
							 ,ls_direct_cost
							 ,ls_indirect_cost
							 ,av_coeus_update_timestamp
							 ,'INTRFACE'
							 );
               END LOOP;
			CLOSE fna_cur;
  END;
END
$$
DELIMITER ;
