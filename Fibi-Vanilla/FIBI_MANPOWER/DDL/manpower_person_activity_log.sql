
DROP TABLE IF EXISTS `manpower_person_activity_log`;

CREATE TABLE `manpower_person_activity_log` (
  `PERSON_ID` varchar(40) NOT NULL,
  `PERSON_STATUS_CHANGE_DATE` datetime DEFAULT NULL,
  `FULL_NAME` varchar(90) DEFAULT NULL,
  `PERSON_STATUS` varchar(3) DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  PRIMARY KEY (`PERSON_ID`)
) ;
