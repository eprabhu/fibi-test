DROP TABLE IF EXISTS `eps_prop_discipline_cluster`;

CREATE TABLE `eps_prop_discipline_cluster` (
  `CLUSTER_CODE` int(11) NOT NULL,
  `DESCRIPTION` varchar(255) DEFAULT NULL,
  `UPDATE_TIMESTAMP` datetime(6) DEFAULT NULL,
  `UPDATE_USER` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`CLUSTER_CODE`)
);
