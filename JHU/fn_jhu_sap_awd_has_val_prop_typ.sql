DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` FUNCTION `fn_jhu_sap_awd_has_val_prop_typ`(av_proposal_number  VARCHAR(20)) RETURNS int
    DETERMINISTIC
BEGIN
DECLARE li_proposal_type_count INT(3) DEFAULT 0;
SELECT COUNT(*) INTO li_proposal_type_count
FROM   proposal p
WHERE  p.proposal_number = av_proposal_number
		AND    p.proposal_number NOT IN (SELECT new_ip_Number
										 FROM jhu_multiple_grant)
		AND    p.sequence_number = (SELECT MAX(ip.sequence_number)
									FROM   proposal ip
									WHERE  proposal_number = p.proposal_number)
		AND    p.type_code IN (3, 91, 92, 93, 94, 96, 97);
RETURN li_proposal_type_count;
END
$$
DELIMITER ;
