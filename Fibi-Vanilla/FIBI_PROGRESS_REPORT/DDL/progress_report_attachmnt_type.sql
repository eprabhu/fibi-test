
DROP TABLE IF EXISTS `progress_report_attachmnt_type`;

CREATE TABLE `progress_report_attachmnt_type` (
  `ATTACHMENT_TYPE_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(300) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT 'Y',
  `IS_PRIVATE` varchar(1) DEFAULT 'N',
  PRIMARY KEY (`ATTACHMENT_TYPE_CODE`)
) ;
