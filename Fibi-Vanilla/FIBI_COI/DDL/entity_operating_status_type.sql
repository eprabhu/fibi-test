

--
--  `entity_operating_status_type`
--

DROP TABLE IF EXISTS `entity_operating_status_type`;

CREATE TABLE `entity_operating_status_type` (
  `OPERATING_STATUS_TYPE_CODE` varchar(10) NOT NULL,
  `DESCRIPTION` varchar(500) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT NULL,
  `UPDATE_TIMESTAMP` timestamp NULL DEFAULT NULL,
  `UPDATED_BY` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`OPERATING_STATUS_TYPE_CODE`)
) ;



