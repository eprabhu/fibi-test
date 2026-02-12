DELIMITER $$
CREATE  PROCEDURE `jhu_sap_awd_cleanup_data`(av_grant_number VARCHAR(6))
BEGIN
SET SQL_SAFE_UPDATES= 0;
DELETE FROM staged_awards;
DELETE FROM  award_comment
WHERE  award_number  LIKE CONCAT(av_grant_number,'%')
AND    COMMENT_TYPE_CODE = 800;
DELETE FROM subcontract_amount_info
WHERE  update_user <> 'INTRFACE';
DELETE FROM award_amount_info
WHERE  update_user <> 'INTRFACE';
COMMIT;
END
$$
DELIMITER ;
