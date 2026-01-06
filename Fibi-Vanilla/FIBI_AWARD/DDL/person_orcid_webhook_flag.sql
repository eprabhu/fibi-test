DROP TABLE IF EXISTS `person_orcid_webhook_flag`;

CREATE TABLE `person_orcid_webhook_flag` (
  `PERSON_ID` varchar(40) NOT NULL,
  `IS_REGISTERED_FLAG` varchar(1) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`PERSON_ID`)
) ;
