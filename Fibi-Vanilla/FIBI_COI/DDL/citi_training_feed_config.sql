

--
--  `citi_training_feed_config`
--

DROP TABLE IF EXISTS `citi_training_feed_config`;

CREATE TABLE `citi_training_feed_config` (
  `CONFIGURATION_KEY` varchar(255) NOT NULL,
  `CONFIGURATION_VALUE` varchar(255) DEFAULT NULL,
  `DESCRIPTION` varchar(255) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATED_BY` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`CONFIGURATION_KEY`)
) ;



