DELIMITER $$
CREATE  PROCEDURE `jhu_sap_sponsor_feed`(av_sponsor_code_in  VARCHAR(100)
  ,av_address_line_1_in  VARCHAR(80)
  ,av_acronym_in  VARCHAR(100)
  ,av_city_in  VARCHAR(30)
  ,av_country_code_in  VARCHAR(100)
  ,av_email_address_in  VARCHAR(60)
  ,av_fax_number_in  VARCHAR(20)
  ,av_phone_number_in  VARCHAR(20)
  ,av_postal_code_in  VARCHAR(15)
  ,av_sponsor_name_in  VARCHAR(200)
  ,av_sponsor_type_in  VARCHAR(3)
  ,av_state_in  VARCHAR(100))
BEGIN
DECLARE  ls_mail_host VARCHAR(30) DEFAULT 'smtp.johnshopkins.edu';
DECLARE  ls_sender VARCHAR(50) DEFAULT 'sponsor_interface@prcoeus.johnshopkins.edu';
DECLARE  ls_recipient VARCHAR(30) DEFAULT 'ret@jhu.edu';
DECLARE  li_row_count INT(1) DEFAULT NULL;
DECLARE  li_country_row_count INT(1) DEFAULT NULL;
DECLARE  ls_action_performed VARCHAR(8) DEFAULT NULL;
DECLARE  ls_sponsor_code VARCHAR(6) DEFAULT NULL;
DECLARE  li_sponsor_type_code INT(2) DEFAULT NULL;
DECLARE  ls_country_code VARCHAR(3) DEFAULT 'XXX';
DECLARE  ls_acronym VARCHAR(10) DEFAULT NULL;
DECLARE  ls_message_spacer VARCHAR(40) DEFAULT '                                     ';
DECLARE  ls_state VARCHAR(30) DEFAULT null;
DECLARE  ls_file_text LONGTEXT DEFAULT  '';
DECLARE  ls_error VARCHAR(1000);
DECLARE ls_file_sequence  varchar(20) DEFAULT CONCAT(DATE_FORMAT(UTC_TIMESTAMP(),'%Y%m%d%h%i%s'));
DECLARE ls_file_path     VARCHAR(40) DEFAULT '/var/lib/mysql-files/';
DECLARE ls_out_file_name VARCHAR(40) DEFAULT 'sap_sponsor_feed_';
DECLARE ls_full_file_path varchar(200) DEFAULT concat(ls_file_path,ls_out_file_name,ls_file_sequence,'.log');
DECLARE ls_sql_statement LONGTEXT DEFAULT  '';
DECLARE ls_mail_text LONGTEXT DEFAULT  '';
DECLARE ls_mail_subject LONGTEXT DEFAULT  '';
DECLARE  ls_message_text VARCHAR(1000) DEFAULT CONCAT('The following parameters were sent:  ' ,
							   'sponsor_code_in   = ' ,IFNULL(av_sponsor_code_in,'') , '\n' , ls_message_spacer ,
							   'address_line_1_in = ' , IFNULL(av_address_line_1_in,'') , '\n' , ls_message_spacer ,
							   'acronym_in        = ' , IFNULL(av_acronym_in,'') ,'\n' , ls_message_spacer ,
							   'city_in           = ' , IFNULL(av_city_in,'') , '\n' , ls_message_spacer ,
							   'country_code_in   = ' , IFNULL(av_country_code_in,'') , '\n' , ls_message_spacer ,
							   'email_address_in  = ' , IFNULL(av_email_address_in,'') , '\n', ls_message_spacer ,
							   'fax_number_in     = ' , IFNULL(av_fax_number_in,'') , '\n' , ls_message_spacer ,
							   'phone_number_in   = ' , IFNULL(av_phone_number_in,'') , '\n' , ls_message_spacer ,
							   'postal_code_in    = ' , IFNULL(av_postal_code_in,'') , '\n' , ls_message_spacer ,
							   'sponsor_name_in   = ' , IFNULL(av_sponsor_name_in,'') , '\n' , ls_message_spacer ,
							   'sponsor_type_in   = ' , IFNULL(av_sponsor_type_in,'') ,'\n' , ls_message_spacer ,
							   'state_in          = ' , IFNULL(av_state_in,'') ,'\n\n\n');
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
	GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
	 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
	SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
	SELECT @full_error INTO LS_ERROR;
	SET ls_file_text = concat(IFNULL(ls_message_text,''),'\n',IFNULL(LS_ERROR,''),'\n');
	SET ls_mail_subject = CONCAT('Sponsor ',IFNULL(av_sponsor_code_in,''),' (' ,IFNULL(ls_sponsor_code,''),') Interface - ',IFNULL(ls_action_performed,''),' Failed' );
    INSERT INTO jhu_sap_interface_log (MODULE_ITEM_ID,RESULT_TYPE,FILE_NAME,ERROR_MESSAGE,FILE_TEXT,MAIL_TEXT,MAIL_SUBJECT,MAIL_RECIPIENT,MAIL_SENDER)
	VALUES (av_sponsor_code_in,'SQLEXCEPTION','sap_sponsor_feed',SUBSTR(LS_ERROR,1,999),ls_file_text,ls_mail_text,ls_mail_subject,ls_recipient,ls_sender);
	COMMIT;
END;
SET SQL_SAFE_UPDATES = 0;
    SET ls_sponsor_code = SUBSTR(av_sponsor_code_in, 5, 6);
    SET ls_acronym = RTRIM(SUBSTR(av_acronym_in, 1, 10));
    SELECT COUNT(*)
    INTO li_row_count
    FROM sponsor
    WHERE sponsor_code = ls_sponsor_code;
    IF UPPER(av_country_code_in) = 'US'  THEN
      SELECT UPPER(state_code)
      INTO ls_state
      FROM state_code
      WHERE UPPER(description) = UPPER(av_state_in);
    ELSEIF UPPER(av_country_code_in) = 'GU' THEN
      SET  ls_state = 'GM';
    ELSEIF UPPER(av_country_code_in) IN ('AS', 'FM', 'MH', 'MP', 'PR', 'PW', 'VI') THEN
      SET ls_state = UPPER(av_country_code_in);
    ELSE
      SET ls_state = av_state_in;
    END IF;
    SET li_sponsor_type_code = CAST(av_sponsor_type_in AS DECIMAL);
    SELECT COUNT(*)
    INTO li_country_row_count
    FROM sap_country_code
    WHERE TRIM(sap_country_code) = TRIM(av_country_code_in);
    IF  (li_country_row_count > 0 AND av_country_code_in IS NOT NULL) THEN
      SELECT MAX(COEUS_COUNTRY_CODE)
      INTO ls_country_code
      FROM sap_country_code
      WHERE TRIM(sap_country_code) = TRIM(av_country_code_in);
    END IF;
    IF li_row_count = 0  THEN
      set ls_action_performed = 'Insert';
      INSERT INTO sponsor (sponsor_code
                              ,sponsor_name
                              ,acronym
                              ,sponsor_type_code
                              ,postal_code
                              ,state
                              ,country_code
                              ,owned_by_unit
                              ,IS_ACTIVE
							  , address_line_1
							  , email_address
							  , phone_number
                              ,create_user
                              ,update_timestamp
                              ,update_user
                              ,CITY
                              ,DISPLAY_NAME
							  )
      VALUES (ls_sponsor_code
             ,av_sponsor_name_in
             ,ls_acronym
             ,li_sponsor_type_code
             ,av_postal_code_in
             ,ls_state
             ,ls_country_code
             ,'000001'
             ,'Y'
			 , av_address_line_1_in
			 , av_email_address_in
			 ,av_phone_number_in
             ,'COEUS'
             ,UTC_TIMESTAMP()
             ,'COEUS'
             ,av_city_in
             ,CONCAT(ls_sponsor_code, ' - ', av_sponsor_name_in, ' (', ls_acronym, ')')
			 );  COMMIT;
    ELSE
      SET ls_action_performed = 'Update';
      UPDATE sponsor SET sponsor_name = av_sponsor_name_in
                            ,acronym = ls_acronym
                            ,sponsor_type_code = li_sponsor_type_code
                            ,postal_code = av_postal_code_in
                            ,state = ls_state
                            ,country_code = ls_country_code
                            ,owned_by_unit = '000001'
							,address_line_1 = av_address_line_1_in
							,email_address = av_email_address_in
							,phone_number = av_phone_number_in
                            ,create_user = 'COEUS'
                            ,update_timestamp = UTC_TIMESTAMP()
                            ,update_user ='COEUS'
                            ,CITY = av_city_in
                            ,DISPLAY_NAME = CONCAT(ls_sponsor_code, ' - ', av_sponsor_name_in, ' (', ls_acronym, ')')
      WHERE sponsor_code = ls_sponsor_code;COMMIT;
    END IF;
    UPDATE sap_interfaces
    SET sponsor_interface_timestamp = UTC_TIMESTAMP();
    Commit;
	SET ls_file_text = CONCAT(ls_file_text,'\nSponsor ',IFNULL(av_sponsor_code_in,''),' (',IFNULL(ls_sponsor_code,''),') ',IFNULL(ls_action_performed,''),' succeeded \n',IFNULL(ls_message_text,''));
	INSERT INTO jhu_sap_interface_log(MODULE_ITEM_ID,RESULT_TYPE,FILE_NAME,ERROR_MESSAGE,FILE_TEXT)
	VALUES (av_sponsor_code_in,'VALIDATION_SUCCESS','sap_sponsor_feed',null,ls_file_text);
	COMMIT;
END
$$
DELIMITER ;
