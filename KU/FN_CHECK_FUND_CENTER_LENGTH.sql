DELIMITER $$
CREATE FUNCTION `FN_CHECK_FUND_CENTER_LENGTH`(
AV_AWARD_ID    DECIMAL(22)
) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
        DECLARE ls_value VARCHAR(4000);
        DECLARE  LI_COUNT INT;
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
                RETURN 'TRUE';
        END IF;
        SELECT COUNT(1) INTO LI_COUNT
        FROM CUSTOM_DATA T1
        WHERE  T1.MODULE_ITEM_CODE = 1
        AND T1.MODULE_SUB_ITEM_CODE = 0
        AND T1.MODULE_ITEM_KEY = AV_AWARD_ID
        AND T1.MODULE_SUB_ITEM_KEY =0
        AND T1.COLUMN_ID = (SELECT MAX(COLUMN_ID) FROM CUSTOM_DATA_ELEMENTS WHERE CUSTOM_ELEMENT_NAME = 'FUND CENTER')
        AND T1.COLUMN_VERSION_NUMBER = (SELECT MAX(T2.COLUMN_VERSION_NUMBER) FROM CUSTOM_DATA T2
                                                                        WHERE T2.COLUMN_ID = T1.COLUMN_ID
                                                                        AND T2.MODULE_ITEM_CODE = 1
                                                                        AND T2.MODULE_SUB_ITEM_CODE = 0
                                                                        AND T2.MODULE_ITEM_KEY = AV_AWARD_ID
                                                                        AND T2.MODULE_SUB_ITEM_KEY =0);
        IF LI_COUNT > 0 THEN
                        SELECT T1.VALUE INTO ls_value
                        FROM CUSTOM_DATA T1
                        WHERE  T1.MODULE_ITEM_CODE = 1
                        AND T1.MODULE_SUB_ITEM_CODE = 0
                        AND T1.MODULE_ITEM_KEY = AV_AWARD_ID
                        AND T1.MODULE_SUB_ITEM_KEY =0
                        AND T1.COLUMN_ID = (SELECT MAX(COLUMN_ID) FROM CUSTOM_DATA_ELEMENTS WHERE CUSTOM_ELEMENT_NAME = 'FUND CENTER')
                        AND T1.COLUMN_VERSION_NUMBER = (SELECT MAX(T2.COLUMN_VERSION_NUMBER) FROM CUSTOM_DATA T2
                                                                                        WHERE T2.COLUMN_ID = T1.COLUMN_ID
                                                                                        AND T2.MODULE_ITEM_CODE = 1
                                                                                        AND T2.MODULE_SUB_ITEM_CODE = 0
                                                                                        AND T2.MODULE_ITEM_KEY = AV_AWARD_ID
                                                                                        AND T2.MODULE_SUB_ITEM_KEY =0);
                        IF ls_value = '' OR LENGTH(ls_value) <> 10 THEN
                                RETURN 'FALSE';
                        END IF;
        END IF;
        RETURN 'TRUE';
END
$$
DELIMITER ;
