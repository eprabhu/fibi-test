

--
--  `coi_project_comment_type`
--

DROP TABLE IF EXISTS `coi_project_comment_type`;

CREATE TABLE `coi_project_comment_type` (
  `COMMENT_TYPE_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATED_BY` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`COMMENT_TYPE_CODE`)
) ;



