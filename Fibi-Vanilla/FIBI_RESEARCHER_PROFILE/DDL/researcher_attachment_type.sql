
DROP TABLE IF EXISTS `researcher_attachment_type`;

CREATE TABLE `researcher_attachment_type` (
  `RESEARCHER_ATTACH_TYPE_CODE` varchar(3) NOT NULL,
  `NAME` varchar(100) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`RESEARCHER_ATTACH_TYPE_CODE`)
) ;
