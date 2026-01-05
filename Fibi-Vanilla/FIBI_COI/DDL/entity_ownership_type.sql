

--
--  `entity_ownership_type`
--

DROP TABLE IF EXISTS `entity_ownership_type`;

CREATE TABLE `entity_ownership_type` (
  `OWNERSHIP_TYPE_CODE` varchar(10) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT 'Y',
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATED_BY` varchar(40) DEFAULT NULL,
  PRIMARY KEY (`OWNERSHIP_TYPE_CODE`)
) ;



