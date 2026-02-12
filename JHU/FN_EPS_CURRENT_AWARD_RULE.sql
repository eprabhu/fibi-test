DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` FUNCTION `FN_EPS_CURRENT_AWARD_RULE`(a1s_proposal int) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE li_count INT;
DECLARE EXIT HANDLER FOR NOT FOUND BEGIN
RETURN FALSE;
END;
   SELECT  count(*)
                INTO    li_count
                FROM    eps_proposal  ep, award a
                WHERE   ep.PROPOSAL_ID = a1s_proposal
                AND     ep.AWARD_NUMBER = a.AWARD_NUMBER;
                      IF (li_count > 0) then
                        return 'TRUE';
                else
                        return 'FALSE';
                end if;
END
$$
DELIMITER ;
