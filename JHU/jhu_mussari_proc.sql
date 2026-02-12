DELIMITER $$
CREATE  PROCEDURE `jhu_mussari_proc`()
BEGIN
DECLARE filename VARCHAR(200) DEFAULT '/var/lib/mysql-files/eco_';
DECLARE full_string VARCHAR(20000) DEFAULT ' ';
DECLARE proposal VARCHAR(20);
DECLARE ip_number VARCHAR(20);
DECLARE grant_number VARCHAR(10);
DECLARE fibi_award_id INT;
DECLARE title VARCHAR(1000);
DECLARE pi_name VARCHAR(90);
DECLARE person_id VARCHAR(10);
DECLARE pi_email_address VARCHAR(100);
DECLARE sponsor_name VARCHAR(200);
DECLARE q1055_answer VARCHAR(20) DEFAULT ' ';
DECLARE q1063_answer VARCHAR(1000) DEFAULT ' ';
DECLARE q1066_answer VARCHAR(20) DEFAULT ' ';
DECLARE q1067_answer VARCHAR(20) DEFAULT ' ';
DECLARE q1078_answer VARCHAR(20) DEFAULT ' ';
DECLARE q1090_answer VARCHAR(20) DEFAULT ' ';
DECLARE q1107_answer VARCHAR(20) DEFAULT ' ';
DECLARE q1112_answer VARCHAR(20) DEFAULT ' ';
DECLARE q1115_answer VARCHAR(20) DEFAULT ' ';
DECLARE q1134_answer VARCHAR(20) DEFAULT ' ';
DECLARE q1135_answer VARCHAR(20) DEFAULT ' ';
DECLARE q1136_answer VARCHAR(20) DEFAULT ' ';
DECLARE q1137_answer VARCHAR(20) DEFAULT ' ';
DECLARE q1425_answer VARCHAR(20) DEFAULT ' ';
DECLARE q1426_answer VARCHAR(20) DEFAULT ' ';
DECLARE q1431_answer VARCHAR(20) DEFAULT ' ';
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
        ,pd.ip_number
	    ,g.grant_number
        ,pdi.full_name
        ,s.sponsor_name
        ,p.person_id
        ,p.email_address
  FROM   eps_proposal pd
        ,sap_grant g
        ,eps_proposal_persons pdi
        ,person p
        ,sponsor s
  WHERE  STR_TO_DATE(g.grant_end_date, '%Y%m%d') > NOW()
  AND    pd.ip_number = g.proposal_number
  AND    pd.proposal_id = pdi.proposal_id
  -- and g.grant_number LIKE '1510%'
  AND    pdi.person_id = p.person_id
  AND    pd.sponsor_code = s.sponsor_code
  ORDER BY 1
;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
/*
     SET full_string = CONCAT('PD Number', '|'
				 	 			 , 'IP Number', '|'
                                 , 'Grant Number', '|'
                                 , 'PI', '|'
                                 , 'PI Email Address', '|'
                                 , 'Sponsor', '|'
                                 , 'Q1055', '|'
                                 , 'Q1063', '|'
					 	 	     , 'Q1066', '|'
    							 , 'Q1067', '|'
								 , 'Q1078', '|'
                                 , 'Q1090', '|'
                                 , 'Q1107', '|'
                                 , 'Q1112', '|'
                                 , 'Q1115', '|'
                                 , 'Q1134', '|'
                                 , 'Q1135', '|'
                                 , 'Q1136', '|'
				    			 , 'Q1137', '|'
                                 , 'Q1425', '|'
                                 , 'Q1426', '|'
                                 , 'Q1431', '|'
                                 ,'\r');
                                 */
OPEN proposal_cursor;
read_proposals: LOOP
  FETCH proposal_cursor INTO proposal, ip_number, grant_number, pi_name, sponsor_name, person_id, pi_email_address;
  IF done THEN
    LEAVE read_proposals;
  END IF;
-- select proposal;
  SELECT MAX(qa.answer)
  INTO   q1055_answer
  FROM   quest_answer_header qah
        ,quest_answer qa
        ,quest_question qq
  WHERE  qah.module_item_key = proposal
  AND    qah.module_item_code = 3
  AND    qa.questionnaire_ans_header_id = (SELECT MAX(iqah.questionnaire_ans_header_id)
                                            FROM   quest_answer_header iqah
												  ,quest_header iqh
  										    WHERE  iqah.module_item_key = proposal
                                            AND    iqh.questionnaire_number = 91
											AND    iqah.questionnaire_id = iqh.questionnaire_id)
  AND    qq.question like 'Q1055%'
  AND    qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id
  AND    qa.question_id = qq.question_id;
 SELECT MAX(REPLACE(REGEXP_REPLACE(qa.answer, '[^0-9A-Za-z ]', ''), '\n', ' '))
  INTO   q1063_answer
  FROM   quest_answer_header qah
        ,quest_answer qa
        ,quest_question qq
  WHERE  qah.module_item_key = proposal
  AND    qah.module_item_code = 3
  AND    qa.questionnaire_ans_header_id = (SELECT MAX(iqah.questionnaire_ans_header_id)
                                            FROM   quest_answer_header iqah
												  ,quest_header iqh
  										    WHERE  iqah.module_item_key = proposal
                                            AND    iqh.questionnaire_number = 91
											AND    iqah.questionnaire_id = iqh.questionnaire_id)
  AND    qq.question like 'Q1063%'
  AND    qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id
  AND    qa.question_id = qq.question_id;
  SELECT MAX(qa.answer)
  INTO   q1066_answer
  FROM   quest_answer_header qah
        ,quest_answer qa
        ,quest_question qq
  WHERE  qah.module_item_key = proposal
  AND    qah.module_item_code = 3
  AND    qa.questionnaire_ans_header_id = (SELECT MAX(iqah.questionnaire_ans_header_id)
                                            FROM   quest_answer_header iqah
												  ,quest_header iqh
  										    WHERE  iqah.module_item_key = proposal
                                            AND    iqh.questionnaire_number IN (46, 87, 88)
											AND    iqah.questionnaire_id = iqh.questionnaire_id)
  AND    qq.question like 'Q1066%'
  AND    qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id
  AND    qa.question_id = qq.question_id;
  SELECT MAX(qa.answer)
  INTO   q1067_answer
  FROM   quest_answer_header qah
        ,quest_answer qa
        ,quest_question qq
  WHERE  qah.module_item_key = proposal
  AND    qah.module_item_code = 3
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
  INTO   q1078_answer
  FROM   quest_answer_header qah
        ,quest_answer qa
        ,quest_question qq
  WHERE  qah.module_item_key = proposal
  AND    qah.module_item_code = 3
  AND    qa.questionnaire_ans_header_id = (SELECT MAX(iqah.questionnaire_ans_header_id)
                                            FROM   quest_answer_header iqah
												  ,quest_header iqh
  										    WHERE  iqah.module_item_key = proposal
                                            AND    iqah.module_sub_item_key = person_id
                                            AND    iqh.questionnaire_number = 90
											AND    iqah.questionnaire_id = iqh.questionnaire_id)
  AND    qq.question like 'Q1078%'
  AND    qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id
  AND    qa.question_id = qq.question_id;
  SELECT MAX(qa.answer)
  INTO   q1090_answer
  FROM   quest_answer_header qah
        ,quest_answer qa
        ,quest_question qq
  WHERE  qah.module_item_key = proposal
  AND    qah.module_item_code = 3
  AND    qa.questionnaire_ans_header_id = (SELECT MAX(iqah.questionnaire_ans_header_id)
                                            FROM   quest_answer_header iqah
												  ,quest_header iqh
  										    WHERE  iqah.module_item_key = proposal
                                            AND    iqh.questionnaire_number = 91
											AND    iqah.questionnaire_id = iqh.questionnaire_id)
  AND    qq.question like 'Q1090%'
  AND    qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id
  AND    qa.question_id = qq.question_id;
  SELECT MAX(qa.answer)
  INTO   q1107_answer
  FROM   quest_answer_header qah
        ,quest_answer qa
        ,quest_question qq
  WHERE  qah.module_item_key = proposal
  AND    qah.module_item_code = 3
  AND    qa.questionnaire_ans_header_id = (SELECT MAX(iqah.questionnaire_ans_header_id)
                                            FROM   quest_answer_header iqah
												  ,quest_header iqh
  										    WHERE  iqah.module_item_key = proposal
                                            AND    iqh.questionnaire_number IN (46, 87, 88)
											AND    iqah.questionnaire_id = iqh.questionnaire_id)
  AND    qq.question like 'Q1107%'
  AND    qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id
  AND    qa.question_id = qq.question_id;
  SELECT MAX(qa.answer)
  INTO   q1112_answer
  FROM   quest_answer_header qah
        ,quest_answer qa
        ,quest_question qq
  WHERE  qah.module_item_key = proposal
  AND    qah.module_item_code = 3
  AND    qa.questionnaire_ans_header_id = (SELECT MAX(iqah.questionnaire_ans_header_id)
                                            FROM   quest_answer_header iqah
												  ,quest_header iqh
  										    WHERE  iqah.module_item_key = proposal
                                            AND    iqh.questionnaire_number = 91
											AND    iqah.questionnaire_id = iqh.questionnaire_id)
  AND    qq.question like 'Q1112%'
  AND    qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id
  AND    qa.question_id = qq.question_id;
  SELECT MAX(qa.answer)
  INTO   q1115_answer
  FROM   quest_answer_header qah
        ,quest_answer qa
        ,quest_question qq
  WHERE  qah.module_item_key = proposal
  AND    qah.module_item_code = 3
  AND    qa.questionnaire_ans_header_id = (SELECT MAX(iqah.questionnaire_ans_header_id)
                                            FROM   quest_answer_header iqah
												  ,quest_header iqh
  										    WHERE  iqah.module_item_key = proposal
                                             AND    iqah.module_sub_item_key = person_id
                                            AND    iqh.questionnaire_number = 90
											AND    iqah.questionnaire_id = iqh.questionnaire_id)
  AND    qq.question like 'Q1115%'
  AND    qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id
  AND    qa.question_id = qq.question_id;
  SELECT MAX(qa.answer)
  INTO   q1134_answer
  FROM   quest_answer_header qah
        ,quest_answer qa
        ,quest_question qq
  WHERE  qah.module_item_key = proposal
  AND    qah.module_item_code = 3
  AND    qa.questionnaire_ans_header_id = (SELECT MAX(iqah.questionnaire_ans_header_id)
                                            FROM   quest_answer_header iqah
												  ,quest_header iqh
  										    WHERE  iqah.module_item_key = proposal
											AND    iqah.module_sub_item_key = person_id
                                            AND    iqh.questionnaire_number = 90
											AND    iqah.questionnaire_id = iqh.questionnaire_id)
  AND    qq.question like 'Q1134%'
  AND    qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id
  AND    qa.question_id = qq.question_id;
  SELECT MAX(qa.answer)
  INTO   q1135_answer
  FROM   quest_answer_header qah
        ,quest_answer qa
        ,quest_question qq
  WHERE  qah.module_item_key = proposal
  AND    qah.module_item_code = 3
  AND    qa.questionnaire_ans_header_id = (SELECT MAX(iqah.questionnaire_ans_header_id)
                                            FROM   quest_answer_header iqah
												  ,quest_header iqh
  										    WHERE  iqah.module_item_key = proposal
											AND    iqah.module_sub_item_key = person_id
                                            AND    iqh.questionnaire_number = 90
											AND    iqah.questionnaire_id = iqh.questionnaire_id)
  AND    qq.question like 'Q1135%'
  AND    qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id
  AND    qa.question_id = qq.question_id;
  SELECT MAX(qa.answer)
  INTO   q1136_answer
  FROM   quest_answer_header qah
        ,quest_answer qa
        ,quest_question qq
  WHERE  qah.module_item_key = proposal
  AND    qah.module_item_code = 3
  AND    qa.questionnaire_ans_header_id = (SELECT MAX(iqah.questionnaire_ans_header_id)
                                            FROM   quest_answer_header iqah
												  ,quest_header iqh
  										    WHERE  iqah.module_item_key = proposal
											AND    iqah.module_sub_item_key = person_id
                                            AND    iqh.questionnaire_number = 90
											AND    iqah.questionnaire_id = iqh.questionnaire_id)
  AND    qq.question like 'Q1136%'
  AND    qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id
  AND    qa.question_id = qq.question_id;
  SELECT MAX(qa.answer)
  INTO   q1137_answer
  FROM   quest_answer_header qah
        ,quest_answer qa
        ,quest_question qq
  WHERE  qah.module_item_key = proposal
  AND    qah.module_item_code = 3
  AND    qa.questionnaire_ans_header_id = (SELECT MAX(iqah.questionnaire_ans_header_id)
                                            FROM   quest_answer_header iqah
												  ,quest_header iqh
  										    WHERE  iqah.module_item_key = proposal
											AND    iqah.module_sub_item_key = person_id
                                            AND    iqh.questionnaire_number = 90
											AND    iqah.questionnaire_id = iqh.questionnaire_id)
  AND    qq.question like 'Q1137%'
  AND    qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id
  AND    qa.question_id = qq.question_id;
  SELECT MAX(qa.answer)
  INTO   q1425_answer
  FROM   quest_answer_header qah
        ,quest_answer qa
        ,quest_question qq
  WHERE  qah.module_item_key = proposal
  AND    qah.module_item_code = 3
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
  AND    qah.module_item_code = 3
  AND    qa.questionnaire_ans_header_id =  (SELECT MAX(iqah.questionnaire_ans_header_id)
                                            FROM   quest_answer_header iqah
												  ,quest_header iqh
  										    WHERE  iqah.module_item_key = proposal
                                            AND    iqh.questionnaire_number IN (46, 87, 88)
											AND    iqah.questionnaire_id = iqh.questionnaire_id)
  AND    qq.question like 'Q1426%'
  AND    qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id
  AND    qa.question_id = qq.question_id;
  SELECT qa.answer
  INTO   q1431_answer
  FROM   quest_answer_header qah
        ,quest_answer qa
        ,quest_question qq
  WHERE  qah.module_item_key = proposal
  AND    qah.module_item_code = 3
  AND    qa.questionnaire_ans_header_id = (SELECT MAX(iqah.questionnaire_ans_header_id)
                                            FROM   quest_answer_header iqah
												  ,quest_header iqh
  										    WHERE  iqah.module_item_key = proposal
											AND    iqah.module_sub_item_key = person_id
                                            AND    iqh.questionnaire_number = 90
											AND    iqah.questionnaire_id = iqh.questionnaire_id)
  AND    qq.question like 'Q1431%'
  AND    qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id
  AND    qa.question_id = qq.question_id;
 /*
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
*/
  IF q1055_answer = 'Yes'
  OR q1063_answer = 'Yes'
  OR q1066_answer = 'Yes'
  OR q1067_answer = 'Yes'
  OR q1078_answer = 'Yes'
  OR q1090_answer = 'Yes'
  OR q1107_answer = 'Yes'
  OR q1112_answer = 'Yes'
  OR q1115_answer = 'Yes'
  OR q1134_answer = 'Yes'
  OR q1135_answer = 'Yes'
  OR q1136_answer = 'Yes'
  OR q1137_answer = 'Yes'
  OR q1425_answer = 'Yes'
  OR q1426_answer = 'Yes'
  OR q1431_answer = 'Yes'
  THEN
 /*
	SET full_string = CONCAT(TRIM(full_string)
					        , proposal, '|'
				 	 			 , ip_number, '|'
                                 , grant_number, '|'
                                 , pi_name, '|'
                                 , pi_email_address, '|'
                                 , sponsor_name, '|'
                                 , COALESCE(q1055_answer, ' '), '|'
                                 , COALESCE(q1063_answer, ' '), '|'
					 	 	     , COALESCE(q1066_answer, ' '), '|'
    							 , COALESCE(q1067_answer, ' '), '|'
								 , COALESCE(q1078_answer, ' '), '|'
                                 , COALESCE(q1090_answer, ' '), '|'
                                 , COALESCE(q1107_answer, ' '), '|'
                                 , COALESCE(q1112_answer, ' '), '|'
                                 , COALESCE(q1115_answer, ' '), '|'
                                 , COALESCE(q1134_answer, ' '), '|'
                                 , COALESCE(q1135_answer, ' '), '|'
                                 , COALESCE(q1136_answer, ' '), '|'
				    			 , COALESCE(q1137_answer, ' '), '|'
                                 , COALESCE(q1425_answer, ' '), '|'
                                 , COALESCE(q1426_answer, ' '), '|'
                                 , COALESCE(q1431_answer, ' '), '|'
	 					  ,'\r');
-- select 'a';
--    PREPARE stmt FROM @eco;
--    select 'a1';
--    EXECUTE stmt;
--    select 'a2';
--    DEALLOCATE PREPARE stmt;
-- select 'b';
*/
INSERT INTO jhu_tmp_report_table VALUES (
  proposal
, ip_number
, grant_number
, pi_name
, pi_email_address
, sponsor_name
, COALESCE(q1055_answer, ' ')
, COALESCE(q1063_answer, ' ')
, COALESCE(q1066_answer, ' ')
, COALESCE(q1067_answer, ' ')
, COALESCE(q1078_answer, ' ')
, COALESCE(q1090_answer, ' ')
, COALESCE(q1107_answer, ' ')
, COALESCE(q1112_answer, ' ')
, COALESCE(q1115_answer, ' ')
, COALESCE(q1134_answer, ' ')
, COALESCE(q1135_answer, ' ')
, COALESCE(q1136_answer, ' ')
, COALESCE(q1137_answer, ' ')
, COALESCE(q1425_answer, ' ')
, COALESCE(q1426_answer, ' ')
, COALESCE(q1431_answer, ' '));
  END IF;
-- select 'd';
  SET done = FALSE;
  SET q1055_answer = ' ';
  SET q1063_answer = ' ';
  SET q1066_answer = ' ';
  SET q1067_answer = ' ';
  SET q1078_answer = ' ';
  SET q1090_answer = ' ';
  SET q1107_answer = ' ';
  SET q1112_answer = ' ';
  SET q1115_answer = ' ';
  SET q1134_answer = ' ';
  SET q1135_answer = ' ';
  SET q1136_answer = ' ';
  SET q1137_answer = ' ';
  SET q1425_answer = ' ';
  SET q1426_answer = ' ';
  SET q1431_answer = ' ';
  END LOOP read_proposals;
  /*
     SET filename = '''/var/lib/mysql-files/mussari.txt''';
    -- SET filename = CONCAT('''/var/lib/mysql-files/qa_rpt_', award_end_date_in, '_', unit_in, '_', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'), '.txt''');
  SET @eco = CONCAT('SELECT ''', full_string, ''' INTO OUTFILE ', filename);
  PREPARE stmt FROM @eco;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;
  */
  CLOSE proposal_cursor;
END
$$
DELIMITER ;
