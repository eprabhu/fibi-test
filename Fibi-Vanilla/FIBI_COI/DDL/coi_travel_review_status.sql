

--
--  `coi_travel_review_status`
--

DROP TABLE IF EXISTS `coi_travel_review_status`;

CREATE TABLE `coi_travel_review_status` (
  `REVIEW_STATUS_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  KEY `IDX_REVIEW_STATUS_CODE` (`REVIEW_STATUS_CODE`),
  PRIMARY KEY (`REVIEW_STATUS_CODE`)
) ;



