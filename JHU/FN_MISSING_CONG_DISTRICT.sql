DELIMITER $$
CREATE  FUNCTION `FN_MISSING_CONG_DISTRICT`(a1s_proposal INT) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE li_count INT;
 SELECT  COUNT(1)
                INTO    li_count
                FROM    eps_proposal_organization epo
                        LEFT OUTER JOIN
                        eps_proposal_cong_district epc
				ON epo.PROPOSAL_ORGANIZATION_ID = epc.PROPOSAL_ORGANIZATION_ID
                WHERE   epo.PROPOSAL_ID = a1s_proposal
                AND     ORGANIZATION_TYPE_CODE not in (1,2)
                AND     epc.CONG_DISTRICT_CODE IS NULL;
                IF (li_count > 0) then
                        return 'TRUE';
                else
                        RETURN 'FALSE';
                end if;
END
$$
DELIMITER ;
