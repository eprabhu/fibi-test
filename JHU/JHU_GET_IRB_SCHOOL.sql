DELIMITER $$
CREATE  FUNCTION `JHU_GET_IRB_SCHOOL`(protocol_number  varchar(20)) RETURNS varchar(100) CHARSET utf8mb4
    DETERMINISTIC
begin
 Declare  return_school VARCHAR(15) default 'Unknown';
   IF protocol_number IS NULL
   THEN
     set return_school = 'Not Yet Applied';
   ELSEIF protocol_number LIKE 'IRB%' OR protocol_number LIKE 'NA%'
   THEN
     set return_school = 'SOM';
   ELSEIF protocol_number LIKE 'HIRB%'
   THEN
     set return_school = 'Homewood';
   END IF;
   RETURN return_school;
 end
$$
DELIMITER ;
