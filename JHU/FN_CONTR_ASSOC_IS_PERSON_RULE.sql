DELIMITER $$
CREATE  FUNCTION `FN_CONTR_ASSOC_IS_PERSON_RULE`(a1s_proposal INT,
										a2s_person_id varchar(40)) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
begin
        declare ls_person_count INT;
         	DECLARE EXIT HANDLER FOR NOT FOUND BEGIN
			RETURN 'FALSE';
			END;
                SELECT  COUNT(1)
                INTO    ls_person_count
                FROM    unit,eps_prop_person_units, unit_administrator
                WHERE   eps_prop_person_units.proposal_id = a1s_proposal
                AND     unit_administrator.unit_administrator_type_code = 6
                AND     unit_administrator.person_id = a2s_person_id
                AND     eps_prop_person_units.unit_number = unit.unit_number
                AND     unit.unit_number = unit_administrator.unit_number
                AND     eps_prop_person_units.lead_unit_flag = 'Y';
                IF (ls_person_count > 0) then
                        RETURN 'TRUE';
                else
                       RETURN 'FALSE';
                end if;
END
$$
DELIMITER ;
