DELIMITER $$
CREATE  PROCEDURE `jhu_sap_awd_upd_cost_shar_tb`(av_grant_number  VARCHAR(12)
                                          ,av_start_date  VARCHAR(10)
                                          ,av_sponsored_program_number  VARCHAR(8)
                                          ,av_obligated  DECIMAL(12,2)
                                          ,av_coeus_update_timestamp  DATE
                                          )
BEGIN
    DECLARE li_cost_sharing_row_count INT(3) DEFAULT NULL;
	DECLARE li_cost_sharing_sequence_number INT(3) DEFAULT 1;
	DECLARE ls_cost_sharing_fiscal_year VARCHAR(4) DEFAULT  YEAR(DATE_ADD(DATE_FORMAT(av_start_date, '%Y-%m-%d'), INTERVAL 6 month));
	DECLARE li_coeus_cost_sharing_percentage DECIMAL(5,2) DEFAULT NULL;
    SET SQL_SAFE_UPDATES= 0;
  BEGIN
	SELECT count(*)
	INTO li_cost_sharing_row_count
	FROM award_cost_share
	WHERE award_number = av_grant_number;
	SELECT (s.sponsored_program_value / g.grant_value)
	INTO li_coeus_cost_sharing_percentage
	FROM sap_sponsored_program s INNER JOIN  sap_grant g ON s.grant_number = g.grant_number
	WHERE s.sponsored_program_number = av_sponsored_program_number;
  END;
END
$$
DELIMITER ;
