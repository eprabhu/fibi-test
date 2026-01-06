

--
--  `task_action_type`
--

DROP TABLE IF EXISTS `task_action_type`;

CREATE TABLE `task_action_type` (
  `ACTION_TYPE_CODE` varchar(255) NOT NULL,
  `DESCRIPTION` varchar(255) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime(6) DEFAULT NULL,
  `UPDATE_USER` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ACTION_TYPE_CODE`)
);

