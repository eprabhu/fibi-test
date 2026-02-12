DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` FUNCTION `FN_QUEST_COMPLETED_RULE`(as_proposal INT) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE li_count_compl INT;
DECLARE EXIT HANDLER FOR NOT FOUND BEGIN
RETURN 'FALSE';
END;
 SELECT   count(*)
        INTO    li_count_compl
        FROM    quest_answer_header
        WHERE   MODULE_ITEM_KEY = as_proposal
        and     MODULE_ITEM_CODE = '3'
        and     QUESTIONNAIRE_COMPLETED_FLAG = 'Y';
        IF li_count_compl > 0 then
            return 'TRUE';
        else
            return 'FALSE';
        end if;
END
$$
DELIMITER ;
