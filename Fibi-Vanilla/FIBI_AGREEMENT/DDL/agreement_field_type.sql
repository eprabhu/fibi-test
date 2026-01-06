DROP TABLE IF EXISTS `agreement_field_type`;

CREATE TABLE `agreement_field_type` (
  `FIELD_CODE` varchar(5) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(40) DEFAULT NULL,
  PRIMARY KEY (`FIELD_CODE`)
) ;
