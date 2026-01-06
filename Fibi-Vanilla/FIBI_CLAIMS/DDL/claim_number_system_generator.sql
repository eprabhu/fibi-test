DROP TABLE IF EXISTS `claim_number_system_generator`;

CREATE TABLE `claim_number_system_generator` (
  `next_val` bigint(20) NOT NULL,
  `FISCAL_YEAR` varchar(4) NOT NULL,
  PRIMARY KEY (`FISCAL_YEAR`)
);
