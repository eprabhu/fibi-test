DROP TABLE IF EXISTS `eps_proposal_action_type`;

CREATE TABLE `eps_proposal_action_type` (
  `ACTION_TYPE_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT 'Y',
  `MESSAGE_TEMPLATE` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`ACTION_TYPE_CODE`)
) ;
