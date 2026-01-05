

--
--  `entity_risk_type`
--

DROP TABLE IF EXISTS `entity_risk_type`;

CREATE TABLE `entity_risk_type` (
  `RISK_TYPE_CODE` varchar(10) NOT NULL,
  `RISK_CATEGORY_CODE` varchar(3) DEFAULT NULL,
  `DESCRIPTION` varchar(500) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT NULL,
  `UPDATE_TIMESTAMP` timestamp NULL DEFAULT NULL,
  `UPDATED_BY` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`RISK_TYPE_CODE`)
) ;



