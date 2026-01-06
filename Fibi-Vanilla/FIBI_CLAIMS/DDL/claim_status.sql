

--
--  `claim_status`
--

DROP TABLE IF EXISTS `claim_status`;

CREATE TABLE `claim_status` (
  `CLAIM_STATUS_CODE` varchar(255) NOT NULL,
  `DESCRIPTION` varchar(255) DEFAULT NULL,
  `IS_ACTIVE` varchar(255) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime(6) DEFAULT NULL,
  `UPDATE_USER` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`CLAIM_STATUS_CODE`)
);

