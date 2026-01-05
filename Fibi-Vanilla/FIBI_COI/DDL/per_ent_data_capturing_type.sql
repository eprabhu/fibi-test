

--
--  `per_ent_data_capturing_type`
--

DROP TABLE IF EXISTS `per_ent_data_capturing_type`;

CREATE TABLE `per_ent_data_capturing_type` (
  `DATA_CAPTURING_TYPE_CODE` int(11) NOT NULL AUTO_INCREMENT,
  `DESCRIPTION` varchar(500) DEFAULT NULL,
  `IS_ACTIVE` char(1) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATED_BY` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`DATA_CAPTURING_TYPE_CODE`)
) ;



