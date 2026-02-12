DELIMITER $$
CREATE  FUNCTION `FN_SPECIAL_REVIEW_IS_NULL`(a1s_proposal INT ) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE li_count INT;
DECLARE EXIT HANDLER FOR NOT FOUND BEGIN
			RETURN 'FALSE';
			END;
SELECT 	count(1)
		INTO    li_count
		FROM    eps_proposal_special_review
		WHERE	PROPOSAL_ID = a1s_proposal;
		IF (li_count = 0) then
			RETURN 'TRUE';
		else
			RETURN 'FALSE';
		end if;
END
$$
DELIMITER ;
