DROP TABLE IF EXISTS `orcid_webhook_action_types`;

CREATE TABLE `orcid_webhook_action_types` (
  `WEBHOOK_ACTION_TYPE_CODE` varchar(1) NOT NULL,
  `DESCRIPTION` varchar(20) DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`WEBHOOK_ACTION_TYPE_CODE`)
) ;
