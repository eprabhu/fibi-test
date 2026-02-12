DELIMITER $$
CREATE  FUNCTION `FN_SPONSOR_GROUP`(a1s_proposal INT,a2s_sponsor_group varchar(4000)) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
	declare ls_group VARCHAR(4000);
	declare ls_primeSponsorGroup VARCHAR(4000);
			DECLARE EXIT HANDLER FOR sqlexception BEGIN
		RETURN 'FALSE';
			END;
	begin
	    declare exit handler for sqlexception begin
		     set ls_Group = null;
    	end;
		SELECT 	ORDER_NUMBER
		INTO     ls_group
		FROM 		sponsor_hierarchy
		WHERE    UPPER(SPONSOR_GROUP_NAME) = 'ROUTING'
		AND      SPONSOR_CODE =
			(SELECT 	P.SPONSOR_CODE
			 FROM   	EPS_PROPOSAL P
			 WHERE  	P.PROPOSAL_ID = a1s_proposal);
	end;
	begin
	    declare exit handler for sqlexception begin
		     set ls_primeSponsorGroup = null;
    	end;
				SELECT 	ORDER_NUMBER
		INTO     ls_primeSponsorGroup
		FROM 		sponsor_hierarchy
		WHERE    UPPER(SPONSOR_GROUP_NAME) = 'ROUTING'
		AND      SPONSOR_CODE =
			(SELECT 	P.PRIME_SPONSOR_CODE
			 FROM   EPS_PROPOSAL P
			 WHERE  	P.PROPOSAL_ID = a1s_proposal);
	end;
IF (ls_group = a2s_sponsor_group) or (ls_primeSponsorGroup = a2s_sponsor_group) then
			RETURN 'TRUE';
		else
			RETURN 'FALSE';
		end if;
END
$$
DELIMITER ;
