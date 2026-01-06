DROP TABLE IF EXISTS `eps_proposal_key_personnel_attach_type`;

CREATE TABLE `eps_proposal_key_personnel_attach_type` (
  `ATTACHMNT_TYPE_CODE` int(11) NOT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATE_USER` varchar(60) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT 'Y',
  `IS_PRIVATE` varchar(1) DEFAULT 'N',
  PRIMARY KEY (`ATTACHMNT_TYPE_CODE`)
) ;
