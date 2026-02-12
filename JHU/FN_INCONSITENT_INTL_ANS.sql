DELIMITER $$
CREATE  FUNCTION `FN_INCONSITENT_INTL_ANS`(a1s_proposal INT) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
		DECLARE q_1055_yes_count     INT;
        DECLARE q_1056_yes_count     INT;
        DECLARE q_1112_yes_count     INT;
        DECLARE return_value         INT  default -1;
                SELECT  count(*)
                INTO    q_1055_yes_count
                FROM    quest_answer_header qah
                       ,quest_answer qa
                WHERE   qah.module_item_key = a1s_proposal
                AND     qa.QUESTION_ID = 4796
                AND     qa.answer = 'Yes'
                AND     qa.QUESTIONNAIRE_ANSWER_ID = (SELECT MAX(iqa.QUESTIONNAIRE_ANSWER_ID)
                                                          FROM   quest_answer_header iqah
                                                                ,quest_answer iqa
                                                          WHERE  iqah.module_item_key = a1s_proposal
                                                          AND    iqa.QUESTION_ID = 4796
                                                           AND    iqah.QUESTIONNAIRE_ANS_HEADER_ID = iqa.QUESTIONNAIRE_ANS_HEADER_ID)
                AND     qah.QUESTIONNAIRE_ANS_HEADER_ID = qa.QUESTIONNAIRE_ANS_HEADER_ID;
                IF q_1055_yes_count > 0
                THEN
                  SELECT  count(*)
                  INTO    q_1056_yes_count
                  FROM    quest_answer_header qah
                         ,quest_answer qa
                  WHERE   qah.module_item_key = a1s_proposal
                  AND     qa.QUESTION_ID = 4797
                  AND     qa.answer = 'Yes'
                  AND     qa.QUESTIONNAIRE_ANSWER_ID = (SELECT MAX(iqa.QUESTIONNAIRE_ANSWER_ID)
                                                            FROM   quest_answer_header iqah
                                                                  ,quest_answer iqa
                                                            WHERE  iqah.module_item_key = a1s_proposal
                                                            AND    iqa.QUESTION_ID = 4797
                                                            AND    iqah.QUESTIONNAIRE_ANS_HEADER_ID = iqa.QUESTIONNAIRE_ANS_HEADER_ID)
                AND     qah.QUESTIONNAIRE_ANS_HEADER_ID = qa.QUESTIONNAIRE_ANS_HEADER_ID;
                  IF q_1056_yes_count = 0
                  THEN
                    SELECT  count(*)
                    INTO    q_1112_yes_count
                    FROM    quest_answer_header qah
                           ,quest_answer qa
                    WHERE   qah.module_item_key = a1s_proposal
                    AND     qa.QUESTION_ID = 4904
                    AND     qa.answer = 'Yes'
                    AND     qa.QUESTIONNAIRE_ANSWER_ID = (SELECT MAX(iqa.QUESTIONNAIRE_ANSWER_ID)
                                                              FROM   quest_answer_header iqah
                                                                    ,quest_answer iqa
                                                              WHERE  iqah.module_item_key = a1s_proposal
                                                              AND    iqa.QUESTION_ID = 4904
                                                              AND    iqah.QUESTIONNAIRE_ANS_HEADER_ID = iqa.QUESTIONNAIRE_ANS_HEADER_ID)
                AND     qah.QUESTIONNAIRE_ANS_HEADER_ID = qa.QUESTIONNAIRE_ANS_HEADER_ID;
                    IF q_1112_yes_count = 0
                    THEN
                      RETURN 'TRUE';
					ELSE
					  RETURN 'FALSE';
                    END IF;
                  END IF;
                END IF;
        END
$$
DELIMITER ;
