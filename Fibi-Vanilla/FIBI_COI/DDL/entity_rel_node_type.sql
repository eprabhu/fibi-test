

--
--  `entity_rel_node_type`
--

DROP TABLE IF EXISTS `entity_rel_node_type`;

CREATE TABLE `entity_rel_node_type` (
  `REL_NODE_TYPE_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`REL_NODE_TYPE_CODE`)
) ;



