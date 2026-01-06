DROP TABLE IF EXISTS `award_research_type`;

CREATE TABLE `award_research_type` (
  `RESRCH_TYPE_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT 'Y',
  PRIMARY KEY (`RESRCH_TYPE_CODE`)
) ;
