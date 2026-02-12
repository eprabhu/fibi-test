DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` PROCEDURE `jhu_quest_ans_rpt_proc`(award_end_date_in VARCHAR(4), unit_in VARCHAR(8))
BEGIN
DECLARE filename VARCHAR(200) DEFAULT '/var/lib/mysql-files/qa_';
DECLARE award_end_date DATE DEFAULT STR_TO_DATE(award_end_date_in, '%Y%m%d');
DECLARE dev_proposal VARCHAR(30);
DECLARE inst_proposal VARCHAR(30);
DECLARE grant_number CHAR(6);
DECLARE title VARCHAR(3000);
DECLARE person_id VARCHAR(8);
DECLARE person_name VARCHAR(200);
DECLARE person_role VARCHAR(200);
DECLARE person_email_address VARCHAR(200);
DECLARE sponsor_name VARCHAR(30);
DECLARE questionnaire_id INT;
DECLARE module_sub_item_key VARCHAR(20);
DECLARE questionnaire_name VARCHAR(1000);
DECLARE question_number VARCHAR(30) DEFAULT ' ';
DECLARE question_answer VARCHAR(30) DEFAULT ' ';
DECLARE header_string VARCHAR(4000) DEFAULT 'PD Number|IP Number|Grant Number|Title|Person Name|Person Role|Person Email Address|Sponsor Name|Questionnaire Description|';
DECLARE question_string VARCHAR(4000) DEFAULT ' ';
DECLARE proposal_string VARCHAR(4000);
DECLARE answer_string VARCHAR(4000) DEFAULT ' ';
DECLARE full_string VARCHAR(20000) DEFAULT ' ';
DECLARE proposal_done INT DEFAULT FALSE;
DECLARE question_done INT DEFAULT FALSE;
DECLARE first_record INT DEFAULT TRUE;
DECLARE proposal_cursor CURSOR FOR
SELECT DISTINCT(CAST(pd.proposal_id AS CHAR))
      ,pd.ip_number
      ,g.grant_number
      ,TRIM(REPLACE(REPLACE(REGEXP_REPLACE(pd.title, '^0-9A-Za-z"!()@#$%^*.\n          ,;:"/?><+=|/~`', ''), '\n', ' '), '''', '')) AS title
      ,pdi.person_id AS employee_id
      ,TRIM(REPLACE(REPLACE(REGEXP_REPLACE(pdi.full_name, '^0-9A-Za-z"!()@#$%^*.\n          ,;:"/?><+=|/~`', ''), '\n', ' '), '''', '')) AS pi_name
      ,CASE
                 WHEN pdi.prop_person_role_id = 1 THEN 'Co-Investigator'
                 WHEN pdi.prop_person_role_id = 2 THEN 'Key Study Person'
                 WHEN pdi.prop_person_role_id = 3 THEN 'Principal Investigator'
                 WHEN pdi.prop_person_role_id = 4 THEN 'Manager'
                 WHEN pdi.prop_person_role_id = 5 THEN 'PI Multiple'
                 WHEN pdi.prop_person_role_id = 6 THEN 'Collaborator'
                 WHEN pdi.prop_person_role_id = 7 THEN 'Team PI'
                 WHEN pdi.prop_person_role_id = 9 THEN 'Principal Investigator (Project)'
                 WHEN pdi.prop_person_role_id = 10 THEN 'Mentor'
                 WHEN pdi.prop_person_role_id = 11 THEN 'Co-Mentor'
                 ELSE COALESCE (pdi.project_role, 'Unknown')
           END AS project_role
      ,COALESCE(pdi.email_address, 'Unavailable') AS email_address
      ,TRIM(REPLACE(REPLACE(REGEXP_REPLACE(s.sponsor_name, '^0-9A-Za-z"!()@#$%^*.\n          ,;:"/?><+=|/~`', ''), '\n', ' '), '''', '')) AS sponsor_name
      ,qah.questionnaire_id AS questionnaire_id
      ,qah.module_sub_item_key AS module_sub_item_key
      ,qh.description AS questionnaire_name
FROM   eps_proposal pd
        ,proposal ip
        ,sap_grant g
        ,quest_answer_header qah
        ,quest_header qh
        ,eps_proposal_persons pdi
        ,sponsor s
  WHERE  STR_TO_DATE(g.grant_end_date, '%Y%m%d') > STR_TO_DATE('20230701', '%Y%m%d')
  AND    ip.proposal_sequence_status = 'ACTIVE'
  AND    pd.home_unit_number LIKE '17036%'
  AND    pdi.pi_flag = 'Y'
  AND    LENGTH(TRIM(qah.module_sub_item_key)) = 0
-- and pd.proposal_id LIKE '%9'
  AND    pd.ip_number = ip.proposal_number
  AND    ip.proposal_number = g.proposal_number
  AND    pd.proposal_id = pdi.proposal_id
  AND    pd.proposal_id = qah.module_item_key
  AND    qah.questionnaire_id = qh.questionnaire_id
  AND    pd.sponsor_code = s.sponsor_code
  UNION
  SELECT DISTINCT(CAST(pd.proposal_id AS CHAR))
      ,pd.ip_number
      ,g.grant_number
      ,TRIM(REPLACE(REPLACE(REGEXP_REPLACE(pd.title, '^0-9A-Za-z"!()@#$%^*.\n          ,;:"/?><+=|/~`', ''), '\n', ' '), '''', '')) AS title
      ,pdi.person_id AS employee_id
      ,TRIM(REPLACE(REPLACE(REGEXP_REPLACE(pdi.full_name, '^0-9A-Za-z"!()@#$%^*.\n          ,;:"/?><+=|/~`', ''), '\n', ' '), '''', '')) AS pi_name
      ,CASE
                 WHEN pdi.prop_person_role_id = 1 THEN 'Co-Investigator'
                 WHEN pdi.prop_person_role_id = 2 THEN 'Key Study Person'
                 WHEN pdi.prop_person_role_id = 3 THEN 'Principal Investigator'
                 WHEN pdi.prop_person_role_id = 4 THEN 'Manager'
                 WHEN pdi.prop_person_role_id = 5 THEN 'PI Multiple'
                 WHEN pdi.prop_person_role_id = 6 THEN 'Collaborator'
                 WHEN pdi.prop_person_role_id = 7 THEN 'Team PI'
                 WHEN pdi.prop_person_role_id = 9 THEN 'Principal Investigator (Project)'
                 WHEN pdi.prop_person_role_id = 10 THEN 'Mentor'
                 WHEN pdi.prop_person_role_id = 11 THEN 'Co-Mentor'
                 ELSE COALESCE (pdi.project_role, 'Unknown')
           END AS project_role
      ,COALESCE(pdi.email_address, 'Unavailable') AS email_address
      ,TRIM(REPLACE(REPLACE(REGEXP_REPLACE(s.sponsor_name, '^0-9A-Za-z"!()@#$%^*.\n          ,;:"/?><+=|/~`', ''), '\n', ' '), '''', '')) AS sponsor_name
	  ,qah.questionnaire_id AS questionnaire_id
      ,qah.module_sub_item_key AS module_sub_item_key
      ,qh.description AS questionnaire_name
FROM   eps_proposal pd
        ,proposal ip
        ,sap_grant g
        ,quest_answer_header qah
        ,quest_header qh
        ,eps_proposal_persons pdi
        ,sponsor s
  WHERE  STR_TO_DATE(g.grant_end_date, '%Y%m%d') > STR_TO_DATE('20230701', '%Y%m%d')
  AND    ip.proposal_sequence_status = 'ACTIVE'
  AND    pd.home_unit_number LIKE '17036%'
-- and pd.proposal_id LIKE '%9'
  AND    pd.ip_number = ip.proposal_number
  AND    ip.proposal_number = g.proposal_number
  AND    pd.proposal_id = pdi.proposal_id
  AND    pd.proposal_id = qah.module_item_key
  AND    pdi.person_id = qah.module_sub_item_key
  AND    qah.questionnaire_id = qh.questionnaire_id
  AND    pd.sponsor_code = s.sponsor_code
  ORDER BY 1;
DECLARE question_cursor CURSOR FOR
SELECT DISTINCT(SUBSTR(TRIM(qq.question), 1, 5))
FROM   quest_answer_header qah
      ,quest_answer qa
      ,quest_question qq
WHERE  qah.module_item_code = 3
AND    TRIM(qq.question) LIKE 'Q%'
AND    qq.answer_type LIKE 'Y%'
AND    qah.module_item_key IN (SELECT pd.proposal_id
                               FROM   eps_proposal pd
                                     ,sap_grant g
			                   WHERE  STR_TO_DATE(g.grant_end_date, '%Y%m%d') > STR_TO_DATE('20230701', '%Y%m%d')
                               AND    pd.ip_number = g.proposal_number
                               AND    pd.home_unit_number LIKE CONCAT(unit_in, '%'))
AND    qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id
AND    qa.question_id = qq.question_id
ORDER BY 1
;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET proposal_done = TRUE;
OPEN proposal_cursor;
read_proposals: LOOP
  FETCH proposal_cursor INTO dev_proposal, inst_proposal, grant_number, title, person_id, person_name, person_role, person_email_address, sponsor_name, questionnaire_id, module_sub_item_key, questionnaire_name;
  IF proposal_done THEN
    CLOSE proposal_cursor;
    LEAVE read_proposals;
  END IF;
  SET proposal_string = CONCAT(dev_proposal, '|'
                              ,inst_proposal, '|'
                              ,grant_number, '|'
                              ,title, '|'
                              ,person_name, '|'
                              ,person_role, '|'
                              ,person_email_address, '|'
                              ,sponsor_name, '|'
                              ,questionnaire_name, '|');
  OPEN question_cursor;
  read_questions: LOOP
    FETCH question_cursor INTO question_number;
	  IF first_record THEN
        SET header_string = CONCAT(TRIM(header_string)
								  ,TRIM(question_number)
								  ,'|');
      END IF;
      IF proposal_done THEN
		SET proposal_done = FALSE;
        CLOSE question_cursor;
        LEAVE read_questions;
      END IF;
	  SET answer_string = CONCAT(TRIM(answer_string), jhu_get_question_answer_fn(dev_proposal, questionnaire_id, person_id, question_number), '|');
  END LOOP read_questions;
  IF first_record THEN
	SET full_string = CONCAT(TRIM(full_string)
							,TRIM(header_string)
                            ,'\r');
	SET first_record = FALSE;
  END IF;
  SET full_string = CONCAT(TRIM(full_string)
                          ,proposal_string
						  ,answer_string
	 					  ,'\r');
  SET proposal_done = FALSE;
  SET proposal_string = ' ';
  SET answer_string = ' ';
END LOOP read_proposals;
  SET filename = CONCAT('''/var/lib/mysql-files/qa_rpt_', award_end_date_in, '_', unit_in, '_', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'), '.txt''');
  SET @eco = CONCAT('SELECT ''', full_string, ''' INTO OUTFILE ', filename);
  PREPARE stmt FROM @eco;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;
END
$$
DELIMITER ;
