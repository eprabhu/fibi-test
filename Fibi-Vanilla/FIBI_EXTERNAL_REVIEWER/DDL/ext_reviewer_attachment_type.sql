

DROP TABLE IF EXISTS `ext_reviewer_attachment_type`;

CREATE TABLE `ext_reviewer_attachment_type` (
  `ATTACHMENT_TYPE_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`ATTACHMENT_TYPE_CODE`)
);

