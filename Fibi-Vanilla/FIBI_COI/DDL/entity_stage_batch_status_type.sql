

--
--  `entity_stage_batch_status_type`
--

DROP TABLE IF EXISTS `entity_stage_batch_status_type`;

CREATE TABLE `entity_stage_batch_status_type` (
  `BATCH_STATUS_CODE` int(11) NOT NULL,
  `DESCRIPTION` varchar(255) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `UPDATED_BY` varchar(40) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT NULL,
  PRIMARY KEY (`BATCH_STATUS_CODE`)
) ;



