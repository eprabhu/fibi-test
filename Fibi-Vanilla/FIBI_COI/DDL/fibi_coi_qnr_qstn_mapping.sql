

--
--  `fibi_coi_qnr_qstn_mapping`
--

DROP TABLE IF EXISTS `fibi_coi_qnr_qstn_mapping`;

CREATE TABLE `fibi_coi_qnr_qstn_mapping` (
  `ID` smallint(6) NOT NULL AUTO_INCREMENT,
  `QNR_MAPPING_ID` smallint(6) DEFAULT NULL,
  `SOURCE_QSTN_ID` mediumint(9) NOT NULL,
  `SOURCE_QSTN_NUM` mediumint(9) NOT NULL,
  `SOURCE_QSTN_DATA_TYPE` varchar(30) DEFAULT NULL,
  `FIBI_QSTN_ID` mediumint(9) NOT NULL,
  `FIBI_QSTN_NUM` mediumint(9) NOT NULL,
  `FIBI_QSTN_DATA_TYPE` varchar(30) DEFAULT NULL,
  `UPDATED_BY` varchar(60) NOT NULL,
  `UPDATE_TIMESTAMP` datetime NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `FIBI_COI_QNR_QSTN_MAPPING_FK1` (`QNR_MAPPING_ID`),
  CONSTRAINT `FIBI_COI_QNR_QSTN_MAPPING_FK1` FOREIGN KEY (`QNR_MAPPING_ID`) REFERENCES `fibi_coi_qnr_mapping` (`QNR_MAPPING_ID`)
) ;



