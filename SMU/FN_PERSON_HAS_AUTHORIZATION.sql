DELIMITER $$
CREATE  FUNCTION `FN_PERSON_HAS_AUTHORIZATION`(
AV_MODULE_CODE                   INT(4),
AV_MODULE_ITEM_KEY       VARCHAR(20),
AV_LOGGED_IN_PERSON_ID   VARCHAR(40)
) RETURNS int
    DETERMINISTIC
BEGIN
DECLARE  LI_AUTHORIZED INT DEFAULT 1;
DECLARE  LI_UN_AUTHORIZED INT DEFAULT 0;
DECLARE  LI_COUNT       INT;
DECLARE  LS_GRANT_UNIT_NUMBER VARCHAR(20);
DECLARE LI_ACTIVE_PROJECT_ID DECIMAL(22,0);
DECLARE LI_NEGOTIATION_ID DECIMAL(22,0);
DECLARE LI_FLAG INT;
        IF AV_MODULE_CODE = 3 THEN
                        SELECT COUNT(PROPOSAL_ID) INTO  LI_COUNT
                        FROM EPS_PROPOSAL_PERSONS
                        WHERE PROPOSAL_ID = AV_MODULE_ITEM_KEY
                        AND PERSON_ID = AV_LOGGED_IN_PERSON_ID;
                        IF LI_COUNT > 0 THEN
                                RETURN LI_AUTHORIZED;
                        END IF;
                        SELECT  COUNT(PROPOSAL_ID) INTO LI_COUNT
                        FROM EPS_PROPOSAL_PERSON_ROLES
                        WHERE PROPOSAL_ID = AV_MODULE_ITEM_KEY
                        AND PERSON_ID = AV_LOGGED_IN_PERSON_ID;
                        IF LI_COUNT > 0 THEN
                                RETURN LI_AUTHORIZED;
                        END IF;
                        SELECT  COUNT(PROPOSAL_ID) INTO LI_COUNT
                        FROM PROPOSAL_REVIEW
                        WHERE PROPOSAL_ID = AV_MODULE_ITEM_KEY
                        AND REVIEWER_PERSON_ID = AV_LOGGED_IN_PERSON_ID
                        AND REVIEW_STATUS_CODE = 1;
                        IF LI_COUNT > 0 THEN
                                        RETURN LI_AUTHORIZED;
                        END IF;
                        SELECT COUNT(1) INTO LI_FLAG
                        FROM EPS_PROPOSAL
                WHERE PROPOSAL_ID = AV_MODULE_ITEM_KEY
                        AND GRANT_HEADER_ID IS NOT NULL;
                IF LI_FLAG > 0 THEN
                                SELECT COUNT(1) INTO LI_FLAG FROM GRANT_CALL_HEADER T1
                                INNER JOIN EPS_PROPOSAL T2 ON T1.GRANT_HEADER_ID = T2.GRANT_HEADER_ID
                                WHERE T2.PROPOSAL_ID = AV_MODULE_ITEM_KEY
                                AND T1.HOME_UNIT_NUMBER <> '000001';
                        END IF;
                        IF LI_FLAG = 0 THEN
                                SELECT COUNT(PROPOSAL_ID) INTO  LI_COUNT
                                FROM EPS_PROPOSAL
                                WHERE PROPOSAL_ID = AV_MODULE_ITEM_KEY
                                AND HOME_UNIT_NUMBER IN (
                                                                                SELECT UNIT_NUMBER
                                                                                FROM PERSON_ROLE_RT
                                                                                WHERE RIGHT_NAME IN ('MODIFY_PROPOSAL','VIEW_PROPOSAL','VIEW_ANY_PROPOSAL')
                                                                                AND PERSON_ID = AV_LOGGED_IN_PERSON_ID
                                                                        ) ;
                        IF LI_COUNT > 0 THEN
                                RETURN LI_AUTHORIZED;
                        END IF;
                ELSE
                        SELECT COUNT(PROPOSAL_ID) INTO LI_COUNT
                        FROM EPS_PROPOSAL
                        WHERE PROPOSAL_ID = AV_MODULE_ITEM_KEY
                        AND HOME_UNIT_NUMBER IN (
                                                                                SELECT UNIT_NUMBER
                                                                                FROM PERSON_ROLE_RT
                                                                                WHERE RIGHT_NAME IN ('MODIFY_PROPOSAL','VIEW_PROPOSAL','VIEW_ANY_PROPOSAL')
                                                                                AND PERSON_ID = AV_LOGGED_IN_PERSON_ID
                                                                                AND ROLE_ID <> 100
                                                                        ) ;
                        IF LI_COUNT > 0 THEN
                                RETURN LI_AUTHORIZED;
                        END IF;
                        SELECT COUNT(1) INTO LI_COUNT
                        FROM EPS_PROPOSAL T1
                        INNER JOIN GRANT_CALL_HEADER T2 ON T1.GRANT_HEADER_ID = T2.GRANT_HEADER_ID
                        WHERE T1.PROPOSAL_ID = AV_MODULE_ITEM_KEY
                        AND T2.HOME_UNIT_NUMBER IN (SELECT UNIT_NUMBER
                                                                                FROM PERSON_ROLE_RT
                                                                                WHERE RIGHT_NAME IN ('MODIFY_PROPOSAL','VIEW_PROPOSAL','VIEW_ANY_PROPOSAL')
                                                                                AND PERSON_ID = AV_LOGGED_IN_PERSON_ID
                                                                                AND ROLE_ID = 100
                                                                          );
                        IF LI_COUNT > 0 THEN
                                RETURN LI_AUTHORIZED;
                        END IF;
        END IF;
                        SELECT COUNT(S1.MODULE_ITEM_ID) INTO    LI_COUNT
                        FROM WORKFLOW S1
                        INNER JOIN WORKFLOW_DETAIL S2 ON S1.WORKFLOW_ID = S2.WORKFLOW_ID
                        WHERE S1.IS_WORKFLOW_ACTIVE = 'Y'
                        AND S2.APPROVER_PERSON_ID = AV_LOGGED_IN_PERSON_ID
                        AND S1.MODULE_CODE = 3
                        AND S1.MODULE_ITEM_ID = AV_MODULE_ITEM_KEY;
                        IF LI_COUNT > 0 THEN
                                RETURN LI_AUTHORIZED;
                        END IF;
                        SELECT  COUNT(MODULE_ITEM_KEY) INTO LI_COUNT
                        FROM PRE_REVIEW
                        WHERE MODULE_ITEM_KEY = AV_MODULE_ITEM_KEY
                        AND REVIEWER_PERSON_ID = AV_LOGGED_IN_PERSON_ID
            AND PRE_REVIEW_STATUS_CODE = 1
            AND  MODULE_ITEM_CODE = 3;
            IF LI_COUNT > 0 THEN
                                RETURN LI_AUTHORIZED;
                        END IF;
                ELSEIF AV_MODULE_CODE = 1 THEN
                SELECT COUNT(1) INTO LI_FLAG
                FROM AWARD
                WHERE AWARD_ID = AV_MODULE_ITEM_KEY;
                IF LI_FLAG > 0 THEN
                        SELECT AWARD_ID INTO LI_ACTIVE_PROJECT_ID
                        FROM AWARD
                        WHERE AWARD_NUMBER IN (SELECT AWARD_NUMBER FROM AWARD WHERE AWARD_ID = AV_MODULE_ITEM_KEY)
                        AND AWARD_SEQUENCE_STATUS = 'ACTIVE';
                END IF;
    SELECT COUNT(AWARD_ID) INTO LI_COUNT
                        FROM AWARD
                        WHERE CREATE_USER IN (SELECT USER_NAME FROM PERSON WHERE PERSON_ID = AV_LOGGED_IN_PERSON_ID)
                        AND AWARD_ID = AV_MODULE_ITEM_KEY;
                        IF LI_COUNT > 0 THEN
                                RETURN LI_AUTHORIZED;
                        END IF;
        SELECT COUNT(1) INTO LI_FLAG
        FROM AWARD
    WHERE AWARD_ID = AV_MODULE_ITEM_KEY
        AND GRANT_HEADER_ID IS NOT NULL;
    IF LI_FLAG > 0 THEN
                SELECT COUNT(1) INTO LI_FLAG FROM GRANT_CALL_HEADER T1
                INNER JOIN AWARD T2 ON T1.GRANT_HEADER_ID = T2.GRANT_HEADER_ID
                WHERE T2.AWARD_ID = AV_MODULE_ITEM_KEY
                AND T1.HOME_UNIT_NUMBER <> '000001';
        END IF;
        IF LI_FLAG = 0 THEN
                        SELECT COUNT(AWARD_ID) INTO     LI_COUNT
                        FROM AWARD
                        WHERE AWARD_ID = AV_MODULE_ITEM_KEY
                        AND LEAD_UNIT_NUMBER IN (
                                                                                SELECT UNIT_NUMBER
                                                                                FROM PERSON_ROLE_RT
                                                                                WHERE RIGHT_NAME IN ('MODIFY_AWARD','VIEW_AWARD')
                                                                                AND PERSON_ID = AV_LOGGED_IN_PERSON_ID
                                                                        ) ;
                        IF LI_COUNT > 0 THEN
                                RETURN LI_AUTHORIZED;
                        END IF;
        ELSE
                        SELECT COUNT(AWARD_ID) INTO     LI_COUNT
                        FROM AWARD
                        WHERE AWARD_ID = AV_MODULE_ITEM_KEY
                        AND LEAD_UNIT_NUMBER IN (
                                                                                SELECT UNIT_NUMBER
                                                                                FROM PERSON_ROLE_RT
                                                                                WHERE RIGHT_NAME IN ('MODIFY_AWARD','VIEW_AWARD')
                                                                                AND PERSON_ID = AV_LOGGED_IN_PERSON_ID
                                                                        ) ;
                                IF LI_COUNT > 0 THEN
                                RETURN LI_AUTHORIZED;
                        END IF;
                        SELECT COUNT(1) INTO LI_COUNT
                        FROM AWARD T1
                        INNER JOIN GRANT_CALL_HEADER T2 ON T1.GRANT_HEADER_ID = T2.GRANT_HEADER_ID
                        WHERE T1.AWARD_ID = AV_MODULE_ITEM_KEY
                        AND T2.HOME_UNIT_NUMBER IN (SELECT UNIT_NUMBER
                                                                                FROM PERSON_ROLE_RT
                                                                                WHERE RIGHT_NAME IN ('MODIFY_AWARD','VIEW_AWARD')
                                                                                AND PERSON_ID = AV_LOGGED_IN_PERSON_ID
                                                                                AND ROLE_ID = 100
                                                                          );
                        IF LI_COUNT > 0 THEN
                                RETURN LI_AUTHORIZED;
                        END IF;
        END IF;
        SELECT COUNT(S1.MODULE_ITEM_ID) INTO    LI_COUNT
                        FROM WORKFLOW S1
                        INNER JOIN WORKFLOW_DETAIL S2 ON S1.WORKFLOW_ID = S2.WORKFLOW_ID
                        WHERE S1.IS_WORKFLOW_ACTIVE = 'Y'
                        AND S2.APPROVER_PERSON_ID = AV_LOGGED_IN_PERSON_ID
                        AND S1.MODULE_CODE = 1
                        AND S1.MODULE_ITEM_ID = AV_MODULE_ITEM_KEY;
                        IF LI_COUNT > 0 THEN
                                RETURN LI_AUTHORIZED;
                        END IF;
            SELECT COUNT(AWARD_ID)  INTO LI_COUNT FROM AWARD_PERSON_ROLES
                        WHERE PERSON_ID = AV_LOGGED_IN_PERSON_ID
                        AND AWARD_ID = LI_ACTIVE_PROJECT_ID;
                        IF LI_COUNT > 0 THEN
                                        RETURN LI_AUTHORIZED;
                                END IF;
                        SELECT COUNT(S1.AWARD_ID) INTO LI_COUNT FROM AWARD_PERSON_ROLES S1
                        INNER JOIN AWARD S2 ON S2.AWARD_ID = S1.AWARD_ID
                        WHERE S1.PERSON_ID = AV_LOGGED_IN_PERSON_ID AND S2.AWARD_DOCUMENT_TYPE_CODE = 1
                        AND S1.AWARD_ID = AV_MODULE_ITEM_KEY
            AND S2.AWARD_SEQUENCE_STATUS='PENDING';
                        IF LI_COUNT > 0 THEN
                                        RETURN LI_AUTHORIZED;
                        END IF;
            SELECT  COUNT(MODULE_ITEM_KEY) INTO LI_COUNT
                        FROM PRE_REVIEW
                        WHERE MODULE_ITEM_KEY = AV_MODULE_ITEM_KEY
                        AND REVIEWER_PERSON_ID = AV_LOGGED_IN_PERSON_ID
            AND MODULE_ITEM_CODE = 1
            AND PRE_REVIEW_STATUS_CODE = 1;
                        IF LI_COUNT > 0 THEN
                                RETURN LI_AUTHORIZED;
                        END IF;
                        SELECT COUNT(*) INTO  LI_COUNT
                        FROM TASK
                        WHERE MODULE_ITEM_ID = AV_MODULE_ITEM_KEY
                        AND ASSIGNEE_PERSON_ID = AV_LOGGED_IN_PERSON_ID
            AND TASK_STATUS_CODE IN(1,2,3,4);
                        IF LI_COUNT > 0 THEN
                                RETURN LI_AUTHORIZED;
                        END IF;
       SELECT COUNT(AWARD_ID)  INTO LI_COUNT FROM AWARD_PERSONS
            WHERE PERSON_ID = AV_LOGGED_IN_PERSON_ID
            AND AWARD_ID = AV_MODULE_ITEM_KEY;
                  IF LI_COUNT > 0 THEN
                           RETURN LI_AUTHORIZED;
                  END IF;
          ELSEIF AV_MODULE_CODE = 2 THEN
                        SELECT COUNT(PROPOSAL_ID) INTO  LI_COUNT
                        FROM PROPOSAL_PERSONS
                        WHERE PROPOSAL_ID = AV_MODULE_ITEM_KEY
                        AND PROP_PERSON_ROLE_ID = 3
                        AND PERSON_ID = AV_LOGGED_IN_PERSON_ID;
                        IF LI_COUNT > 0 THEN
                                RETURN LI_AUTHORIZED;
                        END IF;
                        SELECT COUNT(PROPOSAL_ID) INTO  LI_COUNT
                        FROM PROPOSAL
                        WHERE PROPOSAL_ID = AV_MODULE_ITEM_KEY
                        AND HOME_UNIT_NUMBER IN (
                                                                                SELECT UNIT_NUMBER
                                                                                FROM PERSON_ROLE_RT
                                                                                WHERE RIGHT_NAME IN ('MODIFY_PROPOSAL','VIEW_PROPOSAL','VIEW_ANY_PROPOSAL','CREATE_AWARD','MODIFY_INST_PROPOSAL','VIEW_INST_PROPOSAL')
                                                                                AND PERSON_ID = AV_LOGGED_IN_PERSON_ID
                                                                        ) ;
                        IF LI_COUNT > 0 THEN
                                RETURN LI_AUTHORIZED;
                        END IF;
        ELSEIF AV_MODULE_CODE = 5 THEN
                        SELECT COUNT(NEGOTIATION_ID) INTO       LI_COUNT
                        FROM NEGOTIATION
                        WHERE NEGOTIATION_ID = AV_MODULE_ITEM_KEY
                        AND NEGOTIATOR_PERSON_ID = AV_LOGGED_IN_PERSON_ID;
                        IF LI_COUNT > 0 THEN
                                RETURN LI_AUTHORIZED;
                        END IF;
                        SELECT COUNT(UNIT_NUMBER) INTO  LI_COUNT
                        FROM PERSON_ROLE_RT
                        WHERE RIGHT_NAME IN ('MODIFY_NEGOTIATIONS','VIEW_NEGOTIATIONS')
                        AND PERSON_ID = AV_LOGGED_IN_PERSON_ID;
                        IF LI_COUNT > 0 THEN
                                RETURN LI_AUTHORIZED;
                        END IF;
                        SELECT COUNT(S1.MODULE_ITEM_ID) INTO    LI_COUNT
                        FROM WORKFLOW S1
                        INNER JOIN WORKFLOW_DETAIL S2 ON S1.WORKFLOW_ID = S2.WORKFLOW_ID
                        WHERE S1.IS_WORKFLOW_ACTIVE = 'Y'
                        AND S2.APPROVER_PERSON_ID = AV_LOGGED_IN_PERSON_ID
                        AND S1.MODULE_CODE = 5
                        AND S1.MODULE_ITEM_ID = AV_MODULE_ITEM_KEY;
                        IF LI_COUNT > 0 THEN
                                RETURN LI_AUTHORIZED;
                        END IF;
        ELSEIF AV_MODULE_CODE = 15 THEN
                        SELECT COUNT(GRANT_HEADER_ID) INTO      LI_COUNT
                        FROM GRANT_CALL_HEADER
                        WHERE GRANT_HEADER_ID = AV_MODULE_ITEM_KEY
                        AND ((GRANT_STATUS_CODE NOT IN(1, 6) AND IS_PUBLISHED='Y' ) OR (CREATE_USER = (SELECT USER_NAME FROM PERSON WHERE PERSON_ID = AV_LOGGED_IN_PERSON_ID)));
                        IF LI_COUNT > 0 THEN
                                RETURN LI_AUTHORIZED;
                        END IF;
                        SELECT COUNT(GRANT_HEADER_ID) INTO      LI_COUNT
                        FROM GRANT_CALL_HEADER
                        WHERE GRANT_HEADER_ID = AV_MODULE_ITEM_KEY
                        AND HOME_UNIT_NUMBER IN (
                                                                                SELECT UNIT_NUMBER
                                                                                FROM PERSON_ROLE_RT
                                                                                WHERE RIGHT_NAME IN ('MODIFY_GRANT_CALL','VIEW_GRANT_CALL','PUBLISH_GRANT_CALL')
                                                                                AND PERSON_ID = AV_LOGGED_IN_PERSON_ID
                                                                        ) ;
                        IF LI_COUNT > 0 THEN
                                RETURN LI_AUTHORIZED;
                        END IF;
     ELSEIF AV_MODULE_CODE = 14 THEN
                        SELECT COUNT(CLAIM_ID) INTO     LI_COUNT
                        FROM CLAIM
                        WHERE CLAIM_ID = AV_MODULE_ITEM_KEY
                        AND CREATE_USER = (SELECT USER_NAME FROM PERSON WHERE PERSON_ID = AV_LOGGED_IN_PERSON_ID);
                        IF LI_COUNT > 0 THEN
                                RETURN LI_AUTHORIZED;
                        END IF;
                        SELECT COUNT(S1.MODULE_ITEM_ID) INTO LI_COUNT
                        FROM WORKFLOW S1
                        INNER JOIN WORKFLOW_DETAIL S2 ON S1.WORKFLOW_ID = S2.WORKFLOW_ID
                        WHERE S1.IS_WORKFLOW_ACTIVE = 'Y'
                        AND S2.APPROVER_PERSON_ID = AV_LOGGED_IN_PERSON_ID
                        AND S1.MODULE_CODE = 14
                        AND S1.MODULE_ITEM_ID = AV_MODULE_ITEM_KEY;
                        IF LI_COUNT > 0 THEN
                                RETURN LI_AUTHORIZED;
                        END IF;
            SELECT COUNT(T1.UNIT_NUMBER)  INTO  LI_COUNT
                        FROM PERSON_ROLE_RT T1
                        WHERE T1.RIGHT_NAME IN ('MODIFY_CLAIMS','VIEW_CLAIMS','CLAIM_PREPARER')
                        AND T1.PERSON_ID = AV_LOGGED_IN_PERSON_ID
            AND T1.UNIT_NUMBER IN (SELECT T2.LEAD_UNIT_NUMBER
            FROM AWARD T2 WHERE T2.AWARD_ID IN (SELECT T3.AWARD_ID
                        FROM CLAIM T3
                        WHERE T3.CLAIM_ID = AV_MODULE_ITEM_KEY));
                        IF LI_COUNT > 0 THEN
                                RETURN LI_AUTHORIZED;
                        END IF;
                        SELECT COUNT(AWARD_ID)  INTO LI_COUNT FROM AWARD_PERSON_ROLES T1
            INNER JOIN ROLE_RIGHTS T3 ON T1.ROLE_ID = T3.ROLE_ID
            INNER JOIN RIGHTS T4 ON T3.RIGHT_ID = T4.RIGHT_ID
                        WHERE PERSON_ID = AV_LOGGED_IN_PERSON_ID
                        AND AWARD_ID IN (SELECT T3.AWARD_ID
                        FROM CLAIM T3
                        WHERE T3.CLAIM_ID = AV_MODULE_ITEM_KEY)
            AND T4.RIGHT_NAME IN ('VIEW_CLAIMS');
                        IF LI_COUNT > 0 THEN
                                RETURN LI_AUTHORIZED;
                        END IF;
ELSEIF AV_MODULE_CODE = 16 THEN
                        SELECT COUNT(PROGRESS_REPORT_ID) INTO   LI_COUNT
                        FROM AWARD_PROGRESS_REPORT
                        WHERE PROGRESS_REPORT_ID = AV_MODULE_ITEM_KEY
                        AND CREATE_USER = (SELECT USER_NAME FROM PERSON WHERE PERSON_ID = AV_LOGGED_IN_PERSON_ID);
                        IF LI_COUNT > 0 THEN
                                RETURN LI_AUTHORIZED;
                        END IF;
                        SELECT COUNT(S1.MODULE_ITEM_ID) INTO LI_COUNT
                        FROM WORKFLOW S1
                        INNER JOIN WORKFLOW_DETAIL S2 ON S1.WORKFLOW_ID = S2.WORKFLOW_ID
                        WHERE S1.IS_WORKFLOW_ACTIVE = 'Y'
                        AND S2.APPROVER_PERSON_ID = AV_LOGGED_IN_PERSON_ID
                        AND S1.MODULE_CODE = 16
                        AND S1.MODULE_ITEM_ID = AV_MODULE_ITEM_KEY;
                        IF LI_COUNT > 0 THEN
                                RETURN LI_AUTHORIZED;
                        END IF;
            SELECT COUNT(T1.UNIT_NUMBER)  INTO  LI_COUNT
                        FROM PERSON_ROLE_RT T1
                        WHERE T1.RIGHT_NAME IN ('VIEW_PROGRESS_REPORT','MODIFY_PROGRESS_REPORT','CREATE_PROGRESS_REPORT')
                        AND T1.PERSON_ID = AV_LOGGED_IN_PERSON_ID
            AND T1.UNIT_NUMBER IN (SELECT T2.LEAD_UNIT_NUMBER
            FROM AWARD T2 WHERE T2.AWARD_ID IN (SELECT T3.AWARD_ID
                        FROM AWARD_PROGRESS_REPORT T3
                        WHERE T3.PROGRESS_REPORT_ID = AV_MODULE_ITEM_KEY));
                        IF LI_COUNT > 0 THEN
                                RETURN LI_AUTHORIZED;
                        END IF;
                        SELECT COUNT(AWARD_ID)  INTO LI_COUNT FROM AWARD_PERSON_ROLES T1
            INNER JOIN ROLE_RIGHTS T3 ON T1.ROLE_ID = T3.ROLE_ID
            INNER JOIN RIGHTS T4 ON T3.RIGHT_ID = T4.RIGHT_ID
                        WHERE PERSON_ID = AV_LOGGED_IN_PERSON_ID
                        AND AWARD_ID IN (SELECT T3.AWARD_ID
                        FROM AWARD_PROGRESS_REPORT T3
                        WHERE T3.PROGRESS_REPORT_ID = AV_MODULE_ITEM_KEY)
            AND T4.RIGHT_NAME IN ('VIEW_PROGRESS_REPORT','MODIFY_PROGRESS_REPORT','CREATE_PROGRESS_REPORT');
                        IF LI_COUNT > 0 THEN
                                RETURN LI_AUTHORIZED;
                        END IF;
ELSEIF AV_MODULE_CODE = 13  THEN
		SELECT COUNT(1) INTO	LI_COUNT
		FROM AGREEMENT_HEADER
		WHERE AGREEMENT_REQUEST_ID = AV_MODULE_ITEM_KEY
		AND UNIT_NUMBER IN ( SELECT UNIT_NUMBER
							 FROM PERSON_ROLE_RT
							 WHERE RIGHT_NAME IN ('VIEW_ALL_AGREEMENT','MODIFY_ALL_AGREEMENT', 'SUBMIT_AGREEMENT', 'AGREEMENT_ADMINISTRATOR', 'VIEW_ADMIN_GROUP_AGREEMENT')
							 AND PERSON_ID = AV_LOGGED_IN_PERSON_ID
						   );
		IF LI_COUNT > 0 THEN
			RETURN LI_AUTHORIZED;
		END IF;
    SELECT COUNT(1) INTO	LI_COUNT
		FROM AGREEMENT_HEADER T1
    LEFT JOIN AGREEMENT_ADMIN_GROUPS T2 ON T1.ADMIN_GROUP_ID = T2.ADMIN_GROUP_ID
		WHERE T1.AGREEMENT_REQUEST_ID = AV_MODULE_ITEM_KEY
    AND T2.ROLE_ID IN (SELECT T3.ROLE_ID FROM ROLE_RIGHTS T3
                                          LEFT JOIN RIGHTS T4 ON T3.RIGHT_ID = T4.RIGHT_ID
                                          LEFT JOIN PERSON_ROLES T5 ON T3.ROLE_ID = T5.ROLE_ID
                                          WHERE T5.PERSON_ID = AV_LOGGED_IN_PERSON_ID AND T4.RIGHT_NAME = 'VIEW_ADMIN_GROUP_AGREEMENT');
		IF LI_COUNT > 0 THEN
			RETURN LI_AUTHORIZED;
		END IF;
    SELECT COUNT(1) INTO	LI_COUNT
		FROM AGREEMENT_HEADER
		WHERE AGREEMENT_REQUEST_ID = AV_MODULE_ITEM_KEY
    AND ADMIN_PERSON_ID = AV_LOGGED_IN_PERSON_ID;
		IF LI_COUNT > 0 THEN
			RETURN LI_AUTHORIZED;
		END IF;
    SELECT COUNT(1) INTO	LI_COUNT
    FROM AGREEMENT_PEOPLE
    WHERE AGREEMENT_REQUEST_ID = AV_MODULE_ITEM_KEY
    AND (PERSON_ID = AV_LOGGED_IN_PERSON_ID OR ROLODEX_ID = AV_LOGGED_IN_PERSON_ID);
    IF LI_COUNT > 0 THEN
      RETURN LI_AUTHORIZED;
    END IF;
	SELECT COUNT(1) INTO LI_COUNT
	FROM AGREEMENT_HEADER
	WHERE AGREEMENT_REQUEST_ID = AV_MODULE_ITEM_KEY
	AND (REQUESTOR_PERSON_ID = AV_LOGGED_IN_PERSON_ID
		);
	IF LI_COUNT > 0 THEN
		RETURN LI_AUTHORIZED;
	END IF;
	SELECT NEGOTIATION_ID INTO LI_NEGOTIATION_ID FROM NEGOTIATION_ASSOCIATION
	WHERE ASSOCIATED_PROJECT_ID  = AV_MODULE_ITEM_KEY
	AND ASSOCIATION_TYPE_CODE = 4;
	SELECT COUNT(1) INTO LI_COUNT
	FROM NEGOTIATION_LOCATION
	WHERE NEGOTIATION_ID = LI_NEGOTIATION_ID
	AND ASSIGNEE_PERSON_ID = AV_LOGGED_IN_PERSON_ID;
	IF LI_COUNT > 0 THEN
		RETURN LI_AUTHORIZED;
	END IF;
END IF;
RETURN LI_UN_AUTHORIZED;
END
$$
DELIMITER ;
