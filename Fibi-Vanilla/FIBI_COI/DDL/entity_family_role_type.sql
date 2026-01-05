

--
--  `entity_family_role_type`
--

DROP TABLE IF EXISTS `entity_family_role_type`;

CREATE TABLE `entity_family_role_type` (
  `FAMILY_ROLE_TYPE_CODE` varchar(10) NOT NULL,
  `DESCRIPTION` varchar(500) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT NULL,
  `UPDATE_TIMESTAMP` timestamp NULL DEFAULT NULL,
  `UPDATED_BY` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`FAMILY_ROLE_TYPE_CODE`)
) ;



