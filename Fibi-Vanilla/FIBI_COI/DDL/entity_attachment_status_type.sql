

--
--  `entity_attachment_status_type`
--

DROP TABLE IF EXISTS `entity_attachment_status_type`;

CREATE TABLE `entity_attachment_status_type` (
  `ATTACHMENT_STATUS_CODE` varchar(10) NOT NULL,
  `DESCRIPTION` varchar(500) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT NULL,
  `UPDATE_TIMESTAMP` timestamp NULL DEFAULT NULL,
  `UPDATED_BY` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`ATTACHMENT_STATUS_CODE`)
) ;



