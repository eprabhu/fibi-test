

--
--  `coi_travel_funding_agency_type`
--

DROP TABLE IF EXISTS `coi_travel_funding_agency_type`;

CREATE TABLE `coi_travel_funding_agency_type` (
  `FUNDING_AGENCY_CODE` varchar(6) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATED_BY` varchar(40) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT NULL,
  PRIMARY KEY (`FUNDING_AGENCY_CODE`)
) ;



