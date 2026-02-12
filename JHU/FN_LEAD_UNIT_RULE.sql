DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` FUNCTION `FN_LEAD_UNIT_RULE`(as_proposal  int,
      as_unit_number int ) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE li_count INT;
SELECT 	count(1)
		INTO	li_count
		FROM	eps_proposal_persons p, eps_prop_person_units pu
		WHERE	p.PROPOSAL_PERSON_ID=pu.PROPOSAL_PERSON_ID
        AND 	p.proposal_id = as_proposal
		AND		pu.unit_number = as_unit_number
		AND		pu.lead_unit_flag = 'Y';
IF li_count > 0 then
		RETURN 'TRUE';
else
		RETURN 'FALSE';
END IF;
END
$$
DELIMITER ;
