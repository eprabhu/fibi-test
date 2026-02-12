DELIMITER $$
CREATE  FUNCTION `calculate_Duration`(endDate DATE,
    startDate DATE) RETURNS varchar(255) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE years INT;
    DECLARE months INT;
    DECLARE days INT;
    DECLARE result VARCHAR(255);
	set endDate = DATE_ADD(endDate, INTERVAL 1 DAY);
    SET years = TIMESTAMPDIFF(YEAR, startDate, endDate);
    SET startDate = DATE_ADD(startDate, INTERVAL years YEAR);
    SET months = TIMESTAMPDIFF(MONTH, startDate, endDate);
    SET startDate = DATE_ADD(startDate, INTERVAL months MONTH);
    SET days = DATEDIFF(endDate, startDate);
    SET result = CONCAT(
        years, ' year(s), ',
        months, ' month(s), ',
        days, ' day(s)'
    );
    RETURN result;
END
$$
DELIMITER ;
