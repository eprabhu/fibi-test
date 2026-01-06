

--
--  `task_status`
--

DROP TABLE IF EXISTS `task_status`;

CREATE TABLE `task_status` (
  `TASK_STATUS_CODE` varchar(255) NOT NULL,
  `DESCRIPTION` varchar(255) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime(6) DEFAULT NULL,
  `UPDATE_USER` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`TASK_STATUS_CODE`)
);

