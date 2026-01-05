

--
--  `coi_travel_disclosure_status`
--

DROP TABLE IF EXISTS `coi_travel_disclosure_status`;

CREATE TABLE `coi_travel_disclosure_status` (
  `TRAVEL_DISCLOSURE_STATUS_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(50) DEFAULT NULL,
  `SORT_ORDER` int(11) DEFAULT NULL,
  PRIMARY KEY (`TRAVEL_DISCLOSURE_STATUS_CODE`)
) ;



