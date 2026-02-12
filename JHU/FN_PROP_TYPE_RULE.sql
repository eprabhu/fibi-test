DELIMITER $$
CREATE  FUNCTION `FN_PROP_TYPE_RULE`(as_proposal INT,
										ai_type int) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
	DECLARE li_type	int;
    DECLARE EXIT HANDLER FOR NOT FOUND BEGIN
			RETURN 'FALSE';
			END;
		SELECT 	TYPE_CODE
		INTO	li_type
		FROM	eps_proposal
		WHERE	proposal_id = as_proposal;
		if li_type = ai_type then
			RETURN 'TRUE';
		else
		RETURN 'FALSE';
		end if;
END
$$
DELIMITER ;
