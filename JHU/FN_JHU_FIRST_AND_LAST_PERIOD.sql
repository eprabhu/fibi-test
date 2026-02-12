DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` FUNCTION `FN_JHU_FIRST_AND_LAST_PERIOD`(a1s_proposal INT) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
 DECLARE  total_count           INT;
 DECLARE   final_count            INT;
 DECLARE    budget_version_number INT;
 DECLARE   period_count        INT DEFAULT 0;
DECLARE EXIT HANDLER FOR NOT FOUND BEGIN
RETURN 'FALSE';
END;
     SELECT  count(*)
                INTO    total_count
                FROM    budget_header b
                WHERE   b.PROPOSAL_ID = a1s_proposal;
                  IF total_count > 0
                THEN
                  SELECT  count(*)
                  INTO    final_count
                  FROM     budget_header b
                  WHERE b.PROPOSAL_ID = a1s_proposal
                  AND     b.FINAL_VERSION_FLAG = 'Y';
                     IF final_count > 0
                  THEN
                    SELECT  b.VERSION_NUMBER
                    INTO    budget_version_number
                    FROM   budget_header b
                    WHERE   b.PROPOSAL_ID = a1s_proposal
                    AND     b.FINAL_VERSION_FLAG = 'Y';
                      ELSE
                    SELECT  MAX( b.VERSION_NUMBER)
                    INTO    budget_version_number
                    FROM   budget_header b
                    WHERE   b.PROPOSAL_ID = a1s_proposal;
                  END IF;
                    SELECT  count(*)
                  INTO    period_count
                  FROM    budget_period b, budget_header bh
                  WHERE    bh.PROPOSAL_ID = a1s_proposal
                  AND      b.BUDGET_HEADER_ID = bh.BUDGET_HEADER_ID
                  AND     b.VERSION_NUMBER = budget_version_number
                  AND     b.BUDGET_PERIOD = (SELECT  MIN(BP.budget_period)
                                             FROM    budget_header bhd, BUDGET_PERIOD BP
                                             WHERE   bhd.PROPOSAL_ID = bh.PROPOSAL_ID
                                             AND    BP.VERSION_NUMBER =  b.VERSION_NUMBER )
											AND     b.TOTAL_COST = 0;
                                              IF period_count > 0
                  THEN
                                      SELECT  count(*)
                  INTO    period_count
                  FROM    budget_period b, budget_header bh
                  WHERE    bh.PROPOSAL_ID = a1s_proposal
                  AND      b.BUDGET_HEADER_ID = bh.BUDGET_HEADER_ID
                  AND     b.VERSION_NUMBER = budget_version_number
                  AND     b.BUDGET_PERIOD = (SELECT  MAX(BP.budget_period)
                                             FROM    budget_header bhd, BUDGET_PERIOD BP
                                             WHERE   bhd.PROPOSAL_ID = b.PROPOSAL_ID
                                             AND    BP.VERSION_NUMBER =  b.VERSION_NUMBER )
											AND     b.TOTAL_COST = 0;
                                             END IF;
                END IF;
                IF (period_count = 0) then
                        return 'TRUE';
                else
                        return 'FALSE';
                end if;
END
$$
DELIMITER ;
