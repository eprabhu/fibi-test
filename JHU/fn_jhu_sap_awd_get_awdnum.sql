DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` FUNCTION `fn_jhu_sap_awd_get_awdnum`(av_grant_number  VARCHAR(6)
										,av_sponsored_program_number  VARCHAR(8)
										,av_sponsored_program_type  VARCHAR(15)
) RETURNS varchar(12) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
		DECLARE ls_return_varchar VARCHAR(12) DEFAULT NULL;
		DECLARE ls_program_count INT;
		DECLARE ls_hierarchy_number VARCHAR(5) DEFAULT NULL;
      BEGIN
-- UTL_FILE.PUT_LINE(out_file_handle, 'av_sponsored_program_number = ' || av_sponsored_program_number);
-- UTL_FILE.PUT_LINE(out_file_handle, 'av_sponsored_program_type = ' || av_sponsored_program_type);
        IF av_sponsored_program_type = 'GR'
        THEN
          set ls_hierarchy_number = '00001';
        ELSE
          IF av_sponsored_program_type = 'PM'
          THEN
           set  ls_hierarchy_number = '00002';
          ELSE
            SELECT COUNT(*)
            INTO ls_program_count
            FROM award
            WHERE account_number = av_sponsored_program_number;
            IF ls_program_count > 0
            THEN
-- UTL_FILE.PUT_LINE(out_file_handle, 'SELECT 1');
              SELECT SUBSTR(award_number, 8, 5)
              INTO ls_hierarchy_number
              FROM award
              WHERE account_number = av_sponsored_program_number
              AND   sequence_number = (SELECT MAX(sequence_number)
                                       FROM award
                                       WHERE account_number = av_sponsored_program_number);
-- UTL_FILE.PUT_LINE(out_file_handle, 'SELECT 1');
            ELSE
-- UTL_FILE.PUT_LINE(out_file_handle, 'SELECT 2');
              SELECT TRIM(LPAD((CAST(TRIM(SUBSTR(MAX(award_number), 8, 5)) AS DECIMAL) + 1),5, '0'))
              INTO ls_hierarchy_number
              FROM award
              WHERE award_number LIKE CONCAT(av_grant_number , '%');
-- UTL_FILE.PUT_LINE(out_file_handle, 'SELECT 2');
              IF ls_hierarchy_number IS NULL OR TRIM(ls_hierarchy_number) < 3
              THEN
                set ls_hierarchy_number = '00003';
              END IF;
            END IF;
          END IF;
        END IF;
        set ls_return_varchar =CONCAT(TRIM(av_grant_number), '-' , ls_hierarchy_number);
        RETURN ls_return_varchar;
      END;
    END
$$
DELIMITER ;
