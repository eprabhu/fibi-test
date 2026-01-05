

--
--  `disclosureprojects`
--

DROP TABLE IF EXISTS `disclosureprojects`;

CREATE TABLE `disclosureprojects` (
  `PROJECT_ID` varchar(20) NOT NULL,
  `PROJECT_NUMBER` varchar(20) NOT NULL,
  `KEY_PERSON_ID` varchar(40) NOT NULL,
  `DISCLOSURE_STATUS` varchar(27) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `PROJECT_DISCLOSURE_REVIEW_STATUS` varchar(200) DEFAULT NULL
) ;



