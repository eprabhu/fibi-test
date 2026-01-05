

--
--  `entity_section`
--

DROP TABLE IF EXISTS `entity_section`;

CREATE TABLE `entity_section` (
  `ENTITY_SECTION_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(500) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT NULL,
  `UPDATE_TIMESTAMP` timestamp NULL DEFAULT NULL,
  `UPDATED_BY` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`ENTITY_SECTION_CODE`)
) ;



