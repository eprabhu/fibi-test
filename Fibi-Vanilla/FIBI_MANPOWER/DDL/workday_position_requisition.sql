DROP TABLE IF EXISTS `workday_position_requisition`;

CREATE TABLE `workday_position_requisition` (
  `POSITION_ID` varchar(50) NOT NULL,
  `JOB_REQUISITION_STATUS` varchar(20) DEFAULT NULL,
  `PERSON_ID` varchar(40) DEFAULT NULL,
  `JOB_REQUISITION_ID` varchar(40) DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  PRIMARY KEY (`POSITION_ID`)
) ;
