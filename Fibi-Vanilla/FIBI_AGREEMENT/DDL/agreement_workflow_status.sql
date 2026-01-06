

--
--  `agreement_workflow_status`
--

DROP TABLE IF EXISTS `agreement_workflow_status`;

CREATE TABLE `agreement_workflow_status` (
  `WORKFLOW_STATUS_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(40) DEFAULT NULL,
  PRIMARY KEY (`WORKFLOW_STATUS_CODE`)
) ;



