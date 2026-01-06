

DROP TABLE IF EXISTS `kpi_manpower_development_current_status`;

CREATE TABLE `kpi_manpower_development_current_status` (
  `CURRENT_STATUS_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT 'Y',
  PRIMARY KEY (`CURRENT_STATUS_CODE`)
) ;