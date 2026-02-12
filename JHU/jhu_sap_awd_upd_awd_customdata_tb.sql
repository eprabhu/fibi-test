DELIMITER $$
CREATE  PROCEDURE `jhu_sap_awd_upd_awd_customdata_tb`(av_award_id INT
  ,av_proposal_number  VARCHAR(20)
  ,av_update_timestamp  DATE
  )
BEGIN
  DECLARE LI_award_id DECIMAL(22,0);
  DECLARE li_proposal_id INT;
  declare ls_error_msg varchar(4000);
  declare LI_cd_already_exist int;
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
		BEGIN
			GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
			 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
			SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
			SELECT @full_error INTO LS_ERROR_MSG;
			 insert into integration_error_log (SECTION, ERROR_MESSAGE, AWARD_NUMBER, sequence_number)
				values('AWARD CUSTOM_DATA', LS_ERROR_MSG, av_award_id, av_proposal_number);
		END;
	begin
		DECLARE DONE1 INT DEFAULT FALSE;
		DECLARE CUR_custom_DATA CURSOR FOR
		SELECT DISTINCT afp.AWARD_ID, afp.proposal_id
		from award_funding_proposals afp, proposal p
		where afp.award_id = av_award_id
		and afp.proposal_id = p.proposal_id
		and p.proposal_number = av_proposal_number;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE1 = TRUE;
		OPEN CUR_custom_DATA;
		CD_LOOP: LOOP
		FETCH CUR_custom_DATA INTO	LI_AWARD_ID, LI_PROPOSAL_ID;
		IF DONE1 THEN
			LEAVE CD_LOOP;
		END IF;
        set LI_cd_already_exist = NULL;
			 select count(*) into LI_cd_already_exist
			 from custom_data where MODULE_ITEM_CODE = 1
			 and module_item_key = LI_AWARD_ID
			 and MODULE_SUB_ITEM_CODE = 0
			 and MODULE_sub_ITEM_KEY = 0
			 and update_user = 'INTRFACE';
  if LI_cd_already_exist = 0 then
	INSERT INTO custom_data (CUSTOM_DATA_ELEMENTS_ID,
								MODULE_ITEM_CODE,
								MODULE_SUB_ITEM_CODE,
								MODULE_ITEM_KEY,
								MODULE_SUB_ITEM_KEY,
								VALUE,
								UPDATE_TIMESTAMP,
								UPDATE_USER,
								COLUMN_ID,
								COLUMN_VERSION_NUMBER,
								DESCRIPTION
										 )
	SELECT CUSTOM_DATA_ELEMENTS_ID
							,1
							,0
							,li_award_id
							,0
							,VALUE
							,av_update_timestamp
							,'INTRFACE'
							,COLUMN_ID
							,COLUMN_VERSION_NUMBER
							,DESCRIPTION
	FROM custom_data cd
	WHERE MODULE_ITEM_CODE = 2
	AND MODULE_SUB_ITEM_CODE = 0
	AND	MODULE_ITEM_KEY = li_proposal_id
	AND	MODULE_SUB_ITEM_KEY = 0 ;
	COMMIT;
end if;
END LOOP;
COMMIT;
CLOSE CUR_custom_DATA;
end;
END
$$
DELIMITER ;
