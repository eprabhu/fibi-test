

--
--  `entity_status`
--

DROP TABLE IF EXISTS `entity_status`;

CREATE TABLE `entity_status` (
  `ENTITY_STATUS_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT 'Y',
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`ENTITY_STATUS_CODE`)
) ;



