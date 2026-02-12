DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` FUNCTION `FN_EVAL_TRIAGE_QUESTIONNAIRE`(
    AV_MODULE_CODE INT,
    AV_SUB_MODULE_CODE INT,
    AV_MODULE_ITEM_KEY VARCHAR(20)
) RETURNS int
    DETERMINISTIC
BEGIN
    DECLARE LI_TEMPLATE_ID INT;
    DECLARE LI_QUES_ANS_HEADER_ID INT;
    DECLARE LI_COUNT INT;
    DECLARE Q1_ANSWER VARCHAR(100);
    DECLARE Q2_ANSWER VARCHAR(100);
    DECLARE Q21_ANSWER VARCHAR(600);
    DECLARE Q22_ANSWER VARCHAR(600);
    DECLARE Q23_ANSWER VARCHAR(600);
    DECLARE Q24_ANSWER VARCHAR(600);
    SELECT QUESTIONNAIRE_ANS_HEADER_ID
    INTO LI_QUES_ANS_HEADER_ID
    FROM QUEST_ANSWER_HEADER
    WHERE MODULE_ITEM_CODE = AV_MODULE_CODE
        AND MODULE_SUB_ITEM_CODE = AV_SUB_MODULE_CODE
        AND MODULE_ITEM_KEY = AV_MODULE_ITEM_KEY;
    SELECT TRIM(T1.ANSWER) INTO Q1_ANSWER
    FROM QUEST_ANSWER T1
    INNER JOIN QUEST_QUESTION T2 ON T1.QUESTION_ID = T2.QUESTION_ID
    WHERE T1.QUESTIONNAIRE_ANS_HEADER_ID = LI_QUES_ANS_HEADER_ID
    AND T2.QUESTION_NUMBER = 6841;
      IF UPPER(Q1_ANSWER) = 'YES' THEN
				SELECT TRIM(T1.ANSWER) INTO Q24_ANSWER
				FROM QUEST_ANSWER T1
				INNER JOIN QUEST_QUESTION T2 ON T1.QUESTION_ID = T2.QUESTION_ID
				WHERE T1.QUESTIONNAIRE_ANS_HEADER_ID = LI_QUES_ANS_HEADER_ID
				AND T2.QUESTION_NUMBER = 6842;
                RETURN 1;
	  ELSEIF UPPER(Q1_ANSWER) = 'NO' THEN
                SELECT TRIM(T1.ANSWER) INTO Q2_ANSWER
				FROM QUEST_ANSWER T1
				INNER JOIN QUEST_QUESTION T2 ON T1.QUESTION_ID = T2.QUESTION_ID
				WHERE T1.QUESTIONNAIRE_ANS_HEADER_ID = LI_QUES_ANS_HEADER_ID
				AND T2.QUESTION_NUMBER = 6843;
                IF UPPER(Q2_ANSWER) = 'YES' THEN
                            SELECT TRIM(T1.ANSWER) INTO Q24_ANSWER
							FROM QUEST_ANSWER T1
							INNER JOIN QUEST_QUESTION T2 ON T1.QUESTION_ID = T2.QUESTION_ID
							WHERE T1.QUESTIONNAIRE_ANS_HEADER_ID = LI_QUES_ANS_HEADER_ID
							AND T2.QUESTION_NUMBER = 6844;
							RETURN 9;
				ELSEIF UPPER(Q2_ANSWER) = 'NO' THEN
                        SELECT TRIM(T1.ANSWER) INTO Q21_ANSWER
						FROM QUEST_ANSWER T1
						INNER JOIN QUEST_QUESTION T2 ON T1.QUESTION_ID = T2.QUESTION_ID
						WHERE T1.QUESTIONNAIRE_ANS_HEADER_ID = LI_QUES_ANS_HEADER_ID
						AND T2.QUESTION_NUMBER = 6845;
                           IF UPPER(Q21_ANSWER) = 'YES' THEN
                                    SELECT TRIM(T1.ANSWER) INTO Q22_ANSWER
									FROM QUEST_ANSWER T1
									INNER JOIN QUEST_QUESTION T2 ON T1.QUESTION_ID = T2.QUESTION_ID
									WHERE T1.QUESTIONNAIRE_ANS_HEADER_ID = LI_QUES_ANS_HEADER_ID
									AND T2.QUESTION_NUMBER = 6847;
                                        IF UPPER(Q22_ANSWER) = 'YES' THEN
                                                        SELECT TRIM(T1.ANSWER) INTO Q24_ANSWER
														FROM QUEST_ANSWER T1
														INNER JOIN QUEST_QUESTION T2 ON T1.QUESTION_ID = T2.QUESTION_ID
														WHERE T1.QUESTIONNAIRE_ANS_HEADER_ID = LI_QUES_ANS_HEADER_ID
														AND T2.QUESTION_NUMBER = 6851;
                                                IF UPPER(Q24_ANSWER) = UPPER(TRIM('Share or receive confidential information?')) THEN
													RETURN 5;
												ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Will this establish an unfunded collaboration with the outside institution?')) THEN
													RETURN 6;
												ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Establish a cooperative framework with a federal entity? (Note: This is a specific agreement issued by federal entity entitled Cooperative Research and Development Agreement or â€œCRADA.â€)')) THEN
													RETURN 7;
												ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Govern the transfer and use of data?')) THEN
													RETURN 8;
												ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Give or take physical possession (but not ownership) of equipment or other tangible property for a stated purpose?')) THEN
													RETURN 25;
												ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Allow student exchanges between JHU and another institution to take coursesÂ  at an outside institution and receive credit at their home institution?')) THEN
													RETURN 26;
												ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Set forth the respective intellectual property rights between two parties prior to an award?')) THEN
													RETURN 27;
												ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Requires research administration review prior to a proposal or award document is received?')) THEN
													RETURN 28;
												ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Grant rights to use specified intellectual property assets?')) THEN
													RETURN 29;
												ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Set out approved terms to govern multiple forthcoming project agreements?')) THEN
													RETURN 30;
												ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Define the conditions under which research or other materials can be transferred and used among the parties?')) THEN
													RETURN 31;
												ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Establish a relationship among parties for membership of an organization with broad research program objectives that are of interest to multiple organizations. Separate agreements for specific projects may also be required')) THEN
													RETURN 32;
												ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Establish a non-binding agreement between two or more parties to discuss future collaborative work?')) THEN
													RETURN 33;
												ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Govern the provision of professional services from a JHU lab or center that regularly provides such services to other organizations?')) THEN
													RETURN 34;
												ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Provide funds to allow a JHU student to perform work required as part of their degree program at another organization.')) THEN
													RETURN 35;
												ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Set forth the respective obligations of two or more parties when collaborating to prepare a formal project proposal in response to a solicitation?')) THEN
													RETURN 36;
												ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Outline the expectations of the sending and receiving institutions when a JHU faculty member or student is visiting another institution or when a visitor coming to JHU and which require an agreement to participate in research or educational activities?')) THEN
													RETURN 37;
												END IF;
										ELSEIF UPPER(Q22_ANSWER) = 'NO' THEN
                                                        SELECT TRIM(T1.ANSWER) INTO Q24_ANSWER
														FROM QUEST_ANSWER T1
														INNER JOIN QUEST_QUESTION T2 ON T1.QUESTION_ID = T2.QUESTION_ID
														WHERE T1.QUESTIONNAIRE_ANS_HEADER_ID = LI_QUES_ANS_HEADER_ID
														AND T2.QUESTION_NUMBER =6850;
												IF UPPER(Q24_ANSWER) = UPPER(TRIM('Develop a degree-granting program in collaboration with an outside institution?')) THEN
													RETURN 17;
												ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Allow student exchanges between JHU and another institution to take coursesÂ  at an outside institution and receive credit at their home institution?')) THEN
													RETURN 18;
												ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Requires research administration review prior to a proposal or award document is received?')) THEN
													RETURN 19;
												ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Establish a non-binding agreement between two or more parties to discuss future collaborative work?')) THEN
													RETURN 20;
												ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Govern the temporary assignment of a JHU faculty member to another organization?')) THEN
													RETURN 38;
												ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Set out the terms to allow a JHU student to perform work required as part of their degree program at another organization.')) THEN
													RETURN 39;
												END IF;
                                        END IF;
						   ELSEIF UPPER(Q21_ANSWER) = 'NO' THEN
                                                    SELECT TRIM(T1.ANSWER) INTO Q23_ANSWER
													FROM QUEST_ANSWER T1
													INNER JOIN QUEST_QUESTION T2 ON T1.QUESTION_ID = T2.QUESTION_ID
													WHERE T1.QUESTIONNAIRE_ANS_HEADER_ID = LI_QUES_ANS_HEADER_ID
													AND T2.QUESTION_NUMBER = 6846;
                                                        IF UPPER(Q23_ANSWER) = 'YES' THEN
                                                                    SELECT TRIM(T1.ANSWER) INTO Q24_ANSWER
																	FROM QUEST_ANSWER T1
																	INNER JOIN QUEST_QUESTION T2 ON T1.QUESTION_ID = T2.QUESTION_ID
																	WHERE T1.QUESTIONNAIRE_ANS_HEADER_ID = LI_QUES_ANS_HEADER_ID
																	AND T2.QUESTION_NUMBER = 6849;
                                                            IF UPPER(Q24_ANSWER) = UPPER(TRIM('Share or receive confidential information?')) THEN
																RETURN 13;
															ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Will this establish an unfunded collaboration with the outside institution?')) THEN
																RETURN 14;
															ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Establish a cooperative framework with a federal entity? (Note: This is a specific agreement issued by federal entity entitled Cooperative Research and Development Agreement or â€œCRADA.â€)')) THEN
																RETURN 15;
															ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Govern the transfer and use of data?')) THEN
																RETURN 16;
															ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Give or take physical possession (but not ownership) of equipment or other tangible property for a stated purpose?')) THEN
																RETURN 40;
															ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Allow student exchanges between JHU and another institution to take coursesÂ  at an outside institution and receive credit at their home institution?')) THEN
																RETURN 41;
															ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Set forth the respective intellectual property rights between two parties prior to an award?')) THEN
																RETURN 42;
															ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Requires research administration review prior to a proposal or award document is received?')) THEN
																RETURN 43;
															ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Grant rights to use specified intellectual property assets?')) THEN
																RETURN 44;
															ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Set out approved terms to govern multiple forthcoming project agreements?')) THEN
																RETURN 45;
															ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Define the conditions under which research or other materials can be transferred and used among the parties?')) THEN
																RETURN 46;
															ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Establish a relationship among parties for membership of an organization with broad research program objectives that are of interest to multiple organizations. Separate agreements for specific projects may also be required')) THEN
																RETURN 47;
															ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Establish a non-binding agreement between two or more parties to discuss future collaborative work?')) THEN
																RETURN 48;
															ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Govern the provision of professional services from a JHU lab or center that regularly provides such services to other organizations?')) THEN
																RETURN 49;
															ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Provide funds to allow a JHU student to perform work required as part of their degree program at another organization.')) THEN
																RETURN 50;
															ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Set forth the respective obligations of two or more parties when collaborating to prepare a formal project proposal in response to a solicitation?')) THEN
																RETURN 51;
															ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Outline the expectations of the sending and receiving institutions when a JHU faculty member or student is visiting another institution or when a visitor coming to JHU and which require an agreement to participate in research or educational activities?')) THEN
																RETURN 52;
															END IF;
														ELSEIF UPPER(Q23_ANSWER) = 'NO' THEN
                                                                        SELECT TRIM(T1.ANSWER) INTO Q24_ANSWER
																		FROM QUEST_ANSWER T1
																		INNER JOIN QUEST_QUESTION T2 ON T1.QUESTION_ID = T2.QUESTION_ID
																		WHERE T1.QUESTIONNAIRE_ANS_HEADER_ID = LI_QUES_ANS_HEADER_ID
																		AND T2.QUESTION_NUMBER = 6848;
                                                                IF UPPER(Q24_ANSWER) = UPPER(TRIM('Develop a degree-granting program in collaboration with an outside institution?')) THEN
																	RETURN 21;
																ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Allow student exchanges between JHU and another institution to take coursesÂ  at an outside institution and receive credit at their home institution?')) THEN
																	RETURN 22;
																ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Requires research administration review prior to a proposal or award document is received?')) THEN
																	RETURN 23;
																ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Establish a non-binding agreement between two or more parties to discuss future collaborative work?')) THEN
																	RETURN 24;
																ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Govern the temporary assignment of a JHU faculty member to another organization?')) THEN
																	RETURN 53;
																ELSEIF UPPER(Q24_ANSWER) = UPPER(TRIM('Set out the terms to allow a JHU student to perform work required as part of their degree program at another organization.')) THEN
																	RETURN 54;
																END IF;
														END IF;
                           END IF;
                END IF;
      END IF;
    RETURN 0;
END
$$
DELIMITER ;
