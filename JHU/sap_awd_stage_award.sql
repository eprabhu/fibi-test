DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sap_awd_stage_award`(
av_grant_number VARCHAR(6)
,av_sponsored_program_number VARCHAR(8)
,av_coeus_update_timestamp DATE
)
BEGIN
      INSERT INTO staged_awards (grant_number
                                ,sponsored_program_number
                                ,update_timestamp
                                )
      VALUES (av_grant_number
             ,av_sponsored_program_number
             ,av_coeus_update_timestamp);
END
$$
DELIMITER ;
