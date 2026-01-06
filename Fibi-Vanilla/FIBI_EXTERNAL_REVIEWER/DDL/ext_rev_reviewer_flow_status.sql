

--
--  `ext_rev_reviewer_flow_status`
--

DROP TABLE IF EXISTS `ext_rev_reviewer_flow_status`;

CREATE TABLE `ext_rev_reviewer_flow_status` (
  `EXT_REV_REVIEWER_FLOW_STATUS_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`EXT_REV_REVIEWER_FLOW_STATUS_CODE`)
);

