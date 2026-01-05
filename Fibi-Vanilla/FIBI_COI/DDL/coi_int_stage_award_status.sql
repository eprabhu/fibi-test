

--
--  `coi_int_stage_award_status`
--

DROP TABLE IF EXISTS `coi_int_stage_award_status`;

CREATE TABLE `coi_int_stage_award_status` (
  `STATUS_CODE` int(11) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATED_BY` varchar(60) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT 'Y',
  PRIMARY KEY (`STATUS_CODE`)
) ;



