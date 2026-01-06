DROP TABLE IF EXISTS `negotiation_association_type`;

CREATE TABLE `negotiation_association_type` (
  `ASSOCIATION_TYPE_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`ASSOCIATION_TYPE_CODE`)
) ;
