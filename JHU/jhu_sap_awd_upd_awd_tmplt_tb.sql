DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` PROCEDURE `jhu_sap_awd_upd_awd_tmplt_tb`(av_award_id INT
  ,av_award_number  VARCHAR(12)
  ,av_sequence_number  INT(4)
  ,av_template_code  INT(1)
  ,av_update_timestamp  DATE
  )
BEGIN
DECLARE li_template_row_count INT(3) DEFAULT 0;
DECLARE LI_sponsor_term_type_code varchar(3);
DECLARE LI_sponsor_term_code varchar(3);
DECLARE LS_ERROR_MSG varchar(4000);
BEGIN
		DECLARE DONE1 INT DEFAULT FALSE;
		DECLARE CUR_TEMPLATE_TERM CURSOR FOR
		select sponsor_term_type_code, sponsor_term_code
		from sponsor_term
		where sponsor_term_id in (
					select SPONSOR_TERM_ID from sponsor_term_report where FUNDING_SCHEME_ID = av_template_code);
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE1 = TRUE;
			 DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
		BEGIN
			GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
			 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
			SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
			SELECT @full_error INTO LS_ERROR_MSG;
			insert into integration_error_log (SECTION, ERROR_MESSAGE, AWARD_NUMBER, sequence_number)
				values('AWARD TEMPLATE', LS_ERROR_MSG, av_award_number, av_sequence_number);
		END;
	OPEN CUR_TEMPLATE_TERM;
		TEMPLATE_TERM_LOOP: LOOP
		FETCH CUR_TEMPLATE_TERM INTO LI_sponsor_term_type_code
										, LI_sponsor_term_code;
IF DONE1 THEN
	LEAVE TEMPLATE_TERM_LOOP;
END IF;
SELECT count(*)
INTO  li_template_row_count
FROM award_sponsor_term
WHERE AWARD_ID = av_award_id
and sponsor_term_type_code = LI_sponsor_term_type_code
and sponsor_term_code = LI_sponsor_term_code;
IF li_template_row_count = 0 THEN
			INSERT INTO award_sponsor_term ( AWARD_ID
											, AWARD_NUMBER
											, SEQUENCE_NUMBER
											, SPONSOR_TERM_TYPE_CODE
											, SPONSOR_TERM_CODE
											, UPDATE_TIMESTAMP
											, UPDATE_USER
										 )
								values ( av_award_id
											, av_award_number
											, av_sequence_number
											, LI_sponsor_term_type_code
											, LI_sponsor_term_code
											, UTC_TIMESTAMP()
											, 'INTRFACE');commit;
ELSE
		set sql_safe_updates = 0;
        update award_sponsor_term set UPDATE_TIMESTAMP = UTC_TIMESTAMP(), UPDATE_USER = 'INTRFACE'
			WHERE AWARD_ID = av_award_id
			and sponsor_term_type_code = LI_sponsor_term_type_code
			and sponsor_term_code = LI_sponsor_term_code;
        commit;
END IF;
			set LI_sponsor_term_type_code= NULL;
			set  LI_sponsor_term_code = NULL;
		END LOOP;
		CLOSE CUR_TEMPLATE_TERM;
		END;
END
$$
DELIMITER ;
