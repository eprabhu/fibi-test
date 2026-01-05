

--
--  `coi_review_activity`
--

DROP TABLE IF EXISTS `coi_review_activity`;

CREATE TABLE `coi_review_activity` (
  `COI_REVIEW_ACTIVITY_ID` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(2000) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT 'Y',
  PRIMARY KEY (`COI_REVIEW_ACTIVITY_ID`)
) ;



