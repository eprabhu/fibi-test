DROP TABLE IF EXISTS `aderp_integration_log`;

CREATE TABLE `aderp_integration_log` (
  `LOG_ID` int(11) NOT NULL AUTO_INCREMENT,
  `INTEGRATION_TYPE` varchar(60) DEFAULT NULL,
  `STATUS` varchar(20) DEFAULT NULL,
  `MESSAGE` longtext,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`LOG_ID`)
) ;
