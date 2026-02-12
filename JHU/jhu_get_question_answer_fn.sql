DELIMITER $$
CREATE  FUNCTION `jhu_get_question_answer_fn`(
  pd_proposal_id_in         int(10)
 ,questionnaire_id_in       VARCHAR(10)
 ,person_id_in              VARCHAR(8)
 ,question_substring_in     VARCHAR(10)
) RETURNS varchar(2000) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE return_string VARCHAR(2000) DEFAULT ' ';
  SELECT TRIM(REPLACE(REPLACE(REGEXP_REPLACE(qa.answer, '^0-9A-Za-z"!()@#$%^*.\n          ,;:"/?><+=|/~`', ''), '\n', ' '), '''', '')) AS answer
  INTO   return_string
  FROM   quest_answer qa
  WHERE  qa.questionnaire_answer_id = (SELECT MAX(iqa.questionnaire_answer_id)
                                       FROM  quest_answer_header iqah
                                            ,quest_answer iqa
                                            ,quest_question iqq
                                       WHERE  iqah.module_item_key = pd_proposal_id_in
                                       AND    iqah.questionnaire_id = questionnaire_id_in
                                       AND    iqah.module_item_code = 3
                                       AND    iqq.question like CONCAT(question_substring_in, '%')
                                       AND    iqah.module_sub_item_key = person_id_in
                                       AND    iqah.questionnaire_ans_header_id = iqa.questionnaire_ans_header_id
                                       AND    iqa.question_id = iqq.question_id);
IF TRIM(return_string) < 1
THEN
  SELECT qa.answer
  INTO   return_string
  FROM   quest_answer qa
  WHERE  qa.questionnaire_answer_id = (SELECT MAX(iqa.questionnaire_answer_id)
                                       FROM  quest_answer_header iqah
                                            ,quest_answer iqa
                                            ,quest_question iqq
                                       WHERE  iqah.module_item_key = pd_proposal_id_in
                                       AND    iqah.questionnaire_id = questionnaire_id_in
                                       AND    iqah.module_item_code = 3
                                       AND    iqq.question like CONCAT(question_substring_in, '%')
									   AND    TRIM(CONCAT(' ', iqah.module_sub_item_key)) < 8
                                       AND    iqah.questionnaire_ans_header_id = iqa.questionnaire_ans_header_id
                                       AND    iqa.question_id = iqq.question_id);
                                       /*
                                       UNION
                                       SELECT MAX(iqa.questionnaire_answer_id)
                                       FROM  quest_answer_header iqah
                                            ,quest_answer iqa
                                            ,quest_question iqq
                                       WHERE  iqah.module_item_key = pd_proposal_id_in
                                       AND    iqq.question like CONCAT(question_substring_in, '%')
                                       AND    iqah.module_sub_item_key = person_id_in
                                       AND    iqah.questionnaire_ans_header_id = iqa.questionnaire_ans_header_id
                                       AND    iqa.question_id = iqq.question_id); */
END IF;
RETURN RETURN_STRING;
END
$$
DELIMITER ;
