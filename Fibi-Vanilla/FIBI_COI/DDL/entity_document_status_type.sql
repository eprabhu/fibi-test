

--
--  `entity_document_status_type`
--

DROP TABLE IF EXISTS `entity_document_status_type`;

CREATE TABLE `entity_document_status_type` (
  `DOCUMENT_STATUS_TYPE_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(500) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT NULL,
  `UPDATE_TIMESTAMP` timestamp NULL DEFAULT NULL,
  `UPDATED_BY` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`DOCUMENT_STATUS_TYPE_CODE`)
) ;



