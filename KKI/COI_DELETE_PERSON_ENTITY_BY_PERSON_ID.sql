DELIMITER $$
CREATE  PROCEDURE `COI_DELETE_PERSON_ENTITY_BY_PERSON_ID`(IN AV_PERSON_ID VARCHAR(20))
BEGIN
SET FOREIGN_KEY_CHECKS = 0;
SET SQL_SAFE_UPDATES = 0;
    DELETE FROM fb_quest_answer
    WHERE QUESTIONNAIRE_ANS_HEADER_ID IN (
        SELECT QUESTIONNAIRE_ANS_HEADER_ID
        FROM fb_quest_answer_header
        WHERE MODULE_ITEM_CODE = 8
          AND MODULE_SUB_ITEM_CODE = 801
          AND MODULE_ITEM_KEY IN (
              SELECT person_entity_id FROM person_entity WHERE PERSON_ID = AV_PERSON_ID
          )
    );
    DELETE FROM fb_quest_answer_header
    WHERE MODULE_ITEM_CODE = 8
      AND MODULE_SUB_ITEM_CODE = 801
      AND MODULE_ITEM_KEY IN (
          SELECT person_entity_id FROM person_entity WHERE PERSON_ID = AV_PERSON_ID
      );
    DELETE FROM FB_COMP_CUSTOM_ELEMENT_ANSWER
    WHERE MODULE_ITEM_CODE = 8
    AND MODULE_SUB_ITEM_CODE = 801
      AND MODULE_ITEM_KEY IN (
          SELECT person_entity_id FROM person_entity WHERE PERSON_ID = AV_PERSON_ID
      );
    DELETE FROM per_ent_discl_type_selection
    WHERE person_entity_id IN (
        SELECT person_entity_id FROM person_entity WHERE PERSON_ID = AV_PERSON_ID
    );
    DELETE FROM per_ent_matrix_answer
    WHERE person_entity_id IN (
        SELECT person_entity_id FROM person_entity WHERE PERSON_ID = AV_PERSON_ID
    );
    DELETE FROM person_entity_action_log
    WHERE person_entity_id IN (
        SELECT person_entity_id FROM person_entity WHERE PERSON_ID = AV_PERSON_ID
    );
    DELETE FROM person_entity_relationship
    WHERE person_entity_id IN (
        SELECT person_entity_id FROM person_entity WHERE PERSON_ID = AV_PERSON_ID
    );
 DELETE FROM discl_comment where MODULE_CODE = 8 and SUB_MODULE_CODE = 801 and MODULE_ITEM_KEY IN (SELECT person_entity_id FROM person_entity WHERE PERSON_ID = AV_PERSON_ID);
    DELETE FROM coi_quest_answer where QUESTIONNAIRE_ANS_HEADER_ID in
    (SELECT QUESTIONNAIRE_ANS_HEADER_ID FROM quest_answer_header where MODULE_ITEM_CODE = 8 and MODULE_SUB_ITEM_CODE = 801 and MODULE_ITEM_KEY IN
    (SELECT person_entity_id FROM person_entity WHERE PERSON_ID = AV_PERSON_ID));
 DELETE FROM quest_answer_header where MODULE_ITEM_CODE = 8 and MODULE_SUB_ITEM_CODE = 801 and MODULE_ITEM_KEY IN (SELECT person_entity_id FROM person_entity WHERE PERSON_ID = AV_PERSON_ID);
    DELETE FROM person_entity
    WHERE PERSON_ID = AV_PERSON_ID;
SET FOREIGN_KEY_CHECKS = 1;
SET SQL_SAFE_UPDATES = 1;
END
$$
DELIMITER ;
