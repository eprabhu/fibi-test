DROP TABLE IF EXISTS `eps_proposal_document_status`;

CREATE TABLE `eps_proposal_document_status` (
  `DOCUMENT_STATUS_CODE` varchar(3) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`DOCUMENT_STATUS_CODE`)
) ;
