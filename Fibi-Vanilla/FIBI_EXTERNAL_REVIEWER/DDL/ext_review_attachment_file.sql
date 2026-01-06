
DROP TABLE IF EXISTS `ext_review_attachment_file`;

CREATE TABLE `ext_review_attachment_file` (
  `FILE_DATA_ID` varchar(40) NOT NULL,
  `ATTACHMENT` longblob NOT NULL,
  PRIMARY KEY (`FILE_DATA_ID`)
);

