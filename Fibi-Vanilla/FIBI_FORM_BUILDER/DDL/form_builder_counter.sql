
DROP TABLE IF EXISTS `form_builder_counter`;

CREATE TABLE `form_builder_counter` (
  `COUNTER_NAME` varchar(255) NOT NULL,
  `COUNTER_VALUE` int(11) DEFAULT NULL,
  PRIMARY KEY (`COUNTER_NAME`)
) ;
