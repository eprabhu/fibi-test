

--
--  `coi_int_stage_proposal_person_copy`
--

DROP TABLE IF EXISTS `coi_int_stage_proposal_person_copy`;

CREATE TABLE `coi_int_stage_proposal_person_copy` (
  `PROJECT_NUMBER` varchar(12) NOT NULL,
  `KEY_PERSON_ROLE_CODE` int(11) NOT NULL,
  `KEY_PERSON_ROLE_NAME` varchar(25) NOT NULL,
  `KEY_PERSON_ID` varchar(40) NOT NULL,
  `KEY_PERSON_NAME` varchar(90) DEFAULT NULL,
  `PERCENT_OF_EFFORT` decimal(5,2) DEFAULT NULL,
  `ATTRIBUTE_1_LABEL` varchar(255) DEFAULT NULL,
  `ATTRIBUTE_1_VALUE` varchar(255) DEFAULT NULL,
  `ATTRIBUTE_2_LABEL` varchar(255) DEFAULT NULL,
  `ATTRIBUTE_2_VALUE` varchar(255) DEFAULT NULL,
  `ATTRIBUTE_3_LABEL` varchar(255) DEFAULT NULL,
  `ATTRIBUTE_3_VALUE` varchar(255) DEFAULT NULL,
  KEY `idx_key_person_id` (`KEY_PERSON_ID`),
  KEY `idx_project_number` (`PROJECT_NUMBER`)
) ;



