DELIMITER $$
CREATE  PROCEDURE `ROUTING_INFO_PROC_bkp`()
BEGIN
DECLARE LD_ROUTING_START_DATE DATETIME;
DECLARE LS_ROUTING_INFO_START_USER	VARCHAR(50);
DECLARE LI_PROPOSAL_ID BIGINT(12);
DECLARE LI_MIN_ROUTING_NUM BIGINT(12);
DECLARE LI_PRE_PROPOSAL_NUM BIGINT(12);
DECLARE LS_FY VARCHAR(5);
DECLARE LS_FM VARCHAR(5);
DECLARE LS_IPN VARCHAR(50);
DECLARE LS_PROPOSAL_TYPE VARCHAR(50);
DECLARE LS_CREATION_CODE VARCHAR(50);
DECLARE LD_DEADLINE_DATE DATETIME;
DECLARE LS_PI_NAME VARCHAR(500);
DECLARE LS_BA VARCHAR(8);
DECLARE LS_UNIT_NUMBER VARCHAR(50);
DECLARE LS_UNIT_NAME VARCHAR(50);
DECLARE LS_CREATION_STATUS_CODE VARCHAR(5);
DECLARE LS_TITLE VARCHAR(200);
DECLARE LS_SPONSOR_CODE VARCHAR(50);
DECLARE LS_SPONSOR_NAME VARCHAR(200);
DECLARE LS_PRIME_SPONSOR_CODE VARCHAR(5);
DECLARE LS_ACTIVITY_TYPE VARCHAR(50);
DECLARE LS_CFDA_NUMBER VARCHAR(50);
DECLARE LS_PROGRAM_ANNOUNCEMENT_NUMBER  VARCHAR(50);
DECLARE LS_CURRENT_ACCOUNT_NUMBER VARCHAR(5);
DECLARE LS_TEMPLATE_FLAG VARCHAR(1);
DECLARE LS_STATUS_CODE VARCHAR(50);
DECLARE LS_AWARD_TYPE VARCHAR(50);
DECLARE LS_S2STYPE VARCHAR(2);
DECLARE LS_S2SSTATUS VARCHAR(2);
DECLARE LS_TOTAL VARCHAR(50);
DECLARE LS_NEXT_APPROVER VARCHAR(500);
DECLARE LD_ROUTING_INFO_END_DATE DATETIME;
DECLARE LS_ROUTING_END_USER_ID VARCHAR(50);
DECLARE LI_ROUTING_ROUTING_NUMBER BIGINT(12);
DECLARE LS_ROUTING_END_USER VARCHAR(200);
DECLARE LD_ROUTING_END_DATE DATETIME;
DECLARE LI_ROUTING_ATTEMPTS INT(12);
DECLARE LS_ROUTING_ORA_RECEIPT_DATE_ORIG VARCHAR(100);
DECLARE LS_ROUTING_ORA_RECEIPT_DATE_FINAL VARCHAR(100);
DECLARE LI_MAX_ROUTING_NUM BIGINT(12);
DECLARE LS_CNT,LS_CNT2,LS_CNT3,ls_test INT(5);
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE proposal_rec cursor for
        (SELECT DISTINCT P.PROPOSAL_ID "PROPOSAL_NUMBER",
				DATE_FORMAT((D.DATE_APPROVED_BY_OSP + INTERVAL 6 MONTH), '%Y') FY,
				(CASE WHEN DATE_FORMAT(D.DATE_APPROVED_BY_OSP, '%m')= '01' THEN '07'
					  WHEN DATE_FORMAT(D.DATE_APPROVED_BY_OSP, '%m')= '02' THEN '08'
					  WHEN DATE_FORMAT(D.DATE_APPROVED_BY_OSP, '%m')= '03' THEN '09'
					  WHEN DATE_FORMAT(D.DATE_APPROVED_BY_OSP, '%m')= '04' THEN '10'
					  WHEN DATE_FORMAT(D.DATE_APPROVED_BY_OSP, '%m')= '05' THEN '11'
					  WHEN DATE_FORMAT(D.DATE_APPROVED_BY_OSP, '%m')= '06' THEN '12'
					  WHEN DATE_FORMAT(D.DATE_APPROVED_BY_OSP, '%m')= '07' THEN '01'
					  WHEN DATE_FORMAT(D.DATE_APPROVED_BY_OSP, '%m')= '08' THEN '02'
					  WHEN DATE_FORMAT(D.DATE_APPROVED_BY_OSP, '%m')= '09' THEN '03'
					  WHEN DATE_FORMAT(D.DATE_APPROVED_BY_OSP, '%m')= '10' THEN '04'
					  WHEN DATE_FORMAT(D.DATE_APPROVED_BY_OSP, '%m')= '11' THEN '05'
					  WHEN DATE_FORMAT(D.DATE_APPROVED_BY_OSP, '%m')= '12' THEN '06' END) FM,
				(SELECT PROPOSAL_NUMBER FROM PROPOSAL WHERE PROPOSAL_ID= D.INST_PROPOSAL_ID) IPN,
				PT.DESCRIPTION AS PROPOSAL_TYPE,
				P.STATUS_CODE AS CREATION_CODE,
				str_to_date(date_format(P.SPONSOR_DEADLINE_DATE,'%m/%d/%Y'),'%m/%d/%Y') "DEADLINE_DATE",
				SUBSTR(i.FULL_NAME,1,40) AS pi_name,
				SUBSTR(U.UNIT_NUMBER,1,3) "BA",
				U.UNIT_NUMBER "UNIT_NUMBER",
				U.UNIT_NAME "UNIT_NAME",
				(CASE WHEN P.STATUS_CODE= 1 THEN 'In Progress'
					  WHEN P.STATUS_CODE= 2 THEN 'Approval In Progress'
					  WHEN P.STATUS_CODE= 3 THEN 'Rejected'
					  WHEN P.STATUS_CODE= 4 THEN 'Approved'
					  WHEN P.STATUS_CODE= 5 THEN 'Submitted'
					  WHEN P.STATUS_CODE= 6 THEN 'Post-Submission Approval'
					  WHEN P.STATUS_CODE= 7 THEN 'Post-Submission Rejection' END ) "CREATION_STATUS_CODE" ,
				REPLACE(REPLACE(REPLACE(p.title,'\n', ' '),'\t', ' '),'\r ', ' ') AS title,
				P.SPONSOR_CODE "SPONSOR_CODE",
				S.SPONSOR_NAME "SPONSOR_NAME",
				P.PRIME_SPONSOR_CODE "PRIME_SPONSOR_CODE",
				oat.description as ACTIVITY_TYPE,
				CONCAT(SUBSTR(P.CFDA_NUMBER, 1, 2) , '.' , SUBSTR(P.CFDA_NUMBER, 3, 3)) AS CFDA_NUMBER,
				P.PROGRAM_ANNOUNCEMENT_NUMBER "PROGRAM_ANNOUNCEMENT_NUMBER",
				'' CURRENT_ACCOUNT_NUMBER,
				'N' TEMPLATE_FLAG,
				P.STATUS_CODE,
				T.DESCRIPTION AS AWARD_TYPE,
				'' AS S2STYPE,
				'' AS S2SSTATUS
				,pB.TOTAL_cost AS TOTAL
				 ,na.full_name as next_approver
		FROM
				eps_proposal P
				LEFT OUTER JOIN SPONSOR S
							ON 				S.SPONSOR_CODE = P.SPONSOR_CODE
				LEFT OUTER JOIN activity_type oat
							ON 				oat.activity_type_code=P.activity_type_code
				LEFT OUTER JOIN proposal_admin_details D
							ON 				D.DEV_PROPOSAL_ID=P.PROPOSAL_ID
				LEFT OUTER JOIN PROPOSAL_TYPE PT
							ON 				PT.TYPE_CODE = P.TYPE_CODE
				LEFT OUTER JOIN eps_proposal_persons I
							ON 				I.PROPOSAL_ID = P.PROPOSAL_ID
				LEFT OUTER JOIN EPS_PROPOSAL_KEYWORDS SC ON P.PROPOSAL_ID = SC.PROPOSAL_ID
				LEFT OUTER JOIN UNIT U
							ON 				U.UNIT_NUMBER=P.HOME_UNIT_NUMBER
				LEFT OUTER JOIN award_type T
							ON 				T.AWARD_TYPE_CODE= P.AWARD_TYPE_CODE
				LEFT OUTER JOIN (select PROPOSAL_ID, TOTAL_COST from budget_header WHERE IS_FINAL_BUDGET = 'Y')pb
							ON  			pb.PROPOSAL_ID = p.PROPOSAL_ID
				JOIN (
						SELECT
							per.full_name,
							module_item_id
						FROM
							workflow r
								JOIN
							workflow_detail rd ON r.WORKFLOW_ID = rd.WORKFLOW_ID
								AND rd.approval_status = 'W'
								AND rd.PRIMARY_APPROVER_FLAG = 'Y'
								LEFT OUTER JOIN
							person per ON per.person_id = rd.APPROVER_PERSON_ID
						WHERE
							r.MODULE_CODE = 3
								AND r.WORKFLOW_SEQUENCE = (select max(WORKFLOW_SEQUENCE)
														 from workflow
														 where WORKFLOW_ID=r.WORKFLOW_ID))
                 na
                 ON na.module_item_id=p.proposal_id
        WHERE 	I.PI_FLAG = 'Y'
        AND  	P.STATUS_CODE IN (2,
								  4,
								  5,
								  6,
								  7)
		);
	 DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    TRUNCATE TABLE EXT_TABLE_ROUTING;
	SET LI_PRE_PROPOSAL_NUM=-1;
	OPEN proposal_rec;
    L1:LOOP
    SET LI_ROUTING_ATTEMPTS=NULL;
    SET LD_ROUTING_START_DATE=NULL;
    SET LS_ROUTING_INFO_START_USER=NULL;
    SET LD_ROUTING_INFO_END_DATE=NULL;
    SET LS_ROUTING_END_USER_ID=NULL;
    SET LI_ROUTING_ROUTING_NUMBER=NULL;
    SET LS_ROUTING_END_USER=NULL;
    SET LD_ROUTING_END_DATE=NULL;
    SET LS_ROUTING_ORA_RECEIPT_DATE_ORIG=NULL;
    SET LS_ROUTING_ORA_RECEIPT_DATE_FINAL=NULL;
    SET LI_MIN_ROUTING_NUM=NULL;
    SET LI_MAX_ROUTING_NUM =NULL;
    FETCH proposal_rec INTO  LI_PROPOSAL_ID,
							 LS_FY,
							 LS_FM,
							 LS_IPN,
							 LS_PROPOSAL_TYPE,
							 LS_CREATION_CODE,
							 LD_DEADLINE_DATE,
							 LS_PI_NAME,
							 LS_BA,
							 LS_UNIT_NUMBER,
							 LS_UNIT_NAME,
							 LS_CREATION_STATUS_CODE,
							 LS_TITLE,
							 LS_SPONSOR_CODE,
							 LS_SPONSOR_NAME,
							 LS_PRIME_SPONSOR_CODE,
							 LS_ACTIVITY_TYPE,
							 LS_CFDA_NUMBER,
							 LS_PROGRAM_ANNOUNCEMENT_NUMBER,
							 LS_CURRENT_ACCOUNT_NUMBER,
							 LS_TEMPLATE_FLAG,
							 LS_STATUS_CODE,
							 LS_AWARD_TYPE,
							 LS_S2STYPE,
							 LS_S2SSTATUS,
							 LS_TOTAL,
                             LS_NEXT_APPROVER;
    IF done=1 THEN
		leave l1;
    END IF;
    IF LI_PRE_PROPOSAL_NUM != LI_PROPOSAL_ID THEN
	SELECT
		MAX(WORKFLOW_SEQUENCE)
	INTO LI_ROUTING_ATTEMPTS FROM
		workflow
	WHERE
		module_item_id = LI_PROPOSAL_ID
			AND module_code = 3;
    IF done=1 THEN
		set done=0;
        iterate l1;
    END IF;
       SELECT
			r.WORKFLOW_START_DATE, p.full_name
		INTO LD_ROUTING_START_DATE , LS_ROUTING_INFO_START_USER
		FROM
			workflow r
			LEFT OUTER JOIN
			person p ON p.PERSON_ID = r.WORKFLOW_START_PERSON
		WHERE
			module_item_id = LI_PROPOSAL_ID
		AND module_code = 3
		AND WORKFLOW_SEQUENCE = (SELECT
										MIN(WORKFLOW_SEQUENCE)
								 FROM
										workflow
								WHERE
									module_item_id = LI_PROPOSAL_ID
								AND module_code = 3);
		IF done=1 THEN
		set done=0;
        iterate l1;
		END IF;
				SELECT
					r.WORKFLOW_END_DATE,
					r.WORKFLOW_END_PERSON,
					r.WORKFLOW_ID,
					p.full_name
				INTO
					LD_ROUTING_INFO_END_DATE,
					LS_ROUTING_END_USER_ID ,
					LI_ROUTING_ROUTING_NUMBER ,
					LS_ROUTING_END_USER
				FROM
					workflow r
						LEFT OUTER JOIN
					person p ON p.PERSON_ID = r.WORKFLOW_END_PERSON
				WHERE
					module_item_id = LI_PROPOSAL_ID
						AND module_code = 3
						AND WORKFLOW_SEQUENCE = LI_ROUTING_ATTEMPTS;
				IF done=1 THEN
				set done=0;
				iterate l1;
				END IF;
				IF LS_ROUTING_END_USER_ID ='eng_dean' or LS_ROUTING_END_USER_ID ='eng_dean_alt' or LS_ROUTING_END_USER_ID ='bara_dean' or LS_ROUTING_END_USER_ID ='bara_dean_2'
				   THEN
                        SELECT p.full_name, rd.approval_date
						INTO LS_ROUTING_END_USER,
							 LD_ROUTING_END_DATE
						FROM
							workflow_detail rd
							LEFT JOIN person p
										ON 		p.person_id=rd.APPROVER_PERSON_ID
						WHERE rd.approval_status in ('A', 'B')
						AND rd.APPROVER_PERSON_ID!=LS_ROUTING_END_USER_ID
						AND rd.WORKFLOW_ID=LI_ROUTING_ROUTING_NUMBER
						AND rd.MAP_ID = (	SELECT
												rm.MAP_ID
											FROM
												workflow_map rm
											WHERE rm.unit_number in ( 'RPA', 'BARA', 'JHURA')
											AND rm.MAP_ID=rd.MAP_ID)
						AND rd.approval_date =(		SELECT
															max(approval_date)
													FROM
															workflow_detail
													WHERE 	WORKFLOW_ID=LI_ROUTING_ROUTING_NUMBER
													AND 	map_number=rd.map_number
											  );
                      IF done=1 THEN
							set done=0;
							iterate l1;
					 END IF;
				END IF;
				SET LS_ROUTING_ORA_RECEIPT_DATE_ORIG  =null;
				SET LS_ROUTING_ORA_RECEIPT_DATE_FINAL =null;
				SELECT
					MIN(rd.workflow_id), MAX(rd.WORKFLOW_ID)
				INTO LI_MIN_ROUTING_NUM , LI_MAX_ROUTING_NUM
				FROM
					workflow r,
					workflow_detail rd,
					workflow_map rm
				WHERE
					rm.map_id IN (	SELECT
										map_id
									FROM
										workflow_map
									WHERE
										unit_number IN ('JHSPH' , 'SON', 'SOM', 'RPA', 'BARA', 'JHURA'))
				AND r.module_item_id = LI_PROPOSAL_ID
				AND r.WORKFLOW_ID = rd.WORKFLOW_ID
				AND rd.MAP_ID = rm.MAP_ID
				AND rd.APPROVAL_STATUS != 'T';
				IF LI_MIN_ROUTING_NUM IS NOT NULL
					THEN
						SELECT
								date_format(max(APPROVAL_DATE), '%m/%d/%Y')
						INTO LS_ROUTING_ORA_RECEIPT_DATE_ORIG
						FROM
							workflow_detail rd
							,workflow_map rm
						WHERE rm.map_id NOT IN (SELECT
													map_id
											   FROM
													workflow_map
											   WHERE
													unit_number
											   IN ('JHSPH', 'SON', 'SOM', 'RPA', 'BARA', 'JHURA'))
						AND rd.WORKFLOW_ID =LI_MIN_ROUTING_NUM
						AND rd.MAP_ID = rm.MAP_ID
						AND rd.approval_status IN ('A','B');
                        IF done=1 THEN
							set done=0;
							iterate l1;
						END IF;
						IF LS_ROUTING_ORA_RECEIPT_DATE_ORIG is NULL
						  THEN
							SELECT
								date_format(MIN(r.WORKFLOW_START_DATE), '%m/%d/%Y')
							INTO
								LS_ROUTING_ORA_RECEIPT_DATE_ORIG
							FROM
								workflow r
							WHERE
								r.WORKFLOW_ID = LI_MIN_ROUTING_NUM;
						  END IF;
				END IF;
				IF LI_MAX_ROUTING_NUM IS NOT NULL
				   THEN
						SELECT
							date_format(max(APPROVAL_DATE), '%m/%d/%Y')
						INTO
							LS_ROUTING_ORA_RECEIPT_DATE_FINAL
						FROM
							workflow_detail rd
							,workflow_map rm
						WHERE
							rm.map_id 	NOT IN (   SELECT
														map_id
												   FROM
														workflow_map
												   WHERE
														unit_number
												   IN ('JHSPH', 'SON', 'SOM', 'RPA', 'BARA', 'JHURA'))
						AND rd.WORKFLOW_ID =LI_MAX_ROUTING_NUM
						AND rd.MAP_ID = rm.MAP_ID
						AND rd.approval_status IN ('A','B');
                        IF done=1 THEN
							set done=0;
							iterate l1;
						END IF;
						IF(LS_ROUTING_ORA_RECEIPT_DATE_FINAL is NULL )
							THEN
							SELECT
								date_format(MAX(r.WORKFLOW_START_DATE), '%m/%d/%Y')
							INTO
								LS_ROUTING_ORA_RECEIPT_DATE_FINAL
							FROM
								workflow r
							WHERE
								r.workflow_id = LI_MAX_ROUTING_NUM;
							IF done=1 THEN
							set done=0;
							iterate l1;
						END IF;
					 END IF;
				END IF;
						INSERT INTO `jhufibi`.`ext_table_routing`
							(
							`PROPOSAL_NUMBER`,
							`FY`,
							`FM`,
							`IPN`,
							`TYPE`,
							`STATUS`,
							`TITLE`,
							`BA`,
							`LEAD_UNIT`,
							`LEAD_UNIT_NAME`,
							`PI_NAME`,
							`DEADLINE_DATE`,
							`SPONSOR_CODE`,
							`SPONSOR_NAME`,
							`PRIME_SPONSOR_CODE`,
							`CFDA_NUMBER`,
							`PROGRAM_ANNOUNCEMENT_NUMBER`,
							`AWARD_TYPE`,
							`S2STYPE`,
							`S2SSTATUS`,
							`START_USER`,
							`START_DATE`,
							`NEXT_APPROVER`,
							`END_USER`,
							`END_DATE`,
							`ATTEMPTS`,
							`ORA_RECEIPT_DATE_ORIG`,
							`ORA_RECEIPT_DATE_FINAL`,
							`TOTAL`,
							`ACTIVITY_TYPE`)
							VALUES
							(
							LI_PROPOSAL_ID,
							LS_FY,
							LS_FM,
							LS_IPN,
							LS_PROPOSAL_TYPE,
							LS_CREATION_STATUS_CODE,
							LS_TITLE,
							LS_BA,
							LS_UNIT_NUMBER,
							LS_UNIT_NAME,
							LS_PI_NAME,
							LD_DEADLINE_DATE,
							LS_SPONSOR_CODE,
							LS_SPONSOR_NAME,
							LS_PRIME_SPONSOR_CODE,
							LS_CFDA_NUMBER,
							LS_PROGRAM_ANNOUNCEMENT_NUMBER,
							LS_AWARD_TYPE,
							LS_S2STYPE,
							LS_S2SSTATUS,
							LS_ROUTING_INFO_START_USER,
							LD_ROUTING_START_DATE,
							LS_NEXT_APPROVER,
							LS_ROUTING_END_USER,
							LD_ROUTING_INFO_END_DATE,
							LI_ROUTING_ATTEMPTS,
							LS_ROUTING_ORA_RECEIPT_DATE_ORIG,
							LS_ROUTING_ORA_RECEIPT_DATE_FINAL,
							LS_TOTAL,
							LS_ACTIVITY_TYPE);
				set LI_MIN_ROUTING_NUM =NULL;
				set LI_PRE_PROPOSAL_NUM = LI_PROPOSAL_ID;
    END IF;
	END LOOP L1;
	CLOSE proposal_rec;
    END;
END
$$
DELIMITER ;
