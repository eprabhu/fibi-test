

--
--  `entity_relationship_type`
--

DROP TABLE IF EXISTS `entity_relationship_type`;

CREATE TABLE `entity_relationship_type` (
  `ENTITY_REL_TYPE_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`ENTITY_REL_TYPE_CODE`)
) ;



