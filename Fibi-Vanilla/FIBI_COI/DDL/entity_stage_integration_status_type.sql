

--
--  `entity_stage_integration_status_type`
--

DROP TABLE IF EXISTS `entity_stage_integration_status_type`;

CREATE TABLE `entity_stage_integration_status_type` (
  `INTEGRATION_STATUS_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `UPDATED_BY` varchar(40) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT NULL,
  PRIMARY KEY (`INTEGRATION_STATUS_CODE`)
) ;



