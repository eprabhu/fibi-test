

--
--  `coi_sections_type`
--

DROP TABLE IF EXISTS `coi_sections_type`;

CREATE TABLE `coi_sections_type` (
  `COI_SECTIONS_TYPE_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT 'Y',
  PRIMARY KEY (`COI_SECTIONS_TYPE_CODE`)
) ;



