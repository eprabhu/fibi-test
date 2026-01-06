
DROP TABLE IF EXISTS `form_section_component_type`;

CREATE TABLE `form_section_component_type` (
  `COMPONENT_TYPE_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) NOT NULL,
  `IS_ACTIVE` varchar(1) NOT NULL,
  `UPDATE_TIMESTAMP` datetime NOT NULL,
  `UPDATE_USER` varchar(60) NOT NULL,
  `SORT_ORDER` int(11) NOT NULL,
  PRIMARY KEY (`COMPONENT_TYPE_CODE`)
) ;