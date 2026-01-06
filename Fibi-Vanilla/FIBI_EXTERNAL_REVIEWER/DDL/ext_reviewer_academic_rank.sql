DROP TABLE IF EXISTS `ext_reviewer_academic_rank`;

CREATE TABLE `ext_reviewer_academic_rank` (
  `ACADEMIC_RANK_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`ACADEMIC_RANK_CODE`)
);

