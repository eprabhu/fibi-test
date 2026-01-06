DROP TABLE IF EXISTS `agreement_attachment_status`;

CREATE TABLE `agreement_attachment_status` (
  `AGRMNT_ATTACH_STATUS_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT 'Y',
  PRIMARY KEY (`AGRMNT_ATTACH_STATUS_CODE`)
);