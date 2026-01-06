DROP TABLE IF EXISTS `negotiation_activity_type`;

CREATE TABLE `negotiation_activity_type` (
  `ACTIVITY_TYPE_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT 'Y',
  PRIMARY KEY (`ACTIVITY_TYPE_CODE`)
) ;
