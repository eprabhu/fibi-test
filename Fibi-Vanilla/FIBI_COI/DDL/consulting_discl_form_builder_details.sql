

--
--  `consulting_discl_form_builder_details`
--

DROP TABLE IF EXISTS `consulting_discl_form_builder_details`;

CREATE TABLE `consulting_discl_form_builder_details` (
  `CONSULTING_DISCL_FORM_BUILDER_DETAILS_ID` int(11) NOT NULL AUTO_INCREMENT,
  `DISCLOSURE_ID` int(11) NOT NULL,
  `PERSON_ID` varchar(40) NOT NULL,
  `FORM_BUILDER_ID` int(11) NOT NULL,
  `FORM_BUILDER_NUMBER` varchar(20) DEFAULT NULL,
  `IS_PRIMARY_FORM` varchar(1) NOT NULL,
  `UPDATE_TIMESTAMP` datetime NOT NULL,
  `UPDATE_USER` varchar(60) NOT NULL,
  PRIMARY KEY (`CONSULTING_DISCL_FORM_BUILDER_DETAILS_ID`)
) ;



