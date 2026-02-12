DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `DMP_REPORT_SYNC`()
BEGIN
DECLARE LD_SYNC_INTERVAL_START_TIME  DATETIME;
DECLARE LD_SYNC_INTERVAL_END_TIME    DATETIME;
DECLARE LS_DYN_SQL                   LONGTEXT;
DECLARE LS_DYN_SQL_SEL               LONGTEXT;
DECLARE LS_SEL_STMT                  LONGTEXT;
DECLARE AWARD_IDS                    LONGTEXT;
SELECT  DATE_SUB(LAST_SYNC_TIMESTAMP,INTERVAL 4 MINUTE) INTO LD_SYNC_INTERVAL_START_TIME FROM REPORT_LAST_SYNC_TIME;
SELECT  DATE_SUB(UTC_TIMESTAMP(), INTERVAL 3 MINUTE) INTO LD_SYNC_INTERVAL_END_TIME;
SET SQL_SAFE_UPDATES = 0;
TRUNCATE TEMP_AWARD_MASTER_DATASET;
INSERT INTO TEMP_AWARD_MASTER_DATASET (AWARD_ID) SELECT	A3.AWARD_ID FROM AWARD A3
WHERE A3.DOCUMENT_UPDATE_TIMESTAMP BETWEEN LD_SYNC_INTERVAL_START_TIME AND LD_SYNC_INTERVAL_END_TIME
AND ((A3.AWARD_SEQUENCE_STATUS = 'PENDING' AND A3.SEQUENCE_NUMBER = 1)
OR (A3.AWARD_SEQUENCE_STATUS = 'ACTIVE'));
COMMIT;
TRUNCATE TEMP_AWARD_MASTER_DATASET_DMP;
INSERT INTO TEMP_AWARD_MASTER_DATASET_DMP SELECT AWARD_ID,
AWARD_NUMBER ,
ACCOUNT_NUMBER ,
AWARD_STATUS ,
AWARD_TYPE ,
ACTIVITY_TYPE ,
BEGIN_DATE ,
FINAL_EXPIRATION_DATE ,
TITLE ,
GRANT_CALL_TITLE ,
SPONSOR_CODE ,
SPONSOR_NAME ,
PRIME_SPONSOR_NAME ,
PRIME_SPONSOR_CODE ,
SPONSOR_AWARD_NUMBER ,
LEAD_UNIT_NUMBER ,
SUB_LEAD_UNIT ,
UNIT_NAME ,
PI_PERSON_ID ,
PERSON_ROLE_ID ,
PI_NAME ,
KEY_PERSON_EMAIL ,
FUNDING_SCHEME ,
AWARD_MASTER_SET_ID FROM AWARD_MASTER_DATASET_RT WHERE AWARD_ID IN (SELECT AWARD_ID FROM TEMP_AWARD_MASTER_DATASET);
COMMIT;
SET SESSION group_concat_max_len = 4294967295;
SELECT GROUP_CONCAT(A3.AWARD_ID) INTO AWARD_IDS FROM AWARD A3
														WHERE A3.DOCUMENT_UPDATE_TIMESTAMP BETWEEN LD_SYNC_INTERVAL_START_TIME AND LD_SYNC_INTERVAL_END_TIME
														AND (
                                                        (A3.AWARD_SEQUENCE_STATUS IN('PENDING','ARCHIVE','CANCELLED') AND A3.SEQUENCE_NUMBER = 1)
                                                        OR
                                                        A3.AWARD_SEQUENCE_STATUS IN('ACTIVE'));
		IF AWARD_IDS IS NOT NULL THEN
		SET LS_DYN_SQL  = CONCAT('DELETE FROM AWARD_DMP_DATASET_RT T2
		WHERE T2.AWARD_ID IN(', AWARD_IDS, ')');
		SET @QUERY_STATEMENT = LS_DYN_SQL;
		PREPARE EXECUTABLE_STAEMENT FROM @QUERY_STATEMENT;
		EXECUTE EXECUTABLE_STAEMENT;
		END IF;
        BEGIN
        DECLARE DONE1 INT DEFAULT FALSE;
        DECLARE CUR_SEL CURSOR FOR
        SELECT
                CONCAT(
                  'MAX(CASE WHEN T1.QUESTION_NUMBER =',
                  Q1.QUESTION_NUMBER,
                  ' THEN S1.ANSWER END) AS `',
                  Q1.SORT_ORDER, '`'
                )
        FROM
          QUEST_QUESTION Q1 LEFT OUTER JOIN QUEST_HEADER QH ON Q1.QUESTIONNAIRE_ID = QH.QUESTIONNAIRE_ID
          WHERE Q1.QUESTIONNAIRE_ID = QH.QUESTIONNAIRE_ID AND QH.IS_FINAL ='Y' AND QH.QUESTIONNAIRE_NUMBER = 1204 ORDER BY Q1.SORT_ORDER;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE1 = TRUE;
        OPEN CUR_SEL;
        INSERT_LOOP1: LOOP
        FETCH CUR_SEL INTO
        LS_DYN_SQL_SEL;
        IF DONE1 THEN
                LEAVE INSERT_LOOP1;
        END IF;
                SET LS_SEL_STMT:= CONCAT(IFNULL(LS_SEL_STMT,''),',',LS_DYN_SQL_SEL);
        END LOOP;
        CLOSE CUR_SEL;
                SELECT TRIM(TRAILING ',' FROM LS_SEL_STMT) INTO LS_SEL_STMT FROM DUAL;
        END;
SET SESSION group_concat_max_len = 4294967295;
SET LS_DYN_SQL = CONCAT(' INSERT INTO AWARD_DMP_DATASET_RT(AWARD_ID, AWARD_NUMBER, ACCOUNT_NUMBER, AWARD_STATUS, AWARD_TYPE, ACTIVITY_TYPE, AWARD_BEGIN_DATE, FINAL_EXPIRATION_DATE, AWARD_TITLE, GRANT_CALL_TITLE, SPONSOR_CODE, SPONSOR_NAME, PRIME_SPONSOR_CODE, PRIME_SPONSOR_NAME, SPONSOR_AWARD_NUMBER, LEAD_UNIT_NUMBER, UNIT_NAME, SUB_LEAD_UNIT, PI_PERSON_ID, PI_NAME,KEY_PERSON_EMAIL,FUNDING_SCHEME,VERSION_NUMBER,QUESTIONNAIRE_ID,SUBMISSION_DATE,FEED_STATUS,LAST_SYNC_TIME,QUESTION_1_A,QUESTION_1_B,QUESTION_2_A,
QUESTION_2_B,QUESTION_3_A,QUESTION_3_A9,QUESTION_3_A8,
QUESTION_3_A7,QUESTION_3_A6,QUESTION_3_A5,QUESTION_3_A4,QUESTION_3_A3,QUESTION_3_A2,
QUESTION_3_A1,QUESTION_3_B,QUESTION_3_C,QUESTION_4_A,QUESTION_4_B1,QUESTION_4_B2,
QUESTION_4_C,QUESTION_4_D1,QUESTION_4_D2,QUESTION_5_A,QUESTION_5_B,QUESTION_5_B1,
QUESTION_5_C,QUESTION_5_D,QUESTION_5_E,QUESTION_5_F,QUESTION_5_F1,
QUESTION_6_A,QUESTION_6_A3,QUESTION_6_A2,QUESTION_6_A1B,QUESTION_6_A1A,QUESTION_6_A1,
QUESTION_6_A2B,QUESTION_6_A2A,QUESTION_7_A,QUESTION_7_A1,QUESTION_7_B,QUESTION_7_B2,
QUESTION_7_B1,QUESTION_8_A,QUESTION_8_B,QUESTION_8_C,QUESTION_9A,QUESTION_9_A1,
QUESTION_9_A2,QUESTION_9_A3,QUESTION_9_A4,QUESTION_9_A5)
                                   SELECT       A1.AWARD_ID,
                                                        A1.AWARD_NUMBER,
                                                        A1.ACCOUNT_NUMBER,
                                                        A1.AWARD_STATUS,
                                                        A1.AWARD_TYPE,
                                                        A1.ACTIVITY_TYPE,
                                                        A1.BEGIN_DATE,
                                                        A1.FINAL_EXPIRATION_DATE,
                                                        A1.TITLE,
                                                        A1.GRANT_CALL_TITLE,
                                                        A1.SPONSOR_CODE,
                                                        A1.SPONSOR_NAME,
                                                        A1.PRIME_SPONSOR_CODE,
                                                        A1.PRIME_SPONSOR_NAME,
                                                        A1.SPONSOR_AWARD_NUMBER,
                                                        A1.LEAD_UNIT_NUMBER,
                                                        A1.UNIT_NAME,
                                                        A1.SUB_LEAD_UNIT,
                                                        A1.PI_PERSON_ID,
                                                        A1.PI_NAME,
                                                        A1.KEY_PERSON_EMAIL,
                                                        A1.FUNDING_SCHEME,
                                                        FN_COUNT_OF_DMP_UPDATE(A1.AWARD_NUMBER),
                                                        T1.QUESTIONNAIRE_ID,S1.SUBMISSION_DATE,T5.FEED_STATUS,UTC_TIMESTAMP() ', LS_SEL_STMT, '
                   FROM QUEST_QUESTION T1
                                   LEFT OUTER JOIN(
                                                                   SELECT
                                                                                T3.QUESTION_ID,
                                                                                T2.MODULE_ITEM_KEY,
                                                                                CASE WHEN T2.QUESTIONNAIRE_COMPLETED_FLAG=''Y'' THEN T2.UPDATE_TIMESTAMP ELSE NULL END AS SUBMISSION_DATE,
                                                                                GROUP_CONCAT(DISTINCT T3.ANSWER ORDER BY T3.QUESTIONNAIRE_ANSWER_ID) AS ANSWER, T2.MODULE_SUB_ITEM_KEY
                                                                        FROM QUEST_ANSWER_HEADER T2
                                                                        INNER JOIN QUEST_QUESTION QQ ON QQ.QUESTIONNAIRE_ID = T2.QUESTIONNAIRE_ID
                                                                        LEFT OUTER JOIN QUEST_ANSWER T3 ON T2.QUESTIONNAIRE_ANS_HEADER_ID = T3.QUESTIONNAIRE_ANS_HEADER_ID
                                                                        WHERE T2.MODULE_ITEM_CODE = 1
                                                                        AND T2.MODULE_SUB_ITEM_CODE = 3
                                                                        AND T2.QUESTIONNAIRE_ID = (SELECT MAX(S.QUESTIONNAIRE_ID) FROM QUEST_ANSWER_HEADER S
							  INNER JOIN QUEST_HEADER T5 ON S.QUESTIONNAIRE_ID = T5.QUESTIONNAIRE_ID
                              WHERE S.MODULE_ITEM_KEY = T2.MODULE_ITEM_KEY AND S.MODULE_SUB_ITEM_KEY = T2.MODULE_SUB_ITEM_KEY
                              AND T5.QUESTIONNAIRE_NUMBER = 1204
			 AND S.MODULE_ITEM_CODE = 1
                              AND S.MODULE_SUB_ITEM_CODE = 3)
                                                                        AND T2.MODULE_ITEM_KEY IN(SELECT AWARD_ID FROM TEMP_AWARD_MASTER_DATASET)
                                                                        GROUP BY T3.QUESTION_ID,T3.QUESTIONNAIRE_ANS_HEADER_ID
                                                                )S1 ON T1.QUESTION_ID = S1.QUESTION_ID
                                    INNER JOIN TEMP_AWARD_MASTER_DATASET_DMP A1 ON A1.AWARD_ID = S1.MODULE_ITEM_KEY
                                                                                                                                AND A1.PERSON_ROLE_ID = 3
                                        LEFT OUTER JOIN (SELECT T1.AWARD_ID, T2.DESCRIPTION AS FEED_STATUS
                                                FROM SAP_AWARD_FEED T1
                                                INNER JOIN SAP_FEED_STATUS T2 ON T2.FEED_STATUS_CODE = T1.FEED_STATUS
                                                ) T5 ON  A1.AWARD_ID = T5.AWARD_ID
                    WHERE T1.QUESTIONNAIRE_ID = (SELECT MAX(S.QUESTIONNAIRE_ID) FROM QUEST_ANSWER_HEADER S
			 INNER JOIN QUEST_HEADER T5 ON S.QUESTIONNAIRE_ID = T5.QUESTIONNAIRE_ID
                              WHERE S.MODULE_ITEM_KEY = S1.MODULE_ITEM_KEY AND S.MODULE_SUB_ITEM_KEY = S1.MODULE_SUB_ITEM_KEY
                              AND T5.QUESTIONNAIRE_NUMBER = 1204
			AND S.MODULE_ITEM_CODE = 1
                              AND S.MODULE_SUB_ITEM_CODE = 3)
                                        AND A1.AWARD_MASTER_SET_ID IN (SELECT MAX(A2.AWARD_MASTER_SET_ID) FROM AWARD_MASTER_DATASET_RT A2
                                                           WHERE A1.AWARD_ID = A2.AWARD_ID AND A2.PERSON_ROLE_ID = 3
                                                          )
                                   GROUP BY T1.QUESTIONNAIRE_ID,S1.MODULE_ITEM_KEY '
                                   );
SET @QUERY_STATEMENT = LS_DYN_SQL;
PREPARE EXECUTABLE_STAEMENT FROM @QUERY_STATEMENT;
EXECUTE EXECUTABLE_STAEMENT;
SET SQL_SAFE_UPDATES = 0;
DELETE FROM AWARD_DMP_DATASET_RT WHERE AWARD_ID NOT IN (SELECT AWARD_ID FROM AWARD);
SET SQL_SAFE_UPDATES = 1;
 SELECT 1 AS SUCCESS FROM DUAL;
END
$$
DELIMITER ;
