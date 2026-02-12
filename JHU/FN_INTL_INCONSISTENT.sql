DELIMITER $$
CREATE  FUNCTION `FN_INTL_INCONSISTENT`(
  AV_PROPOSAL_ID   int(10)
) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE q_1055_yes_count int;
DECLARE q_1056_yes_count int;
DECLARE q_1112_yes_count int;
DECLARE RETURN_STRING VARCHAR(5) DEFAULT 'FALSE';
SELECT  count(*)
INTO    q_1055_yes_count
FROM    quest_answer_header qah
       ,quest_answer qa
WHERE   qah.module_item_key = AV_PROPOSAL_ID
AND     qa.question_id = 7269
AND     qa.answer = 'Yes'
AND     qa.questionnaire_ans_header_id = (SELECT MAX(iqa.questionnaire_ans_header_id)
                                          FROM   quest_answer_header iqah
                                                ,quest_answer iqa
                                          WHERE  iqah.module_item_key = AV_PROPOSAL_ID
                                          AND    iqa.question_id = 7269
                                          AND    iqah.questionnaire_ans_header_id = iqa.questionnaire_ans_header_id)
AND     qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id;
IF q_1055_yes_count > 0 THEN
  SELECT  count(*)
  INTO    q_1056_yes_count
  FROM    quest_answer_header qah
         ,quest_answer qa
  WHERE   qah.module_item_key = AV_PROPOSAL_ID
  AND     qa.question_id = 7270
  AND     qa.answer = 'Yes'
  AND     qa.questionnaire_ans_header_id = (SELECT MAX(iqa.questionnaire_ans_header_id)
                                            FROM   quest_answer_header iqah
                                                  ,quest_answer iqa
                                            WHERE  iqah.module_item_key = AV_PROPOSAL_ID
                                            AND    iqa.question_id = 7270
                                            AND    iqah.questionnaire_ans_header_id = iqa.questionnaire_ans_header_id)
  AND     qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id;
  SELECT  count(*)
  INTO    q_1112_yes_count
  FROM    quest_answer_header qah
         ,quest_answer qa
  WHERE   qah.module_item_key = AV_PROPOSAL_ID
  AND     qa.question_id = 7328
  AND     qa.answer = 'Yes'
  AND     qa.questionnaire_ans_header_id = (SELECT MAX(iqa.questionnaire_ans_header_id)
                                            FROM   quest_answer_header iqah
                                                  ,quest_answer iqa
                                            WHERE  iqah.module_item_key = AV_PROPOSAL_ID
                                            AND    iqa.question_id = 7328
                                            AND    iqah.questionnaire_ans_header_id = iqa.questionnaire_ans_header_id)
  AND     qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id;
END IF;
IF  q_1055_yes_count > 0
AND q_1056_yes_count < 1
AND q_1112_yes_count < 1
THEN
   SET RETURN_STRING = 'TRUE';
END IF;
RETURN RETURN_STRING;
END
$$
DELIMITER ;
