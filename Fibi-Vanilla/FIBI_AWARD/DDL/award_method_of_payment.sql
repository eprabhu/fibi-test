DROP TABLE IF EXISTS `award_method_of_payment`;

CREATE TABLE `award_method_of_payment` (
  `METHOD_OF_PAYMENT_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT 'Y',
  PRIMARY KEY (`METHOD_OF_PAYMENT_CODE`)
) ;
