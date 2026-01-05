

--
--  `attachment_number_counter`
--

DROP TABLE IF EXISTS `attachment_number_counter`;

CREATE TABLE `attachment_number_counter` (
  `counter_name` varchar(255) NOT NULL,
  `counter_value` int(11) DEFAULT NULL,
  PRIMARY KEY (`counter_name`)
) ;



