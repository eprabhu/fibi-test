DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` FUNCTION `FN_PRIME_SPONSOR_TYPE_RULE`(a1s_proposal INT,
										a2i_sponsor_type int) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
       DECLARE li_code   int;
 	DECLARE EXIT HANDLER FOR NOT FOUND BEGIN
			RETURN 'FALSE';
			END;
                SELECT  sponsor.SPONSOR_TYPE_CODE
                INTO    li_code
                FROM   eps_proposal,
                        sponsor,
                      sponsor_type
                WHERE   eps_proposal.PROPOSAL_ID = a1s_proposal
                AND     eps_proposal.PRIME_SPONSOR_CODE = sponsor.SPONSOR_CODE
                AND     sponsor.SPONSOR_TYPE_CODE = sponsor_type.SPONSOR_TYPE_CODE;
                IF (li_code = a2i_sponsor_type) then
                        RETURN 'TRUE';
                else
                       RETURN 'FALSE';
                end if;
END
$$
DELIMITER ;
