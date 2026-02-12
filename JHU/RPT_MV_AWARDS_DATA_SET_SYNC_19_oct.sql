DELIMITER $$
CREATE  PROCEDURE `RPT_MV_AWARDS_DATA_SET_SYNC_19_oct`()
BEGIN
DECLARE LS_unit_number VARCHAR(8);
DECLARE LS_SPONSOR VARCHAR(10);
DECLARE LS_SPONSOR_NAME VARCHAR(200);
DECLARE LS_PRINCIPAL_INVESTIGATOR_FLAG VARCHAR(1);
DECLARE LS_INV_NAME VARCHAR(90);
DECLARE LS_HOME_UNIT VARCHAR(8);
DECLARE LS_AWARD_TYPE VARCHAR(200);
DECLARE LS_PURPOSE VARCHAR(200);
DECLARE LS_TITLE VARCHAR(200);
DECLARE LS_PROPOSAL_TYPE VARCHAR(200);
DECLARE LD_START_DATE DATETIME;
DECLARE LD_END_DATE DATETIME;
DECLARE LD_AWARD_EFFECTIVE_DATE DATETIME;
DECLARE LI_DIRECT DECIMAL(12,2);
DECLARE LI_INDIRECT DECIMAL(12,2);
DECLARE LI_TOTAL DECIMAL(12,2);
DECLARE LS_AWARD_NUMBER VARCHAR(16);
DECLARE award_numbers LONGTEXT;
DECLARE LS_DYN_SQL LONGTEXT;
DECLARE LS_STATUS VARCHAR(200);
DECLARE LD_LAST_UPDATE_TIMESTAMP DATETIME;
DECLARE LS_LAST_SYNC_TIMESTAMP DATETIME;
DECLARE LS_PERSON_NAME VARCHAR(90);
DECLARE LI_AWARD_ID VARCHAR(70);
DECLARE LS_LEAD_UNIT_NUMBER VARCHAR(8);
SET SQL_SAFE_UPDATES = 0;
set LS_LAST_SYNC_TIMESTAMP='2023-10-19 10:00:33';
SET SESSION group_concat_max_len = 100000000;
SET SESSION group_concat_max_len = 100000000;
SELECT
    GROUP_CONCAT('\'', substring(a.award_number,1,6), '\'')
INTO award_numbers FROM
    award a
WHERE
    a.DOCUMENT_UPDATE_TIMESTAMP >= DATE_SUB(LS_LAST_SYNC_TIMESTAMP,
        INTERVAL 1 HOUR)
        AND  a.status_code != 3
        AND a.award_number LIKE '%-00001'
		AND a.SEQUENCE_NUMBER = 0;
IF award_numbers IS NOT NULL THEN
SET LS_DYN_SQL  = CONCAT('DELETE FROM RPT_MV_AWARDS T2
	WHERE T2.AWARD_NUMBER IN(', award_numbers, ')');
	SET @QUERY_STATEMENT = LS_DYN_SQL;
	PREPARE EXECUTABLE_STATEMENT FROM @QUERY_STATEMENT;
	EXECUTE EXECUTABLE_STATEMENT;
END IF;
BEGIN
DECLARE DONE INT DEFAULT FALSE;
        DECLARE CUR_PENDING_PROPOSALS_DATA_SET CURSOR FOR
	select DISTINCT substr(a.award_number, 1,6) as award_number
             ,a.AWARD_EFFECTIVE_DATE as AWARD_EFFECTIVE_DATE
             ,oas.DESCRIPTION as STATUS
             ,ai.FULL_NAME PERSON_NAME
             ,ai.PI_FLAG PRINCIPAL_INVESTIGATOR_FLAG
             ,au.unit_number as home_unit
             ,at.description award_type
             ,act.description purpose
             ,a.title as title
             ,s.sponsor_name
             ,s.ACRONYM as sponsor
             ,av.start_date as start_date
             ,av.end_date as end_date
             ,av.direct as direct
             ,av.indirect as indirect
             ,av.total as total
             ,a.sponsor_award_number as award_id
             ,au.unit_number as lead_unit_number
             ,utc_timestamp() AS  last_update_timestamp
 from award_persons ai
    left outer join (select award_id
		   , award_number
           , sum(TOTAL_DIRECT_COST) as direct
           , sum(TOTAL_indirect_cost) as indirect
           , sum(TOTAL_DIRECT_COST + TOTAL_indirect_cost) as total
		   , min(start_date) as start_date
           , max(end_date) as end_date
      from AWARD_AMT_FNA_DISTRIBUTION aafd
      WHERE SEQUENCE_NUMBER =(select max(SEQUENCE_NUMBER)
                            from AWARD_AMT_FNA_DISTRIBUTION
                            where award_number=aafd.award_number)
      group by aafd.award_number) av  on  av.award_number=ai.award_number
	left outer  join AWARD a on a.award_number=ai.award_number
    left outer  join AWARD_PERSON_UNIT au on au.AWARD_PERSON_ID=ai.AWARD_PERSON_ID
    join sponsor s on  s.sponsor_code = a.sponsor_code
    join award_type at on at.award_type_code = a.award_type_code
    join activity_type act on act.activity_type_code = a.activity_type_code
    join award_status oas on oas.status_code = a.status_code
where ai.PI_FLAG='Y'
AND ai.PERSON_ROLE_ID =3
and ai.sequence_number =(select max(SEQUENCE_NUMBER)
                         from award_persons
                         where award_number = ai.award_number)
and a.status_code !=3
and a.award_number like '%-00001'
and a.SEQUENCE_NUMBER = (select max(SEQUENCE_NUMBER)
                         from award_amount_info
                         where award_number = a.award_number)
and a.DOCUMENT_UPDATE_TIMESTAMP>=DATE_SUB(LS_LAST_SYNC_TIMESTAMP,INTERVAL 1 HOUR)
and au.lead_unit_flag='Y'
and au.sequence_number=(select max(SEQUENCE_NUMBER)
                         from AWARD_PERSON_UNIT
                         where award_number = au.award_number)
UNION
select DISTINCT substr(a.award_number, 1,6) as award_number
             ,a.AWARD_EFFECTIVE_DATE as AWARD_EFFECTIVE_DATE
             ,oas.DESCRIPTION as STATUS
             ,ai.FULL_NAME PERSON_NAME
             ,ai.PI_FLAG PRINCIPAL_INVESTIGATOR_FLAG
             ,pe.home_unit
             ,at.description award_type
             ,act.description purpose
             ,a.title as title
             ,s.sponsor_name
             ,s.ACRONYM as sponsor
             ,avd.start_date as start_date
             ,avd.end_date as end_date
             ,null as direct
             ,null as indeirect
             ,null as total
             ,a.sponsor_award_number as award_id
			 ,au.unit_number as lead_unit_number
             ,utc_timestamp() AS last_update_timestamp
from award_persons ai
    left outer  join(select award_id
		   , award_number
           , min(start_date) as start_date
           , max(end_date) as end_date
      from AWARD_AMT_FNA_DISTRIBUTION aafd
      Where sequence_number = (select max(sequence_number)
                               from AWARD_AMT_FNA_DISTRIBUTION
                               where award_number= aafd.award_number)
      group by award_number) avd on  avd.award_number=ai.award_number
    left outer  join AWARD a on a.award_number=ai.award_number
    left outer  join AWARD_PERSON_UNIT au on au.AWARD_PERSON_ID=ai.AWARD_PERSON_ID
    join sponsor s on  s.sponsor_code = a.sponsor_code
    join award_type at on at.award_type_code = a.award_type_code
    join activity_type act on act.activity_type_code = a.activity_type_code
    join award_status oas on oas.status_code = a.status_code
    join person pe on pe.person_id=ai.person_id
where  ai.PI_FLAG='N'
AND ai.PERSON_ROLE_ID =1
and ai.sequence_number =(select max(SEQUENCE_NUMBER)
                         from award_persons
                         where award_number = ai.award_number)
and a.status_code !=3
and a.award_number like '%-00001'
and a.SEQUENCE_NUMBER = (select max(SEQUENCE_NUMBER)
                         from award_amount_info
                         where award_number = a.award_number)
 and a.DOCUMENT_UPDATE_TIMESTAMP>=DATE_SUB(LS_LAST_SYNC_TIMESTAMP,INTERVAL 1 HOUR)
and au.lead_unit_flag='N'
and au.sequence_number=(select max(SEQUENCE_NUMBER)
                         from AWARD_PERSON_UNIT
                         where award_number = au.award_number);
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;
	OPEN CUR_PENDING_PROPOSALS_DATA_SET;
    DATA_LOOP: LOOP
                FETCH CUR_PENDING_PROPOSALS_DATA_SET INTO
				LS_AWARD_NUMBER,
				LD_AWARD_EFFECTIVE_DATE,
				LS_STATUS,
				LS_PERSON_NAME,
				LS_PRINCIPAL_INVESTIGATOR_FLAG,
				LS_HOME_UNIT,
				LS_AWARD_TYPE,
				LS_PURPOSE,
				LS_TITLE,
				LS_SPONSOR_NAME,
				LS_SPONSOR,
				LD_START_DATE,
				LD_END_DATE,
				LI_DIRECT,
				LI_INDIRECT,
				LI_TOTAL,
				LI_AWARD_ID,
				LS_LEAD_UNIT_NUMBER,
				LD_LAST_UPDATE_TIMESTAMP;
			IF DONE THEN
				LEAVE DATA_LOOP;
			END IF;
				INSERT INTO `rpt_mv_awards`
			(
				`AWARD_NUMBER`,
				` AWARD_EFFECTIVE_DATE`,
				`STATUS`,
				`FULL_NAME`,
				`PI_FLAG`,
				`HOME_UNIT`,
				`AWARD_TYPE`,
				`PURPOSE`,
				`TITLE`,
				`SPONSOR_NAME`,
				`SPONSOR`,
				`START_DATE`,
				`END_DATE`,
				`DIRECT`,
				`INDIRECT`,
				`TOTAL`,
				`AWARD_ID`,
				`LEAD_UNIT_NUMBER`,
				`LAST_UPDATE_TIMESTAMP`)
			VALUES
			(   LS_AWARD_NUMBER,
				LD_AWARD_EFFECTIVE_DATE,
				LS_STATUS,
				LS_PERSON_NAME,
				LS_PRINCIPAL_INVESTIGATOR_FLAG,
				LS_HOME_UNIT,
				LS_AWARD_TYPE,
				LS_PURPOSE,
				LS_TITLE,
				LS_SPONSOR_NAME,
				LS_SPONSOR,
				LD_START_DATE,
				LD_END_DATE,
				LI_DIRECT,
				LI_INDIRECT,
				LI_TOTAL,
				LI_AWARD_ID,
				LS_LEAD_UNIT_NUMBER,
				LD_LAST_UPDATE_TIMESTAMP);
	END LOOP DATA_LOOP;
	CLOSE CUR_PENDING_PROPOSALS_DATA_SET;
    SET SQL_SAFE_UPDATES = 1;
END;
END
$$
DELIMITER ;
