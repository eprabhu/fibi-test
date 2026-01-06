

--
--  `claim_templates`
--

DROP TABLE IF EXISTS `claim_templates`;

CREATE TABLE `claim_templates` (
  `CLAIM_TEMPLATE_CODE` varchar(10) NOT NULL,
  `DESCRIPTION` varchar(300) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`CLAIM_TEMPLATE_CODE`)
);

