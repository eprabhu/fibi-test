DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` FUNCTION `FN_JHU_HAS_ORIGINAL_PROPOSAL`(a1s_proposal int) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
       DECLARE li_count     INT;
DECLARE EXIT HANDLER FOR NOT FOUND BEGIN
RETURN 'FALSE';
END;
                SELECT  COUNT(*)
                INTO    li_count
                FROM    eps_proposal ep,  proposal_admin_details pad , proposal p
                WHERE   ep.PROPOSAL_ID = a1s_proposal
                AND ep.PROPOSAL_ID = pad.DEV_PROPOSAL_ID
                AND pad.INST_PROPOSAL_ID = p.PROPOSAL_ID
                AND     p.PROPOSAL_ID IS NOT NULL;
                IF (li_count > 0) then
                        return 'TRUE';
                else
                        return 'FALSE';
                end if;
END
$$
DELIMITER ;
