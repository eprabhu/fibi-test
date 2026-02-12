DELIMITER $$
CREATE  FUNCTION `DATEDIFFERENCE`(date1 DATE, date2 DATE) RETURNS varchar(100) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE dif DATE;
    DECLARE days varchar(200);
	DECLARE years varchar(200);
    DECLARE months varchar(200);
    IF DATEDIFF(date1, DATE(CONCAT(YEAR(date1),'-', MONTH(date1), '-', DAY(date2)))) < 0    THEN
                SET dif=DATE_FORMAT(
                                        CONCAT(
                                            PERIOD_DIFF(date_format(date1, '%y%m'),date_format(date2, '%y%m'))DIV 12 ,
                                            '-',
                                            PERIOD_DIFF(date_format(date1, '%y%m'),date_format(date2, '%y%m'))% 12 ,
                                            '-',
                                            DATEDIFF(date1, DATE(CONCAT(YEAR(date1),'-', MONTH(DATE_SUB(date1, INTERVAL 1 MONTH)), '-', DAY(date2))))),
                                        '%Y-%m-%d');
    ELSEIF DATEDIFF(date1, DATE(CONCAT(YEAR(date1),'-', MONTH(date1), '-', DAY(date2)))) < DAY(LAST_DAY(DATE_SUB(date1, INTERVAL 1 MONTH))) THEN
                SET dif=DATE_FORMAT(
                                        CONCAT(
                                            PERIOD_DIFF(date_format(date1, '%y%m'),date_format(date2, '%y%m'))DIV 12 ,
                                            '-',
                                            PERIOD_DIFF(date_format(date1, '%y%m'),date_format(date2, '%y%m'))% 12 ,
                                            '-',
                                            DATEDIFF(date1, DATE(CONCAT(YEAR(date1),'-', MONTH(date1), '-', DAY(date2))))),
                                        '%Y-%m-%d');
    ELSE
                SET dif=DATE_FORMAT(
                                        CONCAT(
                                            PERIOD_DIFF(date_format(date1, '%y%m'),date_format(date2, '%y%m'))DIV 12 ,
                                            '-',
                                            PERIOD_DIFF(date_format(date1, '%y%m'),date_format(date2, '%y%m'))% 12 ,
                                            '-',
                                            DATEDIFF(date1, DATE(CONCAT(YEAR(date1),'-', MONTH(date1), '-', DAY(date2))))),
                                        '%Y-%m-%d');
    END IF;
 SELECT EXTRACT(day FROM dif) into days;
  SELECT EXTRACT(month FROM dif) into months;
 SELECT EXTRACT(year FROM dif) into years;
  if (length(years) > 2) then
 set years = SUBSTRING(years FROM 3 FOR length(years));
  end if;
 return concat(years,' year(s) ', months, ' month(s) & ', days, ' day(s)');
END
$$
DELIMITER ;
