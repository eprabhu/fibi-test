DROP TABLE IF EXISTS `award_expense_temp`;

CREATE TABLE `award_expense_temp` (
  `EXP_RT_ID` int(11) NOT NULL,
  `EXP_TRX_ID` int(11) DEFAULT NULL,
  `FILE_ID` int(11) DEFAULT NULL,
  `AWARD_NUMBER` varchar(12) DEFAULT NULL,
  `ACCOUNT_NUMBER` varchar(16) DEFAULT NULL,
  PRIMARY KEY (`EXP_RT_ID`)
) ;
