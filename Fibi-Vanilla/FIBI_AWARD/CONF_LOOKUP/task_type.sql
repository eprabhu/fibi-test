SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE  task_type;
INSERT INTO task_type (`TASK_TYPE_CODE`,`DESCRIPTION`,`INSTRUCTION`,`IS_REVIEW_TASK`,`UPDATE_TIMESTAMP`,`UPDATE_USER`,`IS_ACTIVE`) VALUES ('1','Budget Scrubbing','Click here or please navigate to the \'Budget & Expenses\' tab and start the budget phasing and provide the budget line item details. Also scrub KPI and Milestones details if required.','N',UTC_TIMESTAMP(),'admin','Y');
INSERT INTO task_type (`TASK_TYPE_CODE`,`DESCRIPTION`,`INSTRUCTION`,`IS_REVIEW_TASK`,`UPDATE_TIMESTAMP`,`UPDATE_USER`,`IS_ACTIVE`) VALUES ('4','Ethics Approval','Click here or please navigate to the Award \'Overview\' tab and add the \'Special Review\'','N',UTC_TIMESTAMP(),'admin','Y');
INSERT INTO task_type (`TASK_TYPE_CODE`,`DESCRIPTION`,`INSTRUCTION`,`IS_REVIEW_TASK`,`UPDATE_TIMESTAMP`,`UPDATE_USER`,`IS_ACTIVE`) VALUES ('5','Confirm Project Details','Confirm the project details as instructed in the task description.','Y',UTC_TIMESTAMP(),'admin','Y');
INSERT INTO task_type (`TASK_TYPE_CODE`,`DESCRIPTION`,`INSTRUCTION`,`IS_REVIEW_TASK`,`UPDATE_TIMESTAMP`,`UPDATE_USER`,`IS_ACTIVE`) VALUES ('7','Finance Account Creation','Click here or please navigate to the Award \'Overview\' tab and add the \'WBS Number\' in the Account number field.','N',UTC_TIMESTAMP(),'admin','Y');
SET FOREIGN_KEY_CHECKS = 1;
