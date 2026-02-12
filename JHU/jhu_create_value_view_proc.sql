DELIMITER $$
CREATE  PROCEDURE `jhu_create_value_view_proc`(
  column_name   VARCHAR(100)
 ,table_name    VARCHAR(100)
 ,where_clause  VARCHAR(1000)
)
BEGIN
SET @select_stmt = CONCAT('CREATE OR REPLACE VIEW jhu_value_proc_view AS'
						 ,' SELECT DISTINCT(', column_name, ') AS column_value'
						 ,' FROM ', table_name
						 ,' WHERE ', where_clause);
PREPARE stmt FROM @select_stmt;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
END
$$
DELIMITER ;
