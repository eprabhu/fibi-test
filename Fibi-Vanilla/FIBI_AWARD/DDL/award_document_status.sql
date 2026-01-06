DROP TABLE IF EXISTS `award_document_status`;

CREATE TABLE `award_document_status` (
  `STATUS_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`STATUS_CODE`)
) ;
