DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `RPT_GET_330E_INFO_bkp`(IN report_start_date  VARCHAR(50)
                   ,IN report_end_date  VARCHAR(50)
                   ,IN report_unit  VARCHAR(20))
BEGIN
 DECLARE unit_count INT(3) DEFAULT 0;
  SELECT count(*)
  INTO   unit_count
  FROM   DUAL
  WHERE  FIND_IN_SET(report_unit,fn_get_temp_unit('som'));
  IF unit_count = 0
  THEN
  SELECT 'This report is for School of Medicine units only.' PROPOSAL_NUMBER
        ,null SAP_GRANT_NUMBER
        ,null PROPOSAL_SUBMISSION_DATE
        ,null PROJECT_UNIT
        ,null PROPOSAL_STATUS
        ,null AWARD_STATUS
        ,null PROPOSAL_TITLE
        ,null PROJECT_PI
        ,null SPONSOR_NAME
        ,null PROPOSAL_START_DATE
        ,null PROPOSAL_END_DATE
        ,null PROPOSAL_AMOUNT
        ,null AWARD_START_DATE
        ,null AWARD_END_DATE
        ,null AWARD_AMOUNT
        ,null PROTOCOL_NUMBER
        ,null PROTOCOL_TITLE
        ,null PROTOCOL_PI
        ,null PROTOCOL_STATUS
        ,null PROTOCOL_EXPIRATION_DATE
        ,null IRB_SCHOOL
        ,null IRB_VALIDITY
        ,'330e' REPORT_NUMBER
        ,'Proposals with Human Subjects' REPORT_TITLE
        ,report_unit PARAMETER_ENTETRED_1
        ,report_start_date PARAMETER_ENTETRED_2
        ,report_end_date PARAMETER_ENTETRED_3
        ,SYSDATE() RUN_TIME
        ,@@hostname  HOST_NAME
  FROM DUAl;
  ELSE
   with
 asr_data as (SELECT ii.protocol_number as irb_protocol_number
								,ii.title
								,ii.status
								,ii.expiration_date
                                ,UPPER(ii.pi_user_name) pi_user_name
                                ,asr.protocol_number as asr_protocol_number
                                ,(case  when asr.protocol_number is null then 'Not Yet Applied'
										when (asr.protocol_number LIKE 'IRB%' OR asr.protocol_number LIKE 'NA_%') then (select if(count(1)>0,'Valid','Invalid') from irb_report irb where irb.protocol_number=asr.protocol_number)
										when asr.protocol_number LIKE 'HIRB%' THEN 'Unknown'
										else 'Invalid' end) irb_validate
                                ,asr.AWARD_ID
  FROM   award_special_review asr
  left join irb_report ii
   on ii.PROTOCOL_NUMBER=asr.PROTOCOL_NUMBER
   where asr.special_review_code=1
   and asr.SEQUENCE_NUMBER = (select max(SEQUENCE_NUMBER) from award_special_review
   where AWARD_ID=asr.AWARD_ID))
  SELECT DISTINCT p.proposal_number PROPOSAL_NUMBER
        ,null SAP_GRANT_NUMBER
        ,DATE_FORMAT(p.create_timestamp, '%m/%d/%Y') PROPOSAL_SUBMISSION_DATE
        ,pu.unit_number PROJECT_UNIT
        ,ps.description PROPOSAL_STATUS
        ,null AWARD_STATUS
        ,p.title PROPOSAL_TITLE
        ,ppr.full_name PROJECT_PI
        ,s.sponsor_name SPONSOR_NAME
        ,DATE_FORMAT(p.start_date, '%m/%d/%Y') PROPOSAL_START_DATE
        ,DATE_FORMAT(p.end_date, '%m/%d/%Y') PROPOSAL_END_DATE
        ,(ibh.total_direct_cost + ibh.total_indirect_cost) PROPOSAL_AMOUNT
        ,null AWARD_START_DATE
        ,null AWARD_END_DATE
        ,null AWARD_AMOUNT
        ,UPPER(TRIM(psr.protocol_number)) PROTOCOL_NUMBER
        ,i.title PROTOCOL_TITLE
        ,i.full_name PROTOCOL_PI
        ,i.status PROTOCOL_STATUS
        ,DATE_FORMAT(i.expiration_date, '%m/%d/%Y') PROTOCOL_EXPIRATION_DATE
        ,JHU_GET_IRB_SCHOOL(UPPER(TRIM(psr.protocol_number))) IRB_SCHOOL
        ,JHU_GET_IRB_VALIDITY(UPPER(TRIM(psr.protocol_number))) IRB_VALIDITY
        ,'330e' REPORT_NUMBER
        ,'Proposals with Human Subjects' REPORT_TITLE
        ,report_unit PARAMETER_ENTETRED_1
        ,report_start_date PARAMETER_ENTETRED_2
        ,report_end_date PARAMETER_ENTETRED_3
        ,SYSDATE() RUN_TIME
        ,@@hostname HOST_NAME
  FROM   proposal p
         inner join ip_budget_header ibh on ibh.proposal_id=p.proposal_id
         inner join proposal_persons  pi on pi.proposal_id=p.proposal_id
											 AND    pi.sequence_number = (SELECT MAX(sequence_number)
																	   FROM   prop_person_units
																	   WHERE  proposal_number = pi.proposal_number)
         inner join prop_person_units pu on pu.PROPOSAL_PERSON_ID = pi.PROPOSAL_PERSON_ID
										 AND    pu.sequence_number = (SELECT MAX(sequence_number)
																	   FROM   prop_person_units
																	   WHERE  proposal_number = pu.proposal_number)
         inner join (SELECT DISTINCT
    psr2.proposal_number, psr2.protocol_number
FROM
    proposal_special_review psr2,
    (SELECT
        MAX(sequence_number) AS max_seq, proposal_number
    FROM
        proposal_special_review
    GROUP BY proposal_number) psr1
WHERE
    psr2.proposal_number = psr1.proposal_number
        AND psr2.special_review_code = 1) psr on psr.proposal_number = p.proposal_number
		 inner join person ppr on ppr.person_id = pi.person_id
         inner join sponsor s on s.sponsor_code = p.sponsor_code
         inner join proposal_status ps on ps.status_code = p.status_code
         left join (SELECT distinct ii.protocol_number
                ,ii.title
                ,ii.status
                ,ii.expiration_date
                ,ipr.full_name
          FROM   irb_report ii
                ,person ipr
          WHERE  UPPER(ii.PI_USER_NAME) = UPPER(ipr.user_name)) i on   i.protocol_number=TRIM(psr.protocol_number)
  WHERE  DATE(p.create_timestamp) >= STR_TO_DATE(report_start_date, '%m/%d/%Y')
  AND    DATE(p.create_timestamp) <= STR_TO_DATE(report_end_date, '%m/%d/%Y')
  AND    p.status_code IN (1, 3)
  AND    type_code IN (1, 4, 5, 6, 9)
  AND    FIND_IN_SET(pu.unit_number,fn_get_temp_unit(report_unit))
  AND    pu.lead_unit_flag = 'Y'
  AND    p.sequence_number = (SELECT MAX(sequence_number)
                              FROM   proposal
                              WHERE  proposal_number = p.proposal_number)
  union
   SELECT DISTINCT p.proposal_number PROPOSAL_NUMBER
        ,SUBSTR(a.award_number, 1, 6) SAP_GRANT_NUMBER
        ,DATE_FORMAT(p.create_timestamp, '%m/%d/%Y') PROPOSAL_SUBMISSION_DATE
        ,au.unit_number PROJECT_UNIT
        ,ps.description PROPOSAL_STATUS
        ,aws.description AWARD_STATUS
        ,p.title PROPOSAL_TITLE
        ,apr.full_name PROJECT_PI
        ,s.sponsor_name SPONSOR_NAME
        ,DATE_FORMAT(p.start_date, '%m/%d/%Y') PROPOSAL_START_DATE
        ,DATE_FORMAT(p.end_date, '%m/%d/%Y') PROPOSAL_END_DATE
        ,(ibh.total_direct_cost + ibh.total_indirect_cost) PROPOSAL_AMOUNT
        ,DATE_FORMAT(a.begin_date, '%m/%d/%Y') AWARD_START_DATE
        ,DATE_FORMAT(aai.final_expiration_date, '%m/%d/%Y') AWARD_END_DATE
        ,(aai.ANTICIPATED_TOTAL_DIRECT + ANTICIPATED_TOTAL_INDIRECT) AWARD_AMOUNT
        ,UPPER(TRIM(asr.asr_protocol_number)) PROTOCOL_NUMBER
        ,asr.title PROTOCOL_TITLE
        ,asr.full_name PROTOCOL_PI
        ,asr.status PROTOCOL_STATUS
        ,DATE_FORMAT(asr.expiration_date, '%m/%d/%Y') PROTOCOL_EXPIRATION_DATE
        ,JHU_GET_IRB_SCHOOL(UPPER(TRIM(asr.asr_protocol_number))) IRB_SCHOOL
        ,asr.irb_validate IRB_VALIDITY
        ,'330e' REPORT_NUMBER
        ,'Proposals with Human Subjects' REPORT_TITLE
        ,report_unit PARAMETER_ENTETRED_1
        ,report_start_date PARAMETER_ENTETRED_2
        ,report_end_date PARAMETER_ENTETRED_3
        ,SYSDATE() RUN_TIME
        ,@@hostname HOST_NAME
  FROM   proposal p
		 inner join ip_budget_header ibh on ibh.proposal_id=p.proposal_id
         inner join award_funding_proposals afp on afp.proposal_id=p.proposal_id
         inner join award a on a.award_id=afp.award_id  AND a.sequence_number = (SELECT MAX(sequence_number)
																			  FROM   award
																			  WHERE  award_number = a.award_number)
		 inner join award_persons ai on ai.award_id=a.award_id AND ai.sequence_number = (SELECT MAX(sequence_number)
																					   FROM   award_person_unit
																					   WHERE  award_number = ai.award_number)
         inner join award_person_unit au on au.award_person_id=ai.award_person_id AND au.sequence_number = (SELECT MAX(sequence_number)
																											   FROM   award_person_unit
																											   WHERE  award_number = au.award_number)
         inner join award_amount_info aai on aai.award_id=a.award_id  AND aai.sequence_number = (SELECT MAX(sequence_number)
																									FROM   award_amount_info
																									WHERE  award_number = aai.award_number)
         inner join (select p.FULL_NAME,asr_data.* from asr_data
					join person p on UPPER(p.user_name)=asr_data.pi_user_name ) asr on asr.award_id=a.award_id   inner join proposal_status ps on ps.status_code = ps.status_code
         inner join award_status aws on aws.status_code = a.status_code
         inner join sponsor s on s.sponsor_code = a.sponsor_code  AND    s.sponsor_code = p.sponsor_code
         inner join person apr on apr.person_id = ai.person_id
         WHERE  DATE(p.create_timestamp) >= STR_TO_DATE(report_start_date, '%m/%d/%Y')
  AND    DATE(p.create_timestamp) <= STR_TO_DATE(report_end_date, '%m/%d/%Y')
  AND    p.status_code = 2
  AND    type_code IN (1, 4, 5, 6, 9)
  AND    p.sequence_number = (SELECT MAX(sequence_number)
                              FROM   proposal
                              WHERE  proposal_number = p.proposal_number)
  AND    find_in_set(au.unit_number,fn_get_temp_unit(report_unit))
  AND    au.lead_unit_flag = 'Y'
  UNION
  SELECT DISTINCT p.proposal_number PROPOSAL_NUMBER
        ,null SAP_GRANT_NUMBER
        ,DATE_FORMAT(p.create_timestamp, '%m/%d/%Y') PROPOSAL_SUBMISSION_DATE
        ,pu.unit_number PROJECT_UNIT
        ,ps.description PROPOSAL_STATUS
        ,null AWARD_STATUS
        ,p.title PROPOSAL_TITLE
        ,ppr.full_name PROJECT_PI
        ,s.sponsor_name SPONSOR_NAME
        ,DATE_FORMAT(p.start_date, '%m/%d/%Y') PROPOSAL_START_DATE
        ,DATE_FORMAT(p.end_date, '%m/%d/%Y') PROPOSAL_END_DATE
        ,(ibh.total_direct_cost + ibh.total_indirect_cost) PROPOSAL_AMOUNT
        ,null AWARD_START_DATE
        ,null AWARD_END_DATE
        ,null AWARD_AMOUNT
        ,UPPER(TRIM(psr.protocol_number)) PROTOCOL_NUMBER
        ,i.title PROTOCOL_TITLE
        ,i.full_name PROTOCOL_PI
        ,i.status PROTOCOL_STATUS
        ,DATE_FORMAT(i.expiration_date, '%m/%d/%Y') PROTOCOL_EXPIRATION_DATE
        ,JHU_GET_IRB_SCHOOL(UPPER(TRIM(psr.protocol_number))) IRB_SCHOOL
        ,JHU_GET_IRB_VALIDITY(UPPER(TRIM(psr.protocol_number))) IRB_VALIDITY
        ,'330e' REPORT_NUMBER
        ,'Proposals with Human Subjects' REPORT_TITLE
        ,report_unit PARAMETER_ENTETRED_1
        ,report_start_date PARAMETER_ENTETRED_2
        ,report_end_date PARAMETER_ENTETRED_3
        ,SYSDATE() RUN_TIME
        ,@@hostname HOST_NAME
  FROM   proposal p
         inner join ip_budget_header ibh on ibh.proposal_id=p.proposal_id
         inner join proposal_persons  pi on pi.proposal_id=p.proposal_id
											 AND    pi.sequence_number = (SELECT MAX(sequence_number)
																	   FROM   prop_person_units
																	   WHERE  proposal_number = pi.proposal_number)
         inner join prop_person_units pu on pu.PROPOSAL_PERSON_ID = pi.PROPOSAL_PERSON_ID
										 AND    pu.sequence_number = (SELECT MAX(sequence_number)
																	   FROM   prop_person_units
																	   WHERE  proposal_number = pu.proposal_number)
         inner join (SELECT DISTINCT
    psr2.proposal_number, psr2.protocol_number
FROM
    proposal_special_review psr2,
    (SELECT
        MAX(sequence_number) AS max_seq, proposal_number
    FROM
        proposal_special_review
    GROUP BY proposal_number) psr1
WHERE
    psr2.proposal_number = psr1.proposal_number
        AND psr2.special_review_code = 1) psr on psr.proposal_number = p.proposal_number
		 inner join person ppr on ppr.person_id = pi.person_id
         inner join sponsor s on s.sponsor_code = p.sponsor_code
         inner join proposal_status ps on ps.status_code = p.status_code
         inner join(SELECT distinct ii.protocol_number
                ,ii.title
                ,ii.status
                ,ii.expiration_date
                ,CONCAT(ii.pi_last_name , ', ' , ii.pi_first_name) full_name
          FROM   irb_report ii
          WHERE  UPPER(ii.PI_USER_NAME) NOT IN (SELECT UPPER(user_name) FROM person)) i on  i.protocol_number=TRIM(psr.protocol_number)
  WHERE  DATE(p.create_timestamp) >= STR_TO_DATE(report_start_date, '%m/%d/%Y')
  AND    DATE(p.create_timestamp) <= STR_TO_DATE(report_end_date, '%m/%d/%Y')
  AND    p.status_code IN (1, 3)
  AND    type_code IN (1, 4, 5, 6, 9)
  AND    FIND_IN_SET(pu.unit_number,fn_get_temp_unit(report_unit))
  AND    pu.lead_unit_flag = 'Y'
  AND    p.sequence_number = (SELECT MAX(sequence_number)
                              FROM   proposal
                              WHERE  proposal_number = p.proposal_number)
  UNION
  SELECT DISTINCT p.proposal_number  PROPOSAL_NUMBER
        ,SUBSTR(a.award_number, 1, 6) SAP_GRANT_NUMBER
        ,DATE_FORMAT(p.create_timestamp, '%m/%d/%Y') PROPOSAL_SUBMISSION_DATE
        ,au.unit_number PROJECT_UNIT
        ,ps.description PROPOSAL_STATUS
        ,aws.description AWARD_STATUS
        ,p.title PROPOSAL_TITLE
        ,apr.full_name PROJECT_PI
        ,s.sponsor_name SPONSOR_NAME
        ,DATE_FORMAT(p.start_date, '%m/%d/%Y') PROPOSAL_START_DATE
        ,DATE_FORMAT(p.end_date, '%m/%d/%Y') PROPOSAL_END_DATE
        ,(ibh.total_direct_cost + ibh.total_indirect_cost) PROPOSAL_AMOUNT
        ,DATE_FORMAT(a.begin_date, '%m/%d/%Y') AWARD_START_DATE
        ,DATE_FORMAT(aai.final_expiration_date, '%m/%d/%Y') AWARD_END_DATE
        ,(aai.ANTICIPATED_TOTAL_DIRECT + ANTICIPATED_TOTAL_INDIRECT) AWARD_AMOUNT
        ,UPPER(TRIM(asr.protocol_number)) PROTOCOL_NUMBER
        ,i.title PROTOCOL_TITLE
        ,i.full_name PROTOCOL_PI
        ,i.status PROTOCOL_STATUS
        ,DATE_FORMAT(i.expiration_date, '%m/%d/%Y') PROTOCOL_EXPIRATION_DATE
        ,JHU_GET_IRB_SCHOOL(UPPER(TRIM(asr.protocol_number))) IRB_SCHOOL
        ,(case  when asr.protocol_number is null then 'Not Yet Applied'
										when (asr.protocol_number LIKE 'IRB%' OR asr.protocol_number LIKE 'NA_%') then (select if(count(1)>0,'Valid','Invalid') from irb_report irb where irb.protocol_number=asr.protocol_number)
										when asr.protocol_number LIKE 'HIRB%' THEN 'Unknown'
										else 'Invalid' end) IRB_VALIDITY
        ,'330e' REPORT_NUMBER
        ,'Proposals with Human Subjects' REPORT_TITLE
        ,report_unit PARAMETER_ENTETRED_1
        ,report_start_date PARAMETER_ENTETRED_2
        ,report_end_date PARAMETER_ENTETRED_3
        ,SYSDATE() RUN_TIME
        ,@@hostname HOST_NAME
  FROM   proposal p
		 inner join ip_budget_header ibh on ibh.proposal_id=p.proposal_id
         inner join award_funding_proposals afp on afp.proposal_id=p.proposal_id
         inner join award a on a.award_id=afp.award_id  AND a.sequence_number = (SELECT MAX(sequence_number)
																			  FROM   award
																			  WHERE  award_number = a.award_number)
		 inner join award_persons ai on ai.award_id=a.award_id AND ai.sequence_number = (SELECT MAX(sequence_number)
																					   FROM   award_person_unit
																					   WHERE  award_number = ai.award_number)
         inner join award_person_unit au on au.award_person_id=ai.award_person_id AND au.sequence_number = (SELECT MAX(sequence_number)
																											   FROM   award_person_unit
																											   WHERE  award_number = au.award_number)
         inner join award_amount_info aai on aai.award_id=a.award_id  AND aai.sequence_number = (SELECT MAX(sequence_number)
																									FROM   award_amount_info
																									WHERE  award_number = aai.award_number)
         inner join award_special_review asr on asr.award_id=a.award_id
         inner join proposal_status ps on ps.status_code = ps.status_code
         inner join award_status aws on aws.status_code = a.status_code
         inner join sponsor s on s.sponsor_code = a.sponsor_code  AND    s.sponsor_code = p.sponsor_code
         inner join person apr on apr.person_id = ai.person_id
         left join (SELECT ii.protocol_number
                ,ii.title
                ,ii.status
                ,ii.expiration_date
                ,CONCAT(ii.pi_last_name , ', ' , ii.pi_first_name) full_name
          FROM   irb_report ii
          WHERE  UPPER(ii.PI_USER_NAME) NOT IN (SELECT UPPER(user_name) FROM person)) i on i.protocol_number = TRIM(asr.protocol_number)
  WHERE  DATE(p.create_timestamp) >= STR_TO_DATE(report_start_date, '%m/%d/%Y')
  AND    DATE(p.create_timestamp) <= STR_TO_DATE(report_end_date, '%m/%d/%Y')
  AND    p.status_code = 2
  AND    type_code IN (1, 4, 5, 6, 9)
  AND    p.sequence_number = (SELECT MAX(sequence_number)
                              FROM   proposal
                              WHERE  proposal_number = p.proposal_number)
  AND    find_in_set(au.unit_number,fn_get_temp_unit(report_unit))
  AND    au.lead_unit_flag = 'Y'
  AND    asr.special_review_code = 1
  ORDER BY 1;
  END IF;
END
$$
DELIMITER ;
