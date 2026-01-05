

--
--  `coi_travel_document_status_type`
--

DROP TABLE IF EXISTS `coi_travel_document_status_type`;

CREATE TABLE `coi_travel_document_status_type` (
  `DOCUMENT_STATUS_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  KEY `IDX_DOCUMENT_STATUS_CODE` (`DOCUMENT_STATUS_CODE`),
  PRIMARY KEY (`DOCUMENT_STATUS_CODE`)
) ;



