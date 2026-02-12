DELIMITER $$
CREATE  FUNCTION `FN_CHCK_IS_BUDGET_MANDATORY`(AV_PROPOSAL_ID INT(22)) RETURNS varchar(8) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE LI_GRANT_CALL_ID INT(22);
    DECLARE LI_CUSTOMDATA_COUNT INT(22);
    DECLARE LI_BUDGET_COUNT INT(22);
    SELECT GRANT_HEADER_ID INTO LI_GRANT_CALL_ID
    FROM EPS_PROPOSAL
    WHERE PROPOSAL_ID = AV_PROPOSAL_ID;
    IF LI_GRANT_CALL_ID IS NOT NULL THEN
		SELECT COUNT(*) INTO LI_CUSTOMDATA_COUNT
                                 FROM CUSTOM_DATA T1
                                WHERE  T1.MODULE_ITEM_CODE = 15
                                AND T1.MODULE_SUB_ITEM_CODE = 0
                                AND T1.MODULE_ITEM_KEY = LI_GRANT_CALL_ID
                                AND T1.MODULE_SUB_ITEM_KEY =0
								AND T1.VALUE = 'YES'
                                AND T1.COLUMN_ID = (SELECT MAX(COLUMN_ID) FROM CUSTOM_DATA_ELEMENTS WHERE CUSTOM_ELEMENT_NAME = 'Proposal Budget Mandatory Check')
                                AND T1.COLUMN_VERSION_NUMBER = (SELECT MAX(T2.COLUMN_VERSION_NUMBER) FROM CUSTOM_DATA T2
                                                                                                WHERE T2.COLUMN_ID = T1.COLUMN_ID
                                                                                                AND T2.MODULE_ITEM_CODE = 15
                                                                                                AND T2.MODULE_SUB_ITEM_CODE = 0
                                                                                                AND T2.MODULE_ITEM_KEY = LI_GRANT_CALL_ID
                                                                                                AND T2.MODULE_SUB_ITEM_KEY =0);
       SELECT COUNT(*) INTO LI_BUDGET_COUNT
        FROM BUDGET_HEADER
        WHERE PROPOSAL_ID = AV_PROPOSAL_ID;
        IF LI_CUSTOMDATA_COUNT > 0 AND LI_BUDGET_COUNT = 0 THEN
			RETURN  'FALSE' ;
		ELSE
			RETURN 'TRUE';
		END IF;
	END IF;
	RETURN 'TRUE';
END
$$
DELIMITER ;
