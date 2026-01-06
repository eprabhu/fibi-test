
DROP TABLE IF EXISTS `manpower_candidate_title_type`;

CREATE TABLE `manpower_candidate_title_type` (
  `CANDIDATE_TITLE_TYPE_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  PRIMARY KEY (`CANDIDATE_TITLE_TYPE_CODE`)
) ;
