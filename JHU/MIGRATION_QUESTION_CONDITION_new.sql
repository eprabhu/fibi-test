DELIMITER $$
CREATE  PROCEDURE `MIGRATION_QUESTION_CONDITION_new`(DATA_REFRESH_FLAG INT)
BEGIN
DECLARE LI_STG_QUESTION_ID INT;
DECLARE LI_QUESTIONNAIRE_ID INT;
DECLARE LI_QUESTIONNAIRE_VERSION_NUMBER INT;
DECLARE LI_MIGRATED_QUESTIONNAIRE_ID INT;
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
declare LI_PARENT_OF_CURRENT_QTN int;
DECLARE LS_QUESTION_NUMBER INT;
DECLARE LS_CONDITION_FLAG VARCHAR(1);
DECLARE LS_CONDITION_VALUE VARCHAR(2000);
DECLARE LS_CONDITION VARCHAR(50);
DECLARE LS_CONDITION_VALUE_COEUS VARCHAR(2000);
DECLARE LS_CONDITION_COEUS VARCHAR(50);
DECLARE LI_SORT_ORDER INT;
DECLARE LS_QUESTION VARCHAR(2000);
DECLARE LI_MAX_ANSWERS tinyint;
DECLARE LS_GROUP_NAME varchar(10);
DECLARE L_group_of_child varchar(10);
DECLARE LS_GROUP_NAME_EXIST varchar(10);
DECLARE LS_CHILD_GROUP_NAME varchar(10);
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
DECLARE LS_VALIDATION_STATUS varchar(10);
DECLARE LI_HIERARCHICAL_PARENT INT;
DECLARE LI_BATCH_ID INT;
DECLARE LI_TOTAL_PROCESSED_DATA_COUNT INT DEFAULT 0;
DECLARE LI_TOTAL_DATA_COUNT INT DEFAULT 0;
DECLARE LI_CONDITION_COUNT INT;
DECLARE LI_ADD_CONDITION INT;
DECLARE LI_RULE_ID INT;
declare li_group_qtn_id int;
declare li_group_qtnr_id int;
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
				VALUES  (IFNULL(LI_STG_QUEST_QTN_ID,0),'QUEST_QUESTION_CONDITION','MIGRATION',CONCAT(LS_ERROR_MSG),UTC_TIMESTAMP(),'JHU_ADMIN');
		END;
BEGIN
	SELECT IFNULL(MAX(BATCH_ID),0)+1 INTO LI_BATCH_ID FROM migration_transtn_auditlog_header1 WHERE ACTION_TYPE = 'MIGRATION' AND MODULE_NAME = 'QUEST_QUESTION_CONDITION';
    INSERT INTO migration_transtn_auditlog_header1 ( BATCH_ID, ACTION_TYPE, MODULE_NAME,EXECUTION_TIME) VALUES (LI_BATCH_ID, 'MIGRATION', 'QUEST_QUESTION_CONDITION',   UTC_TIMESTAMP() );
	INSERT INTO migration_qtn_execution_log (EXECUTION_MESSAGE,EXECUTION_TIME) VALUES ('Started execution : Question condition',UTC_TIMESTAMP());
END;
BEGIN
DECLARE DONE_QUEST boolean DEFAULT FALSE;
DECLARE CUR_QUEST CURSOR FOR
							select
							  Distinct questionnaire_id,
							  VERSION_NUMBER,
							  MIGRATED_QUESTIONNAIRE_ID
							from
							  stage_questionnaire
							where
							  validation_status = 'SUCCESS'
							 and MIGRATED_QUESTIONNAIRE_ID in (3,4,5,6,7,10,12,14,16,17,18,19,20,21,22,23,24,25,26,27,29,30,31,32,35,36,37,39,40,42,43,44,45,46,48)
							Order by
							  questionnaire_id, VERSION_NUMBER;
DECLARE CONTINUE HANDLER FOR NOT FOUND
SET
  DONE_QUEST = TRUE;
OPEN CUR_QUEST;
QUEST_LOOP : LOOP
FETCH CUR_QUEST INTO LI_QUESTIONNAIRE_ID,
					LI_QUESTIONNAIRE_VERSION_NUMBER,
					LI_MIGRATED_QUESTIONNAIRE_ID;
IF DONE_QUEST THEN
	LEAVE QUEST_LOOP;
END IF;
BEGIN
DECLARE DONE1 INT DEFAULT FALSE;
DECLARE CUR_quest_questions CURSOR FOR
				select distinct sqq.PARENT_QUESTION_NUMBER
						, sqq.CONDITION_FLAG
						, sqq.CONDITION
						, sqq.CONDITION_VALUE
                        , sqq.UPDATE_TIMESTAMP
						,sqq.UPDATE_USER
				from stage_quest_questions sqq
				where sqq.QUESTIONNAIRE_ID = LI_QUESTIONNAIRE_ID
				and sqq.questionnaire_version_number = LI_QUESTIONNAIRE_VERSION_NUMBER
				 and sqq.VALIDATION_STATUS in( 'VALID', 'SUCCESS')
                 and ((sqq.`CONDITION_FLAG` = 'Y' and sqq.CONDITION is not null) or ( sqq.rule_id is not null and  sqq.rule_id != 0))
                 and sqq.PARENT_QUESTION_NUMBER != 0
                 order by QUESTION_NUMBER;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE1 = TRUE;
OPEN CUR_quest_questions;
QUEST_QUESTION_LOOP: LOOP
FETCH CUR_quest_questions INTO  LI_PARENT_QUESTION_NUMBER
											, LS_CONDITION_FLAG
											, LS_CONDITION
											, LS_CONDITION_VALUE
                                            , LS_UPDATE_TIMESTAMP
											,LS_UPDATE_USER;
IF DONE1 THEN
	LEAVE QUEST_QUESTION_LOOP;
END IF;
SET LI_TOTAL_PROCESSED_DATA_COUNT = LI_TOTAL_PROCESSED_DATA_COUNT + 1;
					INSERT INTO migration_transtn_auditlog_details1 (ACTION_TYPE,MODULE_NAME,BATCH_ID,MESSAGE,EXECUTION_TIME,PARENT_NUMBER)
							VALUES ('MIGRATION','QUEST_QUESTION_CONDITION',LI_BATCH_ID,'Migration started : Question condition',UTC_TIMESTAMP(),LI_QUESTION_ID);
  set LS_CONDITION_VALUE_COEUS =   LS_CONDITION_VALUE;
set  LS_CONDITION_COEUS  =  LS_CONDITION;
set  LS_CONDITION  = CASE LS_CONDITION WHEN 'GREATER THAN' THEN 'GREATERTHAN' WHEN 'LESS THAN' THEN 'LESSTHAN' WHEN 'EQUAL TO' THEN 'EQUALS' WHEN 'NOT EQUAL' THEN 'NOTEQUALS'
				WHEN 'ENDS WITH' THEN 'CONTAINS'
                ELSE LS_CONDITION end;
set  LS_CONDITION_VALUE  = CASE LS_CONDITION_VALUE WHEN 'Y' then 'Yes' when 'N' then 'No' else LS_CONDITION_VALUE end;
		IF (trim(LI_PARENT_QUESTION_NUMBER) is not null and LI_PARENT_QUESTION_NUMBER <> 0 )then
			SELECT COUNT(*) INTO LI_COUNT FROM
			stage_quest_questions WHERE QUESTION_NUMBER = LI_PARENT_QUESTION_NUMBER
			and QUESTIONNAIRE_ID = LI_QUESTIONNAIRE_ID
			and QUESTIONNAIRE_VERSION_NUMBER = LI_QUESTIONNAIRE_VERSION_NUMBER
            and VALIDATION_STATUS = 'SUCCESS';
				IF LI_COUNT <> 1 THEN
					INSERT INTO migration_questionnaire_errorlog
						(PARENT_ID,SOURCE_TYPE,ERROR_TYPE,ERROR_MESSAGE,UPDATE_TIMESTAMP,UPDATE_USER)
					VALUES  (IFNULL(LI_STG_QUEST_QTN_ID,0),'QUEST_QUESTION_CONDITION','MIGRATION',CONCAT('Invalid parent question id :  ', LI_PARENT_QUESTION_NUMBER, ' of Questionnaire_id : ', LI_QUESTIONNAIRE_ID, ' Questionnaire version number :',LI_QUESTIONNAIRE_VERSION_NUMBER),UTC_TIMESTAMP(),'JHU_ADMIN');
				UPDATE stage_quest_questions SET VALIDATION_STATUS = 'ERROR' where ID = LI_STG_QUEST_QTN_ID;
                ITERATE QUEST_QUESTION_LOOP;
				ELSE
					select QUESTION_ID, group_name, PARENT_QUESTION_ID
                    into  LI_MIGRATED_PARENT_QUESTION_ID, LS_GROUP_NAME, LI_PARENT_OF_CURRENT_QTN
					from quest_question where question_id in (
												select migrated_question_id
												from stage_quest_questions
												where question_NUMBER = LI_PARENT_QUESTION_NUMBER
												and QUESTIONNAIRE_ID = LI_QUESTIONNAIRE_ID
												and QUESTIONNAIRE_VERSION_NUMBER = LI_QUESTIONNAIRE_VERSION_NUMBER
												and VALIDATION_STATUS in('VALID', 'SUCCESS'));
            set LI_CONDITION_COUNT = -1;
					select count(1) into LI_CONDITION_COUNT from quest_question_condition
					where QUESTION_ID = LI_MIGRATED_PARENT_QUESTION_ID
					and CONDITION_TYPE = LS_CONDITION
					and CONDITION_VALUE =  LS_CONDITION_VALUE;
		IF ( LI_CONDITION_COUNT = 0) and (LS_CONDITION is not null) and (LS_CONDITION_VALUE is not null) then
				select IFNULL(MAX(QUESTION_CONDITION_ID),0)+1 INTO LI_MIGRATED_QUESTION_CONDITION_ID
				from quest_question_condition;
					select IFNULL((concat('G',max(cast(substr(GROUP_NAME,2) as signed)+1))),'G1') into LS_CHILD_GROUP_NAME from quest_question_condition
					where question_id in (select question_id from quest_question where questionnaire_id =  LI_MIGRATED_QUESTIONNAIRE_ID
					);
				INSERT INTO quest_question_condition(
											QUESTION_CONDITION_ID
											, QUESTION_ID
											, CONDITION_TYPE
											, CONDITION_VALUE
											, GROUP_NAME
											, UPDATE_TIMESTAMP
											, UPDATE_USER
									)VALUES(
											LI_MIGRATED_QUESTION_CONDITION_ID
											, LI_MIGRATED_PARENT_QUESTION_ID
											,  LS_CONDITION
                                            , LS_CONDITION_VALUE
											,  LS_CHILD_GROUP_NAME
											, date(LS_UPDATE_TIMESTAMP)
											, LS_UPDATE_USER
										);
            update quest_question set GROUP_NAME = LS_CHILD_GROUP_NAME
                     where QUESTION_ID in (select MIGRATED_QUESTION_ID from stage_quest_questions
											where QUESTIONNAIRE_ID = LI_QUESTIONNAIRE_ID
											and QUESTIONNAIRE_VERSION_NUMBER = LI_QUESTIONNAIRE_VERSION_NUMBER
											and `CONDITION` =  LS_CONDITION_COEUS
											 and CONDITION_VALUE = LS_CONDITION_VALUE_COEUS
											 and parent_question_number = LI_PARENT_QUESTION_NUMBER)
					and GROUP_NAME is null;
					set sql_safe_updates = 0;
                    update quest_question set HAS_CONDITION = 'Y'
                    where QUESTIONNAIRE_ID = LI_MIGRATED_QUESTIONNAIRE_ID
                    and QUESTION_ID in(select question_id from quest_question_condition ) ;
               END IF;
				END IF;
			END IF;
			IF LI_TOTAL_PROCESSED_DATA_COUNT < LI_TOTAL_DATA_COUNT THEN
					IF LI_TOTAL_PROCESSED_DATA_COUNT = 10000 THEN
						INSERT INTO migration_qtn_execution_log (EXECUTION_MESSAGE,EXECUTION_TIME)
						VALUES (CONCAT('Migrated ',LI_TOTAL_PROCESSED_DATA_COUNT,' records of Questionnaire Questions'),UTC_TIMESTAMP());
						SET LI_TOTAL_PROCESSED_DATA_COUNT = 0;
					END IF;
				END IF ;
				INSERT INTO migration_transtn_auditlog_details1 (ACTION_TYPE,MODULE_NAME,BATCH_ID,MESSAGE,EXECUTION_TIME,PARENT_NUMBER)
													VALUES ('MIGRATION','QUEST_QUESTION_CONDITION',LI_BATCH_ID,'Completed execution ',UTC_TIMESTAMP(),LI_QUESTION_ID);
				set LI_STG_QUESTION_ID = NULL;
				set LI_MIGRATED_QUESTION_ID = NULL;
				set LI_MIGRATED_QUESTION_NUMBER = NULL;
				set LI_QUESTION_VERSION_NUMBER = NULL;
				set LI_SORT_ORDER = NULL;
				set LI_QUESTION_ID = NULL;
				set LS_DESCRIPTION = NULL;
				set LI_MIGRATED_PARENT_QUESTION_ID = NULL;
				set LS_ANSWER_DATA_TYPE = NULL;
				set LI_ANSWER_MAX_LENGTH = NULL;
				set LI_MAX_ANSWERS = NULL;
				set LS_LOOKUP_GUI = NULL;
				set LS_LOOKUP_NAME = NULL;
				set LS_GROUP_NAME = NULL;
                set LS_CHILD_GROUP_NAME = NULL;
                set LS_CONDITION = NULL;
                set LS_CONDITION_VALUE = NULL;
				set LS_CONDITION_FLAG = NULL;
				set LS_QUESTION = NULL;
				set LI_DESCRIPTION_COUNT = NULL;
                set LS_CONDITION_COEUS = null;
                set LS_CONDITION_VALUE_COEUS = null;
                     update quest_question set GROUP_NAME = 'G0'
                    where QUESTIONNAIRE_ID = LI_MIGRATED_QUESTIONNAIRE_ID
					 and SORT_ORDER = 1;
	END LOOP;
	CLOSE CUR_quest_questions;
	set LI_QUESTIONNAIRE_ID = NULL;
	set LI_QUESTIONNAIRE_VERSION_NUMBER = NULL;
	INSERT INTO migration_transtn_auditlog_details1 (ACTION_TYPE,MODULE_NAME,BATCH_ID,MESSAGE,EXECUTION_TIME,PARENT_NUMBER) VALUES ('MIGRATION','QUEST_QUESTION_CONDITION',LI_BATCH_ID,'Exit cursor',UTC_TIMESTAMP(),NULL);
			INSERT INTO migration_qtn_execution_log (EXECUTION_MESSAGE,EXECUTION_TIME)
					VALUES('Migration completed successfully',UTC_TIMESTAMP());
           update quest_column_nextvalue set QUESTION_CONDITION_ID =  (select IFNULL(MAX(QUESTION_CONDITION_ID),0)+1 from quest_question_condition );
END;
END LOOP;
CLOSE CUR_QUEST;
END;
Begin
DECLARE li_null_group_name varchar(10);
DECLARE DONE_GROUP boolean DEFAULT FALSE;
DECLARE cur_null_group cursor for
select question_id, questionnaire_id from quest_question where
 questionnaire_id in (select migrated_questionnaire_id from stage_questionnaire where validation_status = 'SUCCESS')
 and group_name is  null
 and PARENT_QUESTION_ID is not  null
order by questionnaire_id,question_id ;
DECLARE CONTINUE HANDLER FOR NOT FOUND
SET
  DONE_group = TRUE;
OPEN CUR_null_group;
group_LOOP : LOOP
FETCH CUR_null_group INTO li_group_qtn_id,
					li_group_qtnr_id;
IF DONE_GROUP THEN
	LEAVE group_LOOP;
END IF;
	set li_null_group_name = NULL;
    select group_name into li_null_group_name from quest_question
    where question_id = (
    select parent_question_id from quest_question where question_id = li_group_qtn_id
    and questionnaire_id = li_group_qtnr_id);
   update quest_question set group_name = li_null_group_name
    where question_id =  li_group_qtn_id
    and questionnaire_id = li_group_qtnr_id;
END LOOP;
CLOSE CUR_null_group;
END;
END
$$
DELIMITER ;
