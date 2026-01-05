

--
--  `krcr_parm_t`
--

DROP TABLE IF EXISTS `krcr_parm_t`;

CREATE TABLE `krcr_parm_t` (
  `NMSPC_CD` varchar(20) NOT NULL,
  `CMPNT_CD` varchar(100) NOT NULL,
  `PARM_NM` varchar(255) NOT NULL,
  `PARM_TYP_CD` varchar(5) DEFAULT NULL,
  `VAL` varchar(4000) DEFAULT NULL,
  `PARM_DESC_TXT` varchar(4000) DEFAULT NULL,
  `EVAL_OPRTR_CD` varchar(1) DEFAULT NULL,
  `APPL_ID` varchar(255) NOT NULL DEFAULT 'KUALI',
  `OBJ_ID` varchar(36) DEFAULT NULL,
  `VER_NBR` int(11) DEFAULT '1',
  PRIMARY KEY (`NMSPC_CD`,`CMPNT_CD`,`PARM_NM`,`APPL_ID`)
);

