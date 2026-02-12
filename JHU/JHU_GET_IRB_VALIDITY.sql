DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` FUNCTION `JHU_GET_IRB_VALIDITY`(
                                   protocol_number_in varchar(20)
                               ) RETURNS varchar(100) CHARSET utf8mb4
    DETERMINISTIC
begin
        declare return_validity VARCHAR(15) default 'Invalid';
        declare irb_count int(3) default 0;
        IF protocol_number_in IS NULL THEN
                    set return_validity = 'Not Yet Applied';
        ELSEIF protocol_number_in LIKE 'IRB%' OR protocol_number_in LIKE 'NA_%' THEN
                    SELECT
                           COUNT(1)
                    INTO
                           irb_count
                    FROM
                           irb_report i
                    WHERE
                           UPPER(i.protocol_number) = UPPER(protocol_number_in)
                    ;
                    IF irb_count > 0 THEN
                        set return_validity = 'Valid';
                    END IF;
        ELSEIF protocol_number_in LIKE 'HIRB%' THEN
                    set return_validity = 'Unknown';
        END IF;
                RETURN return_validity;
    end
$$
DELIMITER ;
