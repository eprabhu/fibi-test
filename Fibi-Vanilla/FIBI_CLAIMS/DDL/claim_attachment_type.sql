

--
--  `claim_attachment_type`
--

DROP TABLE IF EXISTS `claim_attachment_type`;

CREATE TABLE `claim_attachment_type` (
  `TYPE_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(300) DEFAULT NULL,
  `UPDATE_TIMESTAMP` date DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT 'Y',
  `IS_PRIVATE` varchar(1) DEFAULT 'N',
  PRIMARY KEY (`TYPE_CODE`)
);

