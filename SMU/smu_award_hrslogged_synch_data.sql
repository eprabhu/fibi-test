DELIMITER $$
CREATE  PROCEDURE `smu_award_hrslogged_synch_data`()
BEGIN
DECLARE ls_award_number 	VARCHAR(20);
DECLARE ls_account_number 	VARCHAR(20);
DECLARE ls_fund_code        VARCHAR(100);
DECLARE ls_funds_center     VARCHAR(100);
DECLARE ls_io_code          VARCHAR(50);
DECLARE ls_submitted_hours  DECIMAL(10,2);
DECLARE ls_payroll_hours    DECIMAL(10,2);
DECLARE ls_work_date        DATETIME;
DECLARE DONE1 INT DEFAULT FALSE;
declare li_flag int;
declare li_hours_logged_id int;
DECLARE LI_AWARD_HOURS_LOG_ID_RT INT;
DECLARE EXP_CURSOR CURSOR FOR
SELECT FUND_CODE,
FUNDS_CENTER,
IO_CODE,
SUBMITTED_HOURS,
PAYROLL_HOURS,
WORK_DATE ,
 AWARD_HOURS_LOG_ID
FROM AWARD_HOURS_LOG_RT;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE1 = TRUE;
OPEN EXP_CURSOR;
EXP_CURSOR_LOOP : LOOP
        FETCH EXP_CURSOR INTO  ls_fund_code,ls_funds_center,ls_io_code,ls_submitted_hours,ls_payroll_hours,ls_work_date,LI_AWARD_HOURS_LOG_ID_RT;
		IF DONE1 THEN
			LEAVE EXP_CURSOR_LOOP;
		END IF;
	SELECT count(1) INTO li_flag FROM AWARD
	WHERE ACCOUNT_NUMBER = ls_fund_code;
    if li_flag > 0 then
		SELECT T1.AWARD_NUMBER INTO ls_award_number FROM AWARD T1
		WHERE ACCOUNT_NUMBER = ls_fund_code
        AND T1.SEQUENCE_NUMBER IN (SELECT MAX(T2.SEQUENCE_NUMBER) FROM AWARD T2
							  WHERE T1.AWARD_NUMBER=T2.AWARD_NUMBER) limit 1;
    end if;
    select ifnull(max(hours_logged_id),0)+1 into li_hours_logged_id from AWARD_HOURS_LOGGED;
		INSERT INTO AWARD_HOURS_LOGGED
		(hours_logged_id,
		AWARD_NUMBER,
		ACCOUNT_NUMBER,
		INTERNAL_ORDER_CODE,
		SUBMITTED_HOURS,
		PAYROLL_HOURS,
		UPDATE_TIMESTAMP,
		UPDATE_USER
		)
		VALUES (
        li_hours_logged_id,
        ls_award_number,
		ls_fund_code,
		ls_io_code,
		ls_submitted_hours,
		ls_payroll_hours,
		now(),
		'quickstart');
        commit;
		  update AWARD_HOURS_LOG_RT set HRS_LOG_ID = li_hours_logged_id
		  where AWARD_HOURS_LOG_ID = LI_AWARD_HOURS_LOG_ID_RT;
		  commit;
        SET ls_award_number = NULL;
        SET ls_fund_code = NULL;
        SET ls_io_code = NULL;
        SET ls_submitted_hours = NULL;
        SET ls_payroll_hours = NULL;
		SET ls_work_date = NULL;
	END LOOP;
CLOSE EXP_CURSOR;
	BEGIN
		UPDATE AWARD_HOURS_LOGGED T1
		INNER JOIN AWARD_HOURS_LOG_RT T2 ON T1.hours_logged_id = T2.HRS_LOG_ID
		SET T1.SUBMITTED_DATE = date_format(str_to_date(T2.WORK_DATE,'%d.%m.%Y'),'%Y-%m-%d');
		COMMIT;
	END;
END
$$
DELIMITER ;
