DELIMITER $$
CREATE  FUNCTION `FN_HAS_DETAILED_BUDGET`(a1s_proposal INT,
										a2n_version VARCHAR(50)) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
Declare ls_count int;
   SELECT count(*)
   INTO   ls_count
   FROM   budget_details bd, budget_header bh
   WHERE  bh.BUDGET_HEADER_ID=db.BUDGET_HEADER_ID
   AND	  bh.PROPOSAL_ID = a1s_proposal
   AND    bd.version_number  = a2n_version;
		IF (ls_count > 0) then
			return 'TRUE';
		else
			return 'FALSE';
		end if;
END
$$
DELIMITER ;
