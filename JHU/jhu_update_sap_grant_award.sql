DELIMITER $$
CREATE  PROCEDURE `jhu_update_sap_grant_award`(IN proc_grant_number VARCHAR(6)
                                     ,IN proc_award_key VARCHAR(100)
                                     ,IN proc_update_column VARCHAR(50)
                                     ,IN proc_new_value VARCHAR(1000)
                                     ,IN proc_update_timestamp DATETIME
                                     )
BEGIN
DECLARE DONE INT DEFAULT 0;
        /*  *** *******************************************************
        ** Declare needed local variables                                        **
        **************************************************************************/
        DECLARE row_count SMALLINT  DEFAULT  NULL;
        DECLARE period_counter SMALLINT  DEFAULT  0;
        DECLARE new_award_year VARCHAR(4)  DEFAULT  NULL;
        DECLARE new_award_effective_date VARCHAR(10)  DEFAULT  NULL;
        DECLARE new_grant_budget_start_date VARCHAR(8)  DEFAULT  NULL;
        DECLARE new_grant_budget_end_date VARCHAR(8)  DEFAULT  NULL;
        DECLARE new_grant_award_action VARCHAR(20)  DEFAULT  NULL;
        DECLARE update_statement VARCHAR(1000)  DEFAULT  NULL;
        DECLARE stage_rec_grant_number VARCHAR(200); -- Use -meta option to resolve the data type
        DECLARE stage_rec_award_year VARCHAR(200); -- Use -meta option to resolve the data type
        DECLARE stage_rec_award_effective_date VARCHAR(200); -- Use -meta option to resolve the data type
        DECLARE stage_rec_grant_budget_direct VARCHAR(200); -- Use -meta option to resolve the data type
        DECLARE stage_rec_grant_budget_indirect VARCHAR(200); -- Use -meta option to resolve the data type
        DECLARE stage_rec_grant_budget_start_date VARCHAR(200); -- Use -meta option to resolve the data type
        DECLARE stage_rec_grant_budget_end_date VARCHAR(200); -- Use -meta option to resolve the data type
        DECLARE stage_rec_grant_award_action VARCHAR(200); -- Use -meta option to resolve the data type
        DECLARE stage_rec_update_timestamp VARCHAR(200); -- Use -meta option to resolve the data type
        DECLARE LS_ERROR VARCHAR(4000);
        DECLARE stage_cur CURSOR FOR
          SELECT grant_number
                ,award_year
                ,award_effective_date
                ,grant_budget_direct
                ,grant_budget_indirect
                ,grant_budget_start_date
                ,grant_budget_end_date
                ,grant_award_action
                ,update_timestamp
          FROM   sap_grant_award_stage
          WHERE  update_timestamp = proc_update_timestamp
          AND    grant_number = proc_grant_number
          ORDER BY grant_budget_start_date, grant_budget_end_date;
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
	GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
		 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
		 SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
		 SELECT @full_error INTO LS_ERROR;
        -- SET ls_file_text = concat('Invalid Dataset \n', IFNULL(ls_message_text,'\n'));
			INSERT INTO `jhufibi`.`jhu_sap_award_interface_log`
			(`TABLE_NAME`,`GRANT_NUMBER`,`RESULT_TYPE`,`ERROR_MESSAGE`,`FILE_TEXT`,`FILE_INTEFACE_STATUS`,
			`MAIL_TEXT`,`MAIL_SUBJECT`,`MAIL_RECIPIENT`,`MAIL_SENDER`,`MAIL_SENT_STAUS`,`UPDATE_TIMESTAMP`,`UPDATE_USER`)
			VALUES
			('SAP_GRANT_AWARD',proc_grant_number,'SQLEXCEPTION',LS_ERROR,NULL,'N',null,null,NULL,NULL,'N',now(),'JHU_ADMIN');
	END;
      BEGIN
      DELETE FROM sap_grant_award_stage
      WHERE grant_number = proc_grant_number
      AND   update_timestamp != proc_update_timestamp;
      DELETE FROM sap_grant_award
      WHERE grant_number = proc_grant_number;
      IF proc_award_key != 'X'
      THEN
        SET new_award_year = SUBSTR(proc_award_key, 1, 3);
        SET new_award_effective_date = SUBSTR(proc_award_key, 4, 8);
        SET new_grant_budget_start_date = REPLACE(SUBSTR(proc_award_key, 12, 8), '00000000', '19000101');
        SET new_grant_budget_end_date = REPLACE(SUBSTR(proc_award_key, 20, 8), '00000000', '19000101');
        SET new_grant_award_action  = RTRIM(SUBSTR(proc_award_key, 28, 20));
        SELECT COUNT(*)
        INTO row_count
        FROM sap_grant_award_stage
        WHERE grant_number = proc_grant_number
        AND award_year = new_award_year
        AND award_effective_date = new_award_effective_date
        AND grant_budget_start_date = new_grant_budget_start_date
        AND grant_budget_end_date = new_grant_budget_end_date
        AND grant_award_action = new_grant_award_action;
        IF row_count = 0
        THEN
          INSERT INTO sap_grant_award_stage (grant_number,
                                             award_year,
                                             award_effective_date,
                                             grant_budget_start_date,
                                             grant_budget_end_date,
                                             grant_award_action,
                                             update_timestamp)
          VALUES (proc_grant_number,
                  new_award_year,
                  new_award_effective_date,
                  new_grant_budget_start_date,
                  new_grant_budget_end_date,
                  new_grant_award_action,
                  proc_update_timestamp);
        END IF;
		if proc_update_column IS NOT NULL AND proc_update_column ='grant_budget_direct' then
			 update sap_grant_award_stage
			 set grant_budget_direct=proc_new_value
			 WHERE grant_number = proc_grant_number
			 AND award_year = new_award_year
			 AND award_effective_date =new_award_effective_date
			 AND grant_budget_start_date = new_grant_budget_start_date
			 AND grant_budget_end_date = new_grant_budget_end_date
			 AND grant_award_action = new_grant_award_action;
		elseif proc_update_column IS NOT NULL AND proc_update_column='grant_budget_indirect' then
			 update sap_grant_award_stage
			 set grant_budget_indirect=proc_new_value
			 WHERE grant_number = proc_grant_number
			 AND award_year = new_award_year
			 AND award_effective_date =new_award_effective_date
			 AND grant_budget_start_date = new_grant_budget_start_date
			 AND grant_budget_end_date = new_grant_budget_end_date
			 AND grant_award_action = new_grant_award_action;
		end if;
OPEN stage_cur;
	LOOP1: LOOP BEGIN
	              DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = 1;
         FETCH stage_cur INTO
		          stage_rec_grant_number,
                  stage_rec_award_year,
                  stage_rec_award_effective_date,
                  stage_rec_grant_budget_direct,
                  stage_rec_grant_budget_indirect,
                  stage_rec_grant_budget_start_date,
                  stage_rec_grant_budget_end_date,
                  stage_rec_grant_award_action,
                  stage_rec_update_timestamp;
		  BEGIN
		  IF DONE THEN
		  LEAVE LOOP1;
	      END IF;
		  SET period_counter = period_counter + 1;
          INSERT INTO sap_grant_award (coeus_period,
                                       grant_number,
                                       award_year,
                                       award_effective_date,
                                       grant_budget_direct,
                                       grant_budget_indirect,
                                       grant_budget_start_date,
                                       grant_budget_end_date,
                                       grant_award_action,
                                       update_timestamp)
          VALUES (period_counter,
                  stage_rec_grant_number,
                  stage_rec_award_year,
                  stage_rec_award_effective_date,
                  stage_rec_grant_budget_direct,
                  stage_rec_grant_budget_indirect,
                  stage_rec_grant_budget_start_date,
                  stage_rec_grant_budget_end_date,
                  stage_rec_grant_award_action,
                  stage_rec_update_timestamp);
 END;
 END;
END LOOP;
CLOSE stage_cur;
      END IF;
      END;
    END
$$
DELIMITER ;
