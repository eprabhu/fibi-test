DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `MIGRATION_QUESTION_OPTION`(LI_QUESTIONNAIRE_ID INt,LI_QUESTIONNAIRE_VERSION_NUMBER INT, LI_MIGRATED_QUESTIONNAIRE_ID INT,	AV_QUESTION_NUMBER INT)
BEGIN
DECLARE LI_STG_QUESTION_ID INT;
DECLARE LI_MIGRATED_QUESTIONNAIRE_NUMBER INT;
DECLARE LI_MIGRATED_QUESTION_ID INT;
DECLARE LI_MIGRATED_PARENT_QUESTION_ID INT;
DECLARE LI_MIGRATED_QUESTION_NUMBER	INT;
DECLARE LI_MIGRATED_QUESTION_CONDITION_ID INT;
DECLARE LI_MIGRATED_QUESTION_OPTION_ID INT;
DECLARE LI_STG_QUEST_QTN_ID INT;
DECLARE LI_QUESTION_ID INT;
DECLARE LI_QUESTION_NUMBER INT;
DECLARE LI_QUESTION_VERSION_NUMBER INT;
DECLARE LI_PARENT_QUESTION_NUMBER INT;
DECLARE LS_QUESTION_NUMBER INT;
DECLARE LI_SORT_ORDER INT;
DECLARE LS_QUESTION VARCHAR(2000);
DECLARE LI_MAX_ANSWERS tinyint;
DECLARE LS_GROUP_NAME varchar(10);
DECLARE LS_VALID_ANSWER varchar(20);
DECLARE LS_LOOKUP_NAME varchar(50);
DECLARE LS_ANSWER_DATA_TYPE varchar(30);
DECLARE LI_ANSWER_MAX_LENGTH smallint;
DECLARE LS_LOOKUP_GUI varchar(50);
DECLARE LI_DESCRIPTION_COUNT INT;
DECLARE LS_DESCRIPTION longtext;
DECLARE LS_ERROR_MSG VARCHAR(4000);
DECLARE LI_COUNT INT;
DECLARE LI_quest_count INT;
DECLARE LI_migrated_count INT;
DECLARE LS_DATA_ERROR_FLAG VARCHAR(1);
DECLARE LS_VALIDATION_STATUS varchar(10);
DECLARE LI_HIERARCHICAL_PARENT INT;
DECLARE LI_BATCH_ID INT;
DECLARE LI_TOTAL_PROCESSED_DATA_COUNT INT DEFAULT 0;
DECLARE LI_TOTAL_DATA_COUNT INT DEFAULT 0;
DECLARE LI_CONDITION_COUNT INT;
DECLARE LI_RULE_ID INT;
DECLARE LS_UPDATE_USER VARCHAR(60);
DECLARE LS_UPDATE_TIMESTAMP DATETIME;
		DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
		BEGIN
			GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
			 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
			SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
			SELECT @full_error INTO LS_ERROR_MSG;
			INSERT INTO migration_questionnaire_errorlog
						(PARENT_ID,SOURCE_TYPE,ERROR_TYPE,ERROR_MESSAGE,UPDATE_TIMESTAMP,UPDATE_USER)
				VALUES  (IFNULL(LI_STG_QUEST_QTN_ID,0),'QUEST_QUESTION_OPTION','MIGRATION',CONCAT(LS_ERROR_MSG),UTC_TIMESTAMP(),'JHU_ADMIN');
		END;
BEGIN
	INSERT INTO migration_qtn_execution_log (EXECUTION_MESSAGE,EXECUTION_TIME) VALUES ('Started execution : Question Options',UTC_TIMESTAMP());
END;
PROC_LABEL: BEGIN
				select sqq.ID
						, sqq.QUESTION_ID
                        , sqq.QUESTION_NUMBER
						, sqq.QUESTION_VERSION_NUMBER
						, sqq.PARENT_QUESTION_NUMBER
                        , sqq.RULE_ID
                        ,  UPDATE_USER
						, UPDATE_TIMESTAMP
                        INTO LI_STG_QUEST_QTN_ID
											, LI_QUESTION_ID
                                            , LI_QUESTION_NUMBER
											, LI_QUESTION_VERSION_NUMBER
											, LI_PARENT_QUESTION_NUMBER
                                            , LI_RULE_ID
                                            , LS_UPDATE_USER
											, LS_UPDATE_TIMESTAMP
				from stage_quest_questions sqq
				where sqq.QUESTIONNAIRE_ID = LI_QUESTIONNAIRE_ID
				and sqq.questionnaire_version_number = LI_QUESTIONNAIRE_VERSION_NUMBER
				 and sqq.VALIDATION_STATUS = 'VALID'
				and  sqq.QUESTION_NUMBER = AV_QUESTION_NUMBER;
SET LI_TOTAL_PROCESSED_DATA_COUNT = LI_TOTAL_PROCESSED_DATA_COUNT + 1;
					INSERT INTO migration_transtn_auditlog_details1 (ACTION_TYPE,MODULE_NAME,BATCH_ID,MESSAGE,EXECUTION_TIME,PARENT_NUMBER)
							VALUES ('MIGRATION','QUEST_QUESTION_OPTION',LI_BATCH_ID,'Migration started : Question tables',UTC_TIMESTAMP(),LI_QUESTION_ID);
					SET LS_DATA_ERROR_FLAG = 'N';
		select count(*) into LI_quest_count from stage_questions where question_id =  LI_QUESTION_ID and version_number = LI_QUESTION_VERSION_NUMBER;
        IF LI_quest_count = 1 THEN
				select  ID
						, QUESTION
						, MAX_ANSWERS
						, VALID_ANSWER
						, LOOKUP_NAME
						, ANSWER_MAX_LENGTH
						, LOOKUP_GUI
                        into  LI_STG_QUESTION_ID
											, LS_QUESTION
											, LI_MAX_ANSWERS
											, LS_VALID_ANSWER
											, LS_LOOKUP_NAME
											, LI_ANSWER_MAX_LENGTH
											, LS_LOOKUP_GUI
				from stage_questions
                where question_id =  LI_QUESTION_ID and version_number = LI_QUESTION_VERSION_NUMBER;
ELSE
	INSERT INTO migration_questionnaire_errorlog
						(PARENT_ID,SOURCE_TYPE,ERROR_TYPE,ERROR_MESSAGE,UPDATE_TIMESTAMP,UPDATE_USER)
					VALUES  (IFNULL(LI_STG_QUEST_QTN_ID,0),'QUEST_QUESTION_OPTION','MIGRATION',CONCAT('Invalid quesiton - question id :  ', LI_QUESTION_ID,' version_number : ' ,LI_QUESTION_VERSION_NUMBER ),UTC_TIMESTAMP(),'JHU_ADMIN');
END IF;
          select count(*)  into   LI_DESCRIPTION_COUNT
          from stage_question_explanation where QUESTION_ID = LI_QUESTION_ID;
          IF LI_DESCRIPTION_COUNT = 1 then
			select cast(trim(EXPLANATION) as char) into LS_DESCRIPTION from stage_question_explanation where QUESTION_ID = LI_QUESTION_ID;
          ELSE
			set LS_DESCRIPTION = NULL;
          END IF;
		IF (trim(LI_PARENT_QUESTION_NUMBER) is not null and LI_PARENT_QUESTION_NUMBER <> 0 )then
			SELECT COUNT(*) INTO LI_COUNT FROM
			stage_quest_questions WHERE QUESTION_NUMBER = LI_PARENT_QUESTION_NUMBER
			and QUESTIONNAIRE_ID = LI_QUESTIONNAIRE_ID
			and QUESTIONNAIRE_VERSION_NUMBER = LI_QUESTIONNAIRE_VERSION_NUMBER
            and VALIDATION_STATUS = 'SUCCESS';
				IF LI_COUNT <> 1 THEN
					INSERT INTO migration_questionnaire_errorlog
						(PARENT_ID,SOURCE_TYPE,ERROR_TYPE,ERROR_MESSAGE,UPDATE_TIMESTAMP,UPDATE_USER)
					VALUES  (IFNULL(LI_STG_QUEST_QTN_ID,0),'QUEST_QUESTION_OPTION','MIGRATION',CONCAT('Invalid parent question id :  ', LI_PARENT_QUESTION_NUMBER, ' of Questionnaire_id : ', LI_QUESTIONNAIRE_ID, ' Questionnaire version number :',LI_QUESTIONNAIRE_VERSION_NUMBER),UTC_TIMESTAMP(),'JHU_ADMIN');
					SET LS_DATA_ERROR_FLAG = 'Y';
					SET LI_MIGRATED_PARENT_QUESTION_ID = NULL;
				ELSE
					select QUESTION_ID
                    into  LI_MIGRATED_PARENT_QUESTION_ID
					from quest_question where question_id in (
												select migrated_question_id
												from stage_quest_questions
												where question_NUMBER = LI_PARENT_QUESTION_NUMBER
												and QUESTIONNAIRE_ID = LI_QUESTIONNAIRE_ID
												and QUESTIONNAIRE_VERSION_NUMBER = LI_QUESTIONNAIRE_VERSION_NUMBER
												and VALIDATION_STATUS = 'SUCCESS');
                END IF;
        ELSEIF LI_PARENT_QUESTION_NUMBER =  0  THEN
          set LS_GROUP_NAME = 'G0';
		END IF;
		IF LS_DATA_ERROR_FLAG = 'Y' THEN
				UPDATE stage_quest_questions SET VALIDATION_STATUS = 'ERROR', MIGRATED_QUESTION_ID = -1, MIGRATED_QUESTION_NUMBER = -1 where ID = LI_STG_QUEST_QTN_ID;
                leave PROC_LABEL;
		ELSE
        IF LS_LOOKUP_GUI is not NULL THEN
			IF LS_LOOKUP_GUI = 'ROLODEXSEARCH' THEN
				set LS_VALID_ANSWER = 'elastic';
                set LS_LOOKUP_NAME = 'fibirolodex';
                set LS_LOOKUP_GUI = 'rolodexName';
			ELSEIF LS_LOOKUP_GUI = 'ORGANIZATIONSEARCH' THEN
				set LS_VALID_ANSWER = 'endpoint';
                set LS_LOOKUP_NAME = 'fibiOrganization';
                set LS_LOOKUP_GUI = 'organizationName';
			ELSEIF LS_LOOKUP_GUI = 'CODETABLE' THEN
				set LS_VALID_ANSWER = 'endpoint';
                set LS_LOOKUP_NAME = 'fibiCountry';
                set LS_LOOKUP_GUI = 'countryCode';
			 END IF;
		END IF;
		IF LS_LOOKUP_NAME != 'fibirolodex' and LS_LOOKUP_NAME != 'fibiOrganization' and LS_LOOKUP_NAME != 'fibiCountry' THEN
				set LS_LOOKUP_NAME = concat('ARG_VALUE_LOOKUP#',LS_LOOKUP_NAME);
                set LS_VALID_ANSWER = 'UserLookup';
                set LS_LOOKUP_GUI = NULL;
		END IF;
            select MIGRATED_QUESTION_NUMBER into LI_MIGRATED_QUESTION_NUMBER from stage_quest_questions where ID = LI_STG_QUEST_QTN_ID;
            IF LI_MIGRATED_QUESTION_NUMBER is null or LI_MIGRATED_QUESTION_NUMBER = -1 then
				select IFNULL(MAX(QUESTION_NUMBER),0)+1 into  LI_MIGRATED_QUESTION_NUMBER FROM quest_question;
            END IF ;
			select IFNULL(MAX(QUESTION_ID),0)+1 into  LI_MIGRATED_QUESTION_ID FROM quest_question;
            select ifnull(max(SORT_ORDER),0)+1 into LI_SORT_ORDER from quest_question
            where questionnaire_id = LI_MIGRATED_QUESTIONNAIRE_ID;
			INSERT INTO quest_question(
										QUESTION_ID
										,QUESTION_NUMBER
										,QUESTION_VERSION_NUMBER
										,QUESTIONNAIRE_ID
										,SORT_ORDER
										,QUESTION
										,DESCRIPTION
										,PARENT_QUESTION_ID
										,HELP_LINK
										,ANSWER_TYPE
										,ANSWER_LENGTH
										,NO_OF_ANSWERS
										,LOOKUP_TYPE
										 ,LOOKUP_NAME
										,LOOKUP_FIELD
										,GROUP_NAME
										,GROUP_LABEL
										,RULE_ID
										,UPDATE_TIMESTAMP
										,UPDATE_USER
								)VALUES(
										LI_MIGRATED_QUESTION_ID
										,LI_MIGRATED_QUESTION_NUMBER
										,LI_QUESTION_VERSION_NUMBER
										,LI_MIGRATED_QUESTIONNAIRE_ID
										,LI_SORT_ORDER
										,LS_QUESTION
										,LS_DESCRIPTION
										,LI_MIGRATED_PARENT_QUESTION_ID
										,NULL
										,CASE UPPER(LS_VALID_ANSWER) WHEN 'YNX' then 'Y/N/NA' WHEN 'YN' THEN 'Y/N' WHEN 'TEXT' THEN 'Text' WHEN 'SEARCH' THEN 'elastic' else LS_VALID_ANSWER end
										,LI_ANSWER_MAX_LENGTH
										,LI_MAX_ANSWERS
										,LS_LOOKUP_NAME
										, LS_LOOKUP_GUI
										,NULL
										,LS_GROUP_NAME
										,NULL
										,LI_RULE_ID
										,date(LS_UPDATE_TIMESTAMP)
										,LS_UPDATE_USER
									);
		set sql_safe_updates = 0;
       Update stage_quest_questions SET  MIGRATED_QUESTION_NUMBER = LI_MIGRATED_QUESTION_NUMBER
         where  QUESTIONNAIRE_ID = LI_QUESTIONNAIRE_ID
        and QUESTION_NUMBER = LI_QUESTION_NUMBER
        and QUESTION_VERSION_NUMBER = LI_QUESTION_VERSION_NUMBER
		and MIGRATED_QUESTION_NUMBER is null;
			UPDATE stage_quest_questions SET VALIDATION_STATUS = 'SUCCESS'
			, MIGRATED_QUESTION_ID = LI_MIGRATED_QUESTION_ID, MIGRATED_QUESTION_NUMBER = LI_MIGRATED_QUESTION_NUMBER where ID =  LI_STG_QUEST_QTN_ID;
			select IFNULL(MAX(QUESTION_OPTION_ID),0)+1 INTO LI_MIGRATED_QUESTION_OPTION_ID
			from quest_question_option;
				IF LS_VALID_ANSWER = 'YNX' then
						INSERT INTO	quest_question_option(
												QUESTION_OPTION_ID
												, QUESTION_ID
												, OPTION_NUMBER
												, OPTION_LABEL
												, REQUIRE_EXPLANATION
												, EXPLANTION_LABEL
												, UPDATE_TIMESTAMP
												, UPDATE_USER
										)values(
												LI_MIGRATED_QUESTION_OPTION_ID
												, LI_MIGRATED_QUESTION_ID
												, 1
												, 'Yes'
												, NULL
												, NULL
												, date(LS_UPDATE_TIMESTAMP)
												,LS_UPDATE_USER
											);
						INSERT INTO	quest_question_option(
												QUESTION_OPTION_ID
												, QUESTION_ID
												, OPTION_NUMBER
												, OPTION_LABEL
												, REQUIRE_EXPLANATION
												, EXPLANTION_LABEL
												, UPDATE_TIMESTAMP
												, UPDATE_USER
										)values(
												LI_MIGRATED_QUESTION_OPTION_ID+1
												, LI_MIGRATED_QUESTION_ID
												, 2
												, 'No'
												, NULL
												, NULL
												, date(LS_UPDATE_TIMESTAMP)
												,LS_UPDATE_USER
											);
						INSERT INTO	quest_question_option(
												QUESTION_OPTION_ID
												, QUESTION_ID
												, OPTION_NUMBER
												, OPTION_LABEL
												, REQUIRE_EXPLANATION
												, EXPLANTION_LABEL
												, UPDATE_TIMESTAMP
												, UPDATE_USER
										)values(
												LI_MIGRATED_QUESTION_OPTION_ID+2
												, LI_MIGRATED_QUESTION_ID
												, 3
												, 'None'
												, NULL
												, NULL
												, date(LS_UPDATE_TIMESTAMP)
												,LS_UPDATE_USER
											);
					ELSEIF  LS_VALID_ANSWER = 'YN' THEN
						INSERT INTO	quest_question_option(
												QUESTION_OPTION_ID
												, QUESTION_ID
												, OPTION_NUMBER
												, OPTION_LABEL
												, REQUIRE_EXPLANATION
												, EXPLANTION_LABEL
												, UPDATE_TIMESTAMP
												, UPDATE_USER
										)values(
												LI_MIGRATED_QUESTION_OPTION_ID
												, LI_MIGRATED_QUESTION_ID
												, 1
												, 'Yes'
												, NULL
												, NULL
												, date(LS_UPDATE_TIMESTAMP)
												,LS_UPDATE_USER
											);
						INSERT INTO	quest_question_option(
												QUESTION_OPTION_ID
												, QUESTION_ID
												, OPTION_NUMBER
												, OPTION_LABEL
												, REQUIRE_EXPLANATION
												, EXPLANTION_LABEL
												, UPDATE_TIMESTAMP
												, UPDATE_USER
										)values(
												LI_MIGRATED_QUESTION_OPTION_ID+1
												, LI_MIGRATED_QUESTION_ID
												, 2
												, 'No'
												, NULL
												, NULL
												, date(LS_UPDATE_TIMESTAMP)
												,LS_UPDATE_USER
											);
			END IF;
			IF LI_TOTAL_PROCESSED_DATA_COUNT < LI_TOTAL_DATA_COUNT THEN
					IF LI_TOTAL_PROCESSED_DATA_COUNT = 10000 THEN
						INSERT INTO migration_qtn_execution_log (EXECUTION_MESSAGE,EXECUTION_TIME)
						VALUES (CONCAT('Migrated ',LI_TOTAL_PROCESSED_DATA_COUNT,' records of Questionnaire Questions'),UTC_TIMESTAMP());
						SET LI_TOTAL_PROCESSED_DATA_COUNT = 0;
					END IF;
				END IF ;
				INSERT INTO migration_transtn_auditlog_details1 (ACTION_TYPE,MODULE_NAME,BATCH_ID,MESSAGE,EXECUTION_TIME,PARENT_NUMBER)
													VALUES ('MIGRATION','QUEST_QUESTION_OPTION',LI_BATCH_ID,'Completed execution ',UTC_TIMESTAMP(),LI_QUESTION_ID);
				set LI_STG_QUESTION_ID = NULL;
				set LI_MIGRATED_QUESTION_ID = NULL;
				set LI_MIGRATED_QUESTION_NUMBER = NULL;
				set LI_QUESTION_VERSION_NUMBER = NULL;
				set LI_SORT_ORDER = NULL;
				set LI_QUESTION_ID = NULL;
				set LS_DESCRIPTION = NULL;
				set LI_MIGRATED_PARENT_QUESTION_ID = NULL;
				set LI_ANSWER_MAX_LENGTH = NULL;
				set LI_MAX_ANSWERS = NULL;
				set LS_LOOKUP_GUI = NULL;
				set LS_LOOKUP_NAME = NULL;
				set LS_GROUP_NAME = NULL;
				set LS_QUESTION = NULL;
				set LI_DESCRIPTION_COUNT = NULL;
				set LI_RULE_ID = NULL;
	set LI_MIGRATED_QUESTIONNAIRE_ID = NULL;
	set LI_QUESTIONNAIRE_ID = NULL;
	set LI_QUESTIONNAIRE_VERSION_NUMBER = NULL;
	INSERT INTO migration_transtn_auditlog_details1 (ACTION_TYPE,MODULE_NAME,BATCH_ID,MESSAGE,EXECUTION_TIME,PARENT_NUMBER) VALUES ('MIGRATION','QUEST_QUESTION_OPTION',LI_BATCH_ID,'Exit cursor',UTC_TIMESTAMP(),NULL);
			INSERT INTO migration_qtn_execution_log (EXECUTION_MESSAGE,EXECUTION_TIME)
					VALUES
                    ('Migration completed successfully',UTC_TIMESTAMP());
					set sql_safe_updates = 0;
         update quest_column_nextvalue set
                          QUESTION_OPTION_ID = (select IFNULL(MAX(QUESTION_OPTION_ID),0)+1 from quest_question_option )
						 , QUESTION_ID =   (select IFNULL(MAX(QUESTION_ID),0)+1 from quest_question )
						 , QUESTION_NUMBER =  (select IFNULL(MAX(QUESTION_NUMBER),0)+1 from quest_question );
		END IF;
END;
END
$$
DELIMITER ;
