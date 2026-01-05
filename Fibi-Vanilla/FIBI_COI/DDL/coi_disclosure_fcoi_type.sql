

--
--  `coi_disclosure_fcoi_type`
--

DROP TABLE IF EXISTS `coi_disclosure_fcoi_type`;

CREATE TABLE `coi_disclosure_fcoi_type` (
  `FCOI_TYPE_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`FCOI_TYPE_CODE`)
) ;



