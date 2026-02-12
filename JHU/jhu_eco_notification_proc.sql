DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` PROCEDURE `jhu_eco_notification_proc`()
BEGIN
DECLARE filename VARCHAR(200) DEFAULT '/var/lib/mysql-files/eco_';
DECLARE proposal VARCHAR(20);
DECLARE grant_number VARCHAR(10);
DECLARE fibi_award_id INT;
DECLARE title VARCHAR(1000);
DECLARE pi_name VARCHAR(90);
DECLARE pi_email_address VARCHAR(100);
DECLARE sponsor_name VARCHAR(200);
DECLARE q1055_answer VARCHAR(20) DEFAULT ' ';
DECLARE q1066_answer VARCHAR(20) DEFAULT ' ';
DECLARE q1064_answer VARCHAR(20) DEFAULT ' ';
DECLARE q1067_answer VARCHAR(20) DEFAULT ' ';
DECLARE q1011_answer VARCHAR(20) DEFAULT ' ';
DECLARE q1425_answer VARCHAR(20) DEFAULT ' ';
DECLARE q1426_answer VARCHAR(20) DEFAULT ' ';
DECLARE q1018_answer VARCHAR(20) DEFAULT ' ';
DECLARE q1010_answer VARCHAR(20) DEFAULT ' ';
DECLARE q1012_answer VARCHAR(20) DEFAULT ' ';
DECLARE q1047_answer VARCHAR(20) DEFAULT ' ';
DECLARE q1433_answer VARCHAR(20) DEFAULT ' ';
DECLARE q1058_answer VARCHAR(1000) DEFAULT ' ';
DECLARE group_d VARCHAR(1000) DEFAULT ' ';
DECLARE boycotting VARCHAR(1000) DEFAULT ' ';
DECLARE sanctioned VARCHAR(1000) DEFAULT ' ';
DECLARE module VARCHAR(20) DEFAULT ' ';
DECLARE module_code INT;
DECLARE quest_module_code INT;
DECLARE module_key VARCHAR(20);
DECLARE done INT DEFAULT FALSE;
DECLARE proposal_cursor CURSOR FOR
SELECT pd.proposal_id
        ,' ' AS award_number
        ,' ' AS award_id
        ,pd.proposal_id AS module_key
		,TRIM(REPLACE(REPLACE(REGEXP_REPLACE(pd.title, '^0-9A-Za-z"!()@#$%^*.\n          ,;:"/?><+=|/~`', ''), '\n', ' '), '''', '')) AS title
		,TRIM(REPLACE(REPLACE(REGEXP_REPLACE(pdi.full_name, '^0-9A-Za-z"!()@#$%^*.\n          ,;:"/?><+=|/~`', ''), '\n', ' '), '''', '')) AS pi_name
        ,COALESCE(p.email_address, 'Unavailable') AS email_address
		,TRIM(REPLACE(REPLACE(REGEXP_REPLACE(s.sponsor_name, '^0-9A-Za-z"!()@#$%^*.\n          ,;:"/?><+=|/~`', ''), '\n', ' '), '''', '')) AS sponsor_name
        ,'Proposal' AS module
        ,3 AS module_code
        ,3 AS quest_module_code
  FROM   eps_proposal pd
           LEFT JOIN custom_data cd ON  CAST(pd.proposal_id AS CHAR) = cd.module_item_key
                                    AND cd.update_timestamp > STR_TO_DATE('20231001', '%Y%m%d')
                                    AND    cd.custom_data_elements_id = 13
                                    AND    cd.module_item_code = 3
        ,eps_proposal_persons pdi
        ,person p
        ,sponsor s
  WHERE  pd.submission_date > STR_TO_DATE('20231001', '%Y%m%d')
  AND    pdi.pi_flag = 'Y'
  AND    cd.value IS NULL
  AND    pd.ip_number is not null
  AND    pd.proposal_id = pdi.proposal_id
  AND    pdi.person_id = p.person_id
  AND    pd.sponsor_code = s.sponsor_code
  UNION
  SELECT pd.proposal_id
		,SUBSTR(a.award_number, 1, 6)
        ,a.award_id
        ,a.award_id AS module_key
		,TRIM(REPLACE(REPLACE(REGEXP_REPLACE(pd.title, '^0-9A-Za-z !()@#$%^*.\n          ,;:"/?><+=|/~`', ''), '\n', ' '), '''', '')) AS title
		,TRIM(REPLACE(REPLACE(REGEXP_REPLACE(ai.full_name, '^0-9A-Za-z !()@#$%^*.\n          ,;:"/?><+=|/~`', ''), '\n', ' '), '''', '')) AS pi_name
        ,COALESCE(p.email_address, 'Unavailable') AS email_address
		,TRIM(REPLACE(REPLACE(REGEXP_REPLACE(s.sponsor_name, '^0-9A-Za-z"!()@#$%^*.\n          ,;:"/?><+=|/~`', ''), '\n', ' '), '''', '')) AS sponsor_name
        ,'Award' AS module
        ,1 AS module_code
        ,3 AS quest_module_code
  FROM   eps_proposal pd
        ,award a
		   LEFT JOIN custom_data cd ON  CAST(a.award_id AS CHAR) = cd.module_item_key
								    AND cd.update_timestamp > STR_TO_DATE('20231001', '%Y%m%d')
                                    AND cd.custom_data_elements_id = 13
                                    AND cd.module_item_code = 1
		,sap_grant g
        ,award_funding_proposals afp
        ,proposal_admin_details pad
        ,award_persons ai
        ,person p
        ,sponsor s
  WHERE  g.create_timestamp > STR_TO_DATE('20231001', '%Y%m%d')
-- and pd.proposal_id NOT IN ('232851', '231685', '223236', '226035', '226543')
  AND    ai.pi_flag = 'Y'
  AND    cd.value IS NULL
  AND    a.award_number LIKE '%-00001'
  AND    a.is_latest = 'Y'
  AND    pd.proposal_id = pad.dev_proposal_id
  AND    pad.inst_proposal_id = afp.proposal_id
  AND    afp.award_id = a.award_id
  AND    a.award_id = ai.award_id
  AND    ai.person_id = p.person_id
  AND    SUBSTR(a.award_number, 1, 6) = g.grant_number
  AND    a.sponsor_code = s.sponsor_code
    ORDER BY 1
;
/*
  UNION
  SELECT CAST(sr.sr_header_id AS CHAR(20)) AS proposal_id
		,SUBSTR(a.award_number, 1, 6)
        ,a.award_id as award_id
        ,sr.sr_header_id AS module_key
		,TRIM(REPLACE(REPLACE(REGEXP_REPLACE(a.title, '^0-9A-Za-z !()@#$%^*.\n          ,;:"/?><+=|/~`', ''), '\n', ' '), '''', '')) AS title
		,TRIM(REPLACE(REPLACE(REGEXP_REPLACE(ai.full_name, '^0-9A-Za-z !()@#$%^*.\n          ,;:"/?><+=|/~`', ''), '\n', ' '), '''', '')) AS pi_name
        ,COALESCE(ai.email_address, 'Unavailable') AS email_address
		,TRIM(REPLACE(REPLACE(REGEXP_REPLACE(s.sponsor_name, '^0-9A-Za-z"!()@#$%^*.\n          ,;:"/?><+=|/~`', ''), '\n', ' '), '''', '')) AS sponsor_name
        ,'Service Request' AS module
        ,20 AS module_code
        ,3 AS quest_module_code
FROM     sr_header sr
		   LEFT JOIN jhu_sr_custom_data cd ON  sr.sr_header_id = cd.module_item_key
                                           AND    cd.custom_data_elements_id = 13
                                           AND    cd.module_item_code = 1
		,award a
        ,award_persons ai
        ,sponsor s
  WHERE  ai.pi_flag = 'Y'
  AND    cd.value IS NULL
and CAST(sr.sr_header_id AS CHAR(20)) LIKE '1500a'
  AND    a.is_latest = 'Y'
  AND    sr.status_code IN (4, 5)
  AND    sr.module_item_key = a.award_id
  AND    a.award_id = ai.award_id
  AND    a.sponsor_code = s.sponsor_code
*/
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
OPEN proposal_cursor;
read_proposals: LOOP
  FETCH proposal_cursor INTO proposal, grant_number, fibi_award_id, module_key, title, pi_name, pi_email_address, sponsor_name, module, module_code, quest_module_code;
  IF done THEN
    LEAVE read_proposals;
  END IF;
select proposal;
  SELECT MAX(qa.answer)
  INTO   q1055_answer
  FROM   quest_answer_header qah
        ,quest_answer qa
        ,quest_question qq
  WHERE  qah.module_item_key = proposal
  AND    qah.module_item_code = quest_module_code
  AND    qa.questionnaire_ans_header_id = (SELECT MAX(iqah.questionnaire_ans_header_id)
                                            FROM   quest_answer_header iqah
												  ,quest_header iqh
  										    WHERE  iqah.module_item_key = proposal
                                            AND    iqh.questionnaire_number = 91
											AND    iqah.questionnaire_id = iqh.questionnaire_id)
  AND    qq.question like 'Q1055%'
  AND    qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id
  AND    qa.question_id = qq.question_id;
  SELECT MAX(qa.answer)
  INTO   q1066_answer
  FROM   quest_answer_header qah
        ,quest_answer qa
        ,quest_question qq
  WHERE  qah.module_item_key = proposal
  AND    qah.module_item_code = quest_module_code
  AND    qa.questionnaire_ans_header_id = (SELECT MAX(iqah.questionnaire_ans_header_id)
                                            FROM   quest_answer_header iqah
												  ,quest_header iqh
  										    WHERE  iqah.module_item_key = proposal
                                            AND    iqh.questionnaire_number IN (87, 88)
											AND    iqah.questionnaire_id = iqh.questionnaire_id)
  AND    qq.question like 'Q1066%'
  AND    qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id
  AND    qa.question_id = qq.question_id;
  SELECT MAX(qa.answer)
  INTO   q1064_answer
  FROM   quest_answer_header qah
        ,quest_answer qa
        ,quest_question qq
  WHERE  qah.module_item_key = proposal
  AND    qah.module_item_code = quest_module_code
  AND    qa.questionnaire_ans_header_id = (SELECT MAX(iqah.questionnaire_ans_header_id)
                                            FROM   quest_answer_header iqah
												  ,quest_header iqh
  										    WHERE  iqah.module_item_key = proposal
                                            AND    iqh.questionnaire_number = 91
											AND    iqah.questionnaire_id = iqh.questionnaire_id)
  AND    qq.question like 'Q1064%'
  AND    qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id
  AND    qa.question_id = qq.question_id;
  SELECT MAX(qa.answer)
  INTO   q1067_answer
  FROM   quest_answer_header qah
        ,quest_answer qa
        ,quest_question qq
  WHERE  qah.module_item_key = proposal
  AND    qah.module_item_code = quest_module_code
  AND    qa.questionnaire_ans_header_id = (SELECT MAX(iqah.questionnaire_ans_header_id)
                                            FROM   quest_answer_header iqah
												  ,quest_header iqh
  										    WHERE  iqah.module_item_key = proposal
                                            AND    iqh.questionnaire_number = 91
											AND    iqah.questionnaire_id = iqh.questionnaire_id)
  AND    qq.question like 'Q1067%'
  AND    qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id
  AND    qa.question_id = qq.question_id;
  SELECT MAX(qa.answer)
  INTO   q1011_answer
  FROM   quest_answer_header qah
        ,quest_answer qa
        ,quest_question qq
  WHERE  qah.module_item_key = proposal
  AND    qah.module_item_code = quest_module_code
  AND    qa.questionnaire_ans_header_id = (SELECT MAX(iqah.questionnaire_ans_header_id)
                                            FROM   quest_answer_header iqah
												  ,quest_header iqh
  										    WHERE  iqah.module_item_key = proposal
                                            AND    iqh.questionnaire_number = 87
											AND    iqah.questionnaire_id = iqh.questionnaire_id)
  AND    qq.question like 'Q1011%'
  AND    qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id
  AND    qa.question_id = qq.question_id;
  SELECT MAX(qa.answer)
  INTO   q1425_answer
  FROM   quest_answer_header qah
        ,quest_answer qa
        ,quest_question qq
  WHERE  qah.module_item_key = proposal
  AND    qah.module_item_code = quest_module_code
  AND    qa.questionnaire_ans_header_id = (SELECT MAX(iqah.questionnaire_ans_header_id)
                                            FROM   quest_answer_header iqah
												  ,quest_header iqh
  										    WHERE  iqah.module_item_key = proposal
                                            AND    iqh.questionnaire_number IN (46, 87, 88)
											AND    iqah.questionnaire_id = iqh.questionnaire_id)
  AND    qq.question like 'Q1425%'
  AND    qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id
  AND    qa.question_id = qq.question_id;
  SELECT MAX(qa.answer)
  INTO   q1426_answer
  FROM   quest_answer_header qah
        ,quest_answer qa
        ,quest_question qq
  WHERE  qah.module_item_key = proposal
  AND    qah.module_item_code = quest_module_code
  AND    qa.questionnaire_ans_header_id =  (SELECT MAX(iqah.questionnaire_ans_header_id)
                                            FROM   quest_answer_header iqah
												  ,quest_header iqh
  										    WHERE  iqah.module_item_key = proposal
                                            AND    iqh.questionnaire_number IN (87, 88)
											AND    iqah.questionnaire_id = iqh.questionnaire_id)
  AND    qq.question like 'Q1426%'
  AND    qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id
  AND    qa.question_id = qq.question_id;
  SELECT qa.answer
  INTO   q1018_answer
  FROM   quest_answer_header qah
        ,quest_answer qa
        ,quest_question qq
  WHERE  qah.module_item_key = proposal
  AND    qah.module_item_code = quest_module_code
  AND    qa.questionnaire_ans_header_id = (SELECT MAX(iqah.questionnaire_ans_header_id)
                                            FROM   quest_answer_header iqah
												  ,quest_header iqh
  										    WHERE  iqah.module_item_key = proposal
                                            AND    iqh.questionnaire_number = 87
											AND    iqah.questionnaire_id = iqh.questionnaire_id)
  AND    qq.question like 'Q1018%'
  AND    qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id
  AND    qa.question_id = qq.question_id;
  SELECT MAX(qa.answer)
  INTO   q1010_answer
  FROM   quest_answer_header qah
        ,quest_answer qa
        ,quest_question qq
  WHERE  qah.module_item_key = proposal
  AND    qah.module_item_code = quest_module_code
  AND    qa.questionnaire_ans_header_id = (SELECT MAX(iqah.questionnaire_ans_header_id)
                                            FROM   quest_answer_header iqah
												  ,quest_header iqh
  										    WHERE  iqah.module_item_key = proposal
                                            AND    iqh.questionnaire_number = 87
											AND    iqah.questionnaire_id = iqh.questionnaire_id)
  AND    qq.question like 'Q1010%'
  AND    qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id
  AND    qa.question_id = qq.question_id;
  SELECT MAX(qa.answer)
  INTO   q1012_answer
  FROM   quest_answer_header qah
        ,quest_answer qa
        ,quest_question qq
  WHERE  qah.module_item_key = proposal
  AND    qah.module_item_code = quest_module_code
  AND    qa.questionnaire_ans_header_id = (SELECT MAX(iqah.questionnaire_ans_header_id)
                                            FROM   quest_answer_header iqah
												  ,quest_header iqh
  										    WHERE  iqah.module_item_key = proposal
                                            AND    iqh.questionnaire_number = 87
											AND    iqah.questionnaire_id = iqh.questionnaire_id)
  AND    qq.question like 'Q1012%'
  AND    qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id
  AND    qa.question_id = qq.question_id;
  SELECT MAX(qa.answer)
  INTO   q1047_answer
  FROM   quest_answer_header qah
        ,quest_answer qa
        ,quest_question qq
  WHERE  qah.module_item_key = proposal
  AND    qah.module_item_code = quest_module_code
  AND    qa.questionnaire_ans_header_id = (SELECT MAX(iqah.questionnaire_ans_header_id)
                                            FROM   quest_answer_header iqah
												  ,quest_header iqh
  										    WHERE  iqah.module_item_key = proposal
                                            AND    iqh.questionnaire_number = 87
											AND    iqah.questionnaire_id = iqh.questionnaire_id)
  AND    qq.question like 'Q1047%'
  AND    qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id
  AND    qa.question_id = qq.question_id;
  SELECT MAX(qa.answer)
  INTO   q1433_answer
  FROM   quest_answer_header qah
        ,quest_answer qa
        ,quest_question qq
  WHERE  qah.module_item_key = proposal
  AND    qah.module_item_code = quest_module_code
  AND    qa.questionnaire_ans_header_id = (SELECT MAX(iqah.questionnaire_ans_header_id)
                                            FROM   quest_answer_header iqah
												  ,quest_header iqh
  										    WHERE  iqah.module_item_key = proposal
                                            AND    iqh.questionnaire_number = 87
											AND    iqah.questionnaire_id = iqh.questionnaire_id)
  AND    qq.question like 'Q1433%'
  AND    qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id
  AND    qa.question_id = qq.question_id;
  SELECT DISTINCT('Yes')
  INTO   q1058_answer
  FROM   quest_answer_header qah
        ,quest_answer qa
        ,quest_question qq
  WHERE  qah.module_item_key = proposal
  AND    qah.module_item_code = quest_module_code
  AND    qa.questionnaire_ans_header_id = (SELECT MAX(iqah.questionnaire_ans_header_id)
                                            FROM   quest_answer_header iqah
												  ,quest_header iqh
  										    WHERE  iqah.module_item_key = proposal
                                            AND    iqh.questionnaire_number = 91
											AND    iqah.questionnaire_id = iqh.questionnaire_id)
  AND    qq.question like 'Q1058%'
  AND    qa.answer LIKE 'U.S. or%'
  AND    qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id
  AND    qa.question_id = qq.question_id;
 CALL jhu_create_value_view_proc('qa.answer',
                                 'quest_answer_header qah, quest_answer qa',
								 CONCAT('qa.answer IN (select c.country_name from jhu_sanctioned_country s, country c
                                                        where s.group_d = ''Y'' AND s.country_code = c.country_code)
                                 AND  qah.module_item_key = ''', proposal,'''
                                 AND    qa.question_id IN (SELECT question_id FROM quest_question WHERE question LIKE ''Q1057%'')
                                 AND    qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id ORDER BY qa.answer'));
  SET group_d = jhu_get_formatted_values_fn();
  IF LENGTH(TRIM(group_d)) < 2
  THEN
     SET group_d = 'None';
  END IF;
 CALL jhu_create_value_view_proc('qa.answer',
                                 'quest_answer_header qah, quest_answer qa',
								 CONCAT('qa.answer IN (select c.country_name from jhu_sanctioned_country s, country c
                                                        where s.boycotting = ''Y'' AND s.country_code = c.country_code)
                                 AND  qah.module_item_key = ''', proposal,'''
                                 AND    qa.question_id IN (SELECT question_id FROM quest_question WHERE question LIKE ''Q1057%'')
                                 AND    qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id ORDER BY qa.answer'));
  SET boycotting = jhu_get_formatted_values_fn();
  IF LENGTH(TRIM(boycotting)) < 2
  THEN
     SET boycotting = 'None';
  END IF;
 CALL jhu_create_value_view_proc('qa.answer',
                                 'quest_answer_header qah, quest_answer qa',
								 CONCAT('qa.answer IN (select c.country_name from jhu_sanctioned_country s, country c
                                                        where s.sanctioned = ''Y'' AND s.country_code = c.country_code)
                                 AND  qah.module_item_key = ''', proposal,'''
                                 AND    qa.question_id IN (SELECT question_id FROM quest_question WHERE question LIKE ''Q1057%'')
                                 AND    qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id ORDER BY qa.answer'));
  SET sanctioned = jhu_get_formatted_values_fn();
  IF LENGTH(TRIM(sanctioned)) < 2
  THEN
     SET sanctioned = 'None';
  END IF;
  IF q1055_answer = 'Yes'
  OR q1066_answer = 'Yes'
  OR q1064_answer = 'Yes'
  OR q1067_answer = 'Yes'
  OR q1011_answer = 'Yes'
  OR q1425_answer = 'Yes'
  OR q1426_answer = 'Yes'
  OR q1018_answer = 'Yes'
  OR q1010_answer = 'Yes'
  OR q1012_answer = 'Yes'
  OR q1047_answer = 'Yes'
  OR q1433_answer = 'Yes'
  THEN
/*
SELECT proposal; DO SLEEP(2);
SELECT grant_number; DO SLEEP(2);
SELECT title; DO SLEEP(2);
SELECT pi_name; DO SLEEP(2);
SELECT pi_email_address; DO SLEEP(2);
SELECT sponsor_name; DO SLEEP(2);
SELECT q1055_answer; DO SLEEP(2);
SELECT q1011_answer; DO SLEEP(2);
SELECT q1066_answer; DO SLEEP(2);
SELECT q1064_answer; DO SLEEP(2);
SELECT q1067_answer; DO SLEEP(2);
SELECT q1425_answer; DO SLEEP(2);
SELECT q1426_answer; DO SLEEP(2);
SELECT q1018_answer; DO SLEEP(2);
SELECT q1010_answer; DO SLEEP(2);
SELECT q1012_answer; DO SLEEP(2);
SELECT q1047_answer; DO SLEEP(2);
SELECT q1433_answer; DO SLEEP(2);
SELECT q1058_answer; DO SLEEP(2);
SELECT group_d; DO SLEEP(2);
SELECT boycotting; DO SLEEP(2);
SELECT sanctioned; DO SLEEP(2);
SELECT module; DO SLEEP(2);
*/
    SET filename = CONCAT('''/var/lib/mysql-files/eco_', proposal, '_', TRIM(CAST(module_code AS CHAR(10))), '.txt''');
    SET @eco = CONCAT('SELECT ''', proposal, '|'
				 	 			 , grant_number, '|'
                                 , title, '|'
                                 , pi_name, '|'
                                 , pi_email_address, '|'
                                 , sponsor_name, '|'
                                 , COALESCE(q1055_answer, ' '), '|'
                                 , COALESCE(q1011_answer, ' '), '|'
					 	 	     , COALESCE(q1066_answer, ' '), '|'
    							 , COALESCE(q1064_answer, ' '), '|'
								 , COALESCE(q1067_answer, ' '), '|'
                                 , COALESCE(q1425_answer, ' '), '|'
                                 , COALESCE(q1426_answer, ' '), '|'
                                 , COALESCE(q1018_answer, ' '), '|'
                                 , COALESCE(q1010_answer, ' '), '|'
                                 , COALESCE(q1012_answer, ' '), '|'
                                 , COALESCE(q1047_answer, ' '), '|'
                                 , COALESCE(q1433_answer, ' '), '|'
				    			 , COALESCE(q1058_answer, ' '), '|'
				 	    		 , group_d, '|'
				 				 , boycotting, '|'
					 			 , sanctioned, '|'
						 		 , module, '|'
                                 , ''' INTO OUTFILE ', filename);
-- select 'a';
    PREPARE stmt FROM @eco;
--    select 'a1';
    EXECUTE stmt;
--    select 'a2';
    DEALLOCATE PREPARE stmt;
-- select 'b';
    IF module = 'Service Request'
    THEN
      INSERT INTO jhu_sr_custom_data (custom_data_elements_id,
								      module_item_code,
                                      module_sub_item_code,
                                      module_item_key,
                                      module_sub_item_key,
                                      value,
                                      update_timestamp,
                                      update_user,
                                      column_id,
                                      column_version_number,
                                      description)
      VALUES (13,
              module_code,
              0,
              module_key,
              0,
              DATE_FORMAT(UTC_TIMESTAMP(), '%Y-%m-%d'),
              UTC_TIMESTAMP(),
              'ECO',
              13,
              1,
              NULL);
	ELSE
      INSERT INTO custom_data (custom_data_elements_id,
                               module_item_code,
                               module_sub_item_code,
                               module_item_key,
                               module_sub_item_key,
                               value,
                               update_timestamp,
                               update_user,
                               -- column_id,
                               -- column_version_number,
                               description)
      VALUES (13,
              module_code,
              0,
              module_key,
              0,
              DATE_FORMAT(UTC_TIMESTAMP(), '%Y-%m-%d'),
              UTC_TIMESTAMP(),
              'ECO',
              -- 13,
              -- 1,
              NULL);
   END IF;
  ELSE
    INSERT INTO custom_data (custom_data_elements_id,
                             module_item_code,
                             module_sub_item_code,
                             module_item_key,
                             module_sub_item_key,
                             value,
                             update_timestamp,
                             update_user,
                             -- column_id,
                             -- column_version_number,
                             description)
    VALUES (13,
            module_code,
            0,
            module_key,
            0,
            'N/A',
            UTC_TIMESTAMP(),
            'ECO',
            -- 13,
            -- 1,
            NULL);
-- select 'c';
  END IF;
-- select 'd';
  SET done = FALSE;
  SET q1055_answer = ' ';
  SET q1066_answer = ' ';
  SET q1064_answer = ' ';
  SET q1067_answer = ' ';
  SET q1010_answer = ' ';
  SET q1011_answer = ' ';
  SET q1012_answer = ' ';
  SET q1425_answer = ' ';
  SET q1426_answer = ' ';
  SET q1018_answer = ' ';
  SET q1047_answer = ' ';
  SET q1433_answer = ' ';
  SET q1058_answer = ' ';
  SET group_d = ' ';
  SET boycotting = ' ';
  SET sanctioned = ' ';
-- select filename;
  END LOOP read_proposals;
  CLOSE proposal_cursor;
  COMMIT;
END
$$
DELIMITER ;
