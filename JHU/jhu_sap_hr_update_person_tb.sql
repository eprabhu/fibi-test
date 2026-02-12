DELIMITER $$
CREATE  PROCEDURE `jhu_sap_hr_update_person_tb`(av_person_id  VARCHAR(40)
,av_ssn   VARCHAR(9)
,av_last_name  VARCHAR(50)
,av_first_name  VARCHAR(50)
,av_middle_name  VARCHAR(50)
,av_user_name  VARCHAR(60)
,av_email_address  VARCHAR(60)
,av_date_of_birth   VARCHAR(10)
,av_gender   VARCHAR(30)
,av_race  VARCHAR(30)
,av_education_level  VARCHAR(30)
,av_veteran_code   VARCHAR(255)
,av_visa_code  VARCHAR(255)
,av_visa_type  VARCHAR(255)
,av_visa_renewal_date   VARCHAR(10)
,av_office_location  VARCHAR(100)
,av_office_phone  VARCHAR(20)
,av_secondary_office_location  VARCHAR(30)
,av_secondary_office_phone  VARCHAR(20)
,av_directory_department  VARCHAR(60)
,av_salutation  VARCHAR(30)
,av_country_of_citizenship  VARCHAR(30)
,av_primary_title  VARCHAR(51)
,av_directory_title  VARCHAR(51)
,av_home_unit   VARCHAR(10)
,av_job_group  VARCHAR(255)
,av_personnel_sub_area   VARCHAR(255)
,av_personnel_sub_group  VARCHAR(255)
,av_is_on_sabbatical  VARCHAR(255)
,av_id_provided  VARCHAR(255)
,av_address_line_1  VARCHAR(80)
,av_address_line_2  VARCHAR(80)
,av_city  VARCHAR(30)
,av_state  VARCHAR(30)
,av_postal_code  VARCHAR(15)
,av_country_code  VARCHAR(3)
,av_fax_number  VARCHAR(20)
,av_pager_number  VARCHAR(20)
,av_mobile_phone_number  VARCHAR(20)
,av_era_commons_user_name  VARCHAR(255)
,av_anniversary_date  VARCHAR(10)
,av_update_timestamp  DATE)
BEGIN
DECLARE li_dob_year INT(4) DEFAULT cast(SUBSTR(av_date_of_birth, 5, 4) as decimal);
DECLARE li_today_year INT(4) DEFAULT year(utc_timestamp());
DECLARE li_dob_month_day INT(4) DEFAULT cast(SUBSTR(av_date_of_birth, 1, 4) as decimal);
DECLARE li_today_month_day INT(4) DEFAULT  cast(date_format(now(), '%m%d') as decimal);
DECLARE ls_ssn VARCHAR(9) DEFAULT av_ssn;
DECLARE ls_last_name VARCHAR(30) DEFAULT RTRIM(SUBSTR(av_last_name, 1, 30));
DECLARE ls_first_name VARCHAR(30) DEFAULT RTRIM(SUBSTR(av_first_name, 1, 30));
DECLARE ls_middle_name VARCHAR(30) DEFAULT RTRIM(SUBSTR(av_middle_name, 1, 30));
DECLARE ls_full_name VARCHAR(90) DEFAULT NULL;
DECLARE ls_user_name VARCHAR(60) DEFAULT RTRIM(av_user_name);
DECLARE ls_email_address VARCHAR(60) DEFAULT LOWER(RTRIM(SUBSTR(av_email_address, 1, 60)));
DECLARE ld_date_of_birth DATETIME DEFAULT STR_TO_DATE(av_date_of_birth, '%m%d%Y');
DECLARE li_age INT(3)DEFAULT (li_today_year - li_dob_year);
DECLARE li_age_by_fiscal_year INT(3) DEFAULT li_age;
DECLARE ls_gender VARCHAR(30) DEFAULT NULL;
DECLARE ls_race VARCHAR(30) DEFAULT RTRIM(SUBSTR(av_race, 1, 30));
DECLARE ls_education_level VARCHAR(30) DEFAULT RTRIM(SUBSTR(av_education_level, 1, 30));
DECLARE ls_is_veteran VARCHAR(1) DEFAULT NULL;
DECLARE ls_veteran_code VARCHAR(1) DEFAULT av_veteran_code;
DECLARE ls_veteran_type VARCHAR(30) DEFAULT NULL;
DECLARE ls_visa_code VARCHAR(20) DEFAULT RTRIM(SUBSTR(av_visa_code, 1, 20));
DECLARE ls_visa_type VARCHAR(30) DEFAULT RTRIM(av_visa_type);
DECLARE ld_visa_renewal_date DATETIME DEFAULT STR_TO_DATE(av_visa_renewal_date, '%m%d%Y');
DECLARE ls_has_visa VARCHAR(1) DEFAULT 'N';
DECLARE ls_office_location VARCHAR(30) DEFAULT RTRIM(SUBSTR(av_office_location, 1, 30));
DECLARE ls_office_phone VARCHAR(20) DEFAULT RTRIM(av_office_phone);
DECLARE ls_secondary_office_loc VARCHAR(30) DEFAULT RTRIM(SUBSTR(av_secondary_office_location, 1, 30));
DECLARE ls_secondary_office_phone VARCHAR(20) DEFAULT RTRIM(av_secondary_office_phone);
DECLARE ls_directory_department VARCHAR(30) DEFAULT (select INITCAP(RTRIM(av_directory_department)));
DECLARE ls_salutation_code VARCHAR(1) DEFAULT av_salutation;
DECLARE ls_salutation VARCHAR(30) DEFAULT NULL;
DECLARE ls_country_of_citizenship VARCHAR(30) DEFAULT 'XXX';
DECLARE ls_primary_title VARCHAR(51) DEFAULT (select INITCAP(RTRIM(av_primary_title)));
DECLARE ls_directory_title VARCHAR(50) DEFAULT SUBSTR(ls_primary_title, 1, 50);
DECLARE ls_is_faculty VARCHAR(1) DEFAULT NULL;
DECLARE ls_is_grad_student VARCHAR(1) DEFAULT NULL;
DECLARE ls_is_research_staff VARCHAR(1) DEFAULT NULL;
DECLARE ls_is_service_staff VARCHAR(1) DEFAULT NULL;
DECLARE ls_is_support_staff VARCHAR(1) DEFAULT NULL;
DECLARE ls_is_other_accademic_group VARCHAR(1) DEFAULT NULL;
DECLARE ls_is_medical_staff VARCHAR(1) DEFAULT NULL;
DECLARE ls_is_on_sabbatical VARCHAR(1) DEFAULT RTRIM(av_is_on_sabbatical);
DECLARE ls_id_provided VARCHAR(30) DEFAULT RTRIM(av_id_provided);
DECLARE ls_address_line_1 VARCHAR(80) DEFAULT RTRIM(av_address_line_2);
DECLARE ls_address_line_2 VARCHAR(80) DEFAULT RTRIM(av_address_line_1);
DECLARE ls_city VARCHAR(30) DEFAULT RTRIM(SUBSTR(av_city, 1, 30));
DECLARE ls_county VARCHAR(30) DEFAULT NULL;
DECLARE ls_state VARCHAR(30) DEFAULT RTRIM(av_state);
DECLARE ls_postal_code VARCHAR(15) DEFAULT RTRIM(av_postal_code);
DECLARE ls_country_code VARCHAR(3) DEFAULT 'XXX';
DECLARE ls_fax_number VARCHAR(20) DEFAULT RTRIM(av_fax_number);
DECLARE ls_pager_number VARCHAR(20) DEFAULT RTRIM(av_pager_number);
DECLARE ls_mobile_phone_number VARCHAR(20) DEFAULT RTRIM(av_mobile_phone_number);
DECLARE ls_era_commons_user_name VARCHAR(12) DEFAULT RTRIM(SUBSTR(av_era_commons_user_name, 1, 12));
DECLARE ls_status VARCHAR(1) DEFAULT 'A';
DECLARE ls_salary_anniversary_date DATETIME DEFAULT STR_TO_DATE(av_anniversary_date, '%m%d%Y');
DECLARE ls_action_performed VARCHAR(8) DEFAULT NULL;
DECLARE li_country_row_count INT(1) DEFAULT NULL;
DECLARE li_unit_row_count INT(1) DEFAULT NULL;
DECLARE li_row_count INT(1) DEFAULT NULL;
DECLARE li_user_name_exists INT(1) DEFAULT NULL;
SET SQL_SAFE_UPDATES =0;
BEGIN
IF LENGTH(ls_middle_name) > 0 THEN
  SET ls_full_name = CONCAT(ls_last_name , ', ' , ls_first_name , ' ' , SUBSTR(ls_middle_name, 1, 1));
ELSE
  SET ls_full_name = CONCAT(ls_last_name , ', ' , ls_first_name);
END IF;
IF LENGTH(ls_full_name) > 90 THEN
  SET ls_full_name = CONCAT(ls_first_name , ' ' , SUBSTR(ls_middle_name, 1, 28) , ' ' , ls_last_name);
END IF;
IF ls_user_name LIKE 'CE0%'
	OR ls_user_name LIKE 'CE1%'
	OR ls_user_name LIKE 'CE2%'
	OR ls_user_name LIKE 'CE3%'
	OR ls_user_name LIKE 'CE4%'
	OR ls_user_name LIKE 'CE5%'
	OR ls_user_name LIKE 'CE6%'
	OR ls_user_name LIKE 'CE7%'
	OR ls_user_name LIKE 'CE8%'
	OR ls_user_name LIKE 'CE9%' THEN
 SET  ls_user_name = SUBSTR(ls_user_name, 5);
END IF;
IF av_gender = '1' THEN
  SET  ls_gender = 'Male';
ELSEIF av_gender = '2' THEN
  SET  ls_gender = 'Female';
ELSE
  SET  ls_gender = 'Unknown';
END IF;
IF av_veteran_code IS NOT NULL THEN
  SET  ls_is_veteran = 'Y';
  SELECT veteran_description
  INTO ls_veteran_type
  FROM sap_veteran
  WHERE veteran_code = ls_veteran_code;
ELSE
  SET  ls_is_veteran = 'N';
END IF;
SELECT COUNT(*)
INTO li_country_row_count
FROM country
WHERE TRIM(COUNTRY_CODE_ISO2) = TRIM(av_country_code);
IF  li_country_row_count > 0 AND av_country_code IS NOT NULL THEN
	  SELECT MAX(COUNTRY_CODE)
	  INTO ls_country_code
	  FROM country
	  WHERE COUNTRY_CODE_ISO2 = TRIM(av_country_code);
	  IF UPPER(TRIM(av_country_code)) = 'GU' THEN
		SET  ls_state = 'GM';
	  ELSEIF UPPER(TRIM(av_country_code)) IN ('AS', 'FM', 'MH', 'MP', 'PR', 'PW', 'VI') THEN
		SET  ls_state = UPPER(TRIM(av_country_code));
	  ELSEIF UPPER(TRIM(av_country_code)) != 'US' THEN
		SET  ls_state = NULL;
	  END IF;
END IF;
SET li_unit_row_count = 0;
SELECT COUNT(*)
INTO li_unit_row_count
FROM unit
WHERE unit_number = TRIM(av_home_unit);
IF  li_unit_row_count > 0 THEN
  SELECT (SELECT INITCAP(SUBSTR(unit_name, 1, 30)))
  INTO ls_directory_department
  FROM unit
  WHERE unit_number = TRIM(av_home_unit);
END IF;
SELECT COUNT(*)
INTO li_country_row_count
FROM country
WHERE TRIM(COUNTRY_CODE_ISO2) = TRIM(av_country_of_citizenship);
IF  li_country_row_count > 0 AND av_country_of_citizenship IS NOT NULL THEN
  SELECT MAX(COUNTRY_CODE)
  INTO ls_country_of_citizenship
  FROM country
  WHERE COUNTRY_CODE_ISO2 = TRIM(av_country_of_citizenship);
END IF;
IF ls_country_code <> 'USA' THEN
  SET ls_has_visa = 'Y';
END IF;
if ls_country_code = 'XXX' THEN
insert into jhu_sap_interface_log (MODULE_ITEM_ID, FILE_NAME, ERROR_MESSAGE ) values(av_person_id, 'sap_hr_interface', CONCAT('Person ',av_person_id,' updated with default country_code'));
END IF;
IF li_today_month_day < li_dob_month_day THEN
  SET  li_age = li_age - 1;
  SET  li_age_by_fiscal_year = li_age;
END IF;
IF av_salutation IS NOT NULL THEN
  SELECT salutation_description
  INTO ls_salutation
  FROM sap_salutation
  WHERE salutation_code = ls_salutation_code;
END IF;
IF av_personnel_sub_area IN ('U002','U010')
	OR av_personnel_sub_group = '21'
	OR av_personnel_sub_group = '06'
	OR av_personnel_sub_group = '6' THEN
  SET  ls_is_faculty = 'Y';
ELSE
  SET  ls_is_faculty = 'N';
END IF;
IF av_personnel_sub_area = 'U008' THEN
	SET  ls_is_grad_student = 'Y';
ELSE
	SET ls_is_grad_student = 'N';
END IF;
SELECT COUNT(*)
INTO li_row_count
FROM person
WHERE person_id = av_person_id;
IF li_row_count = 0 THEN
  SET ls_action_performed = 'Insert';
  INSERT INTO person (person_id
						 ,last_name
						 ,first_name
						 ,middle_name
						 ,full_name
						 ,user_name
						 ,email_address
						 ,date_of_birth
						 ,age
						 ,age_by_fiscal_year
						 ,gender
						 ,education_level
						 ,office_location
						 ,office_phone
						 ,secondry_office_location
						 ,secondry_office_phone
						 ,directory_department
						 ,salutation
						 ,country_of_citizenship
						 ,primary_title
						 ,directory_title
						 ,home_unit
						 ,is_faculty
						 ,is_graduate_student_staff
						 ,is_research_staff
						 ,is_service_staff
						 ,is_support_staff
						 ,is_other_accademic_group
						 ,is_medical_staff
						 ,address_line_1
						 ,address_line_2
						 ,city
						 ,county
						 ,state
						 ,postal_code
						 ,country_code
						 ,fax_number
						 ,pager_number
						 ,mobile_phone_number
						 ,status
						 ,salary_anniversary_date
						 ,update_timestamp
						 ,update_user
                         ,visa_code
                         ,visa_type
                         ,visa_renewal_date)
  VALUES (av_person_id
		 ,ls_last_name
		 ,ls_first_name
		 ,ls_middle_name
		 ,ls_full_name
		 ,ls_user_name
		 , IFNULL(ls_email_address,concat(ls_user_name,'@johnshopkins.edu'))
		 ,NULL
		 ,NULL
		 ,NULL
		 ,NULL
		 ,ls_education_level
		 ,ls_office_location
		 ,ls_office_phone
		 ,ls_secondary_office_loc
		 ,ls_secondary_office_phone
		 ,CASE li_unit_row_count WHEN 0 THEN 'JOHNS HOPKINS ENTERPRISE' ELSE ls_directory_department END
		 ,ls_salutation
		 ,ls_country_of_citizenship
		 ,ls_primary_title
		 ,ls_directory_title
		 ,CASE li_unit_row_count WHEN 0 THEN '000001' ELSE ifnull(av_home_unit,'000001') END
		 ,ls_is_faculty
		 ,ls_is_grad_student
		 ,ls_is_research_staff
		 ,ls_is_service_staff
		 ,ls_is_support_staff
		 ,ls_is_other_accademic_group
		 ,ls_is_medical_staff
		 ,ls_address_line_1
		 ,ls_address_line_2
		 ,ls_city
		 ,ls_county
		 ,ls_state
		 ,ls_postal_code
		 ,ls_country_code
		 ,ls_fax_number
		 ,ls_pager_number
		 ,ls_mobile_phone_number
		 ,ls_status
		 ,ls_salary_anniversary_date
		 ,av_update_timestamp
         ,'COEUS'
         ,ls_visa_code
         ,ls_visa_type
         ,ld_visa_renewal_date
		 );
				INSERT INTO appointments (person_id
									,unit_number
									,primary_secondary_indicator
									,appointment_start_date
									,appointment_end_date
									,appointment_type
									,job_code
									,salary
									,update_timestamp
									,update_user)
				VALUES (av_person_id
									,'000001'
									,'Primary'
									,'1900-01-01 00:00:00'
									,'9999-12-31 00:00:00'
									,'12M EMPLOYEE'
									,'999999'
									,0
									,av_update_timestamp
									,'COEUS');
ELSE
  SET  ls_action_performed = 'Update';
  UPDATE person
  SET
	 last_name = ls_last_name
	 ,first_name = ls_first_name
	 ,middle_name = ls_middle_name
	 ,full_name = ls_full_name
	 ,user_name = ls_user_name
	 ,email_address =  IFNULL(ls_email_address,concat(ls_user_name,'@johnshopkins.edu'))
	 ,date_of_birth = NULL
	 ,age = NULL
	 ,age_by_fiscal_year = NULL
	 ,gender = NULL
	 ,education_level = ls_education_level
	 ,office_location = ls_office_location
	 ,office_phone = ls_office_phone
	 ,secondry_office_location = ls_secondary_office_loc
	 ,secondry_office_phone = ls_secondary_office_phone
	 ,directory_department = CASE li_unit_row_count WHEN 0 THEN 'JOHNS HOPKINS ENTERPRISE' ELSE ls_directory_department END
	 ,salutation = ls_salutation
	 ,country_of_citizenship = ls_country_of_citizenship
	 ,primary_title = ls_primary_title
	 ,directory_title = ls_directory_title
	 ,home_unit = CASE li_unit_row_count WHEN 0 THEN '000001' ELSE ifnull(av_home_unit,'000001') END
	 ,is_faculty = ls_is_faculty
	 ,is_graduate_student_staff = ls_is_grad_student
	 ,is_research_staff = ls_is_research_staff
	 ,is_service_staff = ls_is_service_staff
	 ,is_support_staff = ls_is_support_staff
	 ,is_other_accademic_group = ls_is_other_accademic_group
	 ,is_medical_staff = ls_is_medical_staff
	 ,address_line_1 = ls_address_line_1
	 ,address_line_2 = ls_address_line_2
	 ,city = ls_city
	 ,county = ls_county
	 ,state = ls_state
	 ,country_code = ls_country_code
	 ,fax_number = ls_fax_number
	 ,pager_number = ls_pager_number
	 ,mobile_phone_number = ls_mobile_phone_number
	 ,salary_anniversary_date = ls_salary_anniversary_date
	 ,update_timestamp = av_update_timestamp
	 ,update_user = 'COEUS'
    ,visa_code = ls_visa_code
    ,visa_type = ls_visa_type
    ,visa_renewal_date = ld_visa_renewal_date
  WHERE person_id = av_person_id;
END IF;
END;
END
$$
DELIMITER ;
