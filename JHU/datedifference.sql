DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` FUNCTION `datedifference`(startDate DATE,
    endDate DATE) RETURNS varchar(255) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE years INT;
    DECLARE months INT;
    DECLARE days INT;
    DECLARE result VARCHAR(255);
    SET years = TIMESTAMPDIFF(YEAR, endDate, startDate);
    SET endDate = DATE_ADD(endDate, INTERVAL years YEAR);
    SET months = TIMESTAMPDIFF(MONTH, endDate, startDate);
    SET endDate = DATE_ADD(endDate, INTERVAL months MONTH);
    SET days = DATEDIFF(startDate, endDate);
    SET result = CONCAT(
        years, ' year(s), ',
        months, ' month(s) & ',
        days, ' day(s)'
    );
    RETURN result;
END
$$
DELIMITER ;
