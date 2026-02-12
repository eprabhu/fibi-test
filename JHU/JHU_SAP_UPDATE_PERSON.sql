DELIMITER $$
CREATE  PROCEDURE `JHU_SAP_UPDATE_PERSON`()
BEGIN
DECLARE DONE TINYINT DEFAULT 0;
DECLARE C1 CURSOR FOR
	select
 a.person_id
,a.ssn
,a.last_name
,a.first_name
,a.middle_name
,a.user_name
,a.email_address
,a.date_of_birth
,a.gender
,a.race
,a.education_level
,a.veteran_code
,a.visa_code
,a.visa_type
,a.visa_renewal_date
,a.office_location
,a.office_phone
,a.secondary_office_location
,a.secondary_office_phone
,a.directory_department
,a.salutation
,a.country_of_citizenship
,a.primary_title
,a.directory_title
,a.home_unit
,a.job_group
,a.personnel_sub_area
,a.personnel_sub_group
,a.is_on_sabbatical
,a.id_provided
,a.address_line_1
,a.address_line_2
,a.city
,a.state
,a.postal_code
,a.country_code
,a.fax_number
,a.pager_number
,a.mobile_phone_number
,a.era_commons_user_name
,a.anniversary_date
,a.appointment_unit_number
,a.appointment_start_date
,a.appointment_end_date
,a.appointment_type
,a.appointment_job_code
,a.salary
,a.school
,a.degree
,a.major
,a.graduation_date
,a.update_timestamp
 from sap_hr_interface a  where /*a.person_id  in (select person_id from stage_sap_hr_interface_wrong_data)
 and update_timestamp >'20231020000000'
 and*/ a.person_id  in (select person_id from stage_sap_hr_interface_wrong_data)
 order by update_timestamp asc
 ;
OPEN C1;
	LOOP1: LOOP BEGIN
	DECLARE av_person_id_in VARCHAR(40);
DECLARE av_ssn_in VARCHAR(9);
DECLARE av_last_name_in VARCHAR(50);
DECLARE av_first_name_in VARCHAR(50);
DECLARE av_middle_name_in VARCHAR(50);
DECLARE av_user_name_in VARCHAR(60);
DECLARE av_email_address_in VARCHAR(60);
DECLARE av_date_of_birth_in VARCHAR(20);
DECLARE av_gender_in VARCHAR(30);
DECLARE av_race_in VARCHAR(30);
DECLARE av_education_level_in VARCHAR(255);
DECLARE av_veteran_code_in VARCHAR(255);
DECLARE av_visa_code_in VARCHAR(255);
DECLARE av_visa_type_in VARCHAR(255);
DECLARE av_visa_renewal_date_in VARCHAR(255);
DECLARE av_office_location_in VARCHAR(100);
DECLARE av_office_phone_in VARCHAR(20);
DECLARE av_secondary_office_location_in VARCHAR(30);
DECLARE av_secondary_office_phone_in VARCHAR(20);
DECLARE av_directory_department_in VARCHAR(60);
DECLARE av_salutation_in VARCHAR(30);
DECLARE av_country_of_citizenship_in VARCHAR(30);
DECLARE av_primary_title_in VARCHAR(51);
DECLARE av_directory_title_in VARCHAR(51);
DECLARE av_home_unit_in VARCHAR(8);
DECLARE av_job_group_in VARCHAR(255);
DECLARE av_personnel_sub_area_in VARCHAR(255);
DECLARE av_personnel_sub_group_in VARCHAR(255);
DECLARE av_is_on_sabbatical_in VARCHAR(255);
DECLARE av_id_provided_in VARCHAR(255);
DECLARE av_address_line_1_in VARCHAR(80);
DECLARE av_address_line_2_in VARCHAR(80);
DECLARE av_city_in VARCHAR(30);
DECLARE av_state_in VARCHAR(30);
DECLARE av_postal_code_in VARCHAR(15);
DECLARE av_country_code_in VARCHAR(3);
DECLARE av_fax_number_in VARCHAR(20);
DECLARE av_pager_number_in VARCHAR(20);
DECLARE av_mobile_phone_number_in VARCHAR(20);
DECLARE av_era_commons_user_name_in VARCHAR(255);
DECLARE av_anniversary_date_in VARCHAR(255);
DECLARE av_appointment_unit_number_in VARCHAR(8);
DECLARE av_appointment_start_date_in VARCHAR(10);
DECLARE av_appointment_end_date_in VARCHAR(10);
DECLARE av_appointment_type_in VARCHAR(30);
DECLARE av_appointment_job_code_in VARCHAR(6);
DECLARE av_salary_in decimal(12, 2);
DECLARE av_school_in VARCHAR(255);
DECLARE av_degree_in VARCHAR(255);
DECLARE av_major_in VARCHAR(255);
DECLARE av_graduation_date_in VARCHAR(255);
DECLARE av_update_timestamp_in VARCHAR(255);
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET DONE = 1;
	FETCH C1 INTO av_person_id_in
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
,av_home_unit_in
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
,av_appointment_unit_number_in
,av_appointment_start_date_in
,av_appointment_end_date_in
,av_appointment_type_in
,av_appointment_job_code_in
,av_salary_in
,av_school_in
,av_degree_in
,av_major_in
,av_graduation_date_in
,av_update_timestamp_in ;
	IF DONE THEN
		LEAVE LOOP1;
	END IF;
call jhu_sap_hr_interface_proc(av_person_id_in
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
,av_home_unit_in
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
,av_appointment_unit_number_in
,av_appointment_start_date_in
,av_appointment_end_date_in
,av_appointment_type_in
,av_appointment_job_code_in
,av_salary_in
,av_school_in
,av_degree_in
,av_major_in
,av_graduation_date_in
,av_update_timestamp_in);
END;
END LOOP;
CLOSE C1;
END
$$
DELIMITER ;
