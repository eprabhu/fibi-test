

--
--  `citi_training_feed_details`
--

DROP TABLE IF EXISTS `citi_training_feed_details`;

CREATE TABLE `citi_training_feed_details` (
  `FEED_DETAIL_ID` int(11) NOT NULL AUTO_INCREMENT,
  `CURRICULUM_GRADEBOOK` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `GROUP` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `STAGE` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `STAGE_NUMBER` int(11) DEFAULT NULL,
  `CR_NUMBER` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `DATE_COMPLETED` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `EXPIRATION_DATE` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `LEARNER_ID` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `FIRST_NAME` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `LAST_NAME` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `USERNAME` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `EMAIL` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `CUSTOM_FIELD_1` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `CUSTOM_FIELD_2` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `MODULE` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `EXAM_ID` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `EXAM_SCORE` int(11) DEFAULT NULL,
  `PASSING_SCORE` int(11) DEFAULT NULL,
  `MODULE_COMPLETION_DATE` varchar(200) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT '',
  `UPDATE_TIMESTAMP` datetime DEFAULT NULL,
  PRIMARY KEY (`FEED_DETAIL_ID`)
) ;



