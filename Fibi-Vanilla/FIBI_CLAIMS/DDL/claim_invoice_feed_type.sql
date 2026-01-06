

--
--  `claim_invoice_feed_type`
--

DROP TABLE IF EXISTS `claim_invoice_feed_type`;

CREATE TABLE `claim_invoice_feed_type` (
  `TYPE_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(100) NOT NULL,
  `IS_ACTIVE` varchar(1) NOT NULL,
  `UPDATE_USER` varchar(60) NOT NULL,
  `UPDATE_TIMESTAMP` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`TYPE_CODE`)
);

