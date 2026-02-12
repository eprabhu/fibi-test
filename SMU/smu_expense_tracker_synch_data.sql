DELIMITER $$
CREATE  PROCEDURE `smu_expense_tracker_synch_data`()
BEGIN
declare ls_update_timestamp datetime;
DECLARE ls_award_number 	       VARCHAR(20);
DECLARE ls_account_number 	       VARCHAR(20);
DECLARE ls_internal_order_code     VARCHAR(100);
DECLARE ls_amount_in_fma_currency  VARCHAR(100);
DECLARE ls_committed_number        INT(3);
DECLARE ls_award_expense_detls_ext_id INT(12);
DECLARE ls_amount VARCHAR(100);
DECLARE LI_FLAG INT;
	BEGIN
			DECLARE DONE8 INT DEFAULT FALSE;
			DECLARE EXP_HEADER_CURSOR CURSOR FOR
			SELECT
				DISTINCT
				AWARD_NUMBER,
				ACCOUNT_NUMBER
			FROM AWARD_EXPENSE_TRANSACTIONS
            where
            AWARD_NUMBER is not null;
			DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE8 = TRUE;
            set sql_safe_updates = 0;
			OPEN EXP_HEADER_CURSOR;
			INSERT_LOOP1: LOOP
				FETCH EXP_HEADER_CURSOR INTO
				ls_award_number,
				ls_account_number;
				IF DONE8 THEN
					LEAVE INSERT_LOOP1;
				END IF;
				SELECT COUNT(1) INTO LI_FLAG
				FROM AWARD_EXPENSE_HEADER
				WHERE AWARD_NUMBER = ls_award_number
				AND ACCOUNT_NUMBER = ls_account_number;
				IF LI_FLAG = 0 THEN
					INSERT INTO AWARD_EXPENSE_HEADER
					(
						AWARD_NUMBER,
						ACCOUNT_NUMBER,
						CREATE_TIMESTAMP,
						CREATE_USER,
						UPDATE_TIMESTAMP,
						UPDATE_USER,
						LAST_SYNCH_TIMESTAMP
					)
					VALUES
					(
						ls_award_number,
						ls_account_number,
						utc_timestamp(),
						'quickstart',
						utc_timestamp(),
						'quickstart',
						utc_timestamp()
					);
				else
                        select update_timestamp into ls_update_timestamp
                        from award_expense_transactions t1
                        where t1.award_number = ls_award_number
                        and t1.account_number = ls_account_number
                        and t1.AWARD_EXPENSE_TRANS_ID in(select max(t2.AWARD_EXPENSE_TRANS_ID)
													 from award_expense_transactions t2
                                                     where t1.award_number = t2.award_number
                                                     and  t1.account_number = t2.account_number
                                                     );
                      update AWARD_EXPENSE_HEADER t1 set LAST_SYNCH_TIMESTAMP=ls_update_timestamp
                        where t1.award_number = ls_award_number
                        and t1.account_number = ls_account_number;
				END IF;
		END LOOP;
		CLOSE EXP_HEADER_CURSOR;
		END;
		BEGIN
			DECLARE DONE9 INT DEFAULT FALSE;
			DECLARE EXP_DET_CURSOR CURSOR FOR
			SELECT
			AWARD_NUMBER,
			ACCOUNT_NUMBER,
			INTERNAL_ORDER_CODE,
			SUM(AMOUNT_IN_FMA_CURRENCY)
		FROM AWARD_EXPENSE_TRANSACTIONS
		WHERE ACTUAL_OR_COMMITTED_FLAG= 'A'
        and  AWARD_NUMBER is not null
		GROUP BY AWARD_NUMBER,ACCOUNT_NUMBER,INTERNAL_ORDER_CODE;
			DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE9 = TRUE;
			OPEN EXP_DET_CURSOR;
			INSERT_LOOP2: LOOP
				FETCH EXP_DET_CURSOR INTO
				ls_award_number,
				ls_account_number,
				ls_internal_order_code,
				ls_amount;
				IF DONE9 THEN
					LEAVE INSERT_LOOP2;
				END IF;
				SELECT COUNT(1) INTO LI_FLAG
				FROM AWARD_EXPENSE_DETAILS
				WHERE AWARD_NUMBER = ls_award_number
				AND ACCOUNT_NUMBER = ls_account_number
				AND INTERNAL_ORDER_CODE = ls_internal_order_code;
				IF LI_FLAG = 0 THEN
					INSERT INTO AWARD_EXPENSE_DETAILS
					(
						AWARD_NUMBER,
						ACCOUNT_NUMBER,
						INTERNAL_ORDER_CODE,
						TOTAL_EXPENSE_AMOUNT,
						UPDATE_TIMESTAMP,
						UPDATE_USER
					)
					VALUES
					(
						ls_award_number,
						ls_account_number,
						ls_internal_order_code,
						ls_amount,
						utc_timestamp(),
						'quickstart'
					);
				ELSE
					UPDATE AWARD_EXPENSE_DETAILS SET TOTAL_EXPENSE_AMOUNT = ls_amount
					WHERE AWARD_NUMBER = ls_award_number
					AND ACCOUNT_NUMBER = ls_account_number
					AND INTERNAL_ORDER_CODE = ls_internal_order_code;
				END IF;
		END LOOP;
		CLOSE EXP_DET_CURSOR;
		END;
BEGIN
	DECLARE DONE1 INT DEFAULT FALSE;
	DECLARE EXP_CURSOR CURSOR FOR
	SELECT AWARD_NUMBER,ACCOUNT_NUMBER,INTERNAL_ORDER_CODE,SUM(AMOUNT_IN_FMA_CURRENCY)
	FROM AWARD_EXPENSE_TRANSACTIONS
	WHERE ACTUAL_OR_COMMITTED_FLAG= 'C'
    and AWARD_NUMBER is not null
	GROUP BY AWARD_NUMBER,ACCOUNT_NUMBER,INTERNAL_ORDER_CODE;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE1 = TRUE;
	OPEN EXP_CURSOR;
	EXP_CURSOR_LOOP : LOOP
			FETCH EXP_CURSOR INTO  ls_award_number,ls_account_number,ls_internal_order_code,ls_amount_in_fma_currency;
			IF DONE1 THEN
				LEAVE EXP_CURSOR_LOOP;
			END IF;
		 SELECT (CASE WHEN MAX(AWARD_EXPENSE_DETAILS_EXT_ID) IS NULL THEN 1
							ELSE MAX(AWARD_EXPENSE_DETAILS_EXT_ID)+1 END)  INTO ls_award_expense_detls_ext_id
		 FROM AWARD_EXPENSE_DETAILS_EXT;
		 SELECT COUNT(1) INTO LI_FLAG
		 FROM AWARD_EXPENSE_DETAILS_EXT
		 WHERE AWARD_NUMBER = ls_award_number
		 AND ACCOUNT_NUMBER = ls_account_number
		 AND INTERNAL_ORDER_CODE = ls_internal_order_code
		 AND IS_FROM_SAP = 'Y';
		 IF LI_FLAG = 0 THEN
		INSERT INTO AWARD_EXPENSE_DETAILS_EXT
		(   AWARD_EXPENSE_DETAILS_EXT_ID,
			AWARD_NUMBER,
			ACCOUNT_NUMBER,
			INTERNAL_ORDER_CODE,
			COMMITTED_AMOUNT,
			UPDATE_TIMESTAMP,
			UPDATE_USER,
			IS_FROM_SAP
		)
		VALUES(
			ls_award_expense_detls_ext_id,
			ls_award_number,
			ls_account_number,
			ls_internal_order_code,
			ls_amount_in_fma_currency,
			utc_timestamp(),
			'quickstart',
			'Y');
		ELSE
			UPDATE AWARD_EXPENSE_DETAILS_EXT SET COMMITTED_AMOUNT = ls_amount_in_fma_currency
			WHERE AWARD_NUMBER = ls_award_number
			AND ACCOUNT_NUMBER = ls_account_number
			AND INTERNAL_ORDER_CODE = ls_internal_order_code
			AND IS_FROM_SAP = 'Y';
		END IF;
		END LOOP;
	CLOSE EXP_CURSOR;
    set sql_safe_updates = 1;
END;
END
$$
DELIMITER ;
