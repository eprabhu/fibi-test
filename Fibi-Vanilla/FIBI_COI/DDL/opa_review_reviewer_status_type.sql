

--
--  `opa_review_reviewer_status_type`
--

DROP TABLE IF EXISTS `opa_review_reviewer_status_type`;

CREATE TABLE `opa_review_reviewer_status_type` (
  `REVIEW_STATUS_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT 'Y',
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  `SORT_ORDER` int(11) DEFAULT NULL,
  PRIMARY KEY (`REVIEW_STATUS_CODE`)
) ;



