

--
--  `opa_student_subordinate_involvement`
--

DROP TABLE IF EXISTS `opa_student_subordinate_involvement`;

CREATE TABLE `opa_student_subordinate_involvement` (
  `OPA_STUD_SUB_INV_ID` int(11) NOT NULL AUTO_INCREMENT,
  `OPA_DISCLOSURE_ID` int(11) DEFAULT NULL,
  `OPA_PERSON_TYPE_CODE` varchar(3) DEFAULT NULL,
  `PERSON_ID` varchar(40) DEFAULT NULL,
  `NATURE_OF_WORK` varchar(4000) DEFAULT NULL,
  `DESCRIPTION_1` varchar(4000) DEFAULT NULL,
  `DESCRIPTION_2` varchar(4000) DEFAULT NULL,
  `OPA_DISCL_PERSON_ENTITY_ID` int(11) DEFAULT NULL,
  `RELATIONSHIP` varchar(4000) DEFAULT NULL,
  `NUM_OF_DAYS` decimal(5,2) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`OPA_STUD_SUB_INV_ID`)
) ;



