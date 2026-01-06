

--
--  `temp_user`
--

DROP TABLE IF EXISTS `temp_user`;

CREATE TABLE `temp_user` (
  `ID` int(11) NOT NULL,
  `CREATED_USER_NAME` varchar(255) DEFAULT NULL,
  `IS_FO_USER` varchar(255) DEFAULT NULL,
  `UNIT_NUMBER` varchar(255) DEFAULT NULL,
  `USER_NAME` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ID`)
);

