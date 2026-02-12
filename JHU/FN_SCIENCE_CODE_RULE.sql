DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` FUNCTION `FN_SCIENCE_CODE_RULE`(a1s_proposal INT,
										a2i_review_type int) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE 	li_count  int;
 	DECLARE EXIT HANDLER FOR NOT FOUND BEGIN
			RETURN 'FALSE';
            end;
                SELECT  count(1)
                INTO    li_count
                FROM    eps_proposal_keywords
                WHERE   proposal_id = a1s_proposal
                AND     SCIENCE_KEYWORD_CODE = a2i_review_type;
                IF (li_count > 0) then
                        RETURN 'TRUE';
                else
                        RETURN 'FALSE';
                end if;
END
$$
DELIMITER ;
