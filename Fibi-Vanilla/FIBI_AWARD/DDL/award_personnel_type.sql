DROP TABLE IF EXISTS `award_personnel_type`;

CREATE TABLE `award_personnel_type` (
  `VALUE` varchar(1) NOT NULL,
  `NAME` varchar(255) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`VALUE`)
) ;
