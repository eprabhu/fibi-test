
DROP TABLE IF EXISTS `custom_data_report_rt`;

CREATE TABLE `custom_data_report_rt` (
  `MODULE_ITEM_KEY` decimal(22,0) NOT NULL,
  `STEM_NONSTEM` longtext,
  `RIE_DOMAIN` longtext,
  `INPUT_GST_CATEGORY` longtext,
  `OUTPUT_GST_CATEGORY` longtext,
  `GRANT_CODE` longtext,
  `SUB_LEAD_UNIT` longtext,
  `PROFIT_CENTER` longtext,
  `FUND_CENTER` longtext,
  `COST_CENTER` longtext,
  `DISPLAY_AT_ACAD_PROFILE` longtext,
  `LEVEL_2_SUP_ORG` longtext,
  `LAST_SYNC_TIME` datetime DEFAULT NULL,
  `MULTIPLIER` longtext,
  `CLAIM_PREPARER` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`MODULE_ITEM_KEY`)
) ;