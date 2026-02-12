DELIMITER $$
CREATE  FUNCTION `FN_HAS_SACTIONED_COUNTRY`(
  AV_PROPOSAL_ID   int(10)
) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE sanctioned_country_count int;
DECLARE RETURN_STRING VARCHAR(5) DEFAULT 'FALSE';
SELECT  count(*)
INTO    sanctioned_country_count
FROM    quest_answer_header qah
       ,quest_answer qa
       ,country c
       ,jhu_sanctioned_country s
WHERE   qah.module_item_key = AV_PROPOSAL_ID
AND     s.sanctioned = 'Y'
AND     qa.questionnaire_ans_header_id = (SELECT MAX(iqah.questionnaire_ans_header_id)
                                          FROM   quest_answer_header iqah
                                                ,quest_header iqh
                                          WHERE  iqah.module_item_key = AV_PROPOSAL_ID
                                          AND    iqh.questionnaire_number = 91
                                          AND    iqah.questionnaire_id = iqh.questionnaire_id)
AND     qah.questionnaire_ans_header_id = qa.questionnaire_ans_header_id
AND     qa.answer = c.country_name
AND     c.country_code = s.country_code;
IF sanctioned_country_count > 0
THEN
   SET RETURN_STRING = 'TRUE';
END IF;
RETURN RETURN_STRING;
END
$$
DELIMITER ;
