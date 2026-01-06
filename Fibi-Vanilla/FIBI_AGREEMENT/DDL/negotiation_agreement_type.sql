DROP TABLE IF EXISTS `negotiation_agreement_type`;

CREATE TABLE `negotiation_agreement_type` (
  `AGREEMENT_TYPE_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT 'Y',
  PRIMARY KEY (`AGREEMENT_TYPE_CODE`)
) ;
