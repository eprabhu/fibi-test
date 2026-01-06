
SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS = 0;
DELETE FROM `SR_TYPE`;
INSERT INTO `SR_TYPE` (`TYPE_CODE`, `DESCRIPTION`, `UPDATE_TIMESTAMP`, `UPDATE_USER`, `INSTRUCTION`, `SUBJECT`, `IS_ACTIVE`, `sort_order`, `CATEGORY_CODE`) VALUES ('1', 'Adjust Project Duration', '2025-07-29 15:54:51.000000', 'admin', 'Adjust Project Duration', 'Adjust Project Duration', 'Y', '1', '1');
INSERT INTO `SR_TYPE` (`TYPE_CODE`, `DESCRIPTION`, `UPDATE_TIMESTAMP`, `UPDATE_USER`, `INSTRUCTION`, `SUBJECT`, `IS_ACTIVE`, `sort_order`, `CATEGORY_CODE`) VALUES ('19', 'Modify Award Budget', '2025-07-29 15:45:18.000000', 'admin', 'Please provide sufficient details required for the requests. Sequence = Reduce then increase.  Initial base salary should be the highest amount that can be paid for incoming for the position.', 'Modify Award Budget', 'Y', '4', '1');
INSERT INTO `SR_TYPE` (`TYPE_CODE`, `DESCRIPTION`, `UPDATE_TIMESTAMP`, `UPDATE_USER`, `IS_ACTIVE`, `sort_order`, `CATEGORY_CODE`) VALUES ('26', 'Password Reset', '2025-07-29 06:06:42.000000', 'admin', 'Y', '1', '20');
INSERT INTO `SR_TYPE` (`TYPE_CODE`, `DESCRIPTION`, `UPDATE_TIMESTAMP`, `UPDATE_USER`, `IS_ACTIVE`, `sort_order`, `CATEGORY_CODE`) VALUES ('27', 'Email Access Issue', '2025-07-29 06:06:42.000000', 'admin', 'Y', '1', '20');
INSERT INTO `SR_TYPE` (`TYPE_CODE`, `DESCRIPTION`, `UPDATE_TIMESTAMP`, `UPDATE_USER`, `INSTRUCTION`, `SUBJECT`, `IS_ACTIVE`, `sort_order`, `CATEGORY_CODE`) VALUES ('3', 'Modify Research Team', '2025-07-29 15:42:07.000000', 'admin', 'Modify Research Team', 'Modify Research Team', 'Y', '2', '1');
INSERT INTO `SR_TYPE` (`TYPE_CODE`, `DESCRIPTION`, `UPDATE_TIMESTAMP`, `UPDATE_USER`, `INSTRUCTION`, `SUBJECT`, `IS_ACTIVE`, `sort_order`, `CATEGORY_CODE`) VALUES ('4', 'Modify Project Scope', '2025-07-29 15:55:25.000000', 'admin', 'Modify Project Scope', 'Modify Project Scope', 'Y', '3', '1');
INSERT INTO `SR_TYPE` (`TYPE_CODE`, `DESCRIPTION`, `UPDATE_TIMESTAMP`, `UPDATE_USER`, `IS_ACTIVE`, `CATEGORY_CODE`) VALUES ('6', 'Admin Correction', '2020-04-20 14:01:23.337000', 'admin', 'Y', '1');
INSERT INTO `SR_TYPE` (`TYPE_CODE`, `DESCRIPTION`, `UPDATE_TIMESTAMP`, `UPDATE_USER`, `IS_ACTIVE`, `CATEGORY_CODE`) VALUES ('7', 'Award Closure', '2020-04-02 10:16:14.979000', 'admin', 'Y', '1');
SET SQL_SAFE_UPDATES = 1;
SET FOREIGN_KEY_CHECKS = 1;
