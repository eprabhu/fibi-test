DELIMITER $$
CREATE  FUNCTION `FN_SPONSOR_IS_INTERNAL`(a1s_proposal INT) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE li_count INT;
DECLARE EXIT HANDLER FOR NOT FOUND BEGIN
RETURN 'FALSE';
END;
  SELECT  COUNT(*)
                INTO    li_count
                FROM    eps_proposal pd
                WHERE   pd.PROPOSAL_ID = a1s_proposal
                AND     pd.SPONSOR_CODE IN (select sponsor_code from sponsor where upper(sponsor_type_code) = 'IN' );
                IF (li_count > 0) then
                        return 'TRUE';
                else
                        return 'FALSE';
                end if;
END
$$
DELIMITER ;
