DROP TABLE IF EXISTS `agreement_section_type`;

CREATE TABLE `agreement_section_type` (
  `SECTION_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(40) DEFAULT NULL,
  PRIMARY KEY (`SECTION_CODE`)
) ;
