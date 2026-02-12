DELIMITER $$
CREATE  PROCEDURE `jhu_sap_hr_interface_proc`(av_person_id_in VARCHAR(40)
,av_ssn_in VARCHAR(9)
,av_last_name_in VARCHAR(50)
,av_first_name_in VARCHAR(50)
,av_middle_name_in VARCHAR(50)
,av_user_name_in VARCHAR(60)
,av_email_address_in VARCHAR(60)
,av_date_of_birth_in VARCHAR(20)
,av_gender_in VARCHAR(30)
,av_race_in VARCHAR(30)
,av_education_level_in VARCHAR(255)
,av_veteran_code_in VARCHAR(255)
,av_visa_code_in VARCHAR(255)
,av_visa_type_in VARCHAR(255)
,av_visa_renewal_date_in VARCHAR(255)
,av_office_location_in VARCHAR(100)
,av_office_phone_in VARCHAR(20)
,av_secondary_office_location_in VARCHAR(30)
,av_secondary_office_phone_in VARCHAR(20)
,av_directory_department_in VARCHAR(60)
,av_salutation_in VARCHAR(30)
,av_country_of_citizenship_in VARCHAR(30)
,av_primary_title_in VARCHAR(51)
,av_directory_title_in VARCHAR(51)
,av_home_unit_in VARCHAR(10)
,av_job_group_in VARCHAR(255)
,av_personnel_sub_area_in VARCHAR(255)
,av_personnel_sub_group_in VARCHAR(255)
,av_is_on_sabbatical_in VARCHAR(255)
,av_id_provided_in VARCHAR(255)
,av_address_line_1_in VARCHAR(80)
,av_address_line_2_in VARCHAR(80)
,av_city_in VARCHAR(30)
,av_state_in VARCHAR(30)
,av_postal_code_in VARCHAR(15)
,av_country_code_in VARCHAR(3)
,av_fax_number_in VARCHAR(20)
,av_pager_number_in VARCHAR(20)
,av_mobile_phone_number_in VARCHAR(20)
,av_era_commons_user_name_in VARCHAR(255)
,av_anniversary_date_in VARCHAR(255)
,av_appointment_unit_number_in VARCHAR(10)
,av_appointment_start_date_in VARCHAR(10)
,av_appointment_end_date_in VARCHAR(10)
,av_appointment_type_in VARCHAR(30)
,av_appointment_job_code_in VARCHAR(6)
,av_salary_in decimal(12,2)
,av_school_in VARCHAR(255)
,av_degree_in VARCHAR(255)
,av_major_in VARCHAR(255)
,av_graduation_date_in VARCHAR(255)
,av_update_timestamp_in VARCHAR(255))
BEGIN
DECLARE ls_mail_host VARCHAR(30)  DEFAULT  'smtp.johnshopkins.edu';
DECLARE ls_sender VARCHAR(50)  DEFAULT  'hr_interface@prcoeus.johnshopkins.edu';
DECLARE ls_recipient VARCHAR(50)  DEFAULT  'ret@jhu.edu';
DECLARE li_row_count INT(1)  DEFAULT  NULL;
DECLARE li_country_row_count INT(1)  DEFAULT  NULL;
DECLARE li_unit_row_count INT(1)  DEFAULT  NULL;
DECLARE ls_action_performed VARCHAR(8)  DEFAULT  NULL;
DECLARE ls_person_id VARCHAR(40)  DEFAULT  NULL;
DECLARE ls_home_unit VARCHAR(10)  DEFAULT  '000001';
DECLARE ld_interface_timestamp DATETIME  DEFAULT  NULL;
DECLARE ls_message_spacer VARCHAR(40)  DEFAULT  NULL;
DECLARE ls_message_text VARCHAR(4000)  DEFAULT  NULL;
DECLARE LS_ERROR VARCHAR(1000);
DECLARE ls_file_text LONGTEXT DEFAULT  '';
DECLARE ls_file_sequence  varchar(20) DEFAULT CONCAT(DATE_FORMAT(UTC_TIMESTAMP(),'%Y%m%d%h%i%s'));
DECLARE ls_file_path     VARCHAR(40) DEFAULT '/var/lib/mysql-files/';
DECLARE ls_out_file_name VARCHAR(40) DEFAULT 'sap_hr_interface_';
DECLARE ls_full_file_path varchar(200) DEFAULT concat(ls_file_path,ls_out_file_name,ls_file_sequence,'.log');
DECLARE ls_sql_statement LONGTEXT DEFAULT  '';
DECLARE ls_mail_text LONGTEXT DEFAULT  '';
DECLARE ls_mail_subject  LONGTEXT DEFAULT  '';
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
	GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
	 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
	SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
	SELECT @full_error INTO LS_ERROR;
    SET ls_mail_subject = CONCAT('Person (',IFNULL(ls_person_id,''),') Interface - ',IFNULL(ls_action_performed,''),' Failed');
	IF @sqlstate = '45000' THEN
		SET ls_file_text = concat('Invalid Dataset \n', IFNULL(ls_message_text,'\n'));
		INSERT INTO jhu_sap_interface_log (MODULE_ITEM_ID,RESULT_TYPE,FILE_NAME,ERROR_MESSAGE,FILE_TEXT,MAIL_TEXT,MAIL_SUBJECT,MAIL_RECIPIENT,MAIL_SENDER)
	    VALUES (av_person_id_in,'VALIDATION_ERROR','sap_hr_interface','User defined Error',ls_file_text,ls_mail_text,ls_mail_subject,ls_recipient,ls_sender);
	ELSEIF @sqlstate = '45001' THEN
        SET ls_file_text = concat('Invalid Person ID \n', IFNULL(ls_message_text,'\n'));
		INSERT INTO jhu_sap_interface_log (MODULE_ITEM_ID,RESULT_TYPE,FILE_NAME,ERROR_MESSAGE,FILE_TEXT,MAIL_TEXT,MAIL_SUBJECT,MAIL_RECIPIENT,MAIL_SENDER)
	    VALUES (av_person_id_in,'VALIDATION_ERROR','sap_hr_interface','User defined Error',ls_file_text,ls_mail_text,ls_mail_subject,ls_recipient,ls_sender);
	ELSE
		SET ls_file_text = concat(ls_message_text,'\n',LS_ERROR,'\n');
        INSERT INTO jhu_sap_interface_log (MODULE_ITEM_ID,RESULT_TYPE,FILE_NAME,ERROR_MESSAGE,FILE_TEXT,MAIL_TEXT,MAIL_SUBJECT,MAIL_RECIPIENT,MAIL_SENDER)
	    VALUES (av_person_id_in,'SQLEXCEPTION','sap_hr_interface',SUBSTR(LS_ERROR,1,999),ls_file_text,ls_mail_text,ls_mail_subject,ls_recipient,ls_sender);
	END IF;
END;
SET SQL_SAFE_UPDATES =0;
    SET ls_person_id = RTRIM(av_person_id_in);
    SET av_ssn_in = IFNULL(av_ssn_in, '');
    IF (LENGTH(TRIM(av_home_unit_in)) = 10) THEN
      SET ls_home_unit = RTRIM(SUBSTR(av_home_unit_in, 1, 8));
    END IF;
    SET ld_interface_timestamp = DATE_FORMAT(av_update_timestamp_in, '%Y-%m-%d');
    SET ls_message_spacer = '                                     ';
    SET ls_message_text = CONCAT('The following parameters were sent:  ' ,
                    'person_id_in   = ' ,IFNULL( av_person_id_in  ,''), ' (' , IFNULL(ls_person_id ,'')  , ')', '\n' , IFNULL(ls_message_spacer ,'') ,
                    'ssn_in = ' ,IFNULL( av_ssn_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'last_name_in        = ' ,IFNULL( av_last_name_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'first_name_in           = ' ,IFNULL( av_first_name_in,'') ,'\n' , IFNULL(ls_message_spacer ,'') ,
                    'middle_name_in   = ' ,IFNULL( av_middle_name_in,'') ,  '\n' ,  IFNULL(ls_message_spacer ,'') ,
                    'user_name_in  = ', IFNULL(av_user_name_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'email_address_in     = ' ,IFNULL( av_email_address_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'date_of_birth_in   = ' ,IFNULL( av_date_of_birth_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'gender_in    = ' ,IFNULL( av_gender_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'race_in   = ' ,IFNULL( av_race_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'education_level_in   = ' ,IFNULL( av_education_level_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'veteran_code_in   = ' ,IFNULL( av_veteran_code_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'visa_code_in   = ' ,IFNULL( av_visa_code_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'visa_type_in   = ' ,IFNULL( av_visa_type_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'visa_renewal_date_in   = ' ,IFNULL( av_visa_renewal_date_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'office_location_in   = ' ,IFNULL( av_office_location_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'office_phone_in   = ' ,IFNULL( av_office_phone_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'secondary_office_location_in   = ' ,IFNULL( av_secondary_office_location_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'secondary_office_phone_in   = ' ,IFNULL( av_secondary_office_phone_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'directory_department_in   = ' ,IFNULL( av_directory_department_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'salutation_in   = ' ,IFNULL( av_salutation_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'country_of_citizenship_in   = ' ,IFNULL( av_country_of_citizenship_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'primary_title_in   = ' ,IFNULL( av_primary_title_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'directory_title_in   = ' ,IFNULL( av_directory_title_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'home_unit_in   = ' ,IFNULL( av_home_unit_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'job_group_in   = ' ,IFNULL( av_job_group_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'personnel_sub_area_in   = ' ,IFNULL( av_personnel_sub_area_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'personnel_sub_group_in   = ' ,IFNULL( av_personnel_sub_group_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'is_on_sabbatical_in   = ' ,IFNULL( av_is_on_sabbatical_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'id_provided_in   = ' ,IFNULL( av_id_provided_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'address_line_1_in   = ' ,IFNULL( av_address_line_1_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'address_line_2_in   = ' ,IFNULL( av_address_line_2_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'city_in   = ' ,IFNULL( av_city_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'state_in   = ' ,IFNULL( av_state_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'postal_code_in   = ' ,IFNULL( av_postal_code_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'country_code_in   = ' ,IFNULL( av_country_code_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'fax_number_in   = ' ,IFNULL( av_fax_number_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'pager_number_in   = ' ,IFNULL( av_pager_number_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'mobile_phone_number_in   = ' ,IFNULL( av_mobile_phone_number_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'era_commons_user_name_in   = ' ,IFNULL( av_era_commons_user_name_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'anniversary_date_in   = ' ,IFNULL( av_anniversary_date_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'appointment_unit_number_in   = ' ,IFNULL( av_appointment_unit_number_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'appointment_start_date_in   = ' ,IFNULL( av_appointment_start_date_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'appointment_end_date_in   = ' ,IFNULL( av_appointment_end_date_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'appointment_type_in   = ' ,IFNULL( av_appointment_type_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'appointment_job_code_in   = ' ,IFNULL( av_appointment_job_code_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'salary_in   = ' ,IFNULL( av_salary_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'school_in   = ' ,IFNULL( av_school_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'degree_in   = ' ,IFNULL( av_degree_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'major_in   = ' ,IFNULL( av_major_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'graduation_date_in   = ' ,IFNULL( av_graduation_date_in ,'') , '\n' , IFNULL(ls_message_spacer ,'') ,
                    'update_timestamp_in   = ' ,IFNULL( av_update_timestamp_in ,'') , '\n' , '\n' , '\n');
    IF av_appointment_unit_number_in IS NOT NULL AND av_appointment_start_date_in IS NOT NULL AND av_appointment_end_date_in IS NOT NULL THEN
	     CALL jhu_sap_hr_upd_appointmnts_tb(ls_person_id
					   ,av_appointment_unit_number_in
					   ,av_appointment_start_date_in
					   ,av_appointment_end_date_in
					   ,av_primary_title_in
					   ,av_directory_title_in
					   ,av_appointment_type_in
					   ,av_appointment_job_code_in
					   ,av_salary_in
					   ,av_personnel_sub_area_in
					   ,av_personnel_sub_group_in
					   ,ld_interface_timestamp);
	    ELSEIF av_last_name_in IS NOT NULL AND av_appointment_unit_number_in IS NULL AND av_degree_in IS NULL THEN
	      CALL jhu_sap_hr_update_person_tb(ls_person_id
				     ,av_ssn_in
				     ,av_last_name_in
				     ,av_first_name_in
				     ,av_middle_name_in
				     ,av_user_name_in
				     ,av_email_address_in
				     ,av_date_of_birth_in
				     ,av_gender_in
				     ,av_race_in
				     ,av_education_level_in
				     ,av_veteran_code_in
				     ,av_visa_code_in
				     ,av_visa_type_in
				     ,av_visa_renewal_date_in
				     ,av_office_location_in
				     ,av_office_phone_in
				     ,av_secondary_office_location_in
				     ,av_secondary_office_phone_in
				     ,av_directory_department_in
				     ,av_salutation_in
				     ,av_country_of_citizenship_in
				     ,av_primary_title_in
				     ,av_directory_title_in
				     ,ls_home_unit
				     ,av_job_group_in
				     ,av_personnel_sub_area_in
				     ,av_personnel_sub_group_in
				     ,av_is_on_sabbatical_in
				     ,av_id_provided_in
				     ,av_address_line_1_in
				     ,av_address_line_2_in
				     ,av_city_in
				     ,av_state_in
				     ,av_postal_code_in
				     ,av_country_code_in
				     ,av_fax_number_in
				     ,av_pager_number_in
				     ,av_mobile_phone_number_in
				     ,av_era_commons_user_name_in
				     ,av_anniversary_date_in
				     ,ld_interface_timestamp);
					 UPDATE sap_interfaces
						SET hr_interface_timestamp = ld_interface_timestamp;
						SET ls_file_text = concat(IFNULL(ls_file_text,''),'Person ', IFNULL(av_person_id_in,'') , ' succeeded \n',ls_message_text);
						INSERT INTO jhu_sap_interface_log (MODULE_ITEM_ID,RESULT_TYPE,FILE_NAME,ERROR_MESSAGE,FILE_TEXT)
						VALUES (av_person_id_in,'VALIDATION_SUCCESS','sap_hr_interface',NULL,ls_file_text);
	     ELSEIF av_degree_in IS NOT NULL THEN
			SET ls_file_text = 'Degree information is not currently being processed\n';
		 ELSE
                 SIGNAL SQLSTATE '45000' ;
	    END IF;
	END
$$
DELIMITER ;
