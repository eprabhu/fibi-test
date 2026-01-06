-- award_manpower_compr_report_v;

CREATE VIEW `award_manpower_compr_report_v` AS 
select distinct
   `t`.`AWARD_MANPOWER_ID` AS `AWARD_MANPOWER_ID`,
   `t10`.`AWARD_ID` AS `AWARD_ID`,
   `t10`.`AWARD_NUMBER` AS `AWARD_NUMBER`,
   `t10`.`SEQUENCE_NUMBER` AS `SEQUENCE_NUMBER`,
   `t`.`MANPOWER_TYPE_CODE` AS `MANPOWER_TYPE_CODE`,
   `t3`.`DESCRIPTION` AS `MANPOWER_CATEGORY_TYPE`,
   `t`.`PERSON_ID` AS `PERSON_ID`,
   `t`.`ROLODEX_ID` AS `ROLODEX_ID`,
   `t`.`FULL_NAME` AS `FULL_NAME`,
   `t`.`POSITION_ID` AS `POSITION_ID`,
   `t4`.`DESCRIPTION` AS `POSITION_STATUS`,
   `t`.`PLAN_JOB_PROFILE_TYPE_CODE` AS `PLAN_JOB_PROFILE_TYPE_CODE`,
   `t5`.`DESCRIPTION` AS `PLAN_JOB_PROFILE_TYPE`,
   `t6`.`DESCRIPTION` AS `JOB_PROFILE_TYPE`,
   `t`.`CANDIDATE_TITLE_TYPE_CODE` AS `CANDIDATE_TITLE_TYPE_CODE`,
   `t7`.`DESCRIPTION` AS `CANDIDATE_TITLE_TYPE`,
   `t`.`COMMENTS` AS `COMMENTS`,
   (
      case
         coalesce(`t9`.`STATUS`, `t12`.`IS_ACTIVE`) 
         when
            'A' 
         then
            'ACTIVE' 
         when
            'Y' 
         then
            'ACTIVE' 
         when
            'I' 
         then
            'INACTIVE' 
         when
            'N' 
         then
            'INACTIVE' 
      end
   )
   AS `PERSON_STATUS`, `t`.`COST_ALLOCATION` AS `COST_ALLOCATION`, `t`.`PLANNED_BASE_SALARY` AS `INITIAL_MONTHLY_BASE_SALARY`, `t`.`PLANNED_SALARY` AS `INITIAL_COMMITTED_AMOUNT`, `t`.`CHARGE_START_DATE` AS `CHARGE_START_DATE`, `t`.`CHARGE_END_DATE` AS `CHARGE_END_DATE`, `t`.`CHARGE_DURATION` AS `CHARGE_DURATION`, `t`.`COMMITTED_COST` AS `COMMITTED_COST`, `t8`.`BASE_SALARY` AS `BASE_SALARY`, coalesce(`t11`.`unit_name`, `t13`.`unit_name`) AS `HOME_DEPARTMENT`, `t8`.`HIRE_DATE` AS `HIRE_DATE`, `t8`.`CONTRACT_END_DATE` AS `CONTRACT_END_DATE`, `t8`.`CADIDATURE_START_DATE` AS `CANDIDATURE_START_DATE`, `t8`.`CADIDATURE_END_DATE` AS `CANDIDATURE_END_DATE`, `t14`.`DESCRIPTION` AS `NON_PAID_MANPOWER_TYPE`, `t8`.`NATIONALITY` AS `NATIONALITY`, `t8`.`CITIZENSHIP` AS `CITIZENSHIP`, `t10`.`TITLE` AS `TITLE`, `t10`.`PI_PERSON_ID` AS `PI_PERSON_ID`, `t10`.`PI_NAME` AS `PI_NAME`, `t10`.`AWARD_TYPE` AS `AWARD_TYPE`, `t10`.`ACCOUNT_TYPE` AS `ACCOUNT_TYPE`, `t10`.`AWARD_STATUS` AS `AWARD_STATUS`, `t10`.`SPONSOR_NAME` AS `SPONSOR_NAME`, `t10`.`SPONSOR_TYPE` AS `SPONSOR_TYPE`, `t10`.`SPONSOR_AWARD_NUMBER` AS `SPONSOR_AWARD_NUMBER`, `t10`.`unit_name` AS `UNIT_NAME`, `t10`.`SUB_LEAD_UNIT` AS `SUB_LEAD_UNIT`, `t10`.`LEVEL_2_SUP_ORG` AS `LEVEL_2_SUP_ORG`, `t10`.`BEGIN_DATE` AS `AWARD_EFFECTIVE_DATE`, `t10`.`FINAL_EXPIRATION_DATE` AS `FINAL_EXPIRATION_DATE`, `t10`.`DURATION` AS `DURATION`, `t10`.`ACCOUNT_NUMBER` AS `ACCOUNT_NUMBER`, `t10`.`ANTICIPATED_TOTAL_AMOUNT` AS `ANTICIPATED_TOTAL_AMOUNT`, `t10`.`AMOUNT_OBLIGATED_TO_DATE` AS `AMOUNT_OBLIGATED_TO_DATE`, `t10`.`TOTAL_PROJECT_COST` AS `TOTAL_COST`, `t10`.`GRANT_CALL_TITLE` AS `GRANT_CALL_TITLE`, `t10`.`FUNDING_SCHEME` AS `FUNDING_SCHEME`, `t10`.`LEAD_UNIT_NUMBER` AS `LEAD_UNIT_NUMBER`, `t10`.`AWARD_SEQUENCE_STATUS` AS `AWARD_SEQUENCE_STATUS`, `t9`.`GENDER` AS `KEY_PERSON_GENDER`, `t9`.`EMAIL_ADDRESS` AS `KEY_PERSON_EMAIL`, `t`.`L2_WBS_NUMBER` AS `L2_WBS_NUMBER`, ifnull(`t9`.`EMAIL_ADDRESS`, `t12`.`EMAIL_ADDRESS`) AS `PERSON_EMAIL`, `t`.`ADJUSTED_COMMITTED_COST` AS `ADJUSTED_COMMITTED_COST`, `t`.`JOB_PROFILE_TYPE_CODE` AS `JOB_PROFILE_TYPE_CODE`, `t`.`WORKDAY_REFERENCE_ID` AS `WORKDAY_REFERENCE_ID`, 
   (
      `t`.`LINE_ITEM_COST` - ifnull(`t15`.`COMMITTED_AMOUNT`, 0)
   )
   AS `UNCOMMITTED_AMOUNT`, ifnull(`t16`.`EXPENSE_AMOUNT`, 0) AS `EXPENSE_AMOUNT`, ifnull(`t17`.`ACTUAL_HEAD_COUNT`, 0) AS `ACTUAL_HEAD_COUNT`, ifnull(`t15`.`COMMITTED_AMOUNT`, 0) AS `COMMITTED_AMOUNT`, cast(`t`.`QUANTITY` as unsigned) AS `APPROVED_HEAD_COUNT`, `t18`.`DESCRIPTION` AS `COST_ELEMENT`, `t`.`LINE_ITEM_COST` AS `LINE_ITEM_COST`, `t`.`JOB_REQUISITION_STATUS` AS `POSITION_ID_STATUS`, `t`.`PLAN_START_DATE` AS `PROPOSED_START_DATE`, `t`.`PLAN_END_DATE` AS `PROPOSED_END_DATE`, `t`.`PROPOSED_COST_ALLOCATION` AS `PROPOSED_COST_ALLOCATION`, `t`.`LINE_ITEM_DESCRIPTION` AS `LINE_ITEM_DESCRIPTION` 
from
   (
((((((((((((((((
      select
         `s1`.`AWARD_MANPOWER_ID` AS `AWARD_MANPOWER_ID`, `s1`.`AWARD_ID` AS `AWARD_ID`, `s1`.`AWARD_NUMBER` AS `AWARD_NUMBER`, `s1`.`SEQUENCE_NUMBER` AS `SEQUENCE_NUMBER`, `s1`.`MANPOWER_TYPE_CODE` AS `MANPOWER_TYPE_CODE`, `s2`.`PERSON_ID` AS `PERSON_ID`, `s2`.`ROLODEX_ID` AS `ROLODEX_ID`, `s2`.`FULL_NAME` AS `FULL_NAME`, `s2`.`POSITION_ID` AS `POSITION_ID`, `s2`.`POSITION_STATUS_CODE` AS `POSITION_STATUS_CODE`, `s2`.`PLAN_JOB_PROFILE_TYPE_CODE` AS `PLAN_JOB_PROFILE_TYPE_CODE`, `s2`.`CANDIDATE_TITLE_TYPE_CODE` AS `CANDIDATE_TITLE_TYPE_CODE`, `s2`.`DESCRIPTION` AS `COMMENTS`, NULL AS `COST_ALLOCATION`, `s2`.`COST_ALLOCATION` AS `PROPOSED_COST_ALLOCATION`, `s2`.`PLANNED_BASE_SALARY` AS `PLANNED_BASE_SALARY`, `s2`.`PLANNED_SALARY` AS `PLANNED_SALARY`, `s2`.`CHARGE_START_DATE` AS `CHARGE_START_DATE`, `s2`.`CHARGE_END_DATE` AS `CHARGE_END_DATE`, `s2`.`CHARGE_DURATION` AS `CHARGE_DURATION`, `s2`.`COMMITTED_COST` AS `COMMITTED_COST`, 
         (
            case
               when
                  (
                     `s1`.`BUDGET_REFERENCE_TYPE_CODE` = 1
                  )
               then
                  `s1`.`BUDGET_REFERENCE_NUMBER` 
               else
                  NULL 
            end
         )
         AS `L2_WBS_NUMBER`, NULL AS `ADJUSTED_COMMITTED_COST`, `s2`.`JOB_PROFILE_TYPE_CODE` AS `JOB_PROFILE_TYPE_CODE`, NULL AS `WORKDAY_REFERENCE_ID`, `s2`.`RESOURCE_TYPE_CODE` AS `RESOURCE_TYPE_CODE`, `s2`.`PLAN_START_DATE` AS `PLAN_START_DATE`, `s2`.`PLAN_END_DATE` AS `PLAN_END_DATE`, `s5`.`JOB_REQUISITION_STATUS` AS `JOB_REQUISITION_STATUS`, `s9`.`BUDGET_DETAILS_ID` AS `BUDGET_DETAILS_ID`, `s9`.`COST_ELEMENT` AS `COST_ELEMENT`, `s9`.`LINE_ITEM_DESCRIPTION` AS `LINE_ITEM_DESCRIPTION`, `s9`.`LINE_ITEM_COST` AS `LINE_ITEM_COST`, `s9`.`INTERNAL_ORDER_CODE` AS `INTERNAL_ORDER_CODE`, `s9`.`QUANTITY` AS `QUANTITY` 
      from
         (
((((`award_manpower` `s1` 
            join
               `award_manpower_resource` `s2` 
               on((`s1`.`AWARD_MANPOWER_ID` = `s2`.`AWARD_MANPOWER_ID`))) 
            left join
               `workday_position_requisition` `s5` 
               on((`s5`.`POSITION_ID` = `s2`.`POSITION_ID`))) 
            join
               `award` `s7` 
               on(((`s7`.`AWARD_ID` = `s1`.`AWARD_ID`) 
               and 
               (
(`s7`.`AWARD_SEQUENCE_STATUS` = 'ACTIVE') 
                  or 
                  (
(`s7`.`AWARD_SEQUENCE_STATUS` = 'PENDING') 
                     and 
                     (
                        `s7`.`AWARD_DOCUMENT_TYPE_CODE` = 1
                     )
                  )
               )
))) 
            join
               `award_budget_header` `s8` 
               on(((`s8`.`AWARD_ID` = `s7`.`AWARD_ID`) 
               and 
               (
                  `s8`.`VERSION_NUMBER` = 
                  (
                     select
                        max(`award_budget_header`.`VERSION_NUMBER`) 
                     from
                        `award_budget_header` 
                     where
                        (
                           `award_budget_header`.`AWARD_ID` = `s7`.`AWARD_ID`
                        )
                  )
               )
))) 
            join
               `award_budget_detail` `s9` 
               on(((`s9`.`BUDGET_HEADER_ID` = `s8`.`BUDGET_HEADER_ID`) 
               and 
               (
(`s9`.`INTERNAL_ORDER_CODE` = `s1`.`BUDGET_REFERENCE_NUMBER`) 
                  or 
                  (
                     `s9`.`BUDGET_DETAILS_ID` = `s1`.`BUDGET_REFERENCE_NUMBER`
                  )
               )
))
         )
      where
         (
((`s2`.`PERSON_ID` is null) 
            or 
            (
               `s2`.`PERSON_ID` <> '999999999100'
            )
) 
            and 
            (
               `s1`.`MANPOWER_TYPE_CODE` = 1
            )
            and 
            (
(`s2`.`POSITION_ID` is null) 
               or 
               (
                  `s5`.`JOB_REQUISITION_STATUS` is null
               )
               or 
               (
                  `s5`.`JOB_REQUISITION_STATUS` = 'Open'
               )
            )
         )
      union
      select
         NULL AS `AWARD_MANPOWER_ID`, NULL AS `AWARD_ID`, NULL AS `AWARD_NUMBER`, NULL AS `SEQUENCE_NUMBER`, 1 AS `MANPOWER_TYPE_CODE`, `s3`.`PERSON_ID` AS `PERSON_ID`, NULL AS `ROLODEX_ID`, `s4`.`FULL_NAME` AS `FULL_NAME`, `s3`.`POSITION_ID` AS `POSITION_ID`, `s3`.`POSITION_STATUS_CODE` AS `POSITION_STATUS_CODE`, NULL AS `PLAN_JOB_PROFILE_TYPE_CODE`, NULL AS `CANDIDATE_TITLE_TYPE_CODE`, NULL AS `COMMENTS`, `s3`.`COST_ALLOCATION` AS `COST_ALLOCATION`, NULL AS `PROPOSED_COST_ALLOCATION`, NULL AS `PLANNED_BASE_SALARY`, NULL AS `PLANNED_SALARY`, `s3`.`CHARGE_START_DATE` AS `CHARGE_START_DATE`, `s3`.`CHARGE_END_DATE` AS `CHARGE_END_DATE`, `s3`.`CHARGE_DURATION` AS `CHARGE_DURATION`, `s3`.`COMMITTED_COST` AS `COMMITTED_COST`, `s3`.`WBS_NUMBER` AS `L2_WBS_NUMBER`, `s3`.`ADJUSTED_COMMITTED_COST` AS `ADJUSTED_COMMITTED_COST`, `s3`.`JOB_PROFILE_TYPE_CODE` AS `JOB_PROFILE_TYPE_CODE`, `s3`.`WORKDAY_REFERENCE_ID` AS `WORKDAY_REFERENCE_ID`, NULL AS `RESOURCE_TYPE_CODE`, NULL AS `PLAN_START_DATE`, NULL AS `PLAN_END_DATE`, NULL AS `JOB_REQUISITION_STATUS`, `s9`.`BUDGET_DETAILS_ID` AS `BUDGET_DETAILS_ID`, `s9`.`COST_ELEMENT` AS `COST_ELEMENT`, `s9`.`LINE_ITEM_DESCRIPTION` AS `LINE_ITEM_DESCRIPTION`, `s9`.`LINE_ITEM_COST` AS `LINE_ITEM_COST`, `s9`.`INTERNAL_ORDER_CODE` AS `INTERNAL_ORDER_CODE`, `s9`.`QUANTITY` AS `QUANTITY` 
      from
         (
(`manpower_workday_resource` `s3` 
            left join
               `person` `s4` 
               on((`s4`.`PERSON_ID` = `s3`.`PERSON_ID`))) 
            join
               `award_budget_detail` `s9` 
               on((`s9`.`INTERNAL_ORDER_CODE` = `s3`.`WBS_NUMBER`))
         )
      where
         (
(`s3`.`WORKDAY_REFERENCE_ID` is not null) 
            and `s9`.`BUDGET_HEADER_ID` in 
            (
               select
                  max(`tb1`.`BUDGET_HEADER_ID`) 
               from
                  (
                     `award_budget_header` `tb1` 
                     join
                        `award` `tb2` 
                        on(((`tb1`.`AWARD_ID` = `tb2`.`AWARD_ID`) 
                        and 
                        (
                           `tb2`.`AWARD_SEQUENCE_STATUS` = 'ACTIVE'
                        )
))
                  )
               group by
                  `tb2`.`AWARD_ID`
            )
         )
) `t` 
         left join
            `manpower_type` `t3` 
            on((`t3`.`MANPOWER_TYPE_CODE` = `t`.`MANPOWER_TYPE_CODE`))) 
         left join
            `manpower_position_status` `t4` 
            on((`t4`.`POSITION_STATUS_CODE` = `t`.`POSITION_STATUS_CODE`))) 
         left join
            `manpower_job_profile_type` `t5` 
            on((`t5`.`JOB_PROFILE_TYPE_CODE` = `t`.`PLAN_JOB_PROFILE_TYPE_CODE`))) 
         left join
            `manpower_job_profile_type` `t6` 
            on((`t6`.`JOB_PROFILE_TYPE_CODE` = `t`.`JOB_PROFILE_TYPE_CODE`))) 
         left join
            `manpower_candidate_title_type` `t7` 
            on((`t7`.`CANDIDATE_TITLE_TYPE_CODE` = `t`.`CANDIDATE_TITLE_TYPE_CODE`))) 
         left join
            `manpower` `t8` 
            on((`t8`.`PERSON_ID` = `t`.`PERSON_ID`))) 
         left join
            `person` `t9` 
            on((`t9`.`PERSON_ID` = `t`.`PERSON_ID`))) 
         left join
            `unit` `t11` 
            on((`t9`.`HOME_UNIT` = `t11`.`UNIT_NUMBER`))) 
         left join
            `rolodex` `t12` 
            on((`t12`.`ROLODEX_ID` = `t`.`ROLODEX_ID`))) 
         left join
            `unit` `t13` 
            on((`t12`.`OWNED_BY_UNIT` = `t13`.`UNIT_NUMBER`))) 
         join
            `cost_element` `t18` 
            on((`t18`.`COST_ELEMENT` = `t`.`COST_ELEMENT`))) 
         join
            `award_master_dataset_rt` `t10` 
            on((((`t10`.`AWARD_ID` = `t`.`AWARD_ID`) 
            or 
            (
               `t10`.`ACCOUNT_NUMBER` = substring_index(`t`.`L2_WBS_NUMBER`, 'EOM', 1)
            )
) 
            and 
            (
               `t10`.`AWARD_SEQUENCE_STATUS` = 'ACTIVE'
            )
            and 
            (
               `t10`.`PERSON_ROLE_ID` = 3
            )
))) 
         left join
            `manpower_resource_type` `t14` 
            on((`t14`.`RESOURCE_TYPE_CODE` = `t`.`RESOURCE_TYPE_CODE`))) 
         left join
            (
               select
                  ifnull(sum(`sub_query`.`amount`), 0) AS `COMMITTED_AMOUNT`,
                  `sub_query`.`WBS_NUMBER` AS `WBS_NUMBER` 
               from
                  (
                     select
                        ifnull(sum(coalesce(`ta1`.`COMMITTED_COST`, `ta1`.`PLANNED_SALARY`, 0)), 0) AS `amount`,
                        `ta2`.`BUDGET_REFERENCE_NUMBER` AS `WBS_NUMBER` 
                     from
                        (
((`award_manpower_resource` `ta1` 
                           join
                              `award_manpower` `ta2` 
                              on((`ta1`.`AWARD_MANPOWER_ID` = `ta2`.`AWARD_MANPOWER_ID`))) 
                           left join
                              `workday_position_requisition` `ta3` 
                              on((`ta1`.`POSITION_ID` = `ta3`.`POSITION_ID`))) 
                           join
                              `award` `ta4` 
                              on(((`ta2`.`AWARD_ID` = `ta4`.`AWARD_ID`) 
                              and 
                              (
                                 `ta4`.`AWARD_SEQUENCE_STATUS` = 'ACTIVE'
                              )
))
                        )
                     where
                        (
(`ta2`.`MANPOWER_TYPE_CODE` = 1) 
                           and 
                           (
(`ta1`.`POSITION_ID` is null) 
                              or 
                              (
                                 `ta3`.`JOB_REQUISITION_STATUS` is null
                              )
                              or 
                              (
                                 `ta3`.`JOB_REQUISITION_STATUS` = 'Open'
                              )
                           )
                        )
                     group by
                        `ta2`.`BUDGET_REFERENCE_NUMBER` 
                     union
                     select
                        sum(coalesce(`sq1`.`ADJUSTED_COMMITTED_COST`, `sq1`.`COMMITTED_COST`, 0)) AS `amount`,
                        `sq1`.`WBS_NUMBER` AS `WBS_NUMBER` 
                     from
                        `manpower_workday_resource` `sq1` 
                     group by
                        `sq1`.`WBS_NUMBER`
                  )
                  `sub_query` 
               group by
                  `sub_query`.`WBS_NUMBER`
            )
            `t15` 
            on((`t`.`L2_WBS_NUMBER` = `t15`.`WBS_NUMBER`))) 
         left join
            (
               select
                  ifnull(sum(`award_expense_details`.`TOTAL_EXPENSE_AMOUNT`), 0) AS `EXPENSE_AMOUNT`,
                  `award_expense_details`.`INTERNAL_ORDER_CODE` AS `INTERNAL_ORDER_CODE` 
               from
                  `award_expense_details` 
               group by
                  `award_expense_details`.`INTERNAL_ORDER_CODE`
            )
            `t16` 
            on((`t`.`L2_WBS_NUMBER` = `t16`.`INTERNAL_ORDER_CODE`))) 
         left join
            (
               select
                  count(distinct `sq2`.`PERSON_ID`) AS `ACTUAL_HEAD_COUNT`,
                  `sq2`.`WBS_NUMBER` AS `WBS_NUMBER` 
               from
                  `manpower_workday_resource` `sq2` 
               where
                  (
(`sq2`.`PERSON_ID` is not null) 
                     and 
                     (
                        `sq2`.`PERSON_ID` <> '999999999100'
                     )
                     and 
                     (
                        `sq2`.`POSITION_STATUS_CODE` not in 
                        (
                           '8',
                           '5'
                        )
                     )
                     and 
                     (
                        cast(utc_timestamp() as date) between cast(`sq2`.`CHARGE_START_DATE` as date) and cast(`sq2`.`CHARGE_END_DATE` as date)
                     )
                  )
               group by
                  `sq2`.`WBS_NUMBER`
            )
            `t17` 
            on((`t`.`L2_WBS_NUMBER` = `t17`.`WBS_NUMBER`))
   )
;

