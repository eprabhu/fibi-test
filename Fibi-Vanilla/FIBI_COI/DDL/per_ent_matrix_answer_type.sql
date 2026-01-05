

--
--  `per_ent_matrix_answer_type`
--

DROP TABLE IF EXISTS `per_ent_matrix_answer_type`;

CREATE TABLE `per_ent_matrix_answer_type` (
  `ANSWER_TYPE_CODE` int(11) NOT NULL AUTO_INCREMENT,
  `DESCRIPTION` varchar(20) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  `UPDATED_BY` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`ANSWER_TYPE_CODE`)
) ;



