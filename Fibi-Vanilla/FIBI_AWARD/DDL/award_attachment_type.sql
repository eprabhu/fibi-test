DROP TABLE IF EXISTS `award_attachment_type`;

CREATE TABLE `award_attachment_type` (
  `TYPE_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(300) DEFAULT NULL,
  `UPDATE_TIMESTAMP` date DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  `IS_PRIVATE` varchar(1) DEFAULT 'N',
  `IS_ACTIVE` varchar(1) DEFAULT 'Y',
  PRIMARY KEY (`TYPE_CODE`)
) ;
