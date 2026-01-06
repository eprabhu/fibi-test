
                    SET SQL_SAFE_UPDATES = 0;
                    SET FOREIGN_KEY_CHECKS = 0;
                    DELETE FROM `report`;
                    INSERT INTO `REPORT` (`REPORT_CODE`, `DESCRIPTION`, `FINAL_REPORT_FLAG`, `UPDATE_TIMESTAMP`, `UPDATE_USER`) VALUES ('1', 'Periodic', 'Y', '2025-07-29', 'admin');
                    INSERT INTO `REPORT` (`REPORT_CODE`, `DESCRIPTION`, `FINAL_REPORT_FLAG`, `UPDATE_TIMESTAMP`, `UPDATE_USER`) VALUES ('2', 'Quarterly', 'Y', '2025-07-29', 'admin');
                    SET SQL_SAFE_UPDATES = 1;
                    SET FOREIGN_KEY_CHECKS = 1;
