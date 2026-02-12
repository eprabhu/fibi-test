DELIMITER $$
CREATE  FUNCTION `FN_HAS_VALID_BUDGET_DATES`(
  AV_PROPOSAL_ID   int(10)
) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE LI_COUNT int;
DECLARE RETURN_STRING VARCHAR(5) DEFAULT 'FALSE';
 SELECT COUNT(*)
 INTO LI_COUNT
 FROM eps_proposal p
     ,(SELECT ipd.proposal_id
             ,MIN(ibp.start_date) start_date
       FROM   eps_proposal ipd
             ,budget_header ibh
             ,budget_period ibp
       WHERE  ipd.PROPOSAL_ID=AV_PROPOSAL_ID
       AND    ipd.proposal_id = ibh.proposal_id
       AND    ibh.budget_header_id = ibp.budget_header_id) sd
     ,(SELECT ipd.proposal_id
             ,MAX(ibp.end_date) end_date
       FROM   eps_proposal ipd
             ,budget_header ibh
             ,budget_period ibp
       WHERE  ipd.PROPOSAL_ID=AV_PROPOSAL_ID
       AND    ipd.proposal_id = ibh.proposal_id
       AND    ibh.budget_header_id = ibp.budget_header_id) ed
 WHERE p.PROPOSAL_ID=AV_PROPOSAL_ID
 AND   DATE(p.start_date) = DATE(sd.start_date)
 AND   DATE(p.end_date) = DATE(ed.end_date)
 AND   p.proposal_id = sd.proposal_id
 AND   p.proposal_id = ed.proposal_id;
IF LI_COUNT > 0 THEN
   SET RETURN_STRING = 'TRUE';
END IF;
RETURN RETURN_STRING;
END
$$
DELIMITER ;
