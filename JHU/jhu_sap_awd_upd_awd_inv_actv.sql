DELIMITER $$
CREATE  PROCEDURE `jhu_sap_awd_upd_awd_inv_actv`(av_award_id DECIMAL(22,0)
  ,av_award_number VARCHAR(12)
  ,av_sequence_number INT(4)
  )
BEGIN
    DECLARE DONE1 INT DEFAULT FALSE;
declare ls_error_msg varchar(4000);
	  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
		BEGIN
			GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
			 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
			SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
			SELECT @full_error INTO LS_ERROR_MSG;
            insert into integration_error_log (SECTION, ERROR_MESSAGE, AWARD_NUMBER, sequence_number)
				values('AWARD INVESTIGATOR', LS_ERROR_MSG, av_award_number, av_sequence_number);
			-- select concat(LS_ERROR_MSG,'awd_amount_info: ',av_award_number, ' - ' , 0) from dual;
		END;
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE1 = TRUE;
  SET SQL_SAFE_UPDATES= 0;
  BEGIN
	DELETE from award_person_unit
    where award_person_id in(select award_person_id FROM award_persons
						WHERE award_number = av_award_number
						AND sequence_number = 0
						AND person_role_id IN (1,3)) ;
	DELETE FROM award_persons
	WHERE award_number = av_award_number
	AND sequence_number = 0
	AND person_role_id IN (1,3) ;
    SELECT award_id INTO av_award_id
	FROM award
	WHERE award_number = av_award_number
	AND sequence_number = 0 ;
    INSERT INTO award_persons (person_id
							  ,award_number
							  ,award_id
							  ,sequence_number
							  ,full_name
							  ,pi_flag
							  ,is_multi_pi
							  ,update_timestamp
							  ,update_user
							  ,person_role_id
							  ,PERCENTAGE_OF_EFFORT
							  ,EMAIL_ADDRESS)
          SELECT person_id
				 ,award_number
				  ,av_award_id
				  ,0
				  ,full_name
				  ,pi_flag
				  ,is_multi_pi
				  ,update_timestamp
				  ,update_user
				  ,person_role_id
				  ,PERCENTAGE_OF_EFFORT
				  ,EMAIL_ADDRESS
			from award_persons
			WHERE award_number = av_award_number
			AND sequence_number = av_sequence_number  ;
commit;
COMMIT;
END;
END
$$
DELIMITER ;
