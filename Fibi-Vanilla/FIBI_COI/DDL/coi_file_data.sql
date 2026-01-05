

--
--  `coi_file_data`
--

DROP TABLE IF EXISTS `coi_file_data`;

CREATE TABLE `coi_file_data` (
  `FILE_DATA_ID` varchar(40) NOT NULL,
  `DATA` longblob,
  PRIMARY KEY (`FILE_DATA_ID`)
) ;



