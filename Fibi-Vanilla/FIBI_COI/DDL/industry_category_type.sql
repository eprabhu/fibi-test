

--
--  `industry_category_type`
--

DROP TABLE IF EXISTS `industry_category_type`;

CREATE TABLE `industry_category_type` (
  `INDUSTRY_CATEGORY_TYPE_CODE` varchar(10) NOT NULL,
  `IS_PRIMARY` varchar(1) DEFAULT NULL,
  `DESCRIPTION` varchar(500) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT NULL,
  `UPDATE_TIMESTAMP` timestamp NULL DEFAULT NULL,
  `UPDATED_BY` varchar(60) DEFAULT NULL,
  `SOURCE` varchar(1) DEFAULT NULL,
  PRIMARY KEY (`INDUSTRY_CATEGORY_TYPE_CODE`)
) ;



