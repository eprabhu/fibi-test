DELIMITER $$
CREATE  FUNCTION `FN_PROP_AWARD_TYPE_RULE`(as_proposal_ID int(11) ,
  ai_type  	varchar(3)) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE li_type	varchar(3);
DECLARE L_CNT INT(1);
	SELECT
    COUNT(1)
INTO L_CNT FROM
    eps_proposal
WHERE
    PROPOSAL_ID = as_proposal_ID and AWARD_TYPE_CODE = ai_type;
      if L_CNT != 0 then
			RETURN 'true';
		ELSE
			RETURN 'false';
		END IF;
END
$$
DELIMITER ;
