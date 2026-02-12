DELIMITER $$
CREATE  PROCEDURE `upd_awd_customdata_integration`(av_int int
  )
BEGIN
  DECLARE li_award_id DECIMAL(22,0);
  DECLARE li_proposal_id INT;
  declare ls_error_msg varchar(4000);
  declare LI_cd_already_exist int;
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
		BEGIN
			GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
			 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
			SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
			SELECT @full_error INTO LS_ERROR_MSG;
			select concat(LS_ERROR_MSG,'awd_customdata: ',li_award_id, ' - ' ,li_proposal_id ) from dual;
		END;
  BEGIN
		DECLARE DONE1 INT DEFAULT FALSE;
		DECLARE CUR_custom_DATA CURSOR FOR
		select award_id, proposal_number from awd_custom_data
        where award_id not in ( select module_item_key from awd_cd)
		and proposal_id in  ( select module_item_key from prop_cd)  ;
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
	SET @row_number = (SELECT IFNULL(MAX(CUSTOM_DATA_ID),0)+1 FROM custom_data);
	INSERT INTO custom_data (
								CUSTOM_DATA_ID,
								CUSTOM_DATA_ELEMENTS_ID,
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
	SELECT (@row_number:=@row_number + 1)
							,CUSTOM_DATA_ELEMENTS_ID
							,1
							,0
							,li_award_id
							,0
							,VALUE
							,current_timestamp()
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
END IF;
END LOOP;
set sql_safe_updates = 0;
UPDATE custom_data_id_generator   SET NEXT_VAL = (SELECT IFNULL(MAX(CUSTOM_DATA_ID),0) + 1  FROM custom_data);
COMMIT;
CLOSE CUR_CUSTOM_DATA;
end;
END
$$
DELIMITER ;
