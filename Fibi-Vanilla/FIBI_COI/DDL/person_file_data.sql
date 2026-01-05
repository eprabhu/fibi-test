

--
--  `person_file_data`
--

DROP TABLE IF EXISTS `person_file_data`;

CREATE TABLE `person_file_data` (
  `FILE_DATA_ID` varchar(100) NOT NULL,
  `MODULE_CODE` varchar(3) DEFAULT NULL,
  `SUB_MODULE_CODE` varchar(3) DEFAULT NULL,
  `FILE_PATH` varchar(255) DEFAULT NULL,
  `ORIGINAL_FILE_NAME` varchar(500) DEFAULT NULL,
  `FILE_NAME` varchar(200) DEFAULT NULL,
  `DATA` longblob,
  `IS_ARCHIVED` char(1) DEFAULT NULL,
  `FILE` longblob,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`FILE_DATA_ID`)
) ;



