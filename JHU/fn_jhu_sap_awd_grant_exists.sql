DELIMITER $$
CREATE  FUNCTION `fn_jhu_sap_awd_grant_exists`(LS_GRANT_NUMBER VARCHAR(6), LS_SPONSORED_PROGRAM_NUMBER varchar(8),last_run_date date) RETURNS int
    DETERMINISTIC
BEGIN
DECLARE li_awd_count INT(3) DEFAULT 0;
-- award not created
SELECT count(1) into li_awd_count
FROM award
where award_number = CONCAT(LS_GRANT_NUMBER,'-00001');
IF li_awd_count = 0 THEN
	RETURN 1;
ELSE
	-- update_timestamp greater for sap_grant than award
	set li_awd_count = -1;
	select count(1) into li_awd_count
	FROM award a
	WHERE  a.award_number = CONCAT(LS_GRANT_NUMBER,'-00001')
	and a.sequence_number = (select max(sequence_number)
						   from award
						   where award_number = a.award_number)
	AND    update_timestamp < (select max(update_timestamp)
											from sap_grant
											where grant_number = LS_GRANT_NUMBER);
IF li_awd_count > 0 THEN
			RETURN 1;
ELSE
	-- update_timestamp greater for sap_sponsored_program than award
	set li_awd_count = -1;
	select count(1) into li_awd_count
	FROM award a
	WHERE  a.award_number = CONCAT(LS_GRANT_NUMBER,'-00001')
	and a.sequence_number = (select max(sequence_number)
						   from award
						   where award_number = a.award_number)
	and update_timestamp < (select max(update_timestamp)
											from sap_sponsored_program
											where SPONSORED_PROGRAM_NUMBER = LS_SPONSORED_PROGRAM_NUMBER);
		 IF li_awd_count > 0 THEN
			RETURN 1;
ELSE
		-- award changed through application
	set li_awd_count = -1;
	SELECT   count(1) into li_awd_count
	  FROM    award
	  WHERE   award_number = CONCAT(LS_GRANT_NUMBER,'-00001')
      AND update_timestamp >= last_run_date
	  AND     update_user <> 'INTRFACE';
	IF li_awd_count > 0 THEN
		RETURN 1;
	ELSE
		RETURN 0;
	END IF;
	END IF;
	 END IF;
	 END IF;
END
$$
DELIMITER ;
