DROP TABLE IF EXISTS `negotiation_comment_file_data`;

CREATE TABLE `negotiation_comment_file_data` (
  `ID` varchar(36) NOT NULL,
  `DATA` longblob,
  PRIMARY KEY (`ID`)
) ;
