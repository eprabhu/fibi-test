
DROP TABLE IF EXISTS `special_term_quest_report_dataset`;

CREATE TABLE `special_term_quest_report_dataset` (
  `QUEST_REPORT_DATASET_ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `AGREEMENT_ID` int(11) DEFAULT NULL,
  `RESEARCH_TITLE` varchar(1000) DEFAULT NULL,
  `START_DATE` datetime DEFAULT NULL,
  `END_DATE` datetime DEFAULT NULL,
  `AGREEMENT_TYPE` varchar(200) DEFAULT NULL,
  `AGREEMENT_CATEGORY` varchar(200) DEFAULT NULL,
  `PI` varchar(90) DEFAULT NULL,
  `SPONSOR` varchar(255) DEFAULT NULL,
  `LEAD_UNIT` varchar(255) DEFAULT NULL,
  `ADMINISTRATOR` varchar(90) DEFAULT NULL,
  `ADMIN_GROUP` varchar(40) DEFAULT NULL,
  `STATUS` varchar(200) DEFAULT NULL,
  `SUBMISSION_DATE` datetime DEFAULT NULL,
  `REQUESTOR` varchar(90) DEFAULT NULL,
  `Q_6874` longtext,
  `Q_6875` longtext,
  `Q_6876` longtext,
  `Q_6878` longtext,
  `Q_6879` longtext,
  `Q_6880` longtext,
  `Q_6881` longtext,
  `Q_6882` longtext,
  PRIMARY KEY (`QUEST_REPORT_DATASET_ID`)
) ;