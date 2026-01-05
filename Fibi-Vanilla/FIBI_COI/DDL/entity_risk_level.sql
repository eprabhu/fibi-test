

--
--  `entity_risk_level`
--

DROP TABLE IF EXISTS `entity_risk_level`;

CREATE TABLE `entity_risk_level` (
  `RISK_LEVEL_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(500) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT NULL,
  `UPDATE_TIMESTAMP` timestamp NULL DEFAULT NULL,
  `UPDATED_BY` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`RISK_LEVEL_CODE`)
) ;



