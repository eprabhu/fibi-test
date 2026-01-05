

--
--  `entity_address_type`
--

DROP TABLE IF EXISTS `entity_address_type`;

CREATE TABLE `entity_address_type` (
  `ADDRESS_TYPE_CODE` varchar(10) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT 'Y',
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATED_BY` varchar(40) DEFAULT NULL,
  PRIMARY KEY (`ADDRESS_TYPE_CODE`)
) ;



