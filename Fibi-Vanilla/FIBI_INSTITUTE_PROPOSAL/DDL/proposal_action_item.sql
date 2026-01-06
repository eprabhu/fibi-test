
DROP TABLE IF EXISTS `proposal_action_item`;

CREATE TABLE `proposal_action_item` (
  `ACTION_ITEM_ID` varchar(6) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`ACTION_ITEM_ID`)
);