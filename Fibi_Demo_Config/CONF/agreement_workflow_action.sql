
                    SET SQL_SAFE_UPDATES = 0;
                    SET FOREIGN_KEY_CHECKS = 0;
                    UPDATE agreement_workflow_action SET AGREEMENT_STATUS_CODE = 6 WHERE AGREEMENT_WORKFLOW_ACTION_ID = 200;
                    SET SQL_SAFE_UPDATES = 1;
                    SET FOREIGN_KEY_CHECKS = 1;
