

--
--  `task_file_data`
--

DROP TABLE IF EXISTS `task_file_data`;

CREATE TABLE `task_file_data` (
  `FILE_DATA_ID` varchar(255) NOT NULL,
  `DATA` longblob,
  `MODULE_CODE` varchar(3) DEFAULT NULL,
  `SUB_MODULE_CODE` varchar(3) DEFAULT NULL,
  `FILE_PATH` varchar(255) DEFAULT NULL,
  `FILE_NAME` varchar(100) DEFAULT NULL,
  `ORIGINAL_FILE_NAME` varchar(500) DEFAULT NULL,
  `IS_ARCHIVED` varchar(1) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime(6) DEFAULT NULL,
  `UPDATE_USER` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`FILE_DATA_ID`)
);

