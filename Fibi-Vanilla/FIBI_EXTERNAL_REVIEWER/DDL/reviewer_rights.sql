

--
--  `reviewer_rights`
--

DROP TABLE IF EXISTS `reviewer_rights`;

CREATE TABLE `reviewer_rights` (
  `REVIEWER_RIGHTS_ID` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`REVIEWER_RIGHTS_ID`)
);

