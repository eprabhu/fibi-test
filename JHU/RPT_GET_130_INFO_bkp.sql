DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `RPT_GET_130_INFO_bkp`( IN report_start_date VARCHAR(50)
                                               ,IN report_end_date   VARCHAR(50)
                                               ,IN report_unit       VARCHAR(8))
BEGIN
	DECLARE  unit_count INT(3) DEFAULT 0;
	SELECT count(1)
	INTO   unit_count
	FROM   DUAL
	WHERE  find_in_set(report_unit,fn_get_temp_unit('som'));
	IF unit_count = 0  THEN
		SELECT 	 null PROPOSAL_NUMBER
				,null SAP_GRANT_NUMBER
				,null PROPOSAL_SUBMISSION_DATE
				,'This report is for School of Medicine units only.' PROJECT_UNIT
				,null PROPOSAL_STATUS
				,null AWARD_STATUS
				,null PROPOSAL_TITLE
				,null PROJECT_PI
				,null SPONSOR_NAME
				,null PROJECT_START_DATE
				,null PROJECT_END_DATE
				,null PROJECT_AMOUNT
				,null PROTOCOL_NUMBER
				,null PROTOCOL_TITLE
				,null PROTOCOL_PI
				,null PROTOCOL_STATUS
				,null PROTOCOL_EXPIRATION_DATE
				,null IRB_SCHOOL
				,null IRB_VALIDITY
				,null REPORT_NUMBER
				,null REPORT_TITLE
				,report_unit PARAMETER_ENTETRED_1
				,report_start_date PARAMETER_ENTETRED_2
				,report_end_date PARAMETER_ENTETRED_3
				,SYSDATE() RUN_TIME
				,@@hostname as HOST_NAME
        FROM DUAl;
	ELSE
	    SELECT   p.proposal_number PROPOSAL_NUMBER
				,SUBSTR(a.award_number, 1, 6) SAP_GRANT_NUMBER
				,DATE_FORMAT(p.create_timestamp, '%m/%d/%Y') PROPOSAL_SUBMISSION_DATE
				,CONCAT(au.unit_number, ':  ', u.unit_name) PROJECT_UNIT
				,ps.description PROPOSAL_STATUS
				,aws.description AWARD_STATUS
				,p.title PROPOSAL_TITLE
				,apr.full_name PROJECT_PI
				,s.sponsor_name SPONSOR_NAME
				,DATE_FORMAT(a.begin_date, '%m/%d/%Y') PROJECT_START_DATE
				,DATE_FORMAT(aai.final_expiration_date, '%m/%d/%Y') PROJECT_END_DATE
				,(aai.ANTICIPATED_TOTAL_DIRECT + ANTICIPATED_TOTAL_INDIRECT) PROJECT_AMOUNT
				,UPPER(TRIM(IFNULL(asr.protocol_number, 'Not Yet Applied'))) PROTOCOL_NUMBER
				,i.title PROTOCOL_TITLE
				,i.full_name PROTOCOL_PI
				,i.status PROTOCOL_STATUS
				,DATE_FORMAT(i.expiration_date, '%m/%d/%Y') PROTOCOL_EXPIRATION_DATE
				,JHU_GET_IRB_SCHOOL(UPPER(TRIM(asr.protocol_number))) IRB_SCHOOL
				,JHU_GET_IRB_VALIDITY(UPPER(TRIM(asr.protocol_number))) IRB_VALIDITY
				,'330e' REPORT_NUMBER
				,'Proposals with Human Subjects' REPORT_TITLE
				,report_unit PARAMETER_ENTETRED_1
				,report_start_date PARAMETER_ENTETRED_2
				,report_end_date PARAMETER_ENTETRED_3
				,SYSDATE() RUN_TIME
				,@@hostname HOST_NAME
        FROM     proposal p
				LEFT JOIN award_funding_proposals afp ON afp.PROPOSAL_ID=p.PROPOSAL_ID
				LEFT JOIN award a ON a.AWARD_ID = afp.AWARD_ID
												AND    a.sequence_number = (SELECT MAX(sequence_number)
																			  FROM   award
																			  WHERE  award_number = a.award_number)
				LEFT JOIN award_persons ai ON ai.AWARD_ID=a.AWARD_ID
				LEFT JOIN award_person_unit au ON au.AWARD_PERSON_ID = ai.AWARD_PERSON_ID
												AND find_in_set(au.unit_number,fn_get_temp_unit(report_unit))
												AND au.sequence_number = (SELECT MAX(sequence_number)
																			   FROM   award_person_unit
																			   WHERE  award_number = au.award_number)
				LEFT JOIN award_amount_info aai ON  aai.award_number = a.award_number
												AND  aai.sequence_number = (SELECT MAX(sequence_number)
																				FROM   award_amount_info
																				WHERE  award_number = aai.award_number)
												AND  	aai.AWARD_AMOUNT_INFO_ID= (select max(AWARD_AMOUNT_INFO_ID)
												   from award_amount_info
												   where award_number=aai.award_number
												   and SEQUENCE_NUMBER=aai.SEQUENCE_NUMBER)
				 JOIN award_special_review asr ON asr.award_number = a.award_number
													AND    asr.sequence_number = (SELECT MAX(sequence_number)
																					FROM   award_special_review
																					WHERE  award_number = asr.award_number)
													AND    asr.special_review_code = 1
				LEFT JOIN proposal_status ps ON ps.status_code = p.status_code
				LEFT JOIN award_status aws ON aws.status_code = a.status_code
				LEFT JOIN sponsor s ON s.sponsor_code = a.sponsor_code
				                    AND  s.sponsor_code = p.sponsor_code
				LEFT JOIN unit u ON u.unit_number = au.unit_number
				LEFT JOIN person apr ON  apr.person_id = ai.person_id
				LEFT OUTER JOIN(  SELECT ii.protocol_number
										,ii.title
										,ii.status
										,ii.expiration_date
										,ipr.full_name
									FROM   irb_report ii
										,person ipr
									WHERE  UPPER(ii.PI_USER_NAME) = UPPER(ipr.user_name)) i ON i.protocol_number =TRIM(asr.protocol_number)
        WHERE   DATE(p.create_timestamp) >= STR_TO_DATE(report_start_date, '%m/%d/%Y')
				AND   DATE(p.create_timestamp) <= STR_TO_DATE(report_end_date, '%m/%d/%Y')
				AND   p.status_code = 2
				AND   p.type_code IN (1, 4, 5, 6, 9)
				AND   p.sequence_number = (SELECT MAX(sequence_number)
											  FROM   proposal
											  WHERE  proposal_number = p.proposal_number)
				AND    au.lead_unit_flag = 'Y'
		UNION
		SELECT   p.proposal_number PROPOSAL_NUMBER
				,SUBSTR(a.award_number, 1, 6) SAP_GRANT_NUMBER
				,DATE_FORMAT(p.create_timestamp, '%m/%d/%Y') PROPOSAL_SUBMISSION_DATE
				,CONCAT(au.unit_number, ':  ', u.unit_name) PROJECT_UNIT
				,ps.description PROPOSAL_STATUS
				,aws.description AWARD_STATUS
				,p.title PROPOSAL_TITLE
				,apr.full_name PROJECT_PI
				,s.sponsor_name SPONSOR_NAME
				,DATE_FORMAT(a.begin_date, '%m/%d/%Y') PROJECT_START_DATE
				,DATE_FORMAT(aai.final_expiration_date, '%m/%d/%Y') PROJECT_END_DATE
				,(aai.ANTICIPATED_TOTAL_DIRECT + ANTICIPATED_TOTAL_INDIRECT) PROJECT_AMOUNT
				,UPPER(TRIM(IFNULL(asr.protocol_number, 'Not Yet Applied'))) PROTOCOL_NUMBER
				,i.title PROTOCOL_TITLE
				,i.full_name PROTOCOL_PI
				,i.status PROTOCOL_STATUS
				,DATE_FORMAT(i.expiration_date, '%m/%d/%Y') PROTOCOL_EXPIRATION_DATE
				,JHU_GET_IRB_SCHOOL(UPPER(TRIM(asr.protocol_number))) IRB_SCHOOL
				,JHU_GET_IRB_VALIDITY(UPPER(TRIM(asr.protocol_number))) IRB_VALIDITY
				,'330e' REPORT_NUMBER
				,'Proposals with Human Subjects' REPORT_TITLE
				,report_unit PARAMETER_ENTETRED_1
				,report_start_date PARAMETER_ENTETRED_2
				,report_end_date PARAMETER_ENTETRED_3
				,SYSDATE() RUN_TIME
				,@@hostname HOST_NAME
		FROM	proposal p
				LEFT JOIN award_funding_proposals afp ON afp.PROPOSAL_ID=p.PROPOSAL_ID
				LEFT JOIN award a ON a.AWARD_ID = afp.AWARD_ID
												AND a.sequence_number = (SELECT MAX(sequence_number)
																			  FROM   award
																			  WHERE  award_number = a.award_number)
				LEFT JOIN award_persons ai ON ai.AWARD_ID=a.AWARD_ID
				LEFT JOIN award_person_unit au ON au.AWARD_PERSON_ID = ai.AWARD_PERSON_ID
												AND  find_in_set(au.unit_number,fn_get_temp_unit(report_unit))
												AND au.sequence_number = (SELECT MAX(sequence_number)
																			   FROM   award_person_unit
																			   WHERE  award_number = au.award_number)
				LEFT JOIN award_amount_info aai ON  aai.award_number = a.award_number
												AND  aai.sequence_number = (SELECT MAX(sequence_number)
																				FROM   award_amount_info
																				WHERE  award_number = aai.award_number)
												AND  	aai.AWARD_AMOUNT_INFO_ID= (select max(AWARD_AMOUNT_INFO_ID)
																				   from award_amount_info
																				   where award_number=aai.award_number
																				   and SEQUENCE_NUMBER=aai.SEQUENCE_NUMBER)
				 JOIN award_special_review asr ON asr.award_number = a.award_number
													AND    asr.sequence_number = (SELECT MAX(sequence_number)
																					FROM   award_special_review
																					WHERE  award_number = asr.award_number)
													AND    asr.special_review_code = 1
				LEFT JOIN proposal_status ps ON ps.status_code = p.status_code
				LEFT JOIN award_status aws ON aws.status_code = a.status_code
				LEFT JOIN sponsor s ON s.sponsor_code = a.sponsor_code
				                    AND  s.sponsor_code = p.sponsor_code
				LEFT JOIN unit u ON u.unit_number = au.unit_number
				LEFT JOIN person apr ON  apr.person_id = ai.person_id
				LEFT JOIN(SELECT   ii.protocol_number
										,ii.title
										,ii.status
										,ii.expiration_date
										,CONCAT(ii.pi_last_name , ', ' , ii.pi_first_name) full_name
						  FROM   irb_report ii
						  WHERE  UPPER(ii.PI_USER_NAME) NOT IN (SELECT UPPER(user_name) FROM person)) i ON i.protocol_number =TRIM(asr.protocol_number)
		WHERE   DATE(p.create_timestamp) >= STR_TO_DATE(report_start_date, '%m/%d/%Y')
				AND   DATE(p.create_timestamp) <= STR_TO_DATE(report_end_date, '%m/%d/%Y')
				AND   p.status_code = 2
				AND   p.type_code IN (1, 4, 5, 6, 9)
				AND   p.sequence_number = (SELECT MAX(sequence_number)
											  FROM   proposal
											  WHERE  proposal_number = p.proposal_number)
				AND    au.lead_unit_flag = 'Y'
				 ;
	END IF;
END
$$
DELIMITER ;
