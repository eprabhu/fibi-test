DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `jhu_sap_hr_upd_eis_ssn_table`(av_person_id  VARCHAR(40)
  ,av_ssn  VARCHAR(255)
  ,av_last_name  VARCHAR(50)
  ,av_first_name  VARCHAR(50)
  ,av_middle_name  VARCHAR(50)
  ,av_user_name  VARCHAR(60)
  ,av_email_address  VARCHAR(60)
  ,av_gender  VARCHAR(30)
  ,av_race  VARCHAR(30)
  ,av_office_location  VARCHAR(100)
  ,av_office_phone  VARCHAR(20)
  ,av_primary_title  VARCHAR(51)
  ,av_home_unit  VARCHAR(8)
  ,av_personnel_sub_area  VARCHAR(255)
  ,av_personnel_sub_group  VARCHAR(255)
  ,av_update_timestamp  DATE)
BEGIN
DECLARE ls_ssn VARCHAR(9) DEFAULT av_ssn;
DECLARE ls_last_name VARCHAR(30) DEFAULT RTRIM(SUBSTR(av_last_name, 1, 30));
DECLARE ls_first_name VARCHAR(30) DEFAULT RTRIM(SUBSTR(av_first_name, 1, 30));
DECLARE ls_middle_name VARCHAR(30) DEFAULT RTRIM(SUBSTR(av_middle_name, 1, 30));
DECLARE ls_user_name VARCHAR(60) DEFAULT RTRIM(av_user_name);
DECLARE ls_email_address VARCHAR(60) DEFAULT LOWER(RTRIM(SUBSTR(av_email_address, 1, 60)));
DECLARE ls_gender VARCHAR(30) DEFAULT NULL;
DECLARE ls_race VARCHAR(30) DEFAULT RTRIM(SUBSTR(av_race, 1, 30));
DECLARE ls_office_location VARCHAR(30) DEFAULT RTRIM(SUBSTR(av_office_location, 1, 30));
DECLARE ls_office_phone VARCHAR(20) DEFAULT RTRIM(av_office_phone);
DECLARE ls_primary_title VARCHAR(51) DEFAULT (SELECT INITCAP(RTRIM(av_primary_title)));
DECLARE ls_is_faculty VARCHAR(1) DEFAULT NULL;
DECLARE li_row_count INT(3);
SET SQL_SAFE_UPDATES =0;
	IF (ls_user_name LIKE 'CE0%'
		OR ls_user_name LIKE 'CE1%'
		OR ls_user_name LIKE 'CE2%'
		OR ls_user_name LIKE 'CE3%'
		OR ls_user_name LIKE 'CE4%'
		OR ls_user_name LIKE 'CE5%'
		OR ls_user_name LIKE 'CE6%'
		OR ls_user_name LIKE 'CE7%'
		OR ls_user_name LIKE 'CE8%'
		OR ls_user_name LIKE 'CE9%')
	THEN
	  SET ls_user_name = SUBSTR(ls_user_name, 5);
	END IF;
	IF av_gender = '1'THEN
	  SET ls_gender = 'Male';
	ELSEIF av_gender = '2' THEN
	  SET ls_gender = 'Female';
	ELSE
	  SET ls_gender = 'Unknown';
	END IF;
	IF av_personnel_sub_area IN ('U002','U010')
		OR av_personnel_sub_group = '21'
		OR av_personnel_sub_group = '06'
		OR av_personnel_sub_group = '6' THEN
		SET ls_is_faculty = 'Y';
	ELSE
		SET ls_is_faculty = 'N';
	END IF;
	SELECT COUNT(*)
	INTO li_row_count
	FROM eis_ssn
	WHERE person_id = av_person_id;
	IF li_row_count = 0 THEN
		  INSERT INTO eis_ssn (person_id
							  ,ssn
							  ,last_name
							  ,first_name
							  ,middle_name
							  ,user_name
							  ,email_address
							  ,gender
							  ,race
							  ,office_location
							  ,office_phone
							  ,primary_title
							  ,home_unit
							  ,is_faculty
							  ,update_timestamp
							  ,update_user)
		  VALUES (av_person_id
				 ,ls_ssn
				 ,ls_last_name
				 ,ls_first_name
				 ,ls_middle_name
				 ,ls_user_name
				 ,ls_email_address
				 ,ls_gender
				 ,ls_race
				 ,ls_office_location
				 ,ls_office_phone
				 ,ls_primary_title
				 ,av_home_unit
				 ,ls_is_faculty
				 ,av_update_timestamp
				 ,'COEUS');
	ELSE
		  UPDATE eis_ssn
		  SET ssn = ls_ssn
			 ,last_name = ls_last_name
			 ,first_name = ls_first_name
			 ,middle_name = ls_middle_name
			 ,user_name = ls_user_name
			 ,email_address = ls_email_address
			 ,gender = ls_gender
			 ,race = ls_race
			 ,office_location = ls_office_location
			 ,office_phone = ls_office_phone
			 ,primary_title = ls_primary_title
			 ,home_unit = av_home_unit
			 ,is_faculty = ls_is_faculty
			 ,update_timestamp = av_update_timestamp
			 ,update_user = 'COEUS'
		  WHERE person_id = av_person_id;
	END IF;
END
$$
DELIMITER ;
