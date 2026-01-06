

DROP TABLE IF EXISTS `progress_reprt_milestone_status`;

CREATE TABLE `progress_reprt_milestone_status` (
  `MILESTONE_STATUS_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT 'Y',
  PRIMARY KEY (`MILESTONE_STATUS_CODE`)
) ;
