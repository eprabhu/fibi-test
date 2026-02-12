DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` FUNCTION `FN_HAS_NEGATIVE_BUDGET`(
  AV_PROPOSAL_ID   int(10)
) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE LI_COUNT int;
DECLARE RETURN_STRING VARCHAR(5) DEFAULT 'FALSE';
 SELECT COUNT(*)
 INTO LI_COUNT
 FROM eps_proposal p
     ,budget_header b
     ,budget_period bp
 WHERE p.PROPOSAL_ID=AV_PROPOSAL_ID
 AND  (bp.total_direct_cost < 0
 OR    bp.total_indirect_cost < 0)
 AND   p.proposal_id = b.proposal_id
 AND   b.budget_header_id = bp.budget_header_id;
IF LI_COUNT > 0 THEN
   SET RETURN_STRING = 'TRUE';
END IF;
RETURN RETURN_STRING;
END
$$
DELIMITER ;
