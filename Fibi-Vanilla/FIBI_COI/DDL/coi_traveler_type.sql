

--
--  `coi_traveler_type`
--

DROP TABLE IF EXISTS `coi_traveler_type`;

CREATE TABLE `coi_traveler_type` (
  `TRAVELER_TYPE_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`TRAVELER_TYPE_CODE`)
) ;



