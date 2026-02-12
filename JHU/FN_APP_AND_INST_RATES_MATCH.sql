DELIMITER $$
CREATE  FUNCTION `FN_APP_AND_INST_RATES_MATCH`(a1s_proposal INT,
										a2n_version VARCHAR(50)) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
Declare ls_count int;
   SELECT COUNT(*)
   INTO   ls_count
   FROM   budget_header b
         ,eps_proposal_rates br
   WHERE  b.proposal_id = a1s_proposal
   AND    b.version_number  = a2n_version
   AND    br.applicable_rate != br.institute_rate
   AND    b.rate_class_code = br.rate_class_code
   AND    REPLACE(b.on_off_campus_flag, 'D', 'N') = br.on_off_campus_flag
   AND    b.BUDGET_HEADER_ID = br.BUDGET_HEADER_ID;
   IF (ls_count = 0) THEN
			return 'TRUE';
		else
			return 'FALSE';
		end if;
END
$$
DELIMITER ;
