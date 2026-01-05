

--
--  `entity_organization_type`
--

DROP TABLE IF EXISTS `entity_organization_type`;

CREATE TABLE `entity_organization_type` (
  `ORGANIZATION_TYPE_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(500) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATED_BY` varchar(60) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT 'Y',
  PRIMARY KEY (`ORGANIZATION_TYPE_CODE`)
) ;



