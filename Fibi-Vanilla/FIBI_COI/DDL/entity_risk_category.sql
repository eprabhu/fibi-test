

--
--  `entity_risk_category`
--

DROP TABLE IF EXISTS `entity_risk_category`;

CREATE TABLE `entity_risk_category` (
  `RISK_CATEGORY_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(45) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT 'Y',
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  `SORT_ORDER` int(11) DEFAULT NULL,
  PRIMARY KEY (`RISK_CATEGORY_CODE`)
) ;



