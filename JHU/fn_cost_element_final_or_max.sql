DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` FUNCTION `fn_cost_element_final_or_max`(a1s_proposal int ,a2s_ce varchar(12)) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE li_count  INT;
DECLARE final_count INT;
DECLARE EXIT HANDLER FOR NOT FOUND BEGIN
		RETURN 'FALSE';
			END;
 SELECT  count(1)
                INTO    final_count
                FROM   budget_header
                WHERE   PROPOSAL_ID = a1s_proposal
                AND     FINAL_VERSION_FLAG = 'Y';
 IF final_count > 0 THEN
                  SELECT  count(1)
                  INTO    li_count
                  FROM    budget_header b, budget_detail bd
                  WHERE   b.PROPOSAL_ID = a1s_proposal
                  AND     bd.COST_ELEMENT =  a2s_ce
                  AND     b.FINAL_VERSION_FLAG = 'Y'
                  AND     b.BUDGET_HEADER_ID = bd.BUDGET_HEADER_ID
                  AND     b.VERSION_NUMBER = bd.VERSION_NUMBER;
                ELSE
                 SELECT  count(1)
                  INTO    li_count
                  FROM   budget_header b, budget_detail bd
                  WHERE   b.PROPOSAL_ID = a1s_proposal
                  AND     bd.COST_ELEMENT =  a2s_ce
                  AND     b.VERSION_NUMBER = (SELECT MAX(VERSION_NUMBER)
                                              FROM budget_header
                                              WHERE PROPOSAL_ID = b.PROPOSAL_ID)
                  AND     b.BUDGET_HEADER_ID = bd.BUDGET_HEADER_ID
                  AND     b.VERSION_NUMBER = bd.VERSION_NUMBER;
                END IF;
                IF li_count > 0 then
                      RETURN 'TRUE';
                else
                      RETURN 'FALSE';
                end if;
END
$$
DELIMITER ;
