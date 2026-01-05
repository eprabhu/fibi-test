

--
--  `coi_risk_category_type`
--

DROP TABLE IF EXISTS `coi_risk_category_type`;

CREATE TABLE `coi_risk_category_type` (
  `RISK_CATEGORY_TYPE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT 'Y',
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`RISK_CATEGORY_TYPE`)
) ;



