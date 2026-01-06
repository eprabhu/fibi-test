DROP TABLE IF EXISTS `agreement_sponsor_contct_type`;

CREATE TABLE `agreement_sponsor_contct_type` (
  `SPONSOR_CONTCT_TYPE_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT 'Y',
  PRIMARY KEY (`SPONSOR_CONTCT_TYPE_CODE`)
) ;