DELIMITER $$
CREATE  FUNCTION `fn_jhu_sap_awd_get_unit_number`(av_cost_center   VARCHAR(10)
) RETURNS varchar(8) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE return_char VARCHAR(8) DEFAULT TRIM(av_cost_center);
RETURN return_char;
END
$$
DELIMITER ;
