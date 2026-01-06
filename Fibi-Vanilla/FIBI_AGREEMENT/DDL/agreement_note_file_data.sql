DROP TABLE IF EXISTS `agreement_note_file_data`;

CREATE TABLE `agreement_note_file_data` (
  `ID` varchar(36) NOT NULL,
  `DATA` longblob,
  PRIMARY KEY (`ID`)
) ;
