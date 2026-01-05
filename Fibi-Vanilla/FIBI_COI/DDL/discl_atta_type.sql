

--
--  `discl_atta_type`
--

DROP TABLE IF EXISTS `discl_atta_type`;

CREATE TABLE `discl_atta_type` (
  `ATTA_TYPE_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`ATTA_TYPE_CODE`)
) ;



