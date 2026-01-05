

--
--  `opa_review_location_type`
--

DROP TABLE IF EXISTS `opa_review_location_type`;

CREATE TABLE `opa_review_location_type` (
  `LOCATION_TYPE_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT 'Y',
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`LOCATION_TYPE_CODE`)
) ;



