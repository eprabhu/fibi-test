

--
--  `claim_funding_scheme`
--

DROP TABLE IF EXISTS `claim_funding_scheme`;

CREATE TABLE `claim_funding_scheme` (
  `FUNDING_SCHEME_CODE` varchar(8) NOT NULL,
  `CERTIFICATION1` longtext,
  `CERTIFICATION2` longtext,
  `ENDORSEMENT` longtext,
  `IS_ACTIVE` varchar(1) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  `OVERRIDE_NEGATIVE_AMOUNT` varchar(1) DEFAULT NULL,
  PRIMARY KEY (`FUNDING_SCHEME_CODE`)
);

