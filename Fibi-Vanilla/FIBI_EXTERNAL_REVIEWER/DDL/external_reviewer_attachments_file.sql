

DROP TABLE IF EXISTS `external_reviewer_attachments_file`;

CREATE TABLE `external_reviewer_attachments_file` (
  `ID` varchar(40) NOT NULL,
  `DATA` longblob,
  PRIMARY KEY (`ID`)
);

