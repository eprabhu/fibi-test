

--
--  `fibi_coi_connect_dummy`
--

DROP TABLE IF EXISTS `fibi_coi_connect_dummy`;

CREATE TABLE `fibi_coi_connect_dummy` (
  `DUMMY_ID` int(11) NOT NULL AUTO_INCREMENT,
  `TYPE_CODE` varchar(3) DEFAULT NULL,
  `PROPOSAL_ID` int(11) DEFAULT NULL,
  `PERSON_ID` varchar(60) DEFAULT NULL,
  `UNIT_NUMBER` varchar(8) DEFAULT NULL,
  PRIMARY KEY (`DUMMY_ID`)
) ;



