DELIMITER $$
CREATE  PROCEDURE `GET_ADMINISTRATIVE_DETAILS`(AD_TYPE VARCHAR(200) )
BEGIN
DECLARE TAB_QUERY LONGTEXT;
IF AD_TYPE = 'ROLE_MASTER_DATA' THEN
	SET TAB_QUERY = CONCAT('SELECT " Role Name", "Status", "Created By", "Created On", "Updated By", "Updated On" UNION
							(SELECT t1.ROLE_NAME,t1.STATUS_FLAG,IFNULL(t2.FULL_NAME,t1.CREATE_USER) as CREATE_USER ,CONVERT_TZ(t1.CREATE_TIMESTAMP,''+00:00'',''+8:00'') AS CREATE_TIMESTAMP,
							IFNULL(t3.FULL_NAME, t1.UPDATE_USER) as UPDATE_USER,CONVERT_TZ(t1.UPDATE_TIMESTAMP,''+00:00'',''+8:00'') as UPDATE_TIMESTAMP
							FROM role t1 left outer join person t2 on t1.CREATE_USER = t2.USER_NAME
							left outer join person t3 on t1.UPDATE_USER = t3.USER_NAME
							 ) order by 1');
ELSEIF AD_TYPE = 'ROLE_RIGHT_MAPPING' THEN
    SET TAB_QUERY = CONCAT('SELECT " Role Name", " Right Name", "Updated By", "Updated On" UNION
							(SELECT t2.ROLE_NAME,t3.RIGHT_NAME, IFNULL(t4.FULL_NAME, t1.UPDATE_USER) as UPDATE_USER, CONVERT_TZ(t1.UPDATE_TIMESTAMP,''+00:00'',''+8:00'') as UPDATE_TIMESTAMP
							FROM role_rights t1 inner join role t2 on t1.ROLE_ID = t2.ROLE_ID
							inner join rights t3 on t1.RIGHT_ID = t3.RIGHT_ID
							left outer join person t4 on t1.UPDATE_USER = t4.USER_NAME
							) order by 1,2');
ELSEIF AD_TYPE = 'PERSON_ROLE_ASSIGNMENT' THEN
	SET TAB_QUERY = CONCAT('SELECT USER_NAME, FULL_NAME, HOME_UNIT, UNIT_NAME, ROLE_NAME, DESCEND_FLAG, UPDATE_USER, UPDATE_TIMESTAMP FROM
	(SELECT "Username" as USER_NAME, " Full Name" AS FULL_NAME, "Home Unit" AS HOME_UNIT, "Unit Name" AS UNIT_NAME, "Role Name" AS ROLE_NAME, "Descend Flag" AS DESCEND_FLAG, "Updated By" AS UPDATE_USER, "Updated On" AS UPDATE_TIMESTAMP, 1 AS SORT_ORDER UNION
							(SELECT distinct t2.USER_NAME,t2.FULL_NAME, t6.UNIT_NAME as HOME_UNIT, t3.UNIT_NAME,t4.ROLE_NAME,t1.DESCEND_FLAG,
							IFNULL(t5.FULL_NAME, t1.UPDATE_USER) as UPDATE_USER, CONVERT_TZ(t1.UPDATE_TIMESTAMP,''+00:00'',''+8:00'') as UPDATE_TIMESTAMP, 2 AS SORT_ORDER
							FROM person_roles t1
                            inner join person t2 on t1.PERSON_ID = t2.PERSON_ID and t2.STATUS = ''A''
							inner join unit t3 on t3.UNIT_NUMBER = t1.UNIT_NUMBER
							inner join role t4 on t4.ROLE_ID = t1.ROLE_ID
							left outer join person t5 on t1.UPDATE_USER = t5.USER_NAME
                            left outer join unit t6 on t6.UNIT_NUMBER = t2.HOME_UNIT
							 ) ORDER BY SORT_ORDER)Z ');
ELSEIF AD_TYPE = 'UNIT_HIERARCHY' THEN
	SET TAB_QUERY = CONCAT('SELECT "Unit Number", " Unit Name", "Parent Unit Number", "Parent Unit Name", "Active Flag", "Updated By", "Updated On" UNION
							(select t1.UNIT_NUMBER,t1.UNIT_NAME,t1.PARENT_UNIT_NUMBER,t2.UNIT_NAME as PARENT_UNIT_NAME,
							t1.ACTIVE_FLAG,IFNULL(t4.FULL_NAME, t1.UPDATE_USER) as UPDATE_USER,t1.UPDATE_TIMESTAMP as UPDATE_TIMESTAMP
							from unit t1 left outer join unit t2 on t1.PARENT_UNIT_NUMBER = t2.UNIT_NUMBER
							left outer join person t4 on t1.UPDATE_USER = t4.USER_NAME
							) order by 2 ');
ELSEIF AD_TYPE = 'UNIT_ADMINISTRATOR_HOD' THEN
	SET TAB_QUERY = CONCAT('SELECT "Unit Number", " Unit Name", "Unit Administrator Type", "Admin Full Name", "Has HOD Role in Rise", "Updated By", "Updated On" UNION
							(select t1.UNIT_NUMBER, t4.UNIT_NAME, t2.DESCRIPTION AS UNIT_ADMINISTRATOR_TYPE, t3.FULL_NAME as ADMIN_FULL_NAME,
							CASE WHEN ( select count(*) from person_roles s1 where s1.PERSON_ID = t1.PERSON_ID
							and s1.UNIT_NUMBER = t1.UNIT_NUMBER and s1.ROLE_ID = 400) > 0 Then ''Y'' else ''N''
							END as HAS_HOD_ROLE_RISE, IFNULL(t5.FULL_NAME, t1.UPDATE_USER) as UPDATE_USER, CONVERT_TZ(t1.UPDATE_TIMESTAMP,''+00:00'',''+8:00'') as UPDATE_TIMESTAMP
							from unit_administrator t1 inner join unit_administrator_type t2 on t1.UNIT_ADMINISTRATOR_TYPE_CODE = t2.UNIT_ADMINISTRATOR_TYPE_CODE
							inner join person t3 on t1.PERSON_ID = t3.PERSON_ID inner join unit t4 on t4.UNIT_NUMBER = t1.UNIT_NUMBER
							left outer join person t5 on t1.UPDATE_USER = t5.USER_NAME ) order by 2 ');
ELSEIF AD_TYPE = 'BUDGET_COST_ELEMENT_MASTER_DATA' THEN
	SET TAB_QUERY = CONCAT('SELECT " Cost Element Code", "Cost Element", "Budget Category Code", "Updated By", "Updated On" UNION
							(select t1.COST_ELEMENT as COST_ELEMENT_CODE, t1.DESCRIPTION as COST_ELEMENT , t1.BUDGET_CATEGORY_CODE,
							IFNULL(t4.FULL_NAME, t1.UPDATE_USER) as UPDATE_USER, CONVERT_TZ(t1.UPDATE_TIMESTAMP,''+00:00'',''+8:00'') as UPDATE_TIMESTAMP
							from cost_element t1 left outer join person t4 on t1.UPDATE_USER = t4.USER_NAME
							) order by 1 ');
ELSEIF AD_TYPE = 'ROLODEX_MASTER_DATA' THEN
	SET TAB_QUERY = CONCAT('SELECT "Rolodex id#", " Full Name", "Email Address", "Organization Name", "Owned by Unit","Created By", "Updated By", "Updated On" UNION
							(SELECT ROLODEX_ID,rolodex.FULL_NAME,rolodex.EMAIL_ADDRESS,organization.ORGANIZATION_NAME, unit.UNIT_NAME as  OWNED_BY_UNIT,
                            rolodex.CREATE_USER,
							IFNULL(t5.FULL_NAME, rolodex.UPDATE_USER) as UPDATE_USER, CAST(rolodex.UPDATE_TIMESTAMP AS DATE) AS UPDATE_TIMESTAMP
							FROM rolodex left outer join organization on rolodex.ORGANIZATION = organization.ORGANIZATION_ID
							left outer join unit on rolodex.OWNED_BY_UNIT = unit.UNIT_NUMBER
							left outer join person t5 on rolodex.UPDATE_USER = t5.USER_NAME)  order by 2');
ELSEIF AD_TYPE = 'SPONSOR_MASTER_DATA' THEN
	SET TAB_QUERY = CONCAT('SELECT "Sponsor Code", " Sponsor Name", "Acronym", "Sponsor Type", "Rolodex Full Name", "Owned Unit Name",
							"Address Line 1", "Address Line 2", "Address Line 3", "Email Address", "Country Name", "Created By", "Updated By", "Updated On" UNION
							(SELECT sponsor.SPONSOR_CODE,sponsor.SPONSOR_NAME,sponsor.ACRONYM, sponsor_type.DESCRIPTION as SPONSOR_TYPE,
							rolodex.FULL_NAME as ROLODEX_FULL_NAME,unit.UNIT_NAME as OWNED_UNIT_NAME,
							sponsor.ADDRESS_LINE_1,sponsor.ADDRESS_LINE_2,sponsor.ADDRESS_LINE_3,
							sponsor.EMAIL_ADDRESS,country.COUNTRY_NAME, sponsor.CREATE_USER , IFNULL(t5.FULL_NAME, sponsor.UPDATE_USER) as UPDATE_USER, CONVERT_TZ(sponsor.UPDATE_TIMESTAMP,''+00:00'',''+8:00'') as UPDATE_TIMESTAMP
							FROM sponsor left outer join sponsor_type on sponsor_type.SPONSOR_TYPE_CODE = sponsor.SPONSOR_TYPE_CODE
							left outer join rolodex on rolodex.ROLODEX_ID = sponsor.ROLODEX_ID left outer join unit on unit.UNIT_NUMBER = sponsor.OWNED_BY_UNIT
							left outer join country on sponsor.COUNTRY_CODE = country.COUNTRY_CODE left outer join person t5 on sponsor.UPDATE_USER = t5.USER_NAME
							)order by 2');
ELSEIF AD_TYPE = 'ORGANIZATION_MASTER_DATA' THEN
	SET TAB_QUERY = CONCAT('SELECT "  Organization Id#", "     Organization Name", "  Vendor Code", "  Country Code", "  Is Active", "  Updated By", "  Updated On" UNION
							(select t1.ORGANIZATION_ID, t1.ORGANIZATION_NAME, t1.VENDOR_CODE, country.COUNTRY_NAME, t1.IS_ACTIVE,
							IFNULL(t5.FULL_NAME, t1.UPDATE_USER) as UPDATE_USER, CONVERT_TZ(t1.UPDATE_TIMESTAMP,''+00:00'',''+8:00'') as UPDATE_TIMESTAMP from organization t1
							left outer join country on t1.COUNTRY_CODE = country.COUNTRY_CODE left outer join person t5 on t1.UPDATE_USER = t5.USER_NAME
							) order by 2 ');
ELSEIF AD_TYPE = 'MANPOWER_BASE_SALARY_ACCESS' THEN
	SET TAB_QUERY = CONCAT('select
							z.MANPOWER_LOG_USER_ID, z.AWARD_NUMBER, z.ACCOUNT_NUMBER, z.PERSON_ID,z.UPDATE_TIMESTAMP,
							z.UPDATE_USER, z.LOGIN_PERSON_ID, z.FULL_NAME, z.ACCESS_STATUS
							from
							(
							SELECT 2 as sort_order, "Manpower Log User Id#" as MANPOWER_LOG_USER_ID, "Award Number" as AWARD_NUMBER, "Account Number" ACCOUNT_NUMBER,
							"Person Id#" as PERSON_ID , "Updated On" as UPDATE_TIMESTAMP, "Updated By" as UPDATE_USER, "Login Person Id#" as LOGIN_PERSON_ID,
							 "Login Person Name" as FULL_NAME, "Access Status"  as ACCESS_STATUS
							 UNION
								(select 1 as sort_order, t1.MANPOWER_LOG_USER_ID, t1.AWARD_NUMBER, t1.ACCOUNT_NUMBER, t1.PERSON_ID,CONVERT_TZ(t1.UPDATE_TIMESTAMP,''+00:00'',''+8:00'') as UPDATE_TIMESTAMP, t1.UPDATE_USER, t1.LOGIN_PERSON_ID, t2.FULL_NAME, t1.ACCESS_STATUS
								from manpower_log_user t1 left outer join person t2 on t1.LOGIN_PERSON_ID = t2.PERSON_ID
								WHERE t1.UPDATE_TIMESTAMP >= (DATE_ADD(utc_timestamp(),INTERVAL -1 YEAR))
								order by t1.UPDATE_TIMESTAMP desc
								) order by sort_order desc, 6 desc
							) z');
ELSEIF AD_TYPE = 'PERSON_LOGIN_DATA' THEN
	SET TAB_QUERY = CONCAT('
					SELECT  PERSON_ID, USER_ID, FULL_NAME, HOME_UNIT, LOGIN_DATE,
                       IS_FACULTY,STUDENT_STAFF,RESEARCH_STAFF,SUPPORT_STAFF,IS_CONTINGENCY, IS_EXTERNAL
                       FROM
					   (SELECT  1 as SORT_ORDER,"Person Id" AS PERSON_ID, "User Id" AS USER_ID, " Full Name" AS FULL_NAME, "Home unit" AS HOME_UNIT, "Last login Datetime" AS LOGIN_DATE,
                       "Is Faculty" AS IS_FACULTY,"Is Graduate Student Staff" AS STUDENT_STAFF,"Is Research Staff" AS RESEARCH_STAFF,"Is Support Staff" AS SUPPORT_STAFF,"Is Contingency" AS IS_CONTINGENCY, "Is External User" AS IS_EXTERNAL
                       UNION
							( SELECT
                            2 AS SORT_ORDER,
							t1.PERSON_ID,
							t1.USER_NAME,
							t1.FULL_NAME,
							t2.UNIT_NAME as HOME_UNIT,
							(
									select CONVERT_TZ(s1.UPDATE_TIMESTAMP,''+00:00'',''+8:00'')
									from person_login_details s1
									where s1.PERSON_ID = t1.person_id
									and s1.LOGIN_STATUS = ''IN''
									and  s1.LOGIN_DETAIL_ID = (select max(s2.LOGIN_DETAIL_ID) from person_login_details s2
																where s2.PERSON_ID = t1.person_id
																and s2.LOGIN_STATUS = ''IN'')
							) as LAST_LOGIN_DATE_TIME,
                            t1.IS_FACULTY,
							t1.IS_GRADUATE_STUDENT_STAFF,
                            IS_RESEARCH_STAFF,
							t1.IS_SUPPORT_STAFF,
							t1.IS_MEDICAL_STAFF,
							t1.IS_EXTERNAL_USER
							FROM PERSON t1
							LEFT OUTER JOIN UNIT t2 on t1.HOME_UNIT = t2.UNIT_NUMBER
							WHERE t1.STATUS = ''A''
                            ) ORDER BY SORT_ORDER)Z
                            ');
END IF;
SET @QUERY_STATEMENT = TAB_QUERY;
PREPARE EXECUTABLE_STAEMENT FROM @QUERY_STATEMENT;
EXECUTE EXECUTABLE_STAEMENT;
END
$$
DELIMITER ;
