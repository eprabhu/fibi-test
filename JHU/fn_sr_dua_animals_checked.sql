DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` FUNCTION `fn_sr_dua_animals_checked`(
  AV_SR_HEADER_ID   int(10)
) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE LI_COUNT int;
DECLARE RETURN_STRING VARCHAR(5) DEFAULT 'FALSE';
 SELECT COUNT(*)
 INTO   li_count
 FROM   quest_answer_header qah
       ,quest_answer qa
       ,quest_question qq
 WHERE  qah.module_item_key = AV_SR_HEADER_ID
 AND    qah.module_item_code = 20
 AND    qa.questionnaire_ans_header_id = (SELECT MAX(iqah.questionnaire_ans_header_id)
                                          FROM   quest_answer_header iqah
                                                ,quest_header iqh
                                          WHERE  iqah.module_item_key = AV_SR_HEADER_ID
                                          AND    iqh.questionnaire_number = 112
                                          AND    iqah.questionnaire_id = iqh.questionnaire_id)
  AND    qq.question LIKE 'Q1442%'
  AND    qa.answer = 'Animals'
  AND    qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id
  AND    qa.question_id = qq.question_id;
IF LI_COUNT > 0 THEN
   SET RETURN_STRING = 'TRUE';
END IF;
RETURN RETURN_STRING;
END
$$
DELIMITER ;
