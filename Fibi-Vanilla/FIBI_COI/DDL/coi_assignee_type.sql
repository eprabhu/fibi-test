

--
--  `coi_assignee_type`
--

DROP TABLE IF EXISTS `coi_assignee_type`;

CREATE TABLE `coi_assignee_type` (
  `ASSIGNEE_TYPE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`ASSIGNEE_TYPE`)
) ;



