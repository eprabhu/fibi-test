DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `FN_PROPOSAL_UNIT_RULE`(as_proposal int,as_unit_number varchar(8) ) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE li_count INT;
DECLARE EXIT HANDLER FOR NOT FOUND
BEGIN
                        RETURN 'FALSE';
                        END;
				SELECT     count(1)
                INTO        li_count
                FROM        eps_prop_person_units, eps_proposal_persons
                WHERE        eps_prop_person_units.proposal_person_id=eps_proposal_persons.proposal_person_id
        		AND   eps_proposal_persons.PROPOSAL_ID = as_proposal
                AND        eps_prop_person_units.UNIT_NUMBER = as_unit_number;
                IF li_count > 0 then
                RETURN 'TRUE';
                else
                RETURN 'FALSE';
                end if;
END
$$
DELIMITER ;
