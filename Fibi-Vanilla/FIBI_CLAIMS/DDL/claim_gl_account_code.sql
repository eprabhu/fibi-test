

--
--  `claim_gl_account_code`
--

DROP TABLE IF EXISTS `claim_gl_account_code`;

CREATE TABLE `claim_gl_account_code` (
  `GL_ACCOUNT_CODE` varchar(50) NOT NULL,
  `DESCRIPTION` varchar(200) NOT NULL,
  `IS_CONTROLLED_GL` varchar(1) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT 'Y',
  `UPDATE_TIMESTAMP` datetime NOT NULL,
  `UPDATE_USER` varchar(60) NOT NULL,
  PRIMARY KEY (`GL_ACCOUNT_CODE`)
);

