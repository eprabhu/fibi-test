

--
--  `discl_atta_status`
--

DROP TABLE IF EXISTS `discl_atta_status`;

CREATE TABLE `discl_atta_status` (
  `ATTA_STATUS_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`ATTA_STATUS_CODE`)
) ;



