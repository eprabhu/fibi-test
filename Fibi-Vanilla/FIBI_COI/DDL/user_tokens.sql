

--
--  `user_tokens`
--

DROP TABLE IF EXISTS `user_tokens`;

CREATE TABLE `user_tokens` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `USER_NAME` varchar(255) DEFAULT NULL,
  `PASSWORD` varchar(255) DEFAULT NULL,
  `ACCESS_TOKEN` text,
  `SALT` varchar(255) DEFAULT NULL,
  `UPDATE_TIMESTAMP` timestamp NULL DEFAULT NULL,
  `PERSON_ID` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ;



