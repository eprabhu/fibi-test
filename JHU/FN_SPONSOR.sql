DELIMITER $$
CREATE  FUNCTION `FN_SPONSOR`(a1s_proposal INT,
										a2s_sponsor_code int) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE 	ls_code  int;
 	DECLARE EXIT HANDLER FOR NOT FOUND BEGIN
			RETURN 'FALSE';
			END;
		SELECT 	sponsor_code
		INTO    ls_code
		FROM   eps_proposal
		WHERE	PROPOSAL_ID = a1s_proposal;
		IF (ls_code = a2s_sponsor_code) then
			RETURN 'TRUE';
		else
			RETURN 'FALSE';
		end if;
END
$$
DELIMITER ;
