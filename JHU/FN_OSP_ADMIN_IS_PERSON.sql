DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` FUNCTION `FN_OSP_ADMIN_IS_PERSON`(as_proposal INT,
										                       a2s_person_id  int) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
	DECLARE ls_person_id  integer;
    DECLARE EXIT HANDLER FOR NOT FOUND
			BEGIN
	RETURN 'FALSE';
            end;
		SELECT 	unit_administrator.PERSON_ID
		INTO	ls_person_id
		FROM	unit_administrator, eps_prop_person_units
		WHERE	eps_prop_person_units.PROPOSAL_ID = as_proposal
		AND	    eps_prop_person_units.unit_number = unit_administrator.unit_number
        AND   eps_prop_person_units.lead_unit_flag = 'Y';
		IF (ls_person_id = a2s_person_id ) then
			RETURN 'TRUE';
		else
			RETURN 'FALSE';
		end if;
end
$$
DELIMITER ;
