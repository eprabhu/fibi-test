
DROP TABLE IF EXISTS `grantcall_action_type`;

CREATE TABLE `grantcall_action_type` (
  `ACTION_TYPE_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(255) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime(6) DEFAULT NULL,
  `UPDATE_USER` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ACTION_TYPE_CODE`)
) ;
