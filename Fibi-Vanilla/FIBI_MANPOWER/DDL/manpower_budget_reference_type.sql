DROP TABLE IF EXISTS `manpower_budget_reference_type`;

CREATE TABLE `manpower_budget_reference_type` (
  `BUDGET_REFERENCE_TYPE_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT NULL,
  PRIMARY KEY (`BUDGET_REFERENCE_TYPE_CODE`)
) ;