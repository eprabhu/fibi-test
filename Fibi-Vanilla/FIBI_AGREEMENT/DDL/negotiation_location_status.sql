DROP TABLE IF EXISTS `negotiation_location_status`;

CREATE TABLE `negotiation_location_status` (
  `LOCATION_STATUS_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT NULL,
  `COLOR` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`LOCATION_STATUS_CODE`)
) ;
