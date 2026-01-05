

--
--  `citi_training_feed_exception`
--

DROP TABLE IF EXISTS `citi_training_feed_exception`;

CREATE TABLE `citi_training_feed_exception` (
  `FEED_EXCEPTION_ID` int(11) NOT NULL AUTO_INCREMENT,
  `ERROR_CODE` varchar(255) DEFAULT NULL,
  `ERROR_MESSAGE` varchar(255) DEFAULT NULL,
  `STACK_TRACE` blob,
  `ERROR_TYPE` varchar(255) DEFAULT NULL,
  `ERROR_AT` varchar(255) DEFAULT NULL,
  `FEED_INFO_ID` int(11) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATED_BY` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`FEED_EXCEPTION_ID`)
) ;



