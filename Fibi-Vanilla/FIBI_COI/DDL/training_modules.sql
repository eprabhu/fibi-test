

--
--  `training_modules`
--

DROP TABLE IF EXISTS `training_modules`;

CREATE TABLE `training_modules` (
  `TRAINING_MODULES_ID` int(11) DEFAULT NULL,
  `TRAINING_CODE` int(11) DEFAULT NULL,
  `MODULE_CODE` int(11) NOT NULL,
  `SUB_MODULE_CODE` int(11) DEFAULT NULL,
  `DESCRIPTION` varchar(200) NOT NULL,
  `UPDATE_TIMESTAMP` datetime NOT NULL,
  `UPDATE_USER` varchar(60) NOT NULL
) ;



