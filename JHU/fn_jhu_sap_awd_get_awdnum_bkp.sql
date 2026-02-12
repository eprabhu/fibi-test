DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` FUNCTION `fn_jhu_sap_awd_get_awdnum_bkp`(av_grant_number  VARCHAR(6)
										,av_sponsored_program_number  VARCHAR(8)
										,av_sponsored_program_type  VARCHAR(15)
) RETURNS varchar(12) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE ls_return_varchar VARCHAR(12) DEFAULT NULL;
DECLARE ls_program_count VARCHAR(5) DEFAULT NULL;
DECLARE ls_hierarchy_number VARCHAR(3) DEFAULT NULL;
IF av_sponsored_program_type = 'GR' THEN
  SET ls_program_count = '00001';
ELSE
		  IF av_sponsored_program_type = 'PM' THEN
				SET ls_program_count = '00002';
		  ELSE
				SELECT COUNT(*)
				INTO ls_program_count
				FROM award
				WHERE account_number = av_sponsored_program_number;
					IF ls_program_count > 0 THEN
						  SELECT SUBSTR(award_number, 8, 5)
						  INTO ls_program_count
						  FROM award
						  WHERE   substr(award_number,1,6) = av_grant_number
						  AND account_number = av_sponsored_program_number
						  AND   sequence_number = (SELECT MAX(sequence_number)
												   FROM award
												   WHERE account_number = av_sponsored_program_number);
					ELSE
						  SELECT TRIM(LPAD((CAST(TRIM(SUBSTR(MAX(award_number), 8, 5)) AS DECIMAL) + 1),5, '0'))
						  INTO ls_program_count
						  FROM award
						  WHERE award_number LIKE CONCAT(av_grant_number , '%');
						  IF (ls_program_count IS NULL OR TRIM(ls_program_count) < 3) THEN
								SET ls_program_count = '00003';
						  END IF;
					END IF;
		  END IF;
END IF;
SET ls_return_varchar = CONCAT(TRIM(av_grant_number), '-' , ls_program_count);
RETURN ls_return_varchar;
END
$$
DELIMITER ;
