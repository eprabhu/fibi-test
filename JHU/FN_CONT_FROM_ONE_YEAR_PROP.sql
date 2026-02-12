DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` FUNCTION `FN_CONT_FROM_ONE_YEAR_PROP`(a1s_proposal int) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE li_count INT;
DECLARE EXIT HANDLER FOR NOT FOUND BEGIN
RETURN 'FALSE';
END;
  SELECT  COUNT(*)
                INTO    li_count
                FROM   proposal p,
                       eps_proposal pd,
                       proposal_admin_details pad
                WHERE   pd.PROPOSAL_ID = a1s_proposal
				AND     pd.PROPOSAL_ID = pad.DEV_PROPOSAL_ID
                AND    pad.INST_PROPOSAL_ID = p.PROPOSAL_ID
                AND     p.PROPOSAL_ID NOT IN (SELECT NEW_IP_NUMBER FROM jhu_multiple_grant)
                AND     p.SEQUENCE_NUMBER = (SELECT MAX(SEQUENCE_NUMBER)
                                             FROM  proposal
                                             WHERE PROPOSAL_ID = p.PROPOSAL_ID);
                                             IF (li_count > 0) then
                        return 'TRUE';
                else
                        return 'FALSE';
                end if;
END
$$
DELIMITER ;
