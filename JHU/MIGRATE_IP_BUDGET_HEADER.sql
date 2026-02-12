DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` PROCEDURE `MIGRATE_IP_BUDGET_HEADER`(DATA_REFRESH_FLAG INT,FOR_AUDIT INT)
BEGIN
DECLARE LI_RECORD_ID INT;
DECLARE LI_BUDGET_HEADER_ID INT;
DECLARE LI_PROPOSAL_ID INT;
DECLARE LI_BUDGET_PERIOD_ID INT;
DECLARE LS_ON_OFF_CAMPUS_FLAG VARCHAR(1);
DECLARE LS_UPDATE_USER VARCHAR(8);
DECLARE LS_UPDATE_USER_NAME VARCHAR(200);
DECLARE LS_PROPOSAL_NUMBER VARCHAR(8);
DECLARE LS_UPDATE_TIMESTAMP DATETIME;
DECLARE LS_CREATE_TIMESTAMP DATETIME;
DECLARE LS_END_DATE DATETIME;
DECLARE LS_START_DATE DATETIME;
DECLARE LS_TOTAL_COST DECIMAL(12, 2);
DECLARE LS_TOTAL_DIRECT_COST DECIMAL(12, 2);
DECLARE LS_TOTAL_INDIRECT_COST DECIMAL(12, 2);
DECLARE LS_ERROR_MESSAGE VARCHAR(4000);
DECLARE LI_COUNT INT;
DECLARE LI_SOURCE_COUNT INT;
DECLARE LI_DESTINATION_COUNT INT;
DECLARE LS_MIGRATION_STATUS VARCHAR(30);
DECLARE LS_DATA_ERROR_FLAG VARCHAR(1);
DECLARE LS_VALIDATION_STATUS VARCHAR(10);
DECLARE LS_CHILD_ERROR_MESSAGE VARCHAR(500);
DECLARE LS_CHILD_ERROR VARCHAR(1);
DECLARE LS_DELETED_DATA VARCHAR(1);
DECLARE LI_BATCH_ID INT;
DECLARE LI_TOTAL_PROCESSED_DATA_COUNT INT DEFAULT 0;
DECLARE LI_TOTAL_DATA_COUNT INT DEFAULT 0;
DECLARE LI_COMPLETE_STATUS_CODE INT;
DECLARE LS_MASTER_DATA_ERROR_FLAG INT;
DECLARE LS_IDC_ON_RATE VARCHAR(100);
DECLARE LS_IDC_OFF_RATE VARCHAR(100);
DECLARE LS_IDC_BASE VARCHAR(50);
DECLARE LS_ON_OFF_RATES_STATUS VARCHAR(10);
DECLARE LI_IDC_RATE_TYPE_CODE INT;
DECLARE LI_IDC_RATE_CLASS_CODE INT;
DECLARE LI_ON_RATE_COUNT INT;
DECLARE LI_OFF_RATE_COUNT INT;
DECLARE LS_ON_PD_NUMBER VARCHAR(8);
DECLARE LS_OFF_PD_NUMBER VARCHAR(8);
BEGIN
    SET SQL_SAFE_UPDATES = 0;
    SET FOREIGN_KEY_CHECKS = 0;
END;
BEGIN
    DELETE FROM migration_trans_execution_log;
    ALTER TABLE migration_trans_execution_log AUTO_INCREMENT = 1;
    SELECT COUNT(1) INTO LI_TOTAL_DATA_COUNT FROM stage_proposal;
    SELECT IFNULL(MAX(BATCH_ID),0) + 1 INTO LI_BATCH_ID FROM migration_transtn_auditlog_header WHERE ACTION_TYPE = 'MIGRATION' AND MODULE_NAME = 'IPBUDGET';
    INSERT INTO migration_transtn_auditlog_header
        (BATCH_ID,ACTION_TYPE,MODULE_NAME,EXECUTION_TIME)
        VALUES     (LI_BATCH_ID,'MIGRATION','IPBUDGET',UTC_TIMESTAMP());
    INSERT INTO migration_trans_execution_log (EXECUTION_MESSAGE,EXECUTION_TIME) VALUES ('Started execution',UTC_TIMESTAMP());
END;
BEGIN
    SET LI_COUNT = -1;
    SET LS_MASTER_DATA_ERROR_FLAG = 'N';
    SELECT COUNT(1) INTO LI_COUNT FROM budget_status WHERE UPPER(TRIM(DESCRIPTION)) = UPPER(TRIM('Complete')) AND IS_ACTIVE = 'Y';
    IF LI_COUNT = 0 THEN
        INSERT INTO migration_transaction_errorlog
            (PARENT_ID,SOURCE_TYPE,ERROR_TYPE,ERROR_MESSAGE,UPDATE_TIMESTAMP,UPDATE_USER)
        VALUES  (-100,'IPBUDGET','MIGRATION','Invalid budget status : Complete',UTC_TIMESTAMP(),'quickstart');
        SET LS_MASTER_DATA_ERROR_FLAG = 'Y';
    ELSE
        SELECT BUDGET_STATUS_CODE INTO LI_COMPLETE_STATUS_CODE FROM budget_status WHERE UPPER(TRIM(DESCRIPTION)) = UPPER(TRIM('Complete')) AND IS_ACTIVE = 'Y';
    END IF;
END;
IF LS_MASTER_DATA_ERROR_FLAG = 'N' THEN
    BEGIN
        DECLARE LS_ERROR VARCHAR(2000);
        DECLARE DONE1 INT DEFAULT FALSE;
        DECLARE MIGRATION_IP_BUDGET_HEADER_CURSOR CURSOR FOR
        SELECT  MIGRATION_PROPOSAL_ID,
                PROPOSAL_NUMBER,
                REQUESTED_END_DATE_TOTAL,
                REQUESTED_START_DATE_TOTAL,
                TOTAL_DIRECT_COST_TOTAL,
                TOTAL_INDIRECT_COST_TOTAL,
                CREATE_TIMESTAMP,
                UPDATE_USER,
                UPDATE_TIMESTAMP,
                FIBI_IDENTIFIER
        FROM  stage_proposal WHERE VALIDATION_STATUS = 'SUCCESS' AND (FIBI_IDENTIFIER IS NOT NULL AND FIBI_IDENTIFIER <> -1)
        AND FIBI_IDENTIFIER NOT IN (SELECT DISTINCT PROPOSAL_ID FROM ip_budget_header)
        ORDER BY PROPOSAL_NUMBER;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE1 = TRUE;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
            @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
            SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
            SELECT @full_error INTO LS_ERROR;
            INSERT INTO migration_transaction_errorlog
                (PARENT_ID,SOURCE_TYPE,ERROR_TYPE,ERROR_MESSAGE,UPDATE_TIMESTAMP,UPDATE_USER)
            VALUES  (LI_RECORD_ID,'IPBUDGET','MIGRATION',CONCAT(LS_ERROR),UTC_TIMESTAMP(),'quickstart');
            SET LS_DATA_ERROR_FLAG = 'Y';
        END;
        OPEN MIGRATION_IP_BUDGET_HEADER_CURSOR;
        MIGRATION_IP_BUDGET_HEADER_CURSOR_LOOP  :   LOOP
        FETCH MIGRATION_IP_BUDGET_HEADER_CURSOR     INTO           LI_RECORD_ID,
                                                                LS_PROPOSAL_NUMBER,
                                                                LS_END_DATE,
                                                                LS_START_DATE,
                                                                LS_TOTAL_DIRECT_COST,
                                                                LS_TOTAL_INDIRECT_COST,
                                                                LS_CREATE_TIMESTAMP,
                                                                LS_UPDATE_USER,
                                                                LS_UPDATE_TIMESTAMP,
                                                                LI_PROPOSAL_ID;
        IF DONE1 THEN
            LEAVE MIGRATION_IP_BUDGET_HEADER_CURSOR_LOOP;
        END IF;
        SET LS_DATA_ERROR_FLAG = 'N';
        SET LI_BUDGET_HEADER_ID = -1;
        SET LS_UPDATE_USER_NAME = NULL;
        SET LS_TOTAL_COST = -1;
        SET LI_IDC_RATE_CLASS_CODE = -1;
        SET LI_IDC_RATE_TYPE_CODE = -1;
        SET LS_IDC_ON_RATE = NULL;
        SET LS_IDC_OFF_RATE = NULL;
        SET LS_IDC_BASE = NULL;
        SET LS_OFF_PD_NUMBER = NULL;
        SET LS_ON_PD_NUMBER = NULL;
        SET LI_TOTAL_PROCESSED_DATA_COUNT =  LI_TOTAL_PROCESSED_DATA_COUNT + 1;
        IF FOR_AUDIT = 1 THEN
            INSERT INTO migration_transtn_auditlog_details (ACTION_TYPE,MODULE_NAME,BATCH_ID,MESSAGE,EXECUTION_TIME,PARENT_NUMBER,SEQUENCE_NUMBER) VALUES ('MIGRATION','IPBUDGET',LI_BATCH_ID,'Migration start',UTC_TIMESTAMP(),LI_PROPOSAL_ID,NULL);
        END IF;
        SET LI_COUNT = -1;
        SELECT COUNT(1) INTO LI_COUNT FROM proposal WHERE PROPOSAL_ID = LI_PROPOSAL_ID;
        IF LI_COUNT = 0 THEN
            INSERT INTO migration_transaction_errorlog
                (PARENT_ID,SOURCE_TYPE,ERROR_TYPE,ERROR_MESSAGE,UPDATE_TIMESTAMP,UPDATE_USER)
            VALUES  (LI_RECORD_ID,'IPBUDGET','MIGRATION',CONCAT('Invalid proposal number : ', LI_PROPOSAL_ID),UTC_TIMESTAMP(),'quickstart');
            SET LS_DATA_ERROR_FLAG = 'Y';
        END IF;
        IF FOR_AUDIT = 1 THEN
            INSERT INTO migration_transtn_auditlog_details (ACTION_TYPE,MODULE_NAME,BATCH_ID,MESSAGE,EXECUTION_TIME,PARENT_NUMBER,SEQUENCE_NUMBER) VALUES ('MIGRATION','IPBUDGET',LI_BATCH_ID,'fetch proposal id',UTC_TIMESTAMP(),LI_PROPOSAL_ID,NULL);
        END IF;
        SET LI_COUNT = -1;
        SELECT COUNT(1) INTO LI_COUNT FROM stage_fa_rates WHERE IP_NUMBER = LS_PROPOSAL_NUMBER;
        IF LI_COUNT <> 0 THEN
            SET LI_ON_RATE_COUNT = -1;
            SELECT IFNULL(MAX(PD_NUMBER),0) INTO LS_ON_PD_NUMBER FROM stage_fa_rates WHERE IP_NUMBER = LS_PROPOSAL_NUMBER AND TRIM(UPPER(ON_OFF_RATES_FLAG)) = TRIM(UPPER('ON'));
            IF LS_ON_PD_NUMBER > 0 THEN
                SELECT MAX(IDC_RATE),IDC_BASE INTO LS_IDC_ON_RATE,LS_IDC_BASE FROM stage_fa_rates WHERE IP_NUMBER = LS_PROPOSAL_NUMBER AND TRIM(UPPER(ON_OFF_RATES_FLAG)) = TRIM(UPPER('ON')) AND PD_NUMBER = LS_ON_PD_NUMBER;
            END IF;
            IF FOR_AUDIT = 1 THEN
                INSERT INTO migration_transtn_auditlog_details (ACTION_TYPE,MODULE_NAME,BATCH_ID,MESSAGE,EXECUTION_TIME,PARENT_NUMBER,SEQUENCE_NUMBER) VALUES ('MIGRATION','IPBUDGET',LI_BATCH_ID,'After F & A ON Rates',UTC_TIMESTAMP(),LI_PROPOSAL_ID,NULL);
            END IF;
            SET LI_OFF_RATE_COUNT = -1;
            SELECT IFNULL(MAX(PD_NUMBER),0) INTO LS_OFF_PD_NUMBER FROM stage_fa_rates WHERE IP_NUMBER = LS_PROPOSAL_NUMBER AND TRIM(UPPER(ON_OFF_RATES_FLAG)) = TRIM(UPPER('OFF'));
            IF LS_OFF_PD_NUMBER > 0 THEN
                SELECT MAX(IDC_RATE),IDC_BASE INTO LS_IDC_OFF_RATE,LS_IDC_BASE FROM stage_fa_rates WHERE IP_NUMBER = LS_PROPOSAL_NUMBER AND TRIM(UPPER(ON_OFF_RATES_FLAG)) = TRIM(UPPER('OFF')) AND PD_NUMBER = LS_OFF_PD_NUMBER;
            END IF;
            IF FOR_AUDIT = 1 THEN
                INSERT INTO migration_transtn_auditlog_details (ACTION_TYPE,MODULE_NAME,BATCH_ID,MESSAGE,EXECUTION_TIME,PARENT_NUMBER,SEQUENCE_NUMBER) VALUES ('MIGRATION','IPBUDGET',LI_BATCH_ID,'After F & A OFF Rates',UTC_TIMESTAMP(),LI_PROPOSAL_ID,NULL);
            END IF;
            IF LS_IDC_BASE IS NOT NULL THEN
                SET LI_COUNT = -1;
                SELECT COUNT(1) INTO LI_COUNT FROM rate_type WHERE TRIM(UPPER(DESCRIPTION)) = TRIM(UPPER(LS_IDC_BASE)) AND IS_ACTIVE = 'Y';
                IF LI_COUNT = 1 THEN
                    SELECT RATE_CLASS_CODE,RATE_TYPE_CODE INTO LI_IDC_RATE_CLASS_CODE,LI_IDC_RATE_TYPE_CODE FROM rate_type WHERE TRIM(UPPER(DESCRIPTION)) = TRIM(UPPER(LS_IDC_BASE)) AND IS_ACTIVE = 'Y';
                ELSE
                    INSERT INTO migration_transaction_errorlog
                    (PARENT_ID,SOURCE_TYPE,ERROR_TYPE,ERROR_MESSAGE,UPDATE_TIMESTAMP,UPDATE_USER)
                    VALUES  (LI_RECORD_ID,'IPBUDGET','MIGRATION',CONCAT('Invalid rate type  : ', LS_IDC_BASE),UTC_TIMESTAMP(),'quickstart');
                    SET LS_DATA_ERROR_FLAG = 'Y';
                END IF;
            END IF;
            IF FOR_AUDIT = 1 THEN
                INSERT INTO migration_transtn_auditlog_details (ACTION_TYPE,MODULE_NAME,BATCH_ID,MESSAGE,EXECUTION_TIME,PARENT_NUMBER,SEQUENCE_NUMBER) VALUES ('MIGRATION','IPBUDGET',LI_BATCH_ID,'After Over head rate types',UTC_TIMESTAMP(),LI_PROPOSAL_ID,NULL);
            END IF;
        END IF;
        IF FOR_AUDIT = 1 THEN
            INSERT INTO migration_transtn_auditlog_details (ACTION_TYPE,MODULE_NAME,BATCH_ID,MESSAGE,EXECUTION_TIME,PARENT_NUMBER,SEQUENCE_NUMBER) VALUES ('MIGRATION','IPBUDGET',LI_BATCH_ID,'After F & A Rates',UTC_TIMESTAMP(),LI_PROPOSAL_ID,NULL);
        END IF;
        SET LS_TOTAL_COST = LS_TOTAL_DIRECT_COST + LS_TOTAL_INDIRECT_COST;
        IF LS_DATA_ERROR_FLAG = 'N' THEN
            SELECT IFNULL(MAX(BUDGET_HEADER_ID),0) + 1 INTO LI_BUDGET_HEADER_ID
            FROM ip_budget_header;
            INSERT INTO  ip_budget_header
            (
                BUDGET_HEADER_ID,
                ANTICIPATED_TOTAL,
                BUDGET_STATUS_CODE,
                BUDGET_TYPE_CODE,
                COMMENTS,
                CREATE_TIMESTAMP,
                CREATE_USER,
                CREATE_USER_NAME,
                END_DATE,
                IS_AUTO_CALC,
                MODULE_ITEM_CODE,
                MODULE_ITEM_KEY,
                MODULE_SEQUENCE_NUMBER,
                OBLIGATED_CHANGE,
                OBLIGATED_TOTAL,
                ON_OFF_CAMPUS_FLAG,
                RATE_CLASS_CODE,
                RATE_TYPE_CODE,
                START_DATE,
                TOTAL_COST,
                TOTAL_DIRECT_COST,
                TOTAL_INDIRECT_COST,
                UPDATE_TIMESTAMP,
                UPDATE_USER,
                UPDATE_USER_NAME,
                VERSION_NUMBER,
                TOTAL_SUBCONTRACT_COST,
                PROPOSAL_ID,
                COST_SHARING_AMOUNT,
                UNDERRECOVERY_AMOUNT,
                RESIDUAL_FUNDS,
                TOTAL_COST_LIMIT,
                FINAL_VERSION_FLAG,
                MODULAR_BUDGET_FLAG,
                SUBMIT_COST_SHARING_FLAG,
                UNDERRECOVERY_TYPE_CODE,
                UNDERRECOVERY_CLASS_CODE,
                IS_FINAL_BUDGET,
                IS_LATEST_VERSION,
                IS_APPROVED_BUDGET,
                BUDGET_TEMPLATE_TYPE_ID,
                ON_CAMPUS_RATES,
                OFF_CAMPUS_RATES,
                COST_SHARE_TYPE_CODE
            )
            VALUES
            (
                LI_BUDGET_HEADER_ID,
                NULL,
                LI_COMPLETE_STATUS_CODE,
                NULL,
                NULL,
                LS_CREATE_TIMESTAMP,
                LS_UPDATE_USER,
                NULL,
                LS_END_DATE,
                'N',
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                'N',
                CASE WHEN LS_IDC_BASE IS NOT NULL THEN LI_IDC_RATE_CLASS_CODE ELSE NULL END,
                CASE WHEN LS_IDC_BASE IS NOT NULL THEN LI_IDC_RATE_TYPE_CODE ELSE NULL END,
                LS_START_DATE,
                LS_TOTAL_COST,
                LS_TOTAL_DIRECT_COST,
                LS_TOTAL_INDIRECT_COST,
                LS_UPDATE_TIMESTAMP,
                LS_UPDATE_USER,
                NULL,
                1,
                NULL,
                LI_PROPOSAL_ID,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                'N',
                'N',
                NULL,
                NULL,
                'Y',
                'Y',
                'N',
                NULL,
                LS_IDC_ON_RATE,
                LS_IDC_OFF_RATE,
                NULL
            );
        END IF;
        IF LS_DATA_ERROR_FLAG = 'N' THEN
            SELECT IFNULL(MAX(BUDGET_PERIOD_ID),0) + 1 INTO LI_BUDGET_PERIOD_ID
            FROM ip_budget_period;
            INSERT INTO  ip_budget_period
            (
                BUDGET_PERIOD_ID,
                BUDGET_PERIOD,
                END_DATE,
                IS_OBLIGATED_PERIOD,
                MODULE_ITEM_CODE,
                MODULE_ITEM_KEY,
                PERIOD_LABEL,
                START_DATE,
                TOTAL_COST,
                TOTAL_DIRECT_COST,
                TOTAL_INDIRECT_COST,
                UPDATE_TIMESTAMP,
                UPDATE_USER,
                VERSION_NUMBER,
                BUDGET_HEADER_ID,
                SUBCONTRACT_COST,
                COST_SHARING_AMOUNT,
                UNDERRECOVERY_AMOUNT,
                TOTAL_COST_LIMIT,
                COMMENTS,
                TOTAL_DIRECT_COST_LIMIT
            )
            VALUES
            (
                LI_BUDGET_PERIOD_ID,
                1,
                LS_END_DATE,
                NULL,
                NULL,
                NULL,
                NULL,
                LS_START_DATE,
                LS_TOTAL_COST,
                LS_TOTAL_DIRECT_COST,
                LS_TOTAL_INDIRECT_COST,
                LS_UPDATE_TIMESTAMP,
                LS_UPDATE_USER,
                NULL,
                LI_BUDGET_HEADER_ID,
                0,
                0,
                0,
                0,
                NULL,
                0
            );
        END IF;
        IF FOR_AUDIT = 1 THEN
            INSERT INTO migration_transtn_auditlog_details (ACTION_TYPE,MODULE_NAME,BATCH_ID,MESSAGE,EXECUTION_TIME,PARENT_NUMBER,SEQUENCE_NUMBER) VALUES ('MIGRATION','IPBUDGET',LI_BATCH_ID,'After Insert',UTC_TIMESTAMP(),LI_PROPOSAL_ID,NULL);
        END IF;
        IF LI_TOTAL_PROCESSED_DATA_COUNT < LI_TOTAL_DATA_COUNT THEN
            IF LI_TOTAL_PROCESSED_DATA_COUNT = 10000 THEN
                INSERT INTO migration_trans_execution_log (EXECUTION_MESSAGE,EXECUTION_TIME) VALUES (CONCAT('Completed processing of  ',LI_TOTAL_PROCESSED_DATA_COUNT,' records'),UTC_TIMESTAMP());
                SET LI_TOTAL_PROCESSED_DATA_COUNT = 0;
            END IF;
        END IF ;
        IF FOR_AUDIT = 1 THEN
            INSERT INTO migration_transtn_auditlog_details (ACTION_TYPE,MODULE_NAME,BATCH_ID,MESSAGE,EXECUTION_TIME,PARENT_NUMBER,SEQUENCE_NUMBER) VALUES ('MIGRATION','IPBUDGET',LI_BATCH_ID,'migration end',UTC_TIMESTAMP(),LI_PROPOSAL_ID,NULL);
        END IF;
        END LOOP MIGRATION_IP_BUDGET_HEADER_CURSOR_LOOP;
        CLOSE MIGRATION_IP_BUDGET_HEADER_CURSOR;
        IF FOR_AUDIT = 1 THEN
            INSERT INTO migration_transtn_auditlog_details (ACTION_TYPE,MODULE_NAME,BATCH_ID,MESSAGE,EXECUTION_TIME,PARENT_NUMBER,SEQUENCE_NUMBER) VALUES ('MIGRATION','IPBUDGET',LI_BATCH_ID,'exit cursor',UTC_TIMESTAMP(),NULL,NULL);
        END IF;
    END;
    UPDATE ip_budget_header INNER JOIN person ON ip_budget_header.CREATE_USER=person.USER_NAME
    SET ip_budget_header.CREATE_USER_NAME = person.FULL_NAME,
        ip_budget_header.UPDATE_USER_NAME = person.FULL_NAME WHERE CREATE_USER_NAME IS NULL AND UPDATE_USER_NAME IS NULL;
END IF;
    INSERT INTO migration_trans_execution_log (EXECUTION_MESSAGE,EXECUTION_TIME) VALUES ('Completed successfully',UTC_TIMESTAMP());
    SET SQL_SAFE_UPDATES = 1;
    SET FOREIGN_KEY_CHECKS = 1;
    COMMIT;
END
$$
DELIMITER ;
