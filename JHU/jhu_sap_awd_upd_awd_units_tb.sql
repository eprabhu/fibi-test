DELIMITER $$
CREATE  PROCEDURE `jhu_sap_awd_upd_awd_units_tb`(av_award_id DECIMAL(22,0)
  ,av_award_number VARCHAR(12)
  ,av_sequence_number INT(4)
  ,av_coeus_unit_number VARCHAR(10)
  ,av_update_timestamp  DATE
  )
BEGIN
  DECLARE ls_coeus_lead_unit_flag VARCHAR(1) DEFAULT 'N';
  DECLARE li_unit_count INT(8) DEFAULT NULL;
  DECLARE li_award_person_unit_id DECIMAL(22,0);
  DECLARE LS_ERROR_MSG VARCHAR(1000);
  DECLARE LS_AWARD_NUMBER varchar(12);
  DECLARE LI_SEQUENCE_NUMBER int;
  DECLARE LI_HOME_UNIT varchar(8);
  DECLARE LI_AWARD_PERSON_ID varchar(40);
  DECLARE DONE1 INT DEFAULT FALSE;
  DECLARE unit_cursor CURSOR for
  SELECT ai.award_number
		  ,ai.sequence_number
		  ,p.home_unit
		  ,ai.award_person_id
	FROM  award_persons ai
	INNER JOIN  person p ON ai.person_id = p.person_id
	WHERE ai.award_number = av_award_number
	AND   ai.sequence_number = av_sequence_number
	AND ai.person_role_id IN (1,3);
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
		BEGIN
			GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
			 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
			SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
			SELECT @full_error INTO LS_ERROR_MSG;
            insert into integration_error_log (SECTION, ERROR_MESSAGE, AWARD_NUMBER, sequence_number)
				values('AWARD UNIT', LS_ERROR_MSG, av_award_number, av_sequence_number);
		END;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE1 = TRUE;
  SET SQL_SAFE_UPDATES= 0;
	DELETE FROM award_person_unit
	WHERE award_number = av_award_number
	AND   sequence_number = av_sequence_number;
begin
OPEN unit_cursor;
unit_cursor_loop : LOOP
		FETCH unit_cursor INTO LS_AWARD_NUMBER,LI_SEQUENCE_NUMBER,LI_HOME_UNIT,LI_AWARD_PERSON_ID;
		IF DONE1 THEN
			LEAVE unit_cursor_loop;
		END IF;
	INSERT INTO  award_person_unit (award_id
								,award_number
								,sequence_number
								,unit_number
								,lead_unit_flag
								,award_person_id
								,update_timestamp
								,update_user
								)VALUES(
								av_award_id
								,LS_AWARD_NUMBER
								,LI_SEQUENCE_NUMBER
								,LI_HOME_UNIT
								,'N'
								,LI_AWARD_PERSON_ID
								,av_update_timestamp
								,'INTRFACE'
								);
			END LOOP;
	CLOSE unit_cursor;
    COMMIT;
end;
	SELECT COUNT(*)
	INTO li_unit_count
	FROM  award_person_unit
	WHERE unit_number = av_coeus_unit_number
	AND award_number = av_award_number
	AND sequence_number = av_sequence_number
	AND award_person_id = (SELECT award_person_id
					 FROM  award_persons
					 WHERE award_number = av_award_number
					 AND   sequence_number = av_sequence_number
					 AND   PI_FLAG = 'Y'
					 AND person_role_id IN (1,3));
	IF li_unit_count = 0 THEN
	  INSERT INTO  award_person_unit (award_id
								  ,award_number
								  ,sequence_number
								  ,unit_number
								  ,lead_unit_flag
								  ,award_person_id
								  ,update_timestamp
								  ,update_user
								  )
	  SELECT av_award_id
			,award_number
			,sequence_number
			,av_coeus_unit_number
			,'Y'
			,award_person_id
			,update_timestamp
			,update_user
	  FROM  award_persons
	  WHERE award_number = av_award_number
	  AND   sequence_number = av_sequence_number
	  AND   PI_FLAG = 'Y'
	  AND person_role_id IN (1,3);
      COMMIT;
	ELSE
	  UPDATE  award_person_unit
	  SET lead_unit_flag = 'Y'
	  WHERE award_number = av_award_number
	  AND   sequence_number = av_sequence_number
	  AND   unit_number = av_coeus_unit_number
	  AND award_person_id = (SELECT award_person_id
					   FROM  award_persons
					   WHERE award_number = av_award_number
					   AND   sequence_number = av_sequence_number
					   AND   PI_FLAG = 'Y'
					   AND  person_role_id IN (1,3));
      COMMIT;
	END IF;
UPDATE AWARD SET LEAD_UNIT_NUMBER = (SELECT UNIT_NUMBER FROM award_person_unit WHERE  AWARD_ID = av_award_id AND LEAD_UNIT_FLAG = 'Y')
WHERE AWARD_ID = av_award_id;
COMMIT;
COMMIT;
END
$$
DELIMITER ;
