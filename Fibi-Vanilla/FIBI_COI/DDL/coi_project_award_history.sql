

--
--  `coi_project_award_history`
--

DROP TABLE IF EXISTS `coi_project_award_history`;

CREATE TABLE `coi_project_award_history` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `AWARD_NUMBER` varchar(12) NOT NULL,
  `MESSAGE` varchar(500) DEFAULT NULL,
  `COMMENT` varchar(500) DEFAULT NULL,
  `UPDATED_BY` varchar(60) NOT NULL,
  `UPDATE_TIMESTAMP` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ;



