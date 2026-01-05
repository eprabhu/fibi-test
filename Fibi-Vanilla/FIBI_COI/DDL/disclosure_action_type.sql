

--
--  `disclosure_action_type`
--

DROP TABLE IF EXISTS `disclosure_action_type`;

CREATE TABLE `disclosure_action_type` (
  `ACTION_TYPE_CODE` varchar(3) NOT NULL,
  `MESSAGE` varchar(200) DEFAULT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`ACTION_TYPE_CODE`)
) ;



