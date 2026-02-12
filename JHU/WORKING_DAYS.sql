DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` FUNCTION `WORKING_DAYS`(
                           p_start_date DATE
                         , p_end_date   DATE
                       ) RETURNS int
    DETERMINISTIC
BEGIN
        DECLARE v_start_date DATE DEFAULT DATE(p_start_date);
        DECLARE v_end_date DATE DEFAULT DATE(p_end_date);
        IF (v_end_date is not null) and (v_start_date is not null) THEN
                    RETURN ABS(DATEDIFF(v_end_date, v_start_date))
- ABS(DATEDIFF(ADDDATE(v_end_date, INTERVAL 1 - DAYOFWEEK(v_end_date) DAY), ADDDATE(v_start_date, INTERVAL 1 - DAYOFWEEK(v_start_date) DAY))) / 7 * 2
- (DAYOFWEEK(IF(v_start_date < v_end_date, v_start_date, v_end_date)) = 1)
- (DAYOFWEEK( IF(v_start_date > v_end_date, v_start_date, v_end_date)) = 7);
                ELSE
                    RETURN NULL;
                END IF;
            END
$$
DELIMITER ;
