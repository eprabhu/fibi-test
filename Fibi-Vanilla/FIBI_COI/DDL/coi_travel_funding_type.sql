

--
--  `coi_travel_funding_type`
--

DROP TABLE IF EXISTS `coi_travel_funding_type`;

CREATE TABLE `coi_travel_funding_type` (
  `FUNDING_TYPE_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATED_BY` varchar(40) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT NULL,
  PRIMARY KEY (`FUNDING_TYPE_CODE`)
) ;



