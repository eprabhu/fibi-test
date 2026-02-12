DELIMITER $$
CREATE  FUNCTION `get_999_department`(av_unit_number VARCHAR(8)) RETURNS varchar(200) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
   DECLARE return_unit_name VARCHAR(200);
   SELECT distinct(j.unit_name)
   INTO   return_unit_name
   FROM   jhu_unit j
   WHERE  j.sort_value in (SELECT concat(SUBSTR(sort_value, 1, 12),'000000000000000000')
                          FROM   jhu_unit
                          WHERE  unit_number = av_unit_number);
   RETURN return_unit_name;
 END
$$
DELIMITER ;
