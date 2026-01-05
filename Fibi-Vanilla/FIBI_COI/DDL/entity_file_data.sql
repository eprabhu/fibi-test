

--
--  `entity_file_data`
--

DROP TABLE IF EXISTS `entity_file_data`;

CREATE TABLE `entity_file_data` (
  `FILE_DATA_ID` varchar(100) NOT NULL,
  `FILE_PATH` varchar(255) DEFAULT NULL,
  `ORIGINAL_FILE_NAME` varchar(500) DEFAULT NULL,
  `FILE_NAME` varchar(100) DEFAULT NULL,
  `IS_ARCHIVED` char(1) DEFAULT NULL,
  `FILE` longblob,
  `UPDATE_TIMESTAMP` timestamp NULL DEFAULT NULL,
  `UPDATED_BY` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`FILE_DATA_ID`)
) ;



