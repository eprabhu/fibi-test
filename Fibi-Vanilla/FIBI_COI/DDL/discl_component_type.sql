

--
--  `discl_component_type`
--

DROP TABLE IF EXISTS `discl_component_type`;

CREATE TABLE `discl_component_type` (
  `COMPONENT_TYPE_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`COMPONENT_TYPE_CODE`)
) ;



