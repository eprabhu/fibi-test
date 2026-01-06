DROP TABLE IF EXISTS `cost_element_job_profile_mapping`;

CREATE TABLE `cost_element_job_profile_mapping` (
  `COST_JOB_MAPPING_ID` varchar(10) NOT NULL,
  `COST_ELEMENT` varchar(50) DEFAULT NULL,
  `JOB_PROFILE_CODE` varchar(30) DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  PRIMARY KEY (`COST_JOB_MAPPING_ID`)
) ;
