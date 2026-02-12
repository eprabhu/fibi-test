DELIMITER $$
CREATE DEFINER=`fibi`@`%` PROCEDURE `AWARD_CLAIM_REMINDER_QUARTERLY`( AV_DAYS INT )
BEGIN
SELECT  0 AS SUB_MODULE_ITEM_KEY, t0.AWARD_ID AS MODULE_ITEM_KEY, 1 AS MODULE_CODE, 0 AS SUB_MODULE_CODE, t0.FINAL_EXPIRATION_DATE as EXP
FROM
(
        select  t1.AWARD_ID, t1.AWARD_NUMBER, t1.FINAL_EXPIRATION_DATE
        from award t1
        where t1.AWARD_SEQUENCE_STATUS = 'ACTIVE'
		and t1.ACCOUNT_TYPE_CODE IN (1,2,4,6)
        and t1.STATUS_CODE = 1
        and t1.PAYMENT_INVOICE_FREQ_CODE = 12
        AND t1.BEGIN_DATE <= CONVERT_TZ(utc_timestamp(),'+00:00','+8:00')
        AND (MONTH(date(DATE_ADD(CONVERT_TZ(utc_timestamp(),'+00:00','+8:00'),INTERVAL AV_DAYS DAY))) = '4')
        AND (DAY(date(DATE_ADD(CONVERT_TZ(utc_timestamp(),'+00:00','+8:00'),INTERVAL AV_DAYS DAY))) = '01')
        UNION
        select t1.AWARD_ID, t1.AWARD_NUMBER, t1.FINAL_EXPIRATION_DATE
        from award t1
        where t1.AWARD_SEQUENCE_STATUS = 'ACTIVE'
		and t1.ACCOUNT_TYPE_CODE IN (1,2,4,6)
        and t1.STATUS_CODE = 1
        and t1.PAYMENT_INVOICE_FREQ_CODE = 12
        AND t1.BEGIN_DATE <= CONVERT_TZ(utc_timestamp(),'+00:00','+8:00')
        AND (MONTH(date(DATE_ADD(CONVERT_TZ(utc_timestamp(),'+00:00','+8:00'),INTERVAL AV_DAYS DAY))) = '7')
        AND (DAY(date(DATE_ADD(CONVERT_TZ(utc_timestamp(),'+00:00','+8:00'),INTERVAL AV_DAYS DAY))) = '01')
        UNION
        select t1.AWARD_ID, t1.AWARD_NUMBER, t1.FINAL_EXPIRATION_DATE
        from award t1
        where t1.AWARD_SEQUENCE_STATUS = 'ACTIVE'
		and t1.ACCOUNT_TYPE_CODE IN (1,2,4,6)
        and t1.STATUS_CODE = 1
        and t1.PAYMENT_INVOICE_FREQ_CODE = 12
        AND t1.BEGIN_DATE <= CONVERT_TZ(utc_timestamp(),'+00:00','+8:00')
        AND (MONTH(date(DATE_ADD(CONVERT_TZ(utc_timestamp(),'+00:00','+8:00'),INTERVAL AV_DAYS DAY))) = '10')
        AND (DAY(date(DATE_ADD(CONVERT_TZ(utc_timestamp(),'+00:00','+8:00'),INTERVAL AV_DAYS DAY))) = '01')
        UNION
        select t1.AWARD_ID, t1.AWARD_NUMBER, t1.FINAL_EXPIRATION_DATE
        from award t1
        where t1.AWARD_SEQUENCE_STATUS = 'ACTIVE'
		and t1.ACCOUNT_TYPE_CODE IN (1,2,4,6)
        and t1.STATUS_CODE = 1
        and t1.PAYMENT_INVOICE_FREQ_CODE = 12
    AND t1.BEGIN_DATE <= CONVERT_TZ(utc_timestamp(),'+00:00','+8:00')
        AND (MONTH(date(DATE_ADD(CONVERT_TZ(utc_timestamp(),'+00:00','+8:00'),INTERVAL AV_DAYS DAY))) = '01')
        AND (DAY(date(DATE_ADD(CONVERT_TZ(utc_timestamp(),'+00:00','+8:00'),INTERVAL AV_DAYS DAY))) = '01')
) t0
where   0 = (
                                        select count(s2.AWARD_REPORT_TRACKING_ID) from award_report_terms s1
                                        inner join award_report_tracking s2 on s1.AWARD_REPORT_TERMS_ID = s2.AWARD_REPORT_TERMS_ID
                                        where s1.REPORT_CLASS_CODE = 18
                                        and s2.award_number = t0.award_number
                                        and s2.SEQUENCE_NUMBER  = 0
                                        and s2.DUE_DATE > date(CONVERT_TZ(utc_timestamp(),'+00:00','+8:00'))
                        );
END
$$
DELIMITER ;
