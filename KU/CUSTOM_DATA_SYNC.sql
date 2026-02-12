DELIMITER $$
CREATE  PROCEDURE `CUSTOM_DATA_SYNC`()
BEGIN
DECLARE LS_LAST_SYNC_TIMESTAMP DATETIME;
DECLARE LB_MODULE_ITEM_KEY DECIMAL(12,2);
DECLARE LS_MODULE_ITEM_CODE VARCHAR(3);
DECLARE LS_RESEARCH_CENTER LONGTEXT;
DECLARE LS_SPONSOR_ANNOUNCEMENT_DATE VARCHAR(30);
DECLARE LS_DATE_OF_INITIATION VARCHAR(30);
DECLARE LS_PROPOSAL_MILESTONES_MANDATORY_CHECK VARCHAR(30);
DECLARE LS_PROPOSAL_BUDGET_MANDATORY_CHECK VARCHAR(30);
DECLARE LB_AWARD_ID DECIMAL(22,0);
DECLARE LS_AWARD_NUMBER VARCHAR(12);
DECLARE LS_BUDGET_CATEGORY_CODE VARCHAR(3);
DECLARE LB_ORIGINAL_APPROVED_BUDGET DECIMAL(12,2);
DECLARE LB_LATEST_APPROVED_BUDGET DECIMAL(12,2);
SET SQL_SAFE_UPDATES=0;
SELECT LAST_SYNC_TIMESTAMP INTO LS_LAST_SYNC_TIMESTAMP FROM REPORT_LAST_SYNC_TIME;
DELETE FROM CUSTOM_DATA_REPORT_RT T2
WHERE (T2.MODULE_ITEM_KEY, T2.MODULE_ITEM_CODE) IN (
        SELECT DISTINCT T1.MODULE_ITEM_KEY, T1.MODULE_ITEM_CODE FROM CUSTOM_DATA  T1
        WHERE T1.UPDATE_TIMESTAMP >= DATE_SUB(LS_LAST_SYNC_TIMESTAMP,INTERVAL 1 HOUR)
);
        BEGIN
        DECLARE DONE1 INT DEFAULT FALSE;
        DECLARE CUR_CUSTOM_DATA_REPORT CURSOR FOR
        SELECT MODULE_ITEM_KEY, MODULE_ITEM_CODE,
        MAX(case when CUSTOM_DATA_ELEMENTS_ID =  (SELECT MAX(CUSTOM_DATA_ELEMENTS_ID) FROM CUSTOM_DATA_ELEMENTS WHERE CUSTOM_ELEMENT_NAME = 'Research' and IS_LATEST_VERSION = 'Y') then ifnull(description,value) end) as RESEARCH_CENTER,
        MAX(case when CUSTOM_DATA_ELEMENTS_ID =  (SELECT MAX(CUSTOM_DATA_ELEMENTS_ID) FROM CUSTOM_DATA_ELEMENTS WHERE CUSTOM_ELEMENT_NAME = 'Sponsor announcement Date' and IS_LATEST_VERSION = 'Y') then ifnull(description,value) end) as SPONSOR_ANNOUNCEMENT_DATE,
        MAX(case when CUSTOM_DATA_ELEMENTS_ID =  (SELECT MAX(CUSTOM_DATA_ELEMENTS_ID) FROM CUSTOM_DATA_ELEMENTS WHERE CUSTOM_ELEMENT_NAME = 'Date of Initiation' and IS_LATEST_VERSION = 'Y') then ifnull(description,value) end) as DATE_OF_INITIATION,
        MAX(case when CUSTOM_DATA_ELEMENTS_ID =  (SELECT MAX(CUSTOM_DATA_ELEMENTS_ID) FROM CUSTOM_DATA_ELEMENTS WHERE CUSTOM_ELEMENT_NAME = 'Proposal Milestones Mandatory Check' and IS_LATEST_VERSION = 'Y') then ifnull(description,value) end) as PROPOSAL_MILESTONES_MANDATORY_CHECK,
        MAX(case when CUSTOM_DATA_ELEMENTS_ID =  (SELECT MAX(CUSTOM_DATA_ELEMENTS_ID) FROM CUSTOM_DATA_ELEMENTS WHERE CUSTOM_ELEMENT_NAME = 'Proposal Budget Mandatory Check' and IS_LATEST_VERSION = 'Y') then ifnull(description,value) end) as PROPOSAL_BUDGET_MANDATORY_CHECK
        FROM CUSTOM_DATA  T1
        WHERE (T1.MODULE_ITEM_KEY, T1.MODULE_ITEM_CODE) IN (
                SELECT DISTINCT T2.MODULE_ITEM_KEY, T2.MODULE_ITEM_CODE FROM CUSTOM_DATA  T2
                WHERE T2.UPDATE_TIMESTAMP >= DATE_SUB(LS_LAST_SYNC_TIMESTAMP,INTERVAL 1 HOUR)
        )
        GROUP BY MODULE_ITEM_KEY, MODULE_ITEM_CODE;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE1 = TRUE;
        OPEN CUR_CUSTOM_DATA_REPORT;
    INSERT_LOOP1: LOOP
                FETCH CUR_CUSTOM_DATA_REPORT INTO
                        LB_MODULE_ITEM_KEY,
                        LS_MODULE_ITEM_CODE,
                        LS_RESEARCH_CENTER,
                        LS_SPONSOR_ANNOUNCEMENT_DATE,
                        LS_DATE_OF_INITIATION,
                        LS_PROPOSAL_MILESTONES_MANDATORY_CHECK,
                        LS_PROPOSAL_BUDGET_MANDATORY_CHECK ;
        IF DONE1  THEN
                LEAVE INSERT_LOOP1;
        END IF;
        INSERT INTO CUSTOM_DATA_REPORT_RT(
        MODULE_ITEM_KEY,
        MODULE_ITEM_CODE,
        RESEARCH_CENTER,
        SPONSOR_ANNOUNCEMENT_DATE,
        DATE_OF_INITIATION,
        PROPOSAL_MILESTONES_MANDATORY_CHECK,
        PROPOSAL_BUDGET_MANDATORY_CHECK,
        LAST_SYNC_TIME
        )
        VALUES (
        LB_MODULE_ITEM_KEY,
        LS_MODULE_ITEM_CODE,
        LS_RESEARCH_CENTER,
        LS_SPONSOR_ANNOUNCEMENT_DATE,
        LS_DATE_OF_INITIATION,
        LS_PROPOSAL_MILESTONES_MANDATORY_CHECK,
        LS_PROPOSAL_BUDGET_MANDATORY_CHECK,
        utc_timestamp()
        );
        END LOOP;
        CLOSE CUR_CUSTOM_DATA_REPORT;
        END;
DELETE FROM AWARD_ORG_APPROVED_BUDGET_RT T1
WHERE T1.AWARD_NUMBER IN(
                                                SELECT A3.AWARD_NUMBER FROM AWARD A3
                                                WHERE T1.AWARD_NUMBER = A3.AWARD_NUMBER
                                                AND A3.AWARD_SEQUENCE_STATUS IN('PENDING','ARCHIVE','CANCELLED')
                                                AND A3.SEQUENCE_NUMBER = 1
                                                AND A3.DOCUMENT_UPDATE_TIMESTAMP>=DATE_SUB(LS_LAST_SYNC_TIMESTAMP,INTERVAL 1 HOUR)
                                                UNION
                                                SELECT A4.AWARD_NUMBER FROM AWARD A4
                                                WHERE T1.AWARD_NUMBER = A4.AWARD_NUMBER
                                                AND A4.AWARD_SEQUENCE_STATUS IN('ACTIVE')
                                                AND A4.DOCUMENT_UPDATE_TIMESTAMP>=DATE_SUB(LS_LAST_SYNC_TIMESTAMP,INTERVAL 1 HOUR)
                                        );
DELETE FROM AWARD_LATEST_APROVED_BUDGET_RT T1
WHERE T1.AWARD_NUMBER IN(
                                                SELECT A3.AWARD_NUMBER FROM AWARD A3
                                                WHERE T1.AWARD_NUMBER = A3.AWARD_NUMBER
                                                AND A3.AWARD_SEQUENCE_STATUS IN('PENDING','ARCHIVE','CANCELLED')
                                                AND A3.SEQUENCE_NUMBER = 1
                                                AND A3.DOCUMENT_UPDATE_TIMESTAMP>=DATE_SUB(LS_LAST_SYNC_TIMESTAMP,INTERVAL 1 HOUR)
                                                UNION
                                                SELECT A4.AWARD_NUMBER FROM AWARD A4
                                                WHERE T1.AWARD_NUMBER = A4.AWARD_NUMBER
                                                AND A4.AWARD_SEQUENCE_STATUS IN('ACTIVE')
                                                AND A4.DOCUMENT_UPDATE_TIMESTAMP>=DATE_SUB(LS_LAST_SYNC_TIMESTAMP,INTERVAL 1 HOUR)
                                        );
        BEGIN
                DECLARE DONE2 INT DEFAULT FALSE;
        DECLARE CUR_APPROVED_BUDGET CURSOR FOR
        SELECT
        T1.AWARD_ID,
        T1.AWARD_NUMBER,
        T2.BUDGET_CATEGORY_CODE,
        SUM(T2.LINE_ITEM_COST) ORG_APRVED_BUD_BYBUDGET_CATEGORY
                FROM AWARD_BUDGET_HEADER T1
                INNER JOIN AWARD_BUDGET_DETAIL T2 ON T1.BUDGET_HEADER_ID = T2.BUDGET_HEADER_ID
                WHERE  T1.AWARD_ID IN(SELECT T3.AWARD_ID FROM AWARD T3
                                                                        WHERE T3.AWARD_ID IN(
                                                                                                                        SELECT
                                                                                                                                A3.AWARD_ID
                                                                                                                        FROM AWARD A3
                                                                                                                        WHERE T3.AWARD_NUMBER = A3.AWARD_NUMBER
                                                                                                                        AND A3.AWARD_SEQUENCE_STATUS = 'PENDING'
                                                                                                                        AND A3.SEQUENCE_NUMBER = 1
                                                                                                                        AND A3.DOCUMENT_UPDATE_TIMESTAMP>=DATE_SUB(LS_LAST_SYNC_TIMESTAMP,INTERVAL 1 HOUR)
                                                                                                                        UNION
                                                                                                                        SELECT
                                                                                                                                A4.AWARD_ID
                                                                                                                        FROM AWARD A4
                                                                                                                        WHERE T3.AWARD_NUMBER = A4.AWARD_NUMBER
                                                                                                                        AND A4.AWARD_SEQUENCE_STATUS = 'ACTIVE'
                                                                                                                        AND A4.DOCUMENT_UPDATE_TIMESTAMP>=DATE_SUB(LS_LAST_SYNC_TIMESTAMP,INTERVAL 1 HOUR)
                                                                                                                )
                                                         )
                AND T1.VERSION_NUMBER IN (SELECT MIN(AB1.VERSION_NUMBER) FROM AWARD_BUDGET_HEADER AB1
                                                                   WHERE AB1.AWARD_ID = T1.AWARD_ID)
                GROUP BY T1.AWARD_NUMBER,T2.BUDGET_CATEGORY_CODE;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE2 = TRUE;
        OPEN CUR_APPROVED_BUDGET;
    INSERT_LOOP2: LOOP
                FETCH CUR_APPROVED_BUDGET INTO
                LB_AWARD_ID,
                LS_AWARD_NUMBER,
                LS_BUDGET_CATEGORY_CODE,
                LB_ORIGINAL_APPROVED_BUDGET;
        IF DONE2  THEN
                LEAVE INSERT_LOOP2;
        END IF;
        INSERT INTO AWARD_ORG_APPROVED_BUDGET_RT(
        AWARD_ID,
        AWARD_NUMBER,
        BUDGET_CATEGORY_CODE,
        ORIGINAL_APPROVED_BUDGET)
        VALUES (
        LB_AWARD_ID,
        LS_AWARD_NUMBER,
        LS_BUDGET_CATEGORY_CODE,
        LB_ORIGINAL_APPROVED_BUDGET
        );
        END LOOP;
        CLOSE CUR_APPROVED_BUDGET;
        END;
        BEGIN
                DECLARE DONE3 INT DEFAULT FALSE;
        DECLARE LATEST_APPROVED_BUDGET CURSOR FOR
        SELECT
        T1.AWARD_ID,
        T1.AWARD_NUMBER,
        T2.BUDGET_CATEGORY_CODE,
        SUM(T2.LINE_ITEM_COST) LATEST_APRVED_BUD_BYBUDGET_CATEGORY
                FROM AWARD_BUDGET_HEADER T1
                INNER JOIN AWARD_BUDGET_DETAIL T2 ON T1.BUDGET_HEADER_ID = T2.BUDGET_HEADER_ID
                WHERE  T1.AWARD_ID IN(SELECT T3.AWARD_ID FROM AWARD T3
                                                                        WHERE T3.AWARD_ID IN(
                                                                                                                        SELECT
                                                                                                                                A3.AWARD_ID
                                                                                                                        FROM AWARD A3
                                                                                                                        WHERE T3.AWARD_NUMBER = A3.AWARD_NUMBER
                                                                                                                        AND A3.AWARD_SEQUENCE_STATUS = 'PENDING'
                                                                                                                        AND A3.SEQUENCE_NUMBER = 1
                                                                                                                        AND A3.DOCUMENT_UPDATE_TIMESTAMP>=DATE_SUB(LS_LAST_SYNC_TIMESTAMP,INTERVAL 1 HOUR)
                                                                                                                        UNION
                                                                                                                        SELECT
                                                                                                                                A4.AWARD_ID
                                                                                                                        FROM AWARD A4
                                                                                                                        WHERE T3.AWARD_NUMBER = A4.AWARD_NUMBER
                                                                                                                        AND A4.AWARD_SEQUENCE_STATUS = 'ACTIVE'
                                                                                                                        AND A4.DOCUMENT_UPDATE_TIMESTAMP>=DATE_SUB(LS_LAST_SYNC_TIMESTAMP,INTERVAL 1 HOUR)
                                                                                                                )
                                                        )
                AND T1.VERSION_NUMBER IN (SELECT MAX(AB1.VERSION_NUMBER) FROM AWARD_BUDGET_HEADER AB1
                                                                           WHERE AB1.AWARD_ID = T1.AWARD_ID)
                GROUP BY T1.AWARD_NUMBER,T2.BUDGET_CATEGORY_CODE;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE3 = TRUE;
        OPEN LATEST_APPROVED_BUDGET;
    INSERT_LOOP3: LOOP
                FETCH LATEST_APPROVED_BUDGET INTO
                LB_AWARD_ID,
                LS_AWARD_NUMBER,
                LS_BUDGET_CATEGORY_CODE,
                LB_LATEST_APPROVED_BUDGET;
        IF DONE3  THEN
                LEAVE INSERT_LOOP3;
        END IF;
        INSERT INTO AWARD_LATEST_APROVED_BUDGET_RT(
        AWARD_ID,
        AWARD_NUMBER,
        BUDGET_CATEGORY_CODE,
        LATEST_APPROVED_BUDGET)
        VALUES (
        LB_AWARD_ID,
        LS_AWARD_NUMBER,
        LS_BUDGET_CATEGORY_CODE,
        LB_LATEST_APPROVED_BUDGET
        );
        END LOOP;
        CLOSE LATEST_APPROVED_BUDGET;
        END;
commit;
call AWARD_MASTER_DATASET_SYNC();
UPDATE REPORT_LAST_SYNC_TIME SET LAST_SYNC_TIMESTAMP = utc_timestamp();
SET SQL_SAFE_UPDATES=1;
SELECT 1 AS SUCCESS FROM DUAL;
END
$$
DELIMITER ;
