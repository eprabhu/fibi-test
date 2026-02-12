DELIMITER $$
CREATE  PROCEDURE `jhu_sap_awd_set_indicators`(av_award_id INT
,av_award_number VARCHAR(12)
,av_sequence_number INT(4)
)
BEGIN
DECLARE li_row_count INT(4) DEFAULT 0;
SET SQL_SAFE_UPDATES= 0;
SELECT COUNT(*)
INTO li_row_count
FROM award_science_keyword
WHERE award_id = av_award_id;
END
$$
DELIMITER ;
