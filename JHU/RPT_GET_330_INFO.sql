DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `RPT_GET_330_INFO`(IN report_start_date  VARCHAR(50)
                  ,IN report_end_date  VARCHAR(50)
                  ,IN report_unit  VARCHAR(8))
BEGIN
 DECLARE unit_count int(3) DEFAULT 0;
  SELECT count(*)
  INTO   unit_count
  FROM   DUAL
  WHERE  FIND_IN_SET(report_unit,fn_get_temp_unit('SOM'));
 IF unit_count = 0  THEN
  SELECT null PROPOSAL_NUMBER
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
        ,@@hostname HOST_NAME
  FROM DUAl;
  ELSE
SELECT   p.proposal_number PROPOSAL_NUMBER
        ,' ' 											SAP_GRANT_NUMBER
        ,DATE_FORMAT(p.create_timestamp, '%m/%d/%Y') 	PROPOSAL_SUBMISSION_DATE
        ,concat(pu.unit_number , ':  ' , u.unit_name) 	PROJECT_UNIT
        ,ps.description 								PROPOSAL_STATUS
        ,null 											AWARD_STATUS
        ,p.title 										PROPOSAL_TITLE
        ,ppr.full_name 									PROJECT_PI
        ,s.sponsor_name 								SPONSOR_NAME
        ,DATE_FORMAT(p.start_date, '%m/%d/%Y')  PROJECT_START_DATE
        ,DATE_FORMAT(p.end_date, '%m/%d/%Y') 	  PROJECT_END_DATE
        ,(ibh.total_direct_cost + ibh.total_indirect_cost) 			  PROJECT_AMOUNT
        ,UPPER(TRIM(IFNULL(psr.protocol_number, 'Not Yet Applied'))) PROTOCOL_NUMBER
        ,ii.title 										PROTOCOL_TITLE
        ,ii.full_name 									PROTOCOL_PI
        ,ii.status 										PROTOCOL_STATUS
        ,DATE_FORMAT(ii.expiration_date, '%m/%d/%Y') 	PROTOCOL_EXPIRATION_DATE
        ,(case when psr.protocol_number is null then 'Not Yet Applied'
         when psr.protocol_number = '' then 'Not Yet Applied'
         else JHU_GET_IRB_SCHOOL(UPPER(TRIM(psr.protocol_number))) end ) 	IRB_SCHOOL
        ,(case when ii.irb_status is not null then 'VALID'
         when psr.protocol_number is null then 'Not Yet Applied'
         when  psr.protocol_number LIKE 'HIRB%' THEN 'Unknown'
         else 'INVALID' end ) IRB_VALIDITY
        ,'330' 											REPORT_NUMBER
        ,'Proposals with Human Subjects' 				REPORT_TITLE
        ,report_unit 									PARAMETER_ENTETRED_1
        ,report_start_date 								PARAMETER_ENTETRED_2
        ,report_end_date 								PARAMETER_ENTETRED_3
        ,date(SYSDATE())										RUN_TIME
        ,@@hostname 									HOST_NAME
  FROM   proposal p
		 left join ip_budget_header ibh on
										ibh.proposal_id=p.proposal_id
		 inner join proposal_persons pi
								ON 		pi.proposal_number=p.proposal_number
                                AND    	pi.sequence_number = (	SELECT MAX(sequence_number)
																FROM   proposal_persons
																WHERE  proposal_number = pi.proposal_number)
         inner join prop_person_units pu
								ON 		pu.PROPOSAL_PERSON_ID = pi.PROPOSAL_PERSON_ID
								AND    	pu.sequence_number = (	SELECT MAX(sequence_number)
																FROM   prop_person_units
																WHERE  proposal_number = pu.proposal_number)
           join proposal_special_review psr on p.proposal_number=psr.proposal_number
											and psr.special_review_code=1
											and psr.SEQUENCE_NUMBER = (select max(SEQUENCE_NUMBER) from proposal_special_review where proposal_number=psr.proposal_number)
            left outer join (SELECT distinct i.protocol_number as irb_protocol_number
								,i.title
								,i.status
								,i.expiration_date
                                ,UPPER(i.pi_user_name) pi_user_name
                                ,p.full_name
                                ,'Valid' irb_status
  FROM    irb_report i
  join person p on UPPER(p.user_name)=i.pi_user_name) ii
   on ii.irb_protocol_number=psr.PROTOCOL_NUMBER
inner join person ppr ON  ppr.person_id = pi.person_id
inner join sponsor s ON s.sponsor_code = p.sponsor_code
inner join unit u ON u.unit_number = pu.unit_number
inner join proposal_status ps ON ps.status_code = p.status_code
  WHERE  DATE(p.create_timestamp) >= STR_TO_DATE(report_start_date, '%m/%d/%Y')
  AND    DATE(p.create_timestamp) <= STR_TO_DATE(report_end_date, '%m/%d/%Y')
  AND    p.status_code IN (1, 8)
  AND    p.type_code IN (1, 4, 5, 6, 9)
  AND    p.sequence_number = (SELECT MAX(sequence_number)
                              FROM   proposal
                              WHERE  proposal_number = p.proposal_number)
   AND    FIND_IN_SET(pu.unit_number ,fn_get_temp_unit(report_unit))
   AND    pu.lead_unit_flag = 'Y'
   union
   SELECT    p.proposal_number 								PROPOSAL_NUMBER
        ,SUBSTR(a.award_number, 1, 6) 					SAP_GRANT_NUMBER
        ,DATE_FORMAT(p.create_timestamp, '%m/%d/%Y') 	PROPOSAL_SUBMISSION_DATE
        ,CONCAT(au.unit_number , ':  ' , u.unit_name) 	PROJECT_UNIT
        ,ps.description 								PROPOSAL_STATUS
        ,aws.description 								AWARD_STATUS
        ,p.title 										PROPOSAL_TITLE
        ,apr.full_name 									PROJECT_PI
        ,s.sponsor_name 								SPONSOR_NAME
        ,DATE_FORMAT(a.begin_date, '%m/%d/%Y') 			PROJECT_START_DATE
        ,DATE_FORMAT(aai.final_expiration_date, '%m/%d/%Y') 		 PROJECT_END_DATE
        ,(aai.ANTICIPATED_TOTAL_DIRECT + ANTICIPATED_TOTAL_INDIRECT) PROJECT_AMOUNT
        ,UPPER(TRIM(IFNULL(asr.protocol_number, 'Not Yet Applied'))) PROTOCOL_NUMBER
        ,ii.title 										PROTOCOL_TITLE
        ,ii.full_name 									PROTOCOL_PI
        ,ii.status 										PROTOCOL_STATUS
        ,DATE_FORMAT(ii.expiration_date, '%m/%d/%Y') 	PROTOCOL_EXPIRATION_DATE
        ,JHU_GET_IRB_SCHOOL(UPPER(TRIM(asr.protocol_number))) 	IRB_SCHOOL
        ,(case when ii.irb_status is not null then 'VALID'
         when asr.protocol_number is null then 'Not Yet Applied'
         when  asr.protocol_number LIKE 'HIRB%' THEN 'Unknown'
         else 'INVALID' end )IRB_VALIDITY
        ,'330' 											REPORT_NUMBER
        ,'Proposals with Human Subjects' 				REPORT_TITLE
		,report_unit 									PARAMETER_ENTETRED_1
        ,report_start_date 								PARAMETER_ENTETRED_2
        ,report_end_date 								PARAMETER_ENTETRED_3
        ,date(SYSDATE()) 										RUN_TIME
        ,@@hostname 									HOST_NAME
  FROM   proposal p
          join award_funding_proposals afp
								ON 		afp.PROPOSAL_ID=p.PROPOSAL_ID
         inner join award a
								ON 		a.award_id=afp.award_id
								AND    	a.sequence_number = (	SELECT MAX(sequence_number)
																FROM   award
																WHERE  award_number = a.award_number)
		 inner join award_persons ai
								ON 		ai.award_number=a.award_number
								AND 	ai.sequence_number = ( SELECT MAX(sequence_number)
															   FROM   award_persons
															   WHERE  award_number = ai.award_number)
         inner join award_person_unit au
								ON 		au.award_number = a.award_number
								AND 	au.sequence_number = ( SELECT MAX(sequence_number)
															   FROM   award_person_unit
															   WHERE  award_number = au.award_number)
         inner join award_amount_info aai
								ON 		aai.award_id = a.award_id
								AND 	aai.sequence_number = ( SELECT MAX(sequence_number)
															    FROM   award_amount_info
															    WHERE  award_number = aai.award_number)
		 join award_special_review asr on asr.award_id=a.award_id
											and asr.special_review_code=1
		left outer join (SELECT distinct i.protocol_number as irb_protocol_number
								,i.title
								,i.status
								,i.expiration_date
                                ,UPPER(i.pi_user_name) pi_user_name
                                ,p.full_name
                                ,'Valid' irb_status
  FROM    irb_report i
  join person p on UPPER(p.user_name)=i.pi_user_name) ii
   on ii.irb_protocol_number=asr.PROTOCOL_NUMBER
         inner join proposal_status ps
								ON 		ps.status_code = p.status_code
         inner join award_status aws
								ON 		aws.status_code = a.status_code
         inner join sponsor s
								ON 		s.sponsor_code = a.sponsor_code
								AND 	p.sponsor_code = s.sponsor_code
         inner join unit u
								ON 		u.unit_number = au.unit_number
         inner join person apr
								ON 		apr.person_id = ai.person_id
  WHERE  DATE(p.create_timestamp) >= STR_TO_DATE(report_start_date, '%m/%d/%Y')
  AND    DATE(p.create_timestamp) <= STR_TO_DATE(report_end_date, '%m/%d/%Y')
  AND    p.status_code = 2
  AND    p.type_code IN (1, 4, 5, 6, 9)
  AND    p.sequence_number = (SELECT MAX(sequence_number)
                              FROM   proposal
                              WHERE  proposal_number = p.proposal_number)
  AND    FIND_IN_SET(au.unit_number,fn_get_temp_unit(report_unit))
  AND    au.lead_unit_flag = 'Y'
  UNION
  SELECT   p.proposal_number  							PROPOSAL_NUMBER
        ,' ' 											SAP_GRANT_NUMBER
        ,DATE_FORMAT(p.create_timestamp, '%m/%d/%Y') 	PROPOSAL_SUBMISSION_DATE
        ,CONCAT(pu.unit_number , ':  ' , u.unit_name) 	PROJECT_UNIT
        ,ps.description 								PROPOSAL_STATUS
        ,null 											AWARD_STATUS
        ,p.title 										PROPOSAL_TITLE
        ,ppr.full_name 									PROJECT_PI
        ,s.sponsor_name 								SPONSOR_NAME
        ,DATE_FORMAT(p.start_date, '%m/%d/%Y') 			PROJECT_START_DATE
        ,DATE_FORMAT(p.end_date, '%m/%d/%Y') 			PROJECT_END_DATE
        ,(p.total_direct_cost + p.total_indirect_cost) 	PROJECT_AMOUNT
        ,UPPER(TRIM(IFNULL(psr.protocol_number, 'Not Yet Applied'))) PROTOCOL_NUMBER
        ,i.title 										PROTOCOL_TITLE
        ,i.full_name 									PROTOCOL_PI
        ,i.status 										PROTOCOL_STATUS
        ,DATE_FORMAT(i.expiration_date, '%m/%d/%Y') 	PROTOCOL_EXPIRATION_DATE
        ,JHU_GET_IRB_SCHOOL(UPPER(TRIM(psr.protocol_number))) 	IRB_SCHOOL
        ,JHU_GET_IRB_VALIDITY(UPPER(TRIM(psr.protocol_number))) IRB_VALIDITY
        ,'330' 											REPORT_NUMBER
        ,'Proposals with Human Subjects' 				REPORT_TITLE
        ,report_unit 									PARAMETER_ENTETRED_1
        ,report_start_date 								PARAMETER_ENTETRED_2
        ,report_end_date 								PARAMETER_ENTETRED_3
        ,SYSDATE() 										RUN_TIME
        ,@@HOSTNAME 									HOST_NAME
  FROM   proposal p
		 inner join proposal_persons pi
								ON 		pi.proposal_id=p.proposal_id
         inner join prop_person_units pu
								ON 		pu.PROPOSAL_PERSON_ID = pi.PROPOSAL_PERSON_ID
								AND 	pu.sequence_number = ( SELECT MAX(sequence_number)
															   FROM   prop_person_units
															   WHERE  proposal_number = pu.proposal_number)
        inner join proposal_special_review psr
								ON 		psr.proposal_number=p.proposal_number
								AND     psr.sequence_number = ( SELECT MAX(sequence_number)
																FROM   proposal_special_review
																WHERE  proposal_number = psr.proposal_number)
        inner join person ppr
								ON ppr.person_id = pi.person_id
        inner join sponsor s
								ON s.sponsor_code = p.sponsor_code
        inner join unit u
								ON u.unit_number = pu.unit_number
        inner join proposal_status ps
								ON ps.status_code = p.status_code
        inner join ( SELECT 	ii.protocol_number
							,ii.title
							,ii.status
							,ii.expiration_date
							,CONCAT(ii.pi_last_name , ', ' , ii.pi_first_name) full_name
					 FROM   irb_report ii
					 WHERE  UPPER(ii.pi_user_name) NOT IN (SELECT UPPER(user_name) FROM person)) i
								ON i.protocol_number = TRIM(psr.protocol_number)
  WHERE  DATE(p.create_timestamp) >= STR_TO_DATE(report_start_date, '%m/%d/%Y')
  AND    DATE(p.create_timestamp) <= STR_TO_DATE(report_end_date, '%m/%d/%Y')
  AND    p.status_code IN (1, 8)
  AND    p.type_code IN (1, 4, 5, 6, 9)
  AND    FIND_IN_SET(pu.unit_number,fn_get_temp_unit(report_unit))
  AND    pu.lead_unit_flag = 'Y'
  AND    psr.special_review_code = 1
  AND    p.sequence_number = (SELECT MAX(sequence_number)
                              FROM   proposal
                              WHERE  proposal_number = p.proposal_number)
  UNION
  SELECT   p.proposal_number  							PROPOSAL_NUMBER
        ,SUBSTR(a.award_number, 1, 6) 					SAP_GRANT_NUMBER
        ,DATE_FORMAT(p.create_timestamp, '%m/%d/%Y') 	PROPOSAL_SUBMISSION_DATE
        ,au.unit_number || ':  ' || u.unit_name 		PROJECT_UNIT
        ,ps.description 								PROPOSAL_STATUS
        ,aws.description 								AWARD_STATUS
        ,p.title 										PROPOSAL_TITLE
        ,apr.full_name 									PROJECT_PI
        ,s.sponsor_name 								SPONSOR_NAME
        ,DATE_FORMAT(a.begin_date, '%m/%d/%Y') 			PROJECT_START_DATE
        ,DATE_FORMAT(aai.final_expiration_date, '%m/%d/%Y') 			PROJECT_END_DATE
        ,(aai.ANTICIPATED_TOTAL_DIRECT + ANTICIPATED_TOTAL_INDIRECT) 	PROJECT_AMOUNT
        ,UPPER(TRIM(IFNULL(asr.protocol_number, 'Not Yet Applied'))) 	PROTOCOL_NUMBER
        ,i.title 										PROTOCOL_TITLE
        ,i.full_name 									PROTOCOL_PI
        ,i.status 										PROTOCOL_STATUS
        ,DATE_FORMAT(i.expiration_date, '%m/%d/%Y') 	PROTOCOL_EXPIRATION_DATE
        ,JHU_GET_IRB_SCHOOL(UPPER(TRIM(asr.protocol_number))) 	IRB_SCHOOL
        ,JHU_GET_IRB_VALIDITY(UPPER(TRIM(asr.protocol_number))) IRB_VALIDITY
        ,'330' 											REPORT_NUMBER
        ,'Proposals with Human Subjects' 				REPORT_TITLE
        ,report_unit 									PARAMETER_ENTETRED_1
        ,report_start_date 								PARAMETER_ENTETRED_2
        ,report_end_date 								PARAMETER_ENTETRED_3
        ,SYSDATE() 										RUN_TIME
        ,@@hostname 									HOST_NAME
  FROM   proposal p
         inner join award_funding_proposals afp
							ON 		afp.PROPOSAL_ID = p.PROPOSAL_ID
         inner join award a
							ON 	   	a.award_id=afp.award_id
							AND    	a.sequence_number = (  SELECT MAX(sequence_number)
													       FROM   award
													       WHERE  award_number = a.award_number)
		 inner join award_persons ai
							ON  	ai.award_id=a.award_id
							AND 	ai.sequence_number = ( SELECT MAX(sequence_number)
													       FROM   award_persons
													       WHERE  award_number = a.award_number)
         inner join award_person_unit au
							ON 		au.award_person_id=ai.award_person_id
							AND    	au.sequence_number = ( SELECT MAX(sequence_number)
														   FROM   award_person_unit
														   WHERE  award_number = au.award_number)
         inner join award_amount_info aai
							ON 		aai.award_id=a.award_id
							AND     aai.sequence_number = ( SELECT MAX(sequence_number)
															FROM   award_amount_info
															WHERE  award_number = aai.award_number)
         inner join award_special_review asr
							ON 		asr.award_id=a.award_id
         inner join proposal_status ps
							ON     	ps.status_code = p.status_code
         inner join award_status aws
							ON     	aws.status_code = a.status_code
         inner join sponsor s
							ON 		s.sponsor_code = a.sponsor_code
         inner join unit u
							ON 	    u.unit_number = au.unit_number
         inner join person apr
							ON 	    apr.person_id = ai.person_id
         inner join ( SELECT ii.protocol_number
							,ii.title
							,ii.status
							,ii.expiration_date
							,CONCAT(ii.pi_last_name , ', ' , ii.pi_first_name) full_name
					  FROM   irb_report ii
					  WHERE  UPPER(ii.pi_user_name) NOT IN (SELECT UPPER(user_name) FROM person)) i
							 ON    	i.protocol_number = TRIM(asr.protocol_number)
  WHERE  DATE(p.create_timestamp) >= STR_TO_DATE(report_start_date, '%m/%d/%Y')
  AND    DATE(p.create_timestamp) <= STR_TO_DATE(report_end_date, '%m/%d/%Y')
  AND    p.status_code = 2
  AND    p.type_code IN (1, 4, 5, 6, 9)
  AND    p.sequence_number = (SELECT MAX(sequence_number)
                              FROM   proposal
                              WHERE  proposal_number = p.proposal_number)
  AND    FIND_IN_SET(au.unit_number,fn_get_temp_unit(report_unit))
  AND    au.lead_unit_flag = 'Y'
  AND    asr.special_review_code = 1
  ORDER BY 4, 1;
  END IF;
END
$$
DELIMITER ;
