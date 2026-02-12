DELIMITER $$
CREATE  FUNCTION `FN_NON_MIT_PI`(as_proposal int ) RETURNS varchar(8) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE ls_nonmit_cnt INT;
SELECT 	count(1)
		INTO	ls_nonmit_cnt
		FROM	eps_proposal_persons
		WHERE	proposal_id = as_proposal
		AND	pi_flag = 'Y'
        AND ROLODEX_ID is not null;
		IF (ls_nonmit_cnt > 0) then
			return 'TRUE';
		else
			return 'FALSE';
		end if;
END
$$
DELIMITER ;
