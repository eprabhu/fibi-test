DROP TABLE IF EXISTS `negotiation_location_type`;

CREATE TABLE `negotiation_location_type` (
  `LOCATION_TYPE_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT 'Y',
  PRIMARY KEY (`LOCATION_TYPE_CODE`)
) ;
