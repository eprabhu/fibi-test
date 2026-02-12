DELIMITER $$
CREATE  FUNCTION `fn_pd_has_coi`(
  AV_PROPOSAL_ID   int(10)
) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE LI_COUNT int;
DECLARE RETURN_STRING VARCHAR(5) DEFAULT 'FALSE';
 SELECT COUNT(qa.answer)
 INTO   LI_COUNT
 FROM   quest_answer_header qah
       ,quest_answer qa
       ,quest_question qq
 WHERE  qah.module_item_key = AV_PROPOSAL_ID
 AND    qq.question like 'Q1078%'
 AND    qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id
 AND    qa.question_id = qq.question_id
 AND    qah.module_sub_item_code = 3
 AND    UPPER(TRIM(qa.answer))='YES';
IF LI_COUNT > 0 THEN
   SET RETURN_STRING = 'TRUE';
END IF;
RETURN RETURN_STRING;
END
$$
DELIMITER ;
