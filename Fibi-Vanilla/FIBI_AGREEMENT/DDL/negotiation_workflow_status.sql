DROP TABLE IF EXISTS `negotiation_workflow_status`;

CREATE TABLE `negotiation_workflow_status` (
  `WORKFLOW_STATUS_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`WORKFLOW_STATUS_CODE`)
) ;
