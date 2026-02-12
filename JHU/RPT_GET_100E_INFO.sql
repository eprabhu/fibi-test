DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` PROCEDURE `RPT_GET_100E_INFO`(IN unit varchar(20))
BEGIN
SELECT DISTINCT
        u.unit_name UNIT_NAME,
        au.unit_number AS UNIT_NUMBER,
        SUBSTR(a.award_number, 1, 6) AS AWARD_NUMBER,
        ai.FULL_NAME PRINCIPAL_INV,
        a.title AS TITLE,
        s.sponsor_name AS SPONSOR,
        a.sponsor_award_number SPONSOR_AWARD_NUMBER,
        av.start_date AS START_DATE,
        av.end_date AS END_DATE,
        av.direct AS DIRECT,
        av.total AS TOTAL,
		'100e' AS REPORT_NUMBER,
		UNIT AS PARAM_ENTERED_1,
		UTC_TIMESTAMP() AS RUN_TIME,
		'Active Awards' AS REPORT_TITLE
FROM award a
         JOIN (
                SELECT ap.AWARD_ID,
						ap.AWARD_PERSON_ID,
                        ap.FULL_NAME,
                        ap.award_number,
                        ap.PI_FLAG,
                        ap.PERSON_ROLE_ID
                FROM award_persons ap
                WHERE ap.SEQUENCE_NUMBER = 0
        ) ai on a.AWARD_ID = ai.AWARD_ID
         JOIN (
                SELECT apu.AWARD_ID,
                        apu.AWARD_PERSON_ID,
                        apu.unit_number,
                        apu.award_number,
                        apu.lead_unit_flag
                FROM award_person_unit apu
                WHERE apu.SEQUENCE_NUMBER = 0
        ) au ON au.AWARD_NUMBER = ai.AWARD_NUMBER
        JOIN unit u ON au.unit_number = u.unit_number
        JOIN jhu_unit ju ON au.unit_number = ju.unit_number
        JOIN sponsor s ON s.sponsor_code = a.sponsor_code
        JOIN (
                SELECT aafd1.award_number,
                        SUM(aafd1.TOTAL_direct_cost) AS direct,
                        SUM(aafd1.TOTAL_indirect_cost) AS indirect,
                        SUM(aafd1.TOTAL_direct_cost + TOTAL_indirect_cost) AS total,
                        MIN(aafd1.start_date) AS start_date,
                        MAX(aafd1.end_date) AS end_date
                FROM award_amt_fna_distribution aafd1
                WHERE aafd1.sequence_number = 0
                GROUP BY aafd1.award_number
        ) av on a.award_number = av.award_number
        LEFT OUTER JOIN jhu_unit ju1 ON CONCAT(
                SUBSTR(ju.sort_value, 1, 3),
                '000000000000000000000000000'
        ) = ju1.sort_value
        LEFT OUTER JOIN jhu_unit ju2 ON CONCAT(
                SUBSTR(ju.sort_value, 1, 6),
                '000000000000000000000000'
        ) = ju2.sort_value
        LEFT OUTER JOIN jhu_unit ju3 ON CONCAT(
                SUBSTR(ju.sort_value, 1, 9),
                '000000000000000000000'
        ) = ju3.sort_value
        LEFT OUTER JOIN jhu_unit ju4 ON CONCAT(
                SUBSTR(ju.sort_value, 1, 12),
                '000000000000000000'
        ) = ju4.sort_value
        LEFT OUTER JOIN jhu_unit ju5 ON CONCAT(SUBSTR(ju.sort_value, 1, 15), '000000000000000') = ju5.sort_value
        LEFT OUTER JOIN jhu_unit ju6 ON CONCAT(SUBSTR(ju.sort_value, 1, 18), '000000000000') = ju6.sort_value
        LEFT OUTER JOIN jhu_unit ju7 ON CONCAT(SUBSTR(ju.sort_value, 1, 21), '000000000') = ju7.sort_value
WHERE a.status_code = 1
        AND date(av.end_date) >= date(SYSDATE())
        AND a.AWARD_NUMBER LIKE '%-00001'
        AND find_in_set(au.unit_number, fn_get_temp_unit(unit))
        AND au.lead_unit_flag = 'Y'
        AND ai.PI_FLAG = 'Y'
        AND ai.PERSON_ROLE_ID in (3)
        AND a.sequence_number = 0
UNION
SELECT DISTINCT
        u.unit_name UNIT_NAME,
        au.unit_number AS UNIT_NUMBER,
        SUBSTR(a.award_number, 1, 6) AS AWARD_NUMBER,
        ai.FULL_NAME PRINCIPAL_INV,
        a.title AS TITLE,
        s.sponsor_name AS SPONSOR,
        a.sponsor_award_number SPONSOR_AWARD_NUMBER,
         avd.start_date AS START_DATE,
        avd.end_date AS END_DATE,
        NULL AS DIRECT,
        NULL AS TOTAL,
		'100e' AS REPORT_NUMBER,
		UNIT AS PARAM_ENTERED_1,
		UTC_TIMESTAMP() AS RUN_TIME,
		'Active Awards' AS REPORT_TITLE
FROM award a
 JOIN (
                SELECT ap.AWARD_ID,
						ap.AWARD_PERSON_ID,
                        ap.FULL_NAME,
                        ap.award_number,
                        ap.PI_FLAG,
                        ap.person_id,
                        ap.PERSON_ROLE_ID
                FROM award_persons ap
                WHERE ap.SEQUENCE_NUMBER = 0
        ) ai on a.AWARD_ID = ai.AWARD_ID
         JOIN (
                SELECT apu.AWARD_ID,
						apu.AWARD_PERSON_ID,
                        apu.unit_number,
                        apu.award_number,
                        apu.lead_unit_flag
                FROM award_person_unit apu
                WHERE apu.SEQUENCE_NUMBER = 0
        ) au on au.AWARD_NUMBER = ai.AWARD_NUMBER
        JOIN person pe ON pe.person_id = ai.person_id
        JOIN sponsor s ON s.sponsor_code = a.sponsor_code
        JOIN unit u ON au.unit_number = u.unit_number
        JOIN jhu_unit ju ON au.unit_number = ju.unit_number
        LEFT OUTER JOIN jhu_unit ju1 ON CONCAT(
                SUBSTR(ju.sort_value, 1, 3),
                '000000000000000000000000000'
        ) = ju1.sort_value
        LEFT OUTER JOIN jhu_unit ju2 ON CONCAT(
                SUBSTR(ju.sort_value, 1, 6),
                '000000000000000000000000'
        ) = ju2.sort_value
        LEFT OUTER JOIN jhu_unit ju3 ON CONCAT(
                SUBSTR(ju.sort_value, 1, 9),
                '000000000000000000000'
        ) = ju3.sort_value
        LEFT OUTER JOIN jhu_unit ju4 ON CONCAT(
                SUBSTR(ju.sort_value, 1, 12),
                '000000000000000000'
        ) = ju4.sort_value
        LEFT OUTER JOIN jhu_unit ju5 ON CONCAT(SUBSTR(ju.sort_value, 1, 15), '000000000000000') = ju5.sort_value
        LEFT OUTER JOIN jhu_unit ju6 ON CONCAT(SUBSTR(ju.sort_value, 1, 18), '000000000000') = ju6.sort_value
        LEFT OUTER JOIN jhu_unit ju7 ON CONCAT(SUBSTR(ju.sort_value, 1, 21), '000000000') = ju7.sort_value
        JOIN (
                SELECT aafd2.award_number,
                        MIN(aafd2.start_date) AS start_date,
                        MAX(aafd2.end_date) AS end_date
                FROM award_amt_fna_distribution aafd2
                WHERE aafd2.sequence_number = 0
                GROUP BY aafd2.award_number
        ) avd on a.award_number = avd.award_number
        WHERE a.status_code = 1
		AND date(avd.end_date) >= date(SYSDATE())
        AND find_in_set(au.unit_number, fn_get_temp_unit(unit))
        AND a.award_number LIKE '%-00001'
        AND au.lead_unit_flag = 'Y'
        AND ai.PI_FLAG = 'N'
        AND ai.PERSON_ROLE_ID IN (1)
        AND a.sequence_number = 0
ORDER BY 1,
        2,
        3,
        4,
        5,
        6,
        7;
END
$$
DELIMITER ;
