DROP TABLE IF EXISTS `agreement_attachment_file`;

CREATE TABLE `agreement_attachment_file` (
  `AGREEMENT_ATTACHMENT_FILE_ID` varchar(36) NOT NULL,
  `FILEDATA` longblob,
  PRIMARY KEY (`AGREEMENT_ATTACHMENT_FILE_ID`)
);