DELIMITER $$
CREATE  FUNCTION `FN_CHECK_GRANT_CODE_LENGTH`(
AV_AWARD_ID    DECIMAL(22)
) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
        DECLARE ls_value VARCHAR(4000);
        DECLARE  LI_COUNT INT;
		DECLARE LI_CHECK_GRANT_CODE INT(3);
        SELECT count(AWARD_DOCUMENT_TYPE_CODE) INTO LI_COUNT
        FROM AWARD
        WHERE AWARD_ID = AV_AWARD_ID
        AND AWARD_DOCUMENT_TYPE_CODE <> 1;
        IF LI_COUNT > 0 THEN
                RETURN 'TRUE';
        END IF;
		SELECT COUNT(*) INTO LI_COUNT
		FROM AWARD
		WHERE AWARD_ID = AV_AWARD_ID
		AND ACCOUNT_TYPE_CODE IN (1,2,4,6);
		IF LI_COUNT = 0 THEN
			SET LI_CHECK_GRANT_CODE = 0;
			SELECT COUNT(*) INTO LI_COUNT
			FROM AWARD
			WHERE AWARD_ID = AV_AWARD_ID
			AND ACCOUNT_TYPE_CODE IN (3,5)
			AND substring(award_number,8) = '00001';
				IF LI_COUNT = 0 THEN
					select COUNT(*) INTO LI_COUNT
					from award t1
					where t1.award_number in (select CONCAT(substring(award_number,1,6),'-00001') from award where award_id = AV_AWARD_ID)
					and t1.SEQUENCE_NUMBER  = (select max(s1.SEQUENCE_NUMBER) from award s1 where s1.AWARD_NUMBER = t1.AWARD_NUMBER)
					AND t1.ACCOUNT_TYPE_CODE IN (1,2,4,6);
					IF LI_COUNT > 0 THEN
						SET LI_CHECK_GRANT_CODE = 1;
					END IF;
				END IF;
		ELSE
			SET LI_CHECK_GRANT_CODE = 1;
		END IF;
		IF LI_CHECK_GRANT_CODE = 0 THEN
				RETURN 'TRUE';
		END IF;
        SELECT COUNT(1) INTO LI_COUNT
        FROM CUSTOM_DATA T1
        WHERE  T1.MODULE_ITEM_CODE = 1
        AND T1.MODULE_SUB_ITEM_CODE = 0
        AND T1.MODULE_ITEM_KEY = AV_AWARD_ID
        AND T1.MODULE_SUB_ITEM_KEY =0
        AND T1.COLUMN_ID = (SELECT MAX(COLUMN_ID) FROM CUSTOM_DATA_ELEMENTS WHERE CUSTOM_ELEMENT_NAME = 'GRANT CODE')
        AND T1.COLUMN_VERSION_NUMBER = (SELECT MAX(T2.COLUMN_VERSION_NUMBER) FROM CUSTOM_DATA T2
                                                                        WHERE T2.COLUMN_ID = T1.COLUMN_ID
                                                                        AND T2.MODULE_ITEM_CODE = 1
                                                                        AND T2.MODULE_SUB_ITEM_CODE = 0
                                                                        AND T2.MODULE_ITEM_KEY = AV_AWARD_ID
                                                                        AND T2.MODULE_SUB_ITEM_KEY =0);
   SELECT T1.VALUE INTO ls_value
                        FROM CUSTOM_DATA T1
                        WHERE  T1.MODULE_ITEM_CODE = 1
                        AND T1.MODULE_SUB_ITEM_CODE = 0
                        AND T1.MODULE_ITEM_KEY = AV_AWARD_ID
                        AND T1.MODULE_SUB_ITEM_KEY =0
                        AND T1.COLUMN_ID = (SELECT MAX(COLUMN_ID) FROM CUSTOM_DATA_ELEMENTS WHERE CUSTOM_ELEMENT_NAME = 'GRANT CODE')
                        AND T1.COLUMN_VERSION_NUMBER = (SELECT MAX(T2.COLUMN_VERSION_NUMBER) FROM CUSTOM_DATA T2
                                                                                        WHERE T2.COLUMN_ID = T1.COLUMN_ID
                                                                                        AND T2.MODULE_ITEM_CODE = 1
                                                                                        AND T2.MODULE_SUB_ITEM_CODE = 0
                                                                                        AND T2.MODULE_ITEM_KEY = AV_AWARD_ID
                                                                                        AND T2.MODULE_SUB_ITEM_KEY =0);
        IF LI_COUNT > 0 OR ls_value is null THEN
                        SELECT T1.VALUE INTO ls_value
                        FROM CUSTOM_DATA T1
                        WHERE  T1.MODULE_ITEM_CODE = 1
                        AND T1.MODULE_SUB_ITEM_CODE = 0
                        AND T1.MODULE_ITEM_KEY = AV_AWARD_ID
                        AND T1.MODULE_SUB_ITEM_KEY =0
                        AND T1.COLUMN_ID = (SELECT MAX(COLUMN_ID) FROM CUSTOM_DATA_ELEMENTS WHERE CUSTOM_ELEMENT_NAME = 'GRANT CODE')
                        AND T1.COLUMN_VERSION_NUMBER = (SELECT MAX(T2.COLUMN_VERSION_NUMBER) FROM CUSTOM_DATA T2
                                                                                        WHERE T2.COLUMN_ID = T1.COLUMN_ID
                                                                                        AND T2.MODULE_ITEM_CODE = 1
                                                                                        AND T2.MODULE_SUB_ITEM_CODE = 0
                                                                                        AND T2.MODULE_ITEM_KEY = AV_AWARD_ID
                                                                                        AND T2.MODULE_SUB_ITEM_KEY =0);
                        IF (IFNULL(TRIM(ls_value),'') = '' OR LENGTH(ls_value) <> 20) THEN
                                RETURN 'FALSE';
                        END IF;
        END IF;
        RETURN 'TRUE';
END
$$
DELIMITER ;
