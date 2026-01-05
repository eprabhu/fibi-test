

--
--  `fibi_coi_qnr_mapping`
--

DROP TABLE IF EXISTS `fibi_coi_qnr_mapping`;

CREATE TABLE `fibi_coi_qnr_mapping` (
  `QNR_MAPPING_ID` smallint(6) NOT NULL AUTO_INCREMENT,
  `SOURCE_QNR_ID` mediumint(9) NOT NULL,
  `SOURCE_QNR_NUM` mediumint(9) NOT NULL,
  `FIBI_QNR_ID` mediumint(9) NOT NULL,
  `FIBI_QNR_NUM` mediumint(9) NOT NULL,
  `UPDATED_BY` varchar(60) NOT NULL,
  `UPDATE_TIMESTAMP` datetime NOT NULL,
  PRIMARY KEY (`QNR_MAPPING_ID`)
) ;



