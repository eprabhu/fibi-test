

--
--  `travel_form_builder_details`
--

DROP TABLE IF EXISTS `travel_form_builder_details`;

CREATE TABLE `travel_form_builder_details` (
  `TRAVEL_FORM_BUILDER_DETAILS_ID` int(11) NOT NULL AUTO_INCREMENT,
  `TRAVEL_DISCLOSURE_ID` int(11) NOT NULL,
  `TRAVEL_NUMBER` int(11) NOT NULL,
  `PERSON_ID` varchar(40) NOT NULL,
  `FORM_BUILDER_ID` int(11) NOT NULL,
  `IS_PRIMARY_FORM` varchar(1) NOT NULL,
  `UPDATE_TIMESTAMP` datetime NOT NULL,
  `UPDATED_BY` varchar(40) NOT NULL,
  PRIMARY KEY (`TRAVEL_FORM_BUILDER_DETAILS_ID`)
) ;



