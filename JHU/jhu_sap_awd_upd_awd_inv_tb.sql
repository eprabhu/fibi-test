DELIMITER $$
CREATE  PROCEDURE `jhu_sap_awd_upd_awd_inv_tb`(av_award_id   INT
  ,av_award_number VARCHAR(12)
  ,av_sequence_number INT(4)
  ,av_sponsored_program_number VARCHAR(8)
  ,av_update_timestamp  DATE
  ,av_validation_comments LONGTEXT
  )
BEGIN
    DECLARE ls_coeus_person_name VARCHAR(90) DEFAULT NULL;
	DECLARE ls_coeus_pi_flag VARCHAR(1) DEFAULT 'N';
	DECLARE ls_coeus_non_mit_person_flag VARCHAR(1) DEFAULT 'N';
	DECLARE ls_coeus_faculty_flag VARCHAR(1) DEFAULT NULL;
	DECLARE li_coeus_pi_count INT(3) DEFAULT 0;
	DECLARE li_pi_row_count INT(3) DEFAULT 0;
	DECLARE ls_sap_grant_number VARCHAR(6) DEFAULT SUBSTR(av_award_number, 1, 6);
    DECLARE DONE1 INT DEFAULT FALSE;
	DECLARE ls_error_msg varchar(4000);
	DECLARE li_sequence_number int;
	DECLARE li_PI_PERSON DECIMAL(22,0);
    DECLARE li_parent_award_id DECIMAL(22,0);
	DECLARE li_award_person_id DECIMAL(22,0);
	DECLARE ls_responsibility_code VARCHAR(4);
	DECLARE ls_person_id VARCHAR(40);
	DECLARE ls_full_name VARCHAR(200);
	DECLARE ls_is_faculty VARCHAR(1);
    DECLARE ls_email_address VARCHAR(60);
  	DECLARE LI_COUNT int;
	DECLARE pi_cur CURSOR FOR
	 SELECT distinct T.person_id,T.full_name,T.responsibility_code,T.is_faculty,T.EMAIL_ADDRESS
	FROM (SELECT p.person_id AS person_id
					,p.full_name AS full_name
					,gp.responsibility_code AS responsibility_code
					,p.is_faculty AS is_faculty
					,p.EMAIL_ADDRESS as EMAIL_ADDRESS
			  FROM sap_grant_person gp
			  INNER JOIN person p  ON gp.person_id = p.person_id
			  WHERE gp.grant_number = ls_sap_grant_number
			  AND gp.responsibility_code IN ('PRIN', 'COIN')
	  UNION
		  SELECT p.person_id  AS person_id
				,p.full_name  AS full_name
				,spp.responsibility_code AS  responsibility_code
				,p.is_faculty AS  is_faculty
				,p.EMAIL_ADDRESS as EMAIL_ADDRESS
		  FROM sap_sponsored_program_person spp
		  INNER JOIN person p ON spp.person_id = p.person_id
		  WHERE spp.sponsored_program_number = av_sponsored_program_number
		  AND spp.responsibility_code IN ('PRIN', 'COIN'))T
	ORDER BY T.person_id ;
	  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
		BEGIN
			GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
			 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
			SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
			SELECT @full_error INTO LS_ERROR_MSG;
            insert into integration_error_log (SECTION, ERROR_MESSAGE, AWARD_NUMBER, sequence_number)
				values('AWARD INVESTIGATOR', LS_ERROR_MSG, av_award_number, av_sequence_number);
		END;
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE1 = TRUE;
  SET SQL_SAFE_UPDATES= 0;
  BEGIN
	DELETE from award_person_unit
    where award_person_id in(select award_person_id FROM award_persons
						WHERE award_number = av_award_number
						AND sequence_number = av_sequence_number
						AND person_role_id IN (1,3)) ;
	DELETE FROM award_persons
	WHERE award_number = av_award_number
	AND sequence_number = av_sequence_number
	AND person_role_id IN (1,3) ;
    DELETE from award_person_unit
    where award_person_id in(select award_person_id FROM award_persons
						WHERE award_number = av_award_number
						AND sequence_number = 0
						AND person_role_id IN (1,3)) ;
	DELETE FROM award_persons
	WHERE award_number = av_award_number
	AND sequence_number = 0
	AND person_role_id IN (1,3) ;
    SELECT max(sequence_number) INTO li_sequence_number
	FROM award
	WHERE award_number = av_award_number;
	IF (av_sponsored_program_number IS NOT NULL) THEN
	  SET ls_sap_grant_number = 'XXXXXX';
	END IF;
	OPEN pi_cur;
		pi_cur_loop : LOOP
				FETCH pi_cur INTO ls_person_id,ls_full_name,ls_responsibility_code,ls_is_faculty,ls_email_address;
				IF DONE1 THEN
					LEAVE pi_cur_loop;
				END IF;
				  INSERT INTO award_persons (award_id
													  ,award_number
													  ,sequence_number
													  ,person_id
													  ,full_name
													  ,pi_flag
													  ,is_multi_pi
													  ,update_timestamp
													  ,update_user
													  ,person_role_id
													  ,PERCENTAGE_OF_EFFORT
											          ,EMAIL_ADDRESS)
				  VALUES(av_award_id
						,av_award_number
						,av_sequence_number
						,ls_person_id
						,ls_full_name
						,REPLACE(REPLACE(ls_responsibility_code, 'PRIN', 'Y'), 'COIN', 'N')
						,'N'
						 ,av_update_timestamp
						,'INTRFACE'
						,REPLACE(REPLACE(ls_responsibility_code, 'PRIN', 3), 'COIN',1)
						,NULL
						,ls_email_address
						); COMMIT;
				  IF ls_responsibility_code = 'PRIN' THEN
					SET li_pi_row_count = li_pi_row_count + 1;
				  END IF;
			END LOOP;
	CLOSE pi_cur;
	IF av_sponsored_program_number IS NULL THEN
		  INSERT INTO award_persons (person_id
											  ,award_number
                                              ,award_id
											  ,sequence_number
											  ,full_name
											  ,pi_flag
											  ,is_multi_pi
											  ,update_timestamp
											  ,update_user
											  ,person_role_id
											  ,PERCENTAGE_OF_EFFORT
											  ,EMAIL_ADDRESS)
          SELECT DISTINCT
				(spp.person_id)
				,av_award_number
                ,av_award_id
				,av_sequence_number
				,p.full_name
				,'N'
				,'N'
				,av_update_timestamp
				,'INTRFACE'
				,1
				,NULL
				,p.EMAIL_ADDRESS
		  FROM sap_sponsored_program_person spp
		  INNER JOIN  person p ON spp.person_id = p.person_id
		  WHERE spp.sponsored_program_number IN (select sponsored_program_number
												 FROM   sap_sponsored_program
												 WHERE  grant_number = ls_sap_grant_number)
		  AND   spp.person_id NOT IN (SELECT person_id
									  FROM   award_persons
									  WHERE  award_number = av_award_number
                                     )
		  AND   spp.responsibility_code IN ('PRIN', 'COIN') ;
          COMMIT;
 	END IF;
	IF li_pi_row_count > 1 THEN
		  UPDATE award_persons ai
		  SET    ai.IS_MULTI_PI = 'Y'
		  WHERE  ai.award_number = av_award_number
		  AND    ai.sequence_number = av_sequence_number
		  AND    ai.PI_FLAG = 'Y'
		  AND    ai.person_role_id IN (1,3);
          COMMIT;
		   SELECT MIN(ap.person_id) into li_PI_PERSON
								  FROM award_persons ap
								  WHERE ap.award_number = av_award_number
								  AND   ap.sequence_number = av_sequence_number
								  AND   ap.IS_MULTI_PI = 'Y'
								  AND   ap.person_role_id IN (1,3);
		  UPDATE award_persons ai
		  SET    ai.PI_FLAG = 'N', ai.person_role_id = 1
		  WHERE  ai.award_number = av_award_number
		  AND    ai.sequence_number = av_sequence_number
		  AND    ai.person_id <> li_PI_PERSON
		   AND    ai.person_role_id IN (1,3);
		   COMMIT;
	ELSEIF li_pi_row_count < 1 THEN
		  SET av_validation_comments = CONCAT(av_validation_comments,'PI information was not sent from SAP\nhi');
		  INSERT INTO award_persons (person_id
											  ,award_number
                                              ,award_id
											  ,sequence_number
											  ,full_name
											  ,pi_flag
											  ,is_multi_pi
											  ,update_timestamp
											  ,update_user
											  ,person_role_id
											  ,PERCENTAGE_OF_EFFORT
											  ,EMAIL_ADDRESS)
		  SELECT p.person_id
				,av_award_number
                ,av_award_id
				,av_sequence_number
				,p.full_name
				,'Y'
				,'N'
				,av_update_timestamp
				,'INTRFACE'
				,3
				,NULL
				,EMAIL_ADDRESS
		  FROM  person p
		  WHERE p.person_id = '99999880';
		  COMMIT;
	END IF;
COMMIT;
END;
END
$$
DELIMITER ;
