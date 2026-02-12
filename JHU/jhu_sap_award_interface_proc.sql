DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` PROCEDURE `jhu_sap_award_interface_proc`(IN grant_number_in VARCHAR(20)
  ,IN sponsored_program_number_in VARCHAR(20)
  ,IN person_id_in VARCHAR(20)
  ,IN award_key_in VARCHAR(100)
  ,IN field_name_in VARCHAR(30)
  ,IN new_value_in VARCHAR(1000)
  ,IN update_timestamp_in VARCHAR(14)
  )
BEGIN
   -- DECLARE out_file_handle UTL_FILE.FILE_TYPE;
    DECLARE file_path VARCHAR(33)  DEFAULT  '/var/www/tomcat/webapps/coeus/log';
    DECLARE out_file_name VARCHAR(25)  DEFAULT  'sap_award_interface.log';
    --  DECLARE mail_conn UTL_SMTP.CONNECTION;
    DECLARE mail_host VARCHAR(50)  DEFAULT  'smtp.johnshopkins.edu';
    DECLARE sender VARCHAR(50)  DEFAULT  'award_interface@prcoeus.johnshopkins.edu';
    DECLARE recipient VARCHAR(50)  DEFAULT  'ret@jhu.edu';
    DECLARE adjusted_grant_number VARCHAR(6)  DEFAULT  NULL;
    DECLARE update_table_name VARCHAR(50)  DEFAULT  NULL;
    DECLARE update_column_name VARCHAR(50)  DEFAULT  NULL;
    DECLARE row_count TINYINT  DEFAULT  NULL;
    DECLARE update_statement VARCHAR(1000)  DEFAULT  NULL;
    DECLARE action_performed VARCHAR(8)  DEFAULT  NULL;
    DECLARE interface_timestamp DATETIME  DEFAULT  date_add(str_to_date(update_timestamp_in, '%Y%m%d%H%i%s'), interval - ((1/(24/3.5))) * 86400 second);
    DECLARE message_spacer VARCHAR(40)  DEFAULT  '                                     ';
    DECLARE LS_ERROR VARCHAR(4000);
    DECLARE ls_mail_text LONGTEXT DEFAULT  '';
    DECLARE ls_file_text LONGTEXT DEFAULT '';
	DECLARE ls_mail_subject  LONGTEXT DEFAULT  '';
    DECLARE ls_message_text VARCHAR(4000)  DEFAULT  CONCAT('The following parameters were sent:  ' ,
                                   'grant_number_in   = ' , ifnull(grant_number_in, '')  , char(10 using ascii) , ifnull(message_spacer, '') ,
                                   'sponsored_program_number_in   = ' , ifnull(sponsored_program_number_in, '') , char(10 using ascii) , ifnull(message_spacer, '') ,
                                   'person_id_in   = ' , ifnull(person_id_in, '') , char(10 using ascii) , ifnull(message_spacer, '') ,
                                   'award_key_in   = ' , ifnull(award_key_in, '') , char(10 using ascii) , ifnull(message_spacer, '') ,
                                   'field_name_in   = ' , ifnull(field_name_in, '') , char(10 using ascii) , ifnull(message_spacer, '') ,
                                   'new_value_in   = ' , ifnull(new_value_in, '') , char(10 using ascii) , ifnull(message_spacer, '') ,
                                   'update_timestamp_in   = ' , ifnull(update_timestamp_in, '') , char(10 using ascii));
 DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
	GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
		 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
		SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
		 SELECT @full_error INTO LS_ERROR;
		IF @sqlstate = '45000' THEN
			SET ls_file_text = concat('Invalid Dataset \n', IFNULL(ls_message_text,'\n'));
            INSERT INTO `jhufibi`.`jhu_sap_award_interface_log`
			(`TABLE_NAME`,`GRANT_NUMBER`,`RESULT_TYPE`,`ERROR_MESSAGE`,`FILE_TEXT`,`FILE_INTEFACE_STATUS`,
			`MAIL_TEXT`,`MAIL_SUBJECT`,`MAIL_RECIPIENT`,`MAIL_SENDER`,`MAIL_SENT_STAUS`,`UPDATE_TIMESTAMP`,`UPDATE_USER`)
			VALUES
			('sap_award_interface',grant_number_in,'VALIDATION ERROR',LS_ERROR,ls_file_text,'N',null,null,recipient,sender,'N',now(),'JHU_ADMIN');
		ELSE
			SET ls_file_text = concat('Invalid Dataset \n', IFNULL(ls_message_text,'\n'));
			INSERT INTO `jhufibi`.`jhu_sap_award_interface_log`
			(`TABLE_NAME`,`GRANT_NUMBER`,`RESULT_TYPE`,`ERROR_MESSAGE`,`FILE_TEXT`,`FILE_INTEFACE_STATUS`,
			`MAIL_TEXT`,`MAIL_SUBJECT`,`MAIL_RECIPIENT`,`MAIL_SENDER`,`MAIL_SENT_STAUS`,`UPDATE_TIMESTAMP`,`UPDATE_USER`)
			VALUES
			('sap_award_interface',grant_number_in,'SQLEXCEPTION',LS_ERROR,ls_file_text,'N',null,null,recipient,sender,'N',now(),'JHU_ADMIN');
		END IF;
	END;
    BEGIN
    set sql_safe_updates=0;
    UPDATE sap_interfaces
    SET award_interface_in_progress = 1;
    IF grant_number_in IS NOT NULL AND grant_number_in = 'X'
    THEN
      /* **********************************************************
      ** Turn off the award_interface_in_progress flag                          **
      **************************************************************************/
      UPDATE sap_interfaces
      SET award_interface_in_progress = 0;
    ELSE
      /* *** *******************************************************
      ** Get the name of the table and column to be updated (based on          **
      ** field_name_in)                                                        **
      **************************************************************************/
        SELECT award_interface_table_name, award_interface_column_name
      INTO update_table_name, update_column_name
      FROM sap_award_interface_mapping
      WHERE sap_field_name = field_name_in;
    IF update_table_name = NULL OR update_column_name = NULL
      THEN
        SIGNAL SQLSTATE '45000';
      END IF;
      /*  *** *******************************************************
      ** Modify the grant number to remove the padded 0s**
      **************************************************************************/
      IF CHAR_LENGTH(grant_number_in) > 1
      THEN
        SET adjusted_grant_number = SUBSTR(grant_number_in, 15, 6);
      END IF;
    IF update_table_name = 'sap_grant_award'
      THEN
       CALL jhu_update_sap_grant_award(adjusted_grant_number
                               ,award_key_in
                               ,update_column_name
                               ,new_value_in
                               ,interface_timestamp
                               );
      ELSEIF update_table_name = 'sap_sponsored_program_person'
      THEN
       CALL jhu_update_sap_spon_prog_person(sponsored_program_number_in
                                    ,person_id_in
                                    ,update_column_name
                                    ,new_value_in
                                    ,interface_timestamp
                                    );
      ELSEIF update_table_name = 'sap_grant_person'
      THEN
       CALL jhu_update_sap_grant_person(adjusted_grant_number
                                ,person_id_in
                                ,update_column_name
                                ,new_value_in
                                ,interface_timestamp
                                );
      ELSEIF update_table_name = 'sap_sponsored_program'
      THEN
       CALL jhu_update_sap_sponsored_program(adjusted_grant_number
                                     ,sponsored_program_number_in
                                     ,award_key_in
                                     ,update_column_name
                                     ,new_value_in
                                     ,interface_timestamp
                                     );
      ELSE
         CALL jhu_update_sap_grant(adjusted_grant_number
                          ,update_column_name
                          ,new_value_in
                          ,interface_timestamp
                          );
     END IF;
      /* *** *******************************************************
      ** Mark the grant updated.                                               **
      **************************************************************************/
      UPDATE sap_grant
      SET update_timestamp = interface_timestamp
      WHERE grant_number = adjusted_grant_number;
      set sql_safe_updates=1;
    END IF;
  END;
END
$$
DELIMITER ;
