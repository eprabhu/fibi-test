

--
--  `message_alert_mapping`
--

DROP TABLE IF EXISTS `message_alert_mapping`;

CREATE TABLE `message_alert_mapping` (
  `MESSAGE_ALERT_MAPPING_ID` int(11) NOT NULL AUTO_INCREMENT,
  `MESSAGE_TYPE_CODE` varchar(50) NOT NULL,
  `ALERT_TYPE_CODE` varchar(1) NOT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT 'Y',
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  PRIMARY KEY (`MESSAGE_ALERT_MAPPING_ID`)
) ;



