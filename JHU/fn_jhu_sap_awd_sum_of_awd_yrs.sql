DELIMITER $$
CREATE  FUNCTION `fn_jhu_sap_awd_sum_of_awd_yrs`(av_grant_number  VARCHAR(6)) RETURNS decimal(12,2)
    DETERMINISTIC
BEGIN
      DECLARE  li_return_number  DECIMAL(12,2) DEFAULT NULL;
        SELECT ROUND(SUM(CAST(REPLACE(REPLACE(grant_budget_direct, '$',''), ',','') AS DECIMAL(12,2)) +
                   CAST(REPLACE(REPLACE(grant_budget_indirect, '$',''), ',','') AS DECIMAL(12,2))))
        INTO   li_return_number
        FROM   sap_grant_award
        WHERE  grant_number = av_grant_number;
		IF li_return_number IS NULL THEN
			SET li_return_number = 0;
        END IF;
        RETURN li_return_number;
END
$$
DELIMITER ;
