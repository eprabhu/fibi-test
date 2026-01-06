DROP TABLE IF EXISTS `loa_template_type`;

CREATE TABLE `loa_template_type` (
  `TYPE_CODE` int NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `PROCEDURE_NAME` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`TYPE_CODE`)
) ;
