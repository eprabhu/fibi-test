

--
--  `opa_status_type`
--

DROP TABLE IF EXISTS `opa_status_type`;

CREATE TABLE `opa_status_type` (
  `STATUS_TYPE_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`STATUS_TYPE_CODE`)
) ;



