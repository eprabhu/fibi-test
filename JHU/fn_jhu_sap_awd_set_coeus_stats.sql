DELIMITER $$
CREATE  FUNCTION `fn_jhu_sap_awd_set_coeus_stats`(av_status  VARCHAR(6)
												,av_user_status  VARCHAR(5)
                             					,av_end_date  VARCHAR(10)) RETURNS int
    DETERMINISTIC
BEGIN
  DECLARE li_coeus_status INT(3) DEFAULT NULL;
		IF av_user_status = 'E0002' THEN
			SET li_coeus_status = 3;
		ELSE
			  IF (av_end_date IS NOT NULL AND DATE(UTC_TIMESTAMP()) > DATE_FORMAT(av_end_date, '%Y-%m-%d')) THEN
				SET li_coeus_status = 4;
			  ELSE
				SELECT coeus_status_code
				INTO li_coeus_status
				FROM sap_status
				WHERE TRIM(sap_status_code) = av_status;
			  END IF;
		END IF;
	RETURN li_coeus_status;
END
$$
DELIMITER ;
