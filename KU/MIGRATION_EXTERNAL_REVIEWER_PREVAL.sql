DELIMITER $$
CREATE PROCEDURE `MIGRATION_EXTERNAL_REVIEWER_PREVAL`(
av_id int
)
BEGIN
DECLARE LI_ID INT;
DECLARE LI_EXTERNAL_REVIEWER_ID INT;
DECLARE LI_EXTERNAL_REVIEWER_EXT_ID INT;
DECLARE LS_Academic_Rank varchar(500) DEFAULT NULL;
DECLARE LS_Reviewer_Name varchar(500) DEFAULT NULL;
DECLARE LS_First_Name	varchar(50) DEFAULT NULL;
DECLARE LS_Last_Name	varchar(50) DEFAULT NULL;
DECLARE LS_Passport_Name	varchar(500) DEFAULT NULL;
DECLARE LS_Gender	varchar(20) DEFAULT NULL;
DECLARE LS_Affiliated_Institution	varchar(500) DEFAULT NULL;
DECLARE LS_Department	varchar(500) DEFAULT NULL;
DECLARE LS_Top_200_Institution	varchar(5) DEFAULT NULL;
DECLARE LS_Work_Country	varchar(500) DEFAULT NULL;
DECLARE LS_Primary_Email	varchar(500) DEFAULT NULL;
DECLARE LS_Secondary_Email	varchar(500) DEFAULT NULL;
DECLARE LS_COI_With	varchar(50) DEFAULT NULL;
DECLARE LS_Disciplinary_Field	 varchar(500) DEFAULT NULL;
DECLARE LS_Specialism	Longtext DEFAULT NULL;
DECLARE LS_splitted_Specialism varchar(1000) DEFAULT NULL;
DECLARE LI_SPECIALIZATION_ID int;
DECLARE LS_Keyword_1 varchar(500) DEFAULT NULL;
DECLARE LS_Keyword_2	varchar(500) DEFAULT NULL;
DECLARE LS_Keyword_3	varchar(500) DEFAULT NULL;
DECLARE LS_Keyword_4	varchar(500) DEFAULT NULL;
DECLARE LS_Keyword_5	varchar(500) DEFAULT NULL;
DECLARE LS_Keyword_6	varchar(500) DEFAULT NULL;
DECLARE LS_Keyword_7	varchar(500) DEFAULT NULL;
DECLARE LS_Keyword_8	varchar(500) DEFAULT NULL;
DECLARE LS_Keyword_9	varchar(500) DEFAULT NULL;
DECLARE LS_Keyword_10	varchar(500) DEFAULT NULL;
DECLARE LS_Keyword_11	varchar(500) DEFAULT NULL;
DECLARE LS_SPLITTED_KEYWORD VARCHAR(500);
DECLARE LS_KEYWORD_LIST VARCHAR(500);
DECLARE LI_START_LENGTH int;
DECLARE LI_END_LENGTH int;
DECLARE LS_Academic_Area_1	varchar(500) DEFAULT NULL;
DECLARE LS_Academic_Area_2	varchar(500) DEFAULT NULL;
DECLARE LI_H_index	INT(5) DEFAULT NULL;
DECLARE LS_Scopus	varchar(500) DEFAULT NULL;
DECLARE LS_ERSA_Signed_YYYY_MON	varchar(500) DEFAULT NULL;
DECLARE LS_ERSA_EXP_Signed_YYYY_MON	varchar(500) DEFAULT NULL;
DECLARE LS_URL_to_profile 	varchar(500) DEFAULT NULL;
DECLARE LI_Supplier_DOF	INT(5) DEFAULT NULL;
DECLARE LS_CIRA_2021_Scoring_Trends	varchar(2000) DEFAULT NULL;
DECLARE LS_SPLITTED_CIRA varchar(500);
DECLARE LS_CIRA_LIST VARCHAR(500);
DECLARE LS_CIRA VARCHAR(500);
DECLARE LS_Originality	varchar(500) DEFAULT NULL;
DECLARE LS_Thoroughness	varchar(500) DEFAULT NULL;
DECLARE LS_Misc_Files varchar(500) DEFAULT NULL;
DECLARE LS_ERROR_FLAG VARCHAR(1) DEFAULT 'N';
DECLARE LS_ERROR_MSG varchar(1000);
DECLARE LI_COUNT INT;
BEGIN
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
	BEGIN
		GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
		 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
		SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
		SELECT @full_error INTO LS_ERROR_MSG;
		INSERT INTO MIGRATION_EXT_REVIEWER_ERROR_LOG ( STAGE_ID,ERROR_TYPE, FILE_NAME, ERROR_MESSAGE, VALIDATION_TYPE, UPDATE_TIMESTAMP, UPDATE_USER)
		VALUES(LI_ID,'EXCEPTION','EXTERNAL_REVIEWER',LS_ERROR_MSG,'PREVALIDATION',NOW(),'quickstart');
		COMMIT;
	END;
IF av_id = 1 THEN
set sql_safe_updates = 0;
	UPDATE stage_external_reviewer SET VALIDATION_STATUS = NULL where VALIDATION_STATUS = 'FAILED'  ;
    delete  from MIGRATION_EXT_REVIEWER_ERROR_LOG where FILE_NAME = 'EXTERNAL_REVIEWER';
END IF;
	BEGIN
		DECLARE DONE1 INT DEFAULT FALSE;
		DECLARE CUR_SEL_DATA CURSOR FOR
		SELECT ID,
				 Academic_Rank,
				 Reviewer_Name,
				 First_Name,
				 Last_Name,
				 Passport_Name,
				 Gender,
				 Affiliated_Institution,
				 Department,
				 Top_200_Institution,
				 Work_Country,
				 Primary_Email,
				 Secondary_Email,
				 COI_With,
				 Disciplinary_Field,
				 Specialism,
				 Keyword_1,
				 Keyword_2,
				 Keyword_3,
				 Keyword_4,
				 Keyword_5,
				 Keyword_6,
				 Keyword_7,
				 Keyword_8,
				 Keyword_9,
				 Keyword_10,
				 Keyword_11,
				 Academic_Area_1,
				 Academic_Area_2,
				 H_index,
				 Scopus,
				 ERSA_Signed_YYYY_MON,
				 ERSA_EXP_YYYY_MON,
				 URL_profile,
				 Supplier_DOF,
				 CIRA_2021_Scoring_Trends,
				 Originality,
				 Thoroughness
		FROM stage_external_reviewer
		 where validation_status is null;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE1 = TRUE;
		OPEN CUR_SEL_DATA;
		INSERT_LOOP: LOOP
		FETCH CUR_SEL_DATA INTO	LI_ID
								,LS_Academic_Rank
								,LS_Reviewer_Name
								,LS_First_Name
								,LS_Last_Name
								,LS_Passport_Name
								,LS_Gender
								,LS_Affiliated_Institution
								,LS_Department
								,LS_Top_200_Institution
								,LS_Work_Country
								,LS_Primary_Email
								,LS_Secondary_Email
								,LS_COI_With
								,LS_Disciplinary_Field
								,LS_Specialism
								,LS_Keyword_1
								,LS_Keyword_2
								,LS_Keyword_3
								,LS_Keyword_4
								,LS_Keyword_5
								,LS_Keyword_6
								,LS_Keyword_7
								,LS_Keyword_8
								,LS_Keyword_9
								,LS_Keyword_10
								,LS_Keyword_11
								,LS_Academic_Area_1
								,LS_Academic_Area_2
								,LI_H_index
								,LS_Scopus
								,LS_ERSA_Signed_YYYY_MON
								,LS_ERSA_EXP_Signed_YYYY_MON
								,LS_URL_to_profile
								,LI_Supplier_DOF
								,LS_CIRA_2021_Scoring_Trends
								,LS_Originality
								,LS_Thoroughness	;
		IF DONE1 THEN
			LEAVE INSERT_LOOP;
		END IF;
        set LS_ERROR_FLAG = 'N';
		SET LI_COUNT = NULL;
		IF LS_Academic_Rank IS NOT NULL THEN
			select count(*) into LI_COUNT from EXT_REVIEWER_ACADEMIC_RANK
			WHERE TRIM(UPPER(DESCRIPTION)) = TRIM(UPPER(LS_Academic_Rank)) ;
			IF LI_COUNT != 1 THEN
				INSERT INTO MIGRATION_EXT_REVIEWER_ERROR_LOG ( STAGE_ID,ERROR_TYPE, FILE_NAME, ERROR_MESSAGE, VALUE,VALIDATION_TYPE, UPDATE_TIMESTAMP, UPDATE_USER)
				VALUES(LI_ID,'EXCEPTION','EXTERNAL_REVIEWER','Invalid Academic Rank',trim(LS_Academic_Rank),'PREVALIDATION',NOW(),'quickstart');
				COMMIT;
				set LS_ERROR_FLAG = 'Y';
			END IF;
		END IF;
		SET LI_COUNT = NULL;
		IF LS_Academic_Area_1 IS NOT NULL THEN
			SELECT COUNT(*) INTO LI_COUNT FROM EXT_REVIEWER_ACADEMIC_AREA
			WHERE UPPER(TRIM(replace(DESCRIPTION,'\n',''))) = UPPER(TRIM(replace(LS_Academic_Area_1,'\n','')));
				IF LI_COUNT != 1 THEN
					INSERT INTO MIGRATION_EXT_REVIEWER_ERROR_LOG ( STAGE_ID,ERROR_TYPE, FILE_NAME, ERROR_MESSAGE, VALUE,VALIDATION_TYPE, UPDATE_TIMESTAMP, UPDATE_USER)
					VALUES(LI_ID,'EXCEPTION','EXTERNAL_REVIEWER','Invalid AcademicArea 1',trim(LS_Academic_Area_1),'PREVALIDATION',NOW(),'quickstart');
					COMMIT;
					set LS_ERROR_FLAG = 'Y';
				END IF;
		END IF;
		SET LI_COUNT = NULL;
		IF LS_FIRST_NAME IS NOT NULL THEN
			IF LENGTH(LS_FIRST_NAME) > 100 THEN
				INSERT INTO MIGRATION_EXT_REVIEWER_ERROR_LOG ( STAGE_ID,ERROR_TYPE, FILE_NAME, ERROR_MESSAGE, VALUE, VALIDATION_TYPE, UPDATE_TIMESTAMP, UPDATE_USER)
				VALUES(LI_ID,'EXCEPTION','EXTERNAL_REVIEWER','Invalid First name',LS_FIRST_NAME,'PREVALIDATION',NOW(),'quickstart');
				COMMIT;
				set LS_ERROR_FLAG = 'Y';
			END IF;
		END IF;
		SET LI_COUNT = NULL;
		IF LS_LAST_NAME IS NOT NULL THEN
			IF LENGTH(LS_Last_NAME) > 100 THEN
				INSERT INTO MIGRATION_EXT_REVIEWER_ERROR_LOG ( STAGE_ID,ERROR_TYPE, FILE_NAME, ERROR_MESSAGE,VALUE, VALIDATION_TYPE, UPDATE_TIMESTAMP, UPDATE_USER)
				VALUES(LI_ID,'EXCEPTION','EXTERNAL_REVIEWER','Invalid Last name',LS_LAST_NAME,'PREVALIDATION',NOW(),'quickstart');
				COMMIT;
				set LS_ERROR_FLAG = 'Y';
			END IF;
		END IF;
		SET LI_COUNT = NULL;
		IF LS_Affiliated_Institution IS NOT NULL THEN
			SELECT COUNT(*) INTO LI_COUNT FROM EXT_REVIEWER_AFFILIATION
			WHERE UPPER(TRIM(DESCRIPTION)) = UPPER(TRIM(LS_Affiliated_Institution));
				IF LI_COUNT != 1 THEN
					INSERT INTO MIGRATION_EXT_REVIEWER_ERROR_LOG ( STAGE_ID,ERROR_TYPE, FILE_NAME, ERROR_MESSAGE,VALUE, VALIDATION_TYPE, UPDATE_TIMESTAMP, UPDATE_USER)
					VALUES(LI_ID,'EXCEPTION','EXTERNAL_REVIEWER','Invalid Affiliation name',trim(LS_Affiliated_Institution), 'PREVALIDATION',NOW(),'quickstart');
					COMMIT;
					set LS_ERROR_FLAG = 'Y';
				END IF;
		END IF;
		SET LI_COUNT = NULL;
		IF LS_Work_Country IS NOT NULL THEN
			SELECT COUNT(*) INTO LI_COUNT FROM COUNTRY
			WHERE UPPER(TRIM(COUNTRY_NAME)) = UPPER(TRIM(LS_Work_Country));
				IF LI_COUNT != 1 THEN
					INSERT INTO MIGRATION_EXT_REVIEWER_ERROR_LOG ( STAGE_ID,ERROR_TYPE, FILE_NAME, ERROR_MESSAGE,VALUE, VALIDATION_TYPE, UPDATE_TIMESTAMP, UPDATE_USER)
					VALUES(LI_ID,'EXCEPTION','EXTERNAL_REVIEWER','Invalid Work Country name',trim(LS_Work_Country),'PREVALIDATION',NOW(),'quickstart');
					COMMIT;
					set LS_ERROR_FLAG = 'Y';
				END IF;
		END IF;
		SET LI_COUNT = NULL;
		IF LS_Specialism IS NOT NULL THEN
							loop_label:  LOOP
										if 	LS_Specialism is null or LENGTH(TRIM(LS_Specialism)) = 0 then
											leave loop_label;
										else
											set LI_END_LENGTH = char_length(trim(LS_Specialism));
                                            set LS_Specialism = replace(replace(LS_Specialism, ',', ';') ,'.',';');
											set LS_SPLITTED_Specialism = SUBSTRING_INDEX(LS_Specialism, ';', 1);
                                            SELECT COUNT(1) INTO LI_COUNT FROM ext_specialism_keyword
											WHERE TRIM(UPPER(REPLACE(DESCRIPTION, '\n', ''))) = TRIM(UPPER(REPLACE(LS_SPLITTED_Specialism, '\n', '')))
                                            and TRIM(UPPER(REPLACE(LS_SPLITTED_Specialism, '\n', ''))) != ')';
													IF LI_COUNT != 1 THEN
														INSERT INTO MIGRATION_EXT_REVIEWER_ERROR_LOG ( STAGE_ID, FILE_NAME, ERROR_MESSAGE,VALUE,VALIDATION_TYPE,  UPDATE_TIMESTAMP, UPDATE_USER )
														VALUES(LI_ID,'EXTERNAL_REVIEWER','Invalid Specialism Keyword', TRIM(REPLACE(LS_SPLITTED_Specialism, '\n', '')),'PREVALIDATION',NOW(),'quickstart');
														set LS_ERROR_FLAG = 'Y';
														COMMIT;
													END IF;
											set LI_START_LENGTH = char_length(LS_SPLITTED_Specialism);
											set LS_SPLITTED_Specialism = trim(substr(LS_Specialism, LI_START_LENGTH+2, LI_END_LENGTH));
											set LS_Specialism = LS_SPLITTED_Specialism;
										end if;
							end loop;
				END IF;
		SET LI_COUNT = NULL;
		IF LS_Keyword_1 IS NOT NULL THEN
			 SELECT COUNT(1) INTO LI_COUNT FROM ext_specialism_keyword
				WHERE UPPER(TRIM(replace(DESCRIPTION,'\n',''))) = UPPER(TRIM(replace(LS_KEYWORD_1,'\n','')))
                and TRIM(UPPER(REPLACE(LS_KEYWORD_1, '\n', ''))) != ')';
							IF LI_COUNT != 1 THEN
								INSERT INTO MIGRATION_EXT_REVIEWER_ERROR_LOG ( STAGE_ID, FILE_NAME, ERROR_MESSAGE,VALUE,VALIDATION_TYPE,  UPDATE_TIMESTAMP, UPDATE_USER )
								VALUES(LI_ID,'EXTERNAL_REVIEWER','KEYWORD_1 DOES NOT EXIST',TRIM(replace(LS_KEYWORD_1,'\n','')),'PREVALIDATION',NOW(),'quickstart');
								set LS_ERROR_FLAG = 'Y';
								COMMIT;
							END IF;
				END IF;
		SET LI_COUNT = NULL;
		IF LS_Keyword_2 IS NOT NULL THEN
			 SELECT COUNT(1) INTO LI_COUNT FROM ext_specialism_keyword
				WHERE UPPER(TRIM(replace(DESCRIPTION,'\n',''))) = UPPER(TRIM(replace(LS_KEYWORD_2,'\n','')))
                and TRIM(UPPER(REPLACE(LS_KEYWORD_2, '\n', ''))) != ')';
							IF LI_COUNT != 1 THEN
								INSERT INTO MIGRATION_EXT_REVIEWER_ERROR_LOG ( STAGE_ID, FILE_NAME, ERROR_MESSAGE,VALUE,VALIDATION_TYPE,  UPDATE_TIMESTAMP, UPDATE_USER )
								VALUES(LI_ID,'EXTERNAL_REVIEWER','KEYWORD_2 DOES NOT EXIST',TRIM(replace(LS_KEYWORD_2,'\n','')),'PREVALIDATION',NOW(),'quickstart');
								set LS_ERROR_FLAG = 'Y';
								COMMIT;
							END IF;
		END IF;
		SET LI_COUNT = NULL;
		IF LS_Keyword_3 IS NOT NULL THEN
			 SELECT COUNT(1) INTO LI_COUNT FROM ext_specialism_keyword
				WHERE UPPER(TRIM(replace(DESCRIPTION,'\n',''))) = UPPER(TRIM(replace(LS_KEYWORD_3,'\n','')))
                and TRIM(UPPER(REPLACE(LS_KEYWORD_3, '\n', ''))) != ')';
							IF LI_COUNT != 1 THEN
								INSERT INTO MIGRATION_EXT_REVIEWER_ERROR_LOG ( STAGE_ID, FILE_NAME, ERROR_MESSAGE,VALUE,VALIDATION_TYPE,  UPDATE_TIMESTAMP, UPDATE_USER )
								VALUES(LI_ID,'EXTERNAL_REVIEWER','KEYWORD_3 DOES NOT EXIST',TRIM(replace(LS_KEYWORD_3,'\n','')),'PREVALIDATION',NOW(),'quickstart');
								set LS_ERROR_FLAG = 'Y';
								COMMIT;
							END IF;
		END IF;
		SET LI_COUNT = NULL;
		IF LS_Keyword_4 IS NOT NULL THEN
			 SELECT COUNT(1) INTO LI_COUNT FROM ext_specialism_keyword
				WHERE UPPER(TRIM(replace(DESCRIPTION,'\n',''))) = UPPER(TRIM(replace(LS_KEYWORD_4,'\n','')))
                and TRIM(UPPER(REPLACE(LS_KEYWORD_4, '\n', ''))) != ')';
							IF LI_COUNT != 1 THEN
								INSERT INTO MIGRATION_EXT_REVIEWER_ERROR_LOG ( STAGE_ID, FILE_NAME, ERROR_MESSAGE,VALUE,VALIDATION_TYPE,  UPDATE_TIMESTAMP, UPDATE_USER )
								VALUES(LI_ID,'EXTERNAL_REVIEWER','KEYWORD_4 DOES NOT EXIST',TRIM(replace(LS_KEYWORD_4,'\n','')),'PREVALIDATION',NOW(),'quickstart');
								set LS_ERROR_FLAG = 'Y';
								COMMIT;
							END IF;
		END IF;
		SET LI_COUNT = NULL;
		IF LS_Keyword_5 IS NOT NULL THEN
		 SELECT COUNT(1) INTO LI_COUNT FROM ext_specialism_keyword
			WHERE UPPER(TRIM(replace(DESCRIPTION,'\n',''))) = UPPER(TRIM(replace(LS_KEYWORD_5,'\n','')))
            and TRIM(UPPER(REPLACE(LS_KEYWORD_5, '\n', ''))) != ')';
						IF LI_COUNT != 1 THEN
							INSERT INTO MIGRATION_EXT_REVIEWER_ERROR_LOG ( STAGE_ID, FILE_NAME, ERROR_MESSAGE,VALUE,VALIDATION_TYPE,  UPDATE_TIMESTAMP, UPDATE_USER )
							VALUES(LI_ID,'EXTERNAL_REVIEWER','KEYWORD_5 DOES NOT EXIST',TRIM(replace(LS_KEYWORD_5,'\n','')),'PREVALIDATION',NOW(),'quickstart');
							set LS_ERROR_FLAG = 'Y';
							COMMIT;
						END IF;
		END IF;
		SET LI_COUNT = NULL;
		IF LS_keyword_6 IS NOT NULL THEN
		 SELECT COUNT(1) INTO LI_COUNT FROM ext_specialism_keyword
			WHERE UPPER(TRIM(replace(DESCRIPTION,'\n',''))) = UPPER(TRIM(replace(LS_KEYWORD_6,'\n','')))
            and TRIM(UPPER(REPLACE(LS_KEYWORD_6, '\n', ''))) != ')';
						IF LI_COUNT != 1 THEN
							INSERT INTO MIGRATION_EXT_REVIEWER_ERROR_LOG ( STAGE_ID, FILE_NAME, ERROR_MESSAGE,VALUE,VALIDATION_TYPE,  UPDATE_TIMESTAMP, UPDATE_USER )
							VALUES(LI_ID,'EXTERNAL_REVIEWER','KEYWORD_6 DOES NOT EXIST',TRIM(replace(LS_KEYWORD_6,'\n','')),'PREVALIDATION',NOW(),'quickstart');
							set LS_ERROR_FLAG = 'Y';
							COMMIT;
						END IF;
				END IF;
		SET LI_COUNT = NULL;
		IF LS_keyword_7 IS NOT NULL THEN
			 SELECT COUNT(1) INTO LI_COUNT FROM ext_specialism_keyword
				WHERE UPPER(TRIM(replace(DESCRIPTION,'\n',''))) = UPPER(TRIM(replace(LS_KEYWORD_7,'\n','')))
                and TRIM(UPPER(REPLACE(LS_KEYWORD_7, '\n', ''))) != ')';
							IF LI_COUNT != 1 THEN
								INSERT INTO MIGRATION_EXT_REVIEWER_ERROR_LOG ( STAGE_ID, FILE_NAME, ERROR_MESSAGE,VALUE,VALIDATION_TYPE,  UPDATE_TIMESTAMP, UPDATE_USER )
								VALUES(LI_ID,'EXTERNAL_REVIEWER','KEYWORD_7 DOES NOT EXIST',TRIM(replace(LS_KEYWORD_7,'\n','')),'PREVALIDATION',NOW(),'quickstart');
								set LS_ERROR_FLAG = 'Y';
								COMMIT;
							END IF;
			set LI_START_LENGTH = char_length(LS_SPLITTED_KEYWORD);
		END IF;
		SET LI_COUNT = NULL;
		IF LS_keyword_8 IS NOT NULL THEN
		 SELECT COUNT(1) INTO LI_COUNT FROM ext_specialism_keyword
			WHERE UPPER(TRIM(replace(DESCRIPTION,'\n',''))) = UPPER(TRIM(replace(LS_KEYWORD_8,'\n','')))
            and TRIM(UPPER(REPLACE(LS_KEYWORD_8, '\n', ''))) != ')';
						IF LI_COUNT != 1 THEN
							INSERT INTO MIGRATION_EXT_REVIEWER_ERROR_LOG ( STAGE_ID, FILE_NAME, ERROR_MESSAGE,VALUE,VALIDATION_TYPE,  UPDATE_TIMESTAMP, UPDATE_USER )
							VALUES(LI_ID,'EXTERNAL_REVIEWER','KEYWORD_8 DOES NOT EXIST',TRIM(replace(LS_KEYWORD_8,'\n','')),'PREVALIDATION',NOW(),'quickstart');
							set LS_ERROR_FLAG = 'Y';
							COMMIT;
						END IF;
		END IF;
		SET LI_COUNT = NULL;
		IF LS_keyword_9 IS NOT NULL THEN
			 SELECT COUNT(1) INTO LI_COUNT FROM ext_specialism_keyword
				WHERE UPPER(TRIM(replace(DESCRIPTION,'\n',''))) = UPPER(TRIM(replace(LS_KEYWORD_9,'\n','')))
                and TRIM(UPPER(REPLACE(LS_KEYWORD_9, '\n', ''))) != ')';
							IF LI_COUNT != 1 THEN
								INSERT INTO MIGRATION_EXT_REVIEWER_ERROR_LOG ( STAGE_ID, FILE_NAME, ERROR_MESSAGE,VALUE,VALIDATION_TYPE,  UPDATE_TIMESTAMP, UPDATE_USER )
								VALUES(LI_ID,'EXTERNAL_REVIEWER','KEYWORD_9 DOES NOT EXIST',TRIM(replace(LS_KEYWORD_9,'\n','')),'PREVALIDATION',NOW(),'quickstart');
								set LS_ERROR_FLAG = 'Y';
								COMMIT;
							END IF;
		END IF;
		SET LI_COUNT = NULL;
		IF LS_keyword_10 IS NOT NULL THEN
		 SELECT COUNT(1) INTO LI_COUNT FROM ext_specialism_keyword
			WHERE UPPER(TRIM(replace(DESCRIPTION,'\n',''))) = UPPER(TRIM(replace(LS_KEYWORD_10,'\n','')))
            and TRIM(UPPER(REPLACE(LS_KEYWORD_10, '\n', ''))) != ')';
						IF LI_COUNT != 1 THEN
							INSERT INTO MIGRATION_EXT_REVIEWER_ERROR_LOG ( STAGE_ID, FILE_NAME, ERROR_MESSAGE,VALUE,VALIDATION_TYPE,  UPDATE_TIMESTAMP, UPDATE_USER )
							VALUES(LI_ID,'EXTERNAL_REVIEWER','KEYWORD_10 DOES NOT EXIST',TRIM(replace(LS_KEYWORD_10,'\n','')),'PREVALIDATION',NOW(),'quickstart');
							set LS_ERROR_FLAG = 'Y';
							COMMIT;
						END IF;
		END IF;
		SET LI_COUNT = NULL;
		IF LS_keyword_11 IS NOT NULL THEN
		 SELECT COUNT(1) INTO LI_COUNT FROM ext_specialism_keyword
			WHERE UPPER(TRIM(replace(DESCRIPTION,'\n',''))) = UPPER(TRIM(replace(LS_KEYWORD_11,'\n','')))
            and TRIM(UPPER(REPLACE(LS_KEYWORD_11, '\n', ''))) != ')';
						IF LI_COUNT != 1 THEN
							INSERT INTO MIGRATION_EXT_REVIEWER_ERROR_LOG ( STAGE_ID, FILE_NAME, ERROR_MESSAGE,VALUE,VALIDATION_TYPE,  UPDATE_TIMESTAMP, UPDATE_USER )
							VALUES(LI_ID,'EXTERNAL_REVIEWER','KEYWORD_11 DOES NOT EXIST',TRIM(replace(LS_KEYWORD_11,'\n','')),'PREVALIDATION',NOW(),'quickstart');
							set LS_ERROR_FLAG = 'Y';
							COMMIT;
						END IF;
		END IF;
		SET LI_COUNT = NULL;
		IF LS_CIRA_2021_Scoring_Trends IS NOT NULL THEN
							loop_label:  LOOP
										if 	LS_CIRA_2021_Scoring_Trends is null or LENGTH(TRIM(LS_CIRA_2021_Scoring_Trends)) = 0 then
											leave loop_label;
										else
													set LI_END_LENGTH = char_length(trim(LS_CIRA_2021_Scoring_Trends));
													set LS_SPLITTED_CIRA = SUBSTRING_INDEX(LS_CIRA_2021_Scoring_Trends,';',1);
													 SELECT COUNT(1) INTO LI_COUNT FROM ext_reviewer_cira
														WHERE TRIM(UPPER(DESCRIPTION)) = TRIM(UPPER(LS_SPLITTED_CIRA));
																	IF LI_COUNT != 1 THEN
																		INSERT INTO MIGRATION_EXT_REVIEWER_ERROR_LOG ( STAGE_ID, FILE_NAME, ERROR_MESSAGE,VALUE,VALIDATION_TYPE,  UPDATE_TIMESTAMP, UPDATE_USER )
																		VALUES(LI_ID,'EXTERNAL_REVIEWER','CIRA DOES NOT EXIST',trim(LS_SPLITTED_CIRA),'PREVALIDATION',NOW(),'quickstart');
																		set LS_ERROR_FLAG = 'Y';
																		COMMIT;
																	END IF;
													set LI_START_LENGTH = char_length(LS_SPLITTED_CIRA);
													set LS_SPLITTED_CIRA = trim(substr(LS_CIRA_2021_Scoring_Trends, LI_START_LENGTH+2, LI_END_LENGTH));
													set LS_CIRA_2021_Scoring_Trends = LS_SPLITTED_CIRA;
										end if;
							end loop;
				END IF;
		SET LI_COUNT = NULL;
		IF LS_Originality IS NOT NULL THEN
			SELECT COUNT(*) INTO LI_COUNT FROM EXT_REVIEWER_ORIGINALITY
			WHERE UPPER(TRIM(DESCRIPTION)) = UPPER(TRIM(LS_Originality));
				IF LI_COUNT != 1 THEN
					INSERT INTO MIGRATION_EXT_REVIEWER_ERROR_LOG ( STAGE_ID,ERROR_TYPE, FILE_NAME, ERROR_MESSAGE, VALUE,VALIDATION_TYPE, UPDATE_TIMESTAMP, UPDATE_USER)
					VALUES(LI_ID,'EXCEPTION','EXTERNAL_REVIEWER','Invalid Orginality',trim(LS_Originality),'PREVALIDATION',NOW(),'quickstart');
					COMMIT;
					set LS_ERROR_FLAG = 'Y';
				END IF;
		END IF;
		SET LI_COUNT = NULL;
		IF LS_Thoroughness IS NOT NULL THEN
			SELECT COUNT(*) INTO LI_COUNT FROM EXT_REVIEWER_THOROUGHNESS
			WHERE UPPER(TRIM(DESCRIPTION)) = UPPER(TRIM(LS_Thoroughness));
				IF LI_COUNT != 1 THEN
					INSERT INTO MIGRATION_EXT_REVIEWER_ERROR_LOG ( STAGE_ID,ERROR_TYPE, FILE_NAME, ERROR_MESSAGE,VALUE, VALIDATION_TYPE, UPDATE_TIMESTAMP, UPDATE_USER)
					VALUES(LI_ID,'EXCEPTION','EXTERNAL_REVIEWER','Invalid Thoroughness',trim(LS_Thoroughness),'PREVALIDATION',NOW(),'quickstart');
					COMMIT;
					set LS_ERROR_FLAG = 'Y';
				END IF;
		END IF;
		IF LS_ERROR_FLAG = 'Y' THEN
			UPDATE stage_external_reviewer SET VALIDATION_STATUS = 'FAILED'  WHERE ID = LI_ID;
		ELSE
			UPDATE stage_external_reviewer SET VALIDATION_STATUS = 'VALID'  WHERE ID = LI_ID;
		END IF;
	END loop;
END;
END;
END
$$
DELIMITER ;
