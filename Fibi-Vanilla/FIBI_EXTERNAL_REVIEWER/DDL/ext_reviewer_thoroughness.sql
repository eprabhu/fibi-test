

DROP TABLE IF EXISTS `ext_reviewer_thoroughness`;

CREATE TABLE `ext_reviewer_thoroughness` (
  `THOROUGHNESS_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`THOROUGHNESS_CODE`)
);

