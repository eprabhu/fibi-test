

--
--  `opa_form_builder_details`
--

DROP TABLE IF EXISTS `opa_form_builder_details`;

CREATE TABLE `opa_form_builder_details` (
  `OPA_FORM_BUILDER_DETAILS_ID` int(11) NOT NULL AUTO_INCREMENT,
  `OPA_DISCLOSURE_ID` int(11) NOT NULL,
  `OPA_DISCLOSURE_NUMBER` varchar(20) NOT NULL,
  `PERSON_ID` varchar(40) NOT NULL,
  `FORM_BUILDER_ID` int(11) NOT NULL,
  `IS_PRIMARY_FORM` varchar(1) NOT NULL,
  `UPDATE_TIMESTAMP` datetime NOT NULL,
  `UPDATE_USER` varchar(90) NOT NULL,
  PRIMARY KEY (`OPA_FORM_BUILDER_DETAILS_ID`)
) ;



