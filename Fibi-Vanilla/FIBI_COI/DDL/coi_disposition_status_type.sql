

--
--  `coi_disposition_status_type`
--

DROP TABLE IF EXISTS `coi_disposition_status_type`;

CREATE TABLE `coi_disposition_status_type` (
  `DISPOSITION_STATUS_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT 'Y',
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  `SORT_ORDER` int(11) DEFAULT NULL,
  PRIMARY KEY (`DISPOSITION_STATUS_CODE`)
) ;



