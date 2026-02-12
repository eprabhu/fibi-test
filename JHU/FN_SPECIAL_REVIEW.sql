DELIMITER $$
CREATE  FUNCTION `FN_SPECIAL_REVIEW`(a1s_proposal INT ,a2i_review_type INT ) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE li_count INT;
DECLARE EXIT HANDLER FOR NOT FOUND BEGIN
			RETURN 'FALSE';
			END;
SELECT 	count(1)
		INTO    li_count
		FROM    eps_proposal_special_review
		WHERE	PROPOSAL_ID = a1s_proposal
		AND	SPECIAL_REVIEW_CODE = a2i_review_type;
		IF (li_count > 0) then
			RETURN 'TRUE';
		else
			RETURN 'FALSE';
		end if;
END
$$
DELIMITER ;
