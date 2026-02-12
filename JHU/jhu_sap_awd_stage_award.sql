DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `jhu_sap_awd_stage_award`(
av_grant_number VARCHAR(6)
,av_sponsored_program_number VARCHAR(8)
,av_coeus_update_timestamp DATE
)
BEGIN
DECLARE LI_STAGED_AWARDS_id INT(12);
SET SQL_SAFE_UPDATES= 0;
SELECT IFNULL(MAX(STAGED_AWARDS_id),0)+1 INTO LI_STAGED_AWARDS_id
FROM staged_awards;
      INSERT INTO staged_awards (STAGED_AWARDS_id
								,grant_number
                                ,sponsored_program_number
                                ,update_timestamp
                                )
      VALUES (LI_STAGED_AWARDS_id
			 ,av_grant_number
             ,av_sponsored_program_number
             ,av_coeus_update_timestamp);
COMMIT;
END
$$
DELIMITER ;
