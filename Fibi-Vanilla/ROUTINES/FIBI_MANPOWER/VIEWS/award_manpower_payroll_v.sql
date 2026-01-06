-- award_manpower_payroll_v;

CREATE VIEW `award_manpower_payroll_v` AS 
select distinct
   NULL AS `MANPOWER_WORKDAY_RESOURCE_ID`,
   `t2`.`PAYROLL_ID` AS `PAYROLL_ID`,
   `t2`.`GL_ACCOUNT_CODE` AS `GL_ACCOUNT_CODE`,
   `t2`.`EMPLOYEE_NUMBER` AS `EMPLOYEE_NUMBER`,
   `t2`.`INTERNAL_ORDER_CODE` AS `INTERNAL_ORDER_CODE`,
   `t2`.`COST_SHARING` AS `COST_SHARING`,
   `t2`.`PAY_ELEMENT_CODE` AS `PAY_ELEMENT_CODE`,
   `t2`.`PAY_ELEMENT` AS `PAY_ELEMENT`,
   str_to_date(concat('01', `t2`.`PAYROLL_PERIOD`), '%d%m%Y') AS `PAYROLL_PERIOD`,
   `t2`.`REMARKS` AS `REMARKS`,
   `t2`.`AMOUNT` AS `AMOUNT`,
   `t4`.`NATIONALITY` AS `NATIONALITY`,
   `t4`.`CITIZENSHIP` AS `CITIZENSHIP`,
   NULL AS `POSITION_STATUS`,
   NULL AS `POSITION_STATUS_CODE`,
   NULL AS `PLAN_JOB_PROFILE_TYPE`,
   `t7`.`DEFAULT_JOB_TITLE` AS `JOB_PROFILE_TYPE`,
   NULL AS `CANDIDATE_TITLE_TYPE`,
   `t4`.`BASE_SALARY` AS `BASE_SALARY`,
   `t2`.`EMPLOYEE_NUMBER` AS `PERSON_ID`,
   NULL AS `ROLODEX_ID`,
   `t9`.`FULL_NAME` AS `FULL_NAME`,
   `t4`.`POSITION_ID` AS `POSITION_ID`,
   NULL AS `CANDIDATE_TITLE_TYPE_CODE`,
   NULL AS `COMMENTS`,
   NULL AS `COST_ALLOCATION`,
   NULL AS `PLAN_START_DATE`,
   NULL AS `PLAN_END_DATE`,
   NULL AS `PLAN_DURATION`,
   NULL AS `INITIAL_MONTHLY_BASE_SALARY`,
   NULL AS `INITIAL_COMMITTED_AMOUNT`,
   NULL AS `CHARGE_START_DATE`,
   NULL AS `CHARGE_END_DATE`,
   NULL AS `CHARGE_DURATION`,
   NULL AS `COMMITTED_COST`,
   (
      case
         `t9`.`STATUS` 
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
   AS `PERSON_STATUS`, `t10`.`unit_name` AS `HOME_DEPARTMENT`, date_format(`t4`.`HIRE_DATE`, '%d/%m/%Y') AS `HIRE_DATE`, date_format(`t4`.`CONTRACT_END_DATE`, '%d/%m/%Y') AS `CONTRACT_END_DATE`, date_format(`t4`.`CADIDATURE_START_DATE`, '%d/%m/%Y') AS `CANDIDATURE_START_DATE`, date_format(`t4`.`CADIDATURE_END_DATE`, '%d/%m/%Y') AS `CANDIDATURE_END_DATE`, `t9`.`EMAIL_ADDRESS` AS `PERSON_EMAIL`, `t15`.`TITLE` AS `TITLE`, `t15`.`PI_PERSON_ID` AS `PI_PERSON_ID`, `t15`.`PI_NAME` AS `PI_NAME`, `t15`.`AWARD_TYPE` AS `AWARD_TYPE`, `t15`.`ACCOUNT_TYPE` AS `ACCOUNT_TYPE`, `t15`.`AWARD_STATUS` AS `AWARD_STATUS`, `t15`.`SPONSOR_NAME` AS `SPONSOR_NAME`, `t15`.`SPONSOR_TYPE` AS `SPONSOR_TYPE`, `t15`.`SPONSOR_AWARD_NUMBER` AS `SPONSOR_AWARD_NUMBER`, `t15`.`unit_name` AS `UNIT_NAME`, `t15`.`SUB_LEAD_UNIT` AS `SUB_LEAD_UNIT`, `t15`.`BEGIN_DATE` AS `BEGIN_DATE`, `t15`.`FINAL_EXPIRATION_DATE` AS `FINAL_EXPIRATION_DATE`, `t15`.`DURATION` AS `DURATION`, `t15`.`ACCOUNT_NUMBER` AS `ACCOUNT_NUMBER`, `t15`.`ANTICIPATED_TOTAL_AMOUNT` AS `ANTICIPATED_TOTAL_AMOUNT`, `t15`.`AMOUNT_OBLIGATED_TO_DATE` AS `AMOUNT_OBLIGATED_TO_DATE`, `t15`.`TOTAL_COST` AS `TOTAL_COST`, `t15`.`GRANT_CALL_TITLE` AS `GRANT_CALL_TITLE`, `t15`.`FUNDING_SCHEME` AS `FUNDING_SCHEME`, `t15`.`LEAD_UNIT_NUMBER` AS `LEAD_UNIT_NUMBER`, `t15`.`AWARD_SEQUENCE_STATUS` AS `AWARD_SEQUENCE_STATUS`, cast(`t15`.`AWARD_ID` as unsigned) AS `AWARD_ID`, `t15`.`AWARD_NUMBER` AS `AWARD_NUMBER`, `t15`.`SEQUENCE_NUMBER` AS `SEQUENCE_NUMBER`, NULL AS `MANPOWER_TYPE_CODE`, 'Staff' AS `MANPOWER_CATEGORY_TYPE`, `t2`.`INTERNAL_ORDER_CODE` AS `WBS_NUMBER`, `t15`.`F_AND_A_RATE_TYPE` AS `F_AND_A_RATE_TYPE` 
from
   (
((((`award_master_dataset_rt` `t15` 
      join
         (
            select
               `z1`.`PAYROLL_ID` AS `PAYROLL_ID`,
               `z1`.`GL_ACCOUNT_CODE` AS `GL_ACCOUNT_CODE`,
               `z1`.`EMPLOYEE_NUMBER` AS `EMPLOYEE_NUMBER`,
               `z1`.`INTERNAL_ORDER_CODE` AS `INTERNAL_ORDER_CODE`,
               substr(`z1`.`INTERNAL_ORDER_CODE`, 1, 15) AS `ACCOUNT_NUMBER`,
               `z1`.`COST_SHARING` AS `COST_SHARING`,
               `z1`.`PAY_ELEMENT_CODE` AS `PAY_ELEMENT_CODE`,
               `z1`.`PAY_ELEMENT` AS `PAY_ELEMENT`,
               `z1`.`PAYROLL_PERIOD` AS `PAYROLL_PERIOD`,
               `z1`.`REMARKS` AS `REMARKS`,
               `z1`.`AMOUNT` AS `AMOUNT` 
            from
               `award_manpower_payroll` `z1`
         )
         `t2` 
         on((`t15`.`ACCOUNT_NUMBER` = `t2`.`ACCOUNT_NUMBER`))) 
      left join
         `manpower` `t4` 
         on((`t4`.`PERSON_ID` = `t2`.`EMPLOYEE_NUMBER`))) 
      left join
         `manpower_job_profile_type` `t7` 
         on((`t7`.`JOB_PROFILE_TYPE_CODE` = `t4`.`JOB_CODE`))) 
      left join
         `person` `t9` 
         on((`t9`.`PERSON_ID` = `t2`.`EMPLOYEE_NUMBER`))) 
      left join
         `unit` `t10` 
         on((`t9`.`HOME_UNIT` = `t10`.`UNIT_NUMBER`))
   )
where
   (
      `t15`.`PERSON_ROLE_ID` = 3
   )
;


