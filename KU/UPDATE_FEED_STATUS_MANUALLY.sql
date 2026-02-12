DELIMITER $$
CREATE PROCEDURE `UPDATE_FEED_STATUS_MANUALLY`(AV_AWARD_ID	VARCHAR(22))
BEGIN
DECLARE LS_AWARD_NUMBER	VARCHAR(12);
DECLARE LI_FEED_ID INT;
DECLARE LI_BATCH_ID	INT;
SET SQL_SAFE_UPDATES = 0;
SELECT AWARD_NUMBER , FEED_ID INTO LS_AWARD_NUMBER , LI_FEED_ID FROM SAP_AWARD_FEED WHERE AWARD_ID = AV_AWARD_ID;
CALL SAP_FEED_GENERATE_BATCH(LI_FEED_ID);
SELECT BATCH_ID INTO LI_BATCH_ID  FROM SAP_AWARD_FEED WHERE AWARD_ID = AV_AWARD_ID;
update SAP_FEED_TMPL_FUNDED_PRGM set feed_status = 'S' , error_message = 'Manually Updated ' where batch_id = LI_BATCH_ID;
update SAP_FEED_TMPL_GRANT_BUD_MASTER set feed_status = 'S' , error_message = 'Manually Updated ' where batch_id = LI_BATCH_ID;
update SAP_FEED_TMPL_GRANT_MASTER set feed_status = 'S' , error_message = 'Manually Updated ' where batch_id = LI_BATCH_ID;
update SAP_FEED_TMPL_PROJECT_DEF set feed_status = 'S' , error_message = 'Manually Updated ' where batch_id = LI_BATCH_ID;
update SAP_FEED_TMPL_WBS set feed_status = 'S' , error_message = 'Manually Updated ' where batch_id = LI_BATCH_ID;
update SAP_FEED_TMPL_SPONSOR_CLASS set feed_status = 'S' , error_message = 'Manually Updated ' where batch_id = LI_BATCH_ID;
update SAP_FEED_TMPL_SPONSOR_PRGM set feed_status = 'S' , error_message = 'Manually Updated ' where batch_id = LI_BATCH_ID;
update SAP_FEED_TMPL_FM_BUDGET set feed_status = 'S' , error_message = 'Manually Updated ' where batch_id = LI_BATCH_ID;
UPDATE SAP_AWARD_FEED SET FEED_STATUS = 'R' WHERE AWARD_ID = AV_AWARD_ID AND FEED_STATUS = 'F';
UPDATE AWARD_BUDGET_HEADER SET AWARD_BUDGET_STATUS_CODE = 9 WHERE AWARD_NUMBER = LS_AWARD_NUMBER and  AWARD_BUDGET_STATUS_CODE = 10;
END
$$
DELIMITER ;
