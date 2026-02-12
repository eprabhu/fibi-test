DELIMITER $$
CREATE  FUNCTION `FN_ACTIVITY_TYPE_RULE`(as_proposal INT,
										ai_type varchar(3)) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
  DECLARE li_type INT;
  	DECLARE EXIT HANDLER FOR NOT FOUND BEGIN
			return 'FALSE';
			END;
		SELECT 	ACTIVITY_TYPE_CODE
		INTO    li_type
		FROM    eps_proposal
		WHERE	proposal_id = as_proposal;
		IF li_type = ai_type then
			return 'TRUE';
		else
			return 'FALSE';
		end if;
END
$$
DELIMITER ;
