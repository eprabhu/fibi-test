DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GET_TEMP_UNIT_PROC`(IN  PARENTUNIT VARCHAR(20), inout TEMP_UNIT longtext)
BEGIN
    DECLARE child_unit_number VARCHAR(20);
    set group_concat_max_len=1000000;
    WITH RECURSIVE unit_path (unit_number, path) AS
(
SELECT unit_number,CAST(UNIT_NUMBER AS CHAR(200))
FROM unit
WHERE UNIT_NUMBER = PARENTUNIT
UNION ALL
SELECT u.UNIT_NUMBER, CONCAT(up.path, ',', u.unit_number)
FROM unit_path AS up JOIN unit AS u
ON up.UNIT_NUMBER = u.PARENT_UNIT_NUMBER
)
select group_concat(unit_number order by path) into TEMP_UNIT from unit_path ;
END
$$
DELIMITER ;
