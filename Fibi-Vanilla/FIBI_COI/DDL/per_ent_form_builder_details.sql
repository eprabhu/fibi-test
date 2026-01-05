

--
--  `per_ent_form_builder_details`
--

DROP TABLE IF EXISTS `per_ent_form_builder_details`;

CREATE TABLE `per_ent_form_builder_details` (
  `PER_ENT_FB_DETAILS_ID` int(11) NOT NULL AUTO_INCREMENT,
  `PERSON_ENTITY_ID` int(11) NOT NULL,
  `PERSON_ENTITY_NUMBER` int(11) NOT NULL,
  `PERSON_ID` varchar(40) NOT NULL,
  `FORM_BUILDER_ID` int(11) NOT NULL,
  `IS_PRIMARY_FORM` varchar(1) NOT NULL,
  `UPDATE_TIMESTAMP` datetime NOT NULL,
  `UPDATED_BY` varchar(40) NOT NULL,
  PRIMARY KEY (`PER_ENT_FB_DETAILS_ID`)
) ;



