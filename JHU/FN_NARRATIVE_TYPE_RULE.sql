DELIMITER $$
CREATE  FUNCTION `FN_NARRATIVE_TYPE_RULE`(as_proposal INT,ai_type varchar(3) ) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE li_count INT;
DECLARE EXIT HANDLER FOR NOT FOUND BEGIN
			RETURN 'FALSE';
			END;
	SELECT   count(1)
        INTO    li_count
        FROM    eps_proposal_attachments n, file_data p
        WHERE   n.PROPOSAL_ID = as_proposal
        AND     n.NARRATIVE_STATUS_CODE = ai_type
        AND     n.FILE_DATA_ID = p.ID;
		IF li_count > 0 then
			RETURN 'TRUE';
		else
		RETURN 'FALSE';
		end if;
END
$$
DELIMITER ;
