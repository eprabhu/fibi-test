

-- award_manpower_report_v;

CREATE VIEW `award_manpower_report_v` AS 
select distinct
   `t1`.`AWARD_MANPOWER_ID` AS `AWARD_MANPOWER_ID`,
   `t1`.`AWARD_ID` AS `AWARD_ID`,
   `t1`.`AWARD_NUMBER` AS `AWARD_NUMBER`,
   `t1`.`SEQUENCE_NUMBER` AS `SEQUENCE_NUMBER`,
   `t1`.`MANPOWER_TYPE_CODE` AS `MANPOWER_TYPE_CODE`,
   `t3`.`DESCRIPTION` AS `MANPOWER_CATEGORY_TYPE`,
   `t2`.`PERSON_ID` AS `PERSON_ID`,
   `t2`.`ROLODEX_ID` AS `ROLODEX_ID`,
   `t2`.`FULL_NAME` AS `FULL_NAME`,
   `t2`.`POSITION_ID` AS `POSITION_ID`,
   `t4`.`DESCRIPTION` AS `POSITION_STATUS`,
   `t2`.`PLAN_JOB_PROFILE_TYPE_CODE` AS `PLAN_JOB_PROFILE_TYPE_CODE`,
   `t5`.`DESCRIPTION` AS `PLAN_JOB_PROFILE_TYPE`,
   `t6`.`DESCRIPTION` AS `JOB_PROFILE_TYPE`,
   `t2`.`CANDIDATE_TITLE_TYPE_CODE` AS `CANDIDATE_TITLE_TYPE_CODE`,
   `t7`.`DESCRIPTION` AS `CANDIDATE_TITLE_TYPE`,
   `t2`.`DESCRIPTION` AS `COMMENTS`,
   (
      case
         coalesce(`t9`.`STATUS`, `t12`.`IS_ACTIVE`) 
         when
            'A' 
         then
            'Active' 
         when
            'I' 
         then
            'Inactive' 
      end
   )
   AS `PERSON_STATUS`, `t2`.`COST_ALLOCATION` AS `COST_ALLOCATION`, `t2`.`PLAN_START_DATE` AS `PLAN_START_DATE`, `t2`.`PLAN_END_DATE` AS `PLAN_END_DATE`, `t2`.`PLAN_DURATION` AS `PLAN_DURATION`, `t2`.`PLANNED_BASE_SALARY` AS `INITIAL_MONTHLY_BASE_SALARY`, `t2`.`PLANNED_SALARY` AS `INITIAL_COMMITTED_AMOUNT`, `t2`.`CHARGE_START_DATE` AS `CHARGE_START_DATE`, `t2`.`CHARGE_END_DATE` AS `CHARGE_END_DATE`, `t2`.`CHARGE_DURATION` AS `CHARGE_DURATION`, `t2`.`COMMITTED_COST` AS `COMMITTED_COST`, `t8`.`BASE_SALARY` AS `BASE_SALARY`, coalesce(`t11`.`unit_name`, `t13`.`unit_name`) AS `HOME_DEPARTMENT`, cast(date_format(`t8`.`HIRE_DATE`, '%d/%m/%Y') as char) AS `HIRE_DATE`, cast(date_format(`t8`.`CONTRACT_END_DATE`, '%d/%m/%Y') as char) AS `CONTRACT_END_DATE`, cast(date_format(`t8`.`CADIDATURE_START_DATE`, '%d/%m/%Y') as char) AS `CANDIDATURE_START_DATE`, cast(date_format(`t8`.`CADIDATURE_END_DATE`, '%d/%m/%Y') as char) AS `CANDIDATURE_END_DATE`, `t14`.`DESCRIPTION` AS `NON_PAID_MANPOWER_TYPE`, `t8`.`NATIONALITY` AS `NATIONALITY`, `t8`.`CITIZENSHIP` AS `CITIZENSHIP`, `t10`.`TITLE` AS `TITLE`, `t10`.`PI_PERSON_ID` AS `PI_PERSON_ID`, `t10`.`PI_NAME` AS `PI_NAME`, `t10`.`AWARD_TYPE` AS `AWARD_TYPE`, `t10`.`ACCOUNT_TYPE` AS `ACCOUNT_TYPE`, `t10`.`AWARD_STATUS` AS `AWARD_STATUS`, `t10`.`SPONSOR_NAME` AS `SPONSOR_NAME`, `t10`.`SPONSOR_TYPE` AS `SPONSOR_TYPE`, `t10`.`SPONSOR_AWARD_NUMBER` AS `SPONSOR_AWARD_NUMBER`, `t10`.`unit_name` AS `UNIT_NAME`, `t10`.`SUB_LEAD_UNIT` AS `SUB_LEAD_UNIT`, `t10`.`LEVEL_2_SUP_ORG` AS `LEVEL_2_SUP_ORG`, `t10`.`BEGIN_DATE` AS `AWARD_EFFECTIVE_DATE`, `t10`.`FINAL_EXPIRATION_DATE` AS `FINAL_EXPIRATION_DATE`, `t10`.`DURATION` AS `DURATION`, `t10`.`ACCOUNT_NUMBER` AS `ACCOUNT_NUMBER`, `t10`.`ANTICIPATED_TOTAL_AMOUNT` AS `ANTICIPATED_TOTAL_AMOUNT`, `t10`.`AMOUNT_OBLIGATED_TO_DATE` AS `AMOUNT_OBLIGATED_TO_DATE`, `t10`.`TOTAL_COST` AS `TOTAL_COST`, `t10`.`GRANT_CALL_TITLE` AS `GRANT_CALL_TITLE`, `t10`.`FUNDING_SCHEME` AS `FUNDING_SCHEME`, `t10`.`LEAD_UNIT_NUMBER` AS `LEAD_UNIT_NUMBER`, `t10`.`AWARD_SEQUENCE_STATUS` AS `AWARD_SEQUENCE_STATUS`, `t9`.`GENDER` AS `KEY_PERSON_GENDER`, `t9`.`EMAIL_ADDRESS` AS `KEY_PERSON_EMAIL`, 
   (
      case
         when
            (
               `t1`.`BUDGET_REFERENCE_TYPE_CODE` = 1
            )
         then
            `t1`.`BUDGET_REFERENCE_NUMBER` 
         else
            NULL 
      end
   )
   AS `L2_WBS_NUMBER`, `FN_GET_SAP_FEED_STATUS`(`t10`.`AWARD_ID`, `t10`.`AWARD_NUMBER`) AS `FEED_STATUS`, ifnull(`t9`.`EMAIL_ADDRESS`, `t12`.`EMAIL_ADDRESS`) AS `PERSON_EMAIL` 
from
   (
((((((((((((`award_manpower` `t1` 
      join
         `award_manpower_resource` `t2` 
         on(((`t1`.`AWARD_MANPOWER_ID` = `t2`.`AWARD_MANPOWER_ID`) 
         and 
         (
(`t2`.`PERSON_ID` is null) 
            or 
            (
               `t2`.`PERSON_ID` <> '999999999100'
            )
         )
))) 
      left join
         `manpower_type` `t3` 
         on((`t3`.`MANPOWER_TYPE_CODE` = `t1`.`MANPOWER_TYPE_CODE`))) 
      left join
         `manpower_position_status` `t4` 
         on((`t4`.`POSITION_STATUS_CODE` = `t2`.`POSITION_STATUS_CODE`))) 
      left join
         `manpower_job_profile_type` `t5` 
         on((`t5`.`JOB_PROFILE_TYPE_CODE` = `t2`.`PLAN_JOB_PROFILE_TYPE_CODE`))) 
      left join
         `manpower_job_profile_type` `t6` 
         on((`t6`.`JOB_PROFILE_TYPE_CODE` = `t2`.`JOB_PROFILE_TYPE_CODE`))) 
      left join
         `manpower_candidate_title_type` `t7` 
         on((`t7`.`CANDIDATE_TITLE_TYPE_CODE` = `t2`.`CANDIDATE_TITLE_TYPE_CODE`))) 
      left join
         `manpower` `t8` 
         on((`t8`.`PERSON_ID` = `t2`.`PERSON_ID`))) 
      left join
         `person` `t9` 
         on((`t9`.`PERSON_ID` = `t2`.`PERSON_ID`))) 
      left join
         `unit` `t11` 
         on((`t9`.`HOME_UNIT` = `t11`.`UNIT_NUMBER`))) 
      left join
         `rolodex` `t12` 
         on((`t12`.`ROLODEX_ID` = `t2`.`ROLODEX_ID`))) 
      left join
         `unit` `t13` 
         on((`t12`.`OWNED_BY_UNIT` = `t13`.`UNIT_NUMBER`))) 
      join
         `award_master_dataset_rt` `t10` 
         on(((`t10`.`AWARD_ID` = `t1`.`AWARD_ID`) 
         and 
         (
            `t10`.`AWARD_SEQUENCE_STATUS` = 'ACTIVE'
         )
))) 
      left join
         `manpower_resource_type` `t14` 
         on((`t14`.`RESOURCE_TYPE_CODE` = `t2`.`RESOURCE_TYPE_CODE`))
   )
;

