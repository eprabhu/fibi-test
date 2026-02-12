DELIMITER $$
CREATE  FUNCTION `FN_FP_SPECIAL_IS_PERSON_RULE`(a1s_proposal INT,
										a2s_person_id int) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
      DECLARE  ls_person_count int;
       	DECLARE EXIT HANDLER FOR NOT FOUND BEGIN
			RETURN 'FALSE';
			END;
                SELECT  COUNT(1)
                INTO    ls_person_count
                FROM    unit, eps_prop_person_units, unit_administrator
                WHERE    eps_prop_person_units.PROPOSAL_ID= a1s_proposal
                AND      unit_administrator.UNIT_ADMINISTRATOR_TYPE_CODE = 4
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
