DELIMITER $$
CREATE  FUNCTION `FN_PRIME_SPONSOR_NULL_RULE`(a1s_proposal INT
										) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
     DECLARE   li_count INT;
     DECLARE EXIT HANDLER FOR NOT FOUND BEGIN
     RETURN 'FALSE';
     END;
                SELECT  COUNT(1)
                INTO    li_count
                FROM    eps_proposal
                WHERE   PROPOSAL_ID = a1s_proposal
                AND     PRIME_SPONSOR_CODE IS NOT NULL;
                IF (li_count =  0) then
                        return 'TRUE';
                else
                        return 'FALSE';
                end if;
END
$$
DELIMITER ;
