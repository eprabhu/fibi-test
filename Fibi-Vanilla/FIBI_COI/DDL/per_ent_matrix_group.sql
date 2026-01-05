

--
--  `per_ent_matrix_group`
--

DROP TABLE IF EXISTS `per_ent_matrix_group`;

CREATE TABLE `per_ent_matrix_group` (
  `GROUP_ID` int(11) NOT NULL AUTO_INCREMENT,
  `GROUP_NAME` varchar(500) NOT NULL,
  `SORT_ID` int(11) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATED_BY` varchar(60) NOT NULL,
  PRIMARY KEY (`GROUP_ID`)
) ;



