DELIMITER $$
CREATE DEFINER=`fibi`@`%` PROCEDURE `COI_DELETE_FCOI_DISCLOSURES_BY_PERSON_ID`(IN AV_PERSON_ID VARCHAR(20))
BEGIN
SET FOREIGN_KEY_CHECKS = 0;
SET SQL_SAFE_UPDATES = 0;
    DELETE FROM coi_review
    WHERE disclosure_id IN (
        SELECT disclosure_id FROM coi_disclosure WHERE person_id = AV_PERSON_ID
    );
    DELETE FROM discl_attachment
    WHERE disclosure_id IN (
        SELECT disclosure_id FROM coi_disclosure WHERE person_id = AV_PERSON_ID
    );
    DELETE FROM disclosure_action_log
    WHERE disclosure_id IN (
        SELECT disclosure_id FROM coi_disclosure WHERE person_id = AV_PERSON_ID
    );
    DELETE FROM coi_discl_project_entity_rel
    WHERE COI_DISCL_PROJECTS_ID IN (
        SELECT COI_DISCL_PROJECTS_ID FROM coi_discl_projects
        WHERE disclosure_id IN (
            SELECT disclosure_id FROM coi_disclosure WHERE person_id = AV_PERSON_ID
        )
    );
    DELETE FROM coi_discl_person_entity_rel
        WHERE disclosure_id IN (
            SELECT disclosure_id FROM coi_disclosure WHERE person_id = AV_PERSON_ID
    );
    DELETE FROM coi_discl_projects
    WHERE disclosure_id IN (
        SELECT disclosure_id FROM coi_disclosure WHERE person_id = AV_PERSON_ID
    );
 DELETE FROM discl_comment where MODULE_CODE = 8 and SUB_MODULE_CODE = 0 and MODULE_ITEM_KEY IN (SELECT disclosure_id FROM coi_disclosure WHERE person_id = AV_PERSON_ID);
    DELETE FROM coi_quest_answer where QUESTIONNAIRE_ANS_HEADER_ID in
    (SELECT QUESTIONNAIRE_ANS_HEADER_ID FROM quest_answer_header where MODULE_ITEM_CODE = 8 and MODULE_SUB_ITEM_CODE = 0 and MODULE_ITEM_KEY IN
    (SELECT disclosure_id FROM coi_disclosure WHERE person_id = AV_PERSON_ID));
 DELETE FROM quest_answer_header where MODULE_ITEM_CODE = 8 and MODULE_SUB_ITEM_CODE = 0 and MODULE_ITEM_KEY IN (SELECT disclosure_id FROM coi_disclosure WHERE person_id = AV_PERSON_ID);
    DELETE FROM coi_disclosure WHERE person_id = AV_PERSON_ID;
    SET FOREIGN_KEY_CHECKS = 1;
 SET SQL_SAFE_UPDATES = 1;
END
$$
DELIMITER ;
