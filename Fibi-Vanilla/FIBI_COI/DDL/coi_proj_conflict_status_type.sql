

--
--  `coi_proj_conflict_status_type`
--

DROP TABLE IF EXISTS `coi_proj_conflict_status_type`;

CREATE TABLE `coi_proj_conflict_status_type` (
  `PROJECT_CONFLICT_STATUS_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`PROJECT_CONFLICT_STATUS_CODE`)
) ;



