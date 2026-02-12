DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `PENDING_PROPOSALS_DATA_SET_SYNC_bkp`()
BEGIN
DECLARE LS_unit_number VARCHAR(8);
DECLARE LS_SPONSOR VARCHAR(10);
DECLARE LS_SPONSOR_NAME VARCHAR(200);
DECLARE LS_PI_FLAG VARCHAR(1);
DECLARE LS_INV_NAME VARCHAR(90);
DECLARE LS_HOME_UNIT_NUMBER VARCHAR(8);
DECLARE LS_AWARD_TYPE VARCHAR(200);
DECLARE LS_PURPOSE VARCHAR(200);
DECLARE LS_TITLE VARCHAR(200);
DECLARE LS_PROPOSAL_TYPE VARCHAR(200);
DECLARE LD_START_DATE DATETIME;
DECLARE LD_END_DATE DATETIME;
DECLARE LI_DIRECT_AMOUNT DECIMAL(12,2);
DECLARE LI_INDIRECT_AMOUNT DECIMAL(12,2);
DECLARE LI_TOTAL_AMOUNT DECIMAL(12,2);
DECLARE LS_PROPOSAL_NUMBER VARCHAR(20);
DECLARE PROPOSAL_NUMBERS LONGTEXT;
DECLARE LS_DYN_SQL LONGTEXT;
DECLARE LS_STATUS VARCHAR(200);
DECLARE LD_LAST_UPDATE_TIMESTAMP DATETIME;
DECLARE LS_LAST_SYNC_TIMESTAMP DATETIME;
DECLARE LS_PROPOSAL_ID BIGINT(12);
SELECT PENDING_LAST_SYNC_TIMESTAMP INTO LS_LAST_SYNC_TIMESTAMP FROM REPORT_LAST_SYNC_TIME;
SET SESSION group_concat_max_len = 1000000;
SELECT GROUP_CONCAT('\'', P.PROPOSAL_NUMBER ,'\'') INTO  PROPOSAL_NUMBERS FROM PROPOSAL P
                                                WHERE P.UPDATE_TIMESTAMP>=DATE_SUB(LS_LAST_SYNC_TIMESTAMP,INTERVAL 1 HOUR)
														  and type_code in (1,4,5,6,9);
IF PROPOSAL_NUMBERS IS NOT NULL THEN
SET LS_DYN_SQL  = CONCAT('DELETE FROM RPT_MV_PENDING_PROPOSALS T2
	WHERE T2.PROPOSAL_NUMBER IN(', PROPOSAL_NUMBERS, ')');
	SET @QUERY_STATEMENT = LS_DYN_SQL;
	PREPARE EXECUTABLE_STATEMENT FROM @QUERY_STATEMENT;
	EXECUTE EXECUTABLE_STATEMENT;
END IF;
BEGIN
DECLARE DONE INT DEFAULT FALSE;
        DECLARE CUR_PENDING_PROPOSALS_DATA_SET CURSOR FOR
	SELECT DISTINCT
    PU.UNIT_NUMBER,
    S.ACRONYM SPONSOR,
    S.SPONSOR_NAME SPONSOR_NAME,
    PI.PI_FLAG AS PRINCIPAL_INVESTIGATOR_FLAG,
    pi.FULL_NAME INV_NAME,
    Pu.UNIT_NUMBER home_unit,
    AT.DESCRIPTION AWARD_TYPE,
    ACT.DESCRIPTION PURPOSE,
    P.TITLE,
    PT.DESCRIPTION PROPOSAL_TYPE,
    P.PROPOSAL_NUMBER AS PROPOSAL_NUMBER,
    P.START_DATE START_DATE,
    P.END_DATE END_DATE,
    ibh.TOTAL_DIRECT_COST DIRECT_AMOUNT,
    ibh.TOTAL_INDIRECT_COST INDIRECT_AMOUNT,
    ibh.TOTAL_COST TOTAL_AMOUNT,
	PS.DESCRIPTION STATUS,
    utc_timestamp() AS LAST_UPDATE_TIMESTAMP,
    P.PROPOSAL_ID
FROM
    PROPOSAL P
		LEFT JOIN
	ip_budget_header ibh ON ibh.proposal_id=p.proposal_id
        LEFT OUTER JOIN
    sponsor s ON p.sponsor_code = s.sponsor_code
        LEFT OUTER JOIN
    activity_type act ON p.activity_type_code = act.activity_type_code
        LEFT OUTER JOIN
    award_type at ON p.AWARD_TYPE_CODE = at.AWARD_TYPE_CODE
        LEFT OUTER JOIN
    proposal_type pt ON P.TYPE_CODE = PT.TYPE_CODE
        LEFT JOIN
    proposal_persons pi ON p.proposal_id = pi.proposal_id
						 LEFT JOIN
    proposal_status ps ON p.STATUS_CODE = ps.STATUS_CODE
        LEFT JOIN
    prop_person_units pu ON pu.proposal_number = pi.proposal_number
						 AND   pu.sequence_number=(SELECT MAX(sequence_number)
													 FROM   prop_person_units
													 WHERE proposal_number = p.proposal_number)
     WHERE p.sequence_number=(SELECT MAX(sequence_number)
													 FROM   proposal
													 WHERE proposal_number = p.proposal_number)
     and p.proposal_ID IN (SELECT
										proposal_ID
										FROM proposal
										WHERE  STATUS_CODE =1 and type_code in (1,4,5,6,9) )
	AND pi.pi_flag='Y'
    AND pi.PROP_PERSON_ROLE_ID=3
    AND pu.LEAD_UNIT_FLAG ='Y'
    union
	SELECT DISTINCT
    PU.UNIT_NUMBER,
    S.ACRONYM SPONSOR,
    S.SPONSOR_NAME SPONSOR_NAME,
    PI.PI_FLAG AS PRINCIPAL_INVESTIGATOR_FLAG,
    pi.FULL_NAME INV_NAME,
    pr.HOME_UNIT,
    AT.DESCRIPTION AWARD_TYPE,
    ACT.DESCRIPTION PURPOSE,
    P.TITLE,
    PT.DESCRIPTION PROPOSAL_TYPE,
    P.PROPOSAL_NUMBER AS PROPOSAL_NUMBER,
    P.START_DATE START_DATE,
    P.END_DATE END_DATE,
	null DIRECT_AMOUNT,
    null INDIRECT_AMOUNT,
    null TOTAL_AMOUNT,
	PS.DESCRIPTION STATUS,
    utc_timestamp() AS LAST_UPDATE_TIMESTAMP,
    P.PROPOSAL_ID
FROM
    PROPOSAL P
		LEFT JOIN
	ip_budget_header ibh ON ibh.proposal_id=p.proposal_id
        LEFT OUTER JOIN
    sponsor s ON p.sponsor_code = s.sponsor_code
        LEFT OUTER JOIN
    activity_type act ON p.activity_type_code = act.activity_type_code
        LEFT OUTER JOIN
    award_type at ON p.AWARD_TYPE_CODE = at.AWARD_TYPE_CODE
        LEFT OUTER JOIN
    proposal_type pt ON P.TYPE_CODE = PT.TYPE_CODE
        LEFT JOIN
    proposal_persons pi ON p.proposal_id = pi.proposal_id
						 LEFT JOIN
    proposal_status ps ON p.STATUS_CODE = ps.STATUS_CODE
        LEFT JOIN
    prop_person_units pu ON pu.proposal_number = pi.proposal_number
						 AND   pu.sequence_number=(SELECT MAX(sequence_number)
													 FROM   prop_person_units
													 WHERE proposal_number = p.proposal_number)
     LEFT JOIN
    person pr ON pr.person_id = pi.person_id
    WHERE p.sequence_number=(SELECT MAX(sequence_number)
													 FROM   proposal
													 WHERE proposal_number = p.proposal_number)
     and p.proposal_ID IN (SELECT
										proposal_ID
										FROM proposal
										WHERE  STATUS_CODE =1 and type_code in (1,4,5,6,9) )
	AND pi.pi_flag='N'
    AND pi.PROP_PERSON_ROLE_ID=1
    AND pu.LEAD_UNIT_FLAG ='Y'
    ;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;
	OPEN CUR_PENDING_PROPOSALS_DATA_SET;
    DATA_LOOP: LOOP
                FETCH CUR_PENDING_PROPOSALS_DATA_SET INTO
				LS_UNIT_NUMBER,
				LS_SPONSOR,
				LS_SPONSOR_NAME,
				LS_PI_FLAG,
				LS_INV_NAME,
				LS_HOME_UNIT_NUMBER,
				LS_AWARD_TYPE,
				LS_PURPOSE,
				LS_TITLE,
				LS_PROPOSAL_TYPE,
                LS_PROPOSAL_NUMBER,
				LD_START_DATE,
				LD_END_DATE,
				LI_DIRECT_AMOUNT,
				LI_INDIRECT_AMOUNT,
				LI_TOTAL_AMOUNT,
				LS_STATUS,
				LD_LAST_UPDATE_TIMESTAMP,
                LS_PROPOSAL_ID;
		 IF DONE THEN
                    LEAVE DATA_LOOP;
                END IF;
				INSERT INTO `rpt_mv_pending_proposals`
							(
							`UNIT_NUMBER`,
							`SPONSOR`,
							`SPONSOR_NAME`,
							`PI_FLAG`,
							`INV_NAME`,
							`HOME_UNIT`,
							`AWARD_TYPE`,
							`PURPOSE`,
							`TITLE`,
							`PROPOSAL_TYPE`,
							`START_DATE`,
							`END_DATE`,
							`DIRECT_AMOUNT`,
							`INDIRECT_AMOUNT`,
							`TOTAL_AMOUNT`,
							`PROPOSAL_NUMBER`,
							`STATUS`,
							`LAST_UPDATE_TIMESTAMP`,
                            `PROPOSAL_ID`)
							 VALUES
							 (LS_UNIT_NUMBER,
				LS_SPONSOR,
				LS_SPONSOR_NAME,
				LS_PI_FLAG,
				LS_INV_NAME,
				LS_HOME_UNIT_NUMBER,
				LS_AWARD_TYPE,
				LS_PURPOSE,
				LS_TITLE,
				LS_PROPOSAL_TYPE,
				LD_START_DATE,
				LD_END_DATE,
				LI_DIRECT_AMOUNT,
				LI_INDIRECT_AMOUNT,
				LI_TOTAL_AMOUNT,
				LS_PROPOSAL_NUMBER,
				LS_STATUS,
				LD_LAST_UPDATE_TIMESTAMP,
                LS_PROPOSAL_ID);
	END LOOP DATA_LOOP;
	CLOSE CUR_PENDING_PROPOSALS_DATA_SET;
END;
UPDATE report_last_sync_time SET PENDING_LAST_SYNC_TIMESTAMP=utc_timestamp();
END
$$
DELIMITER ;
