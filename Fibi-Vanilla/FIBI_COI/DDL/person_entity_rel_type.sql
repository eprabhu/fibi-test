

--
--  `person_entity_rel_type`
--

DROP TABLE IF EXISTS `person_entity_rel_type`;

CREATE TABLE `person_entity_rel_type` (
  `RELATIONSHIP_TYPE_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`RELATIONSHIP_TYPE_CODE`)
) ;



