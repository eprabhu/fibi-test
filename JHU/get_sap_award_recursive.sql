DELIMITER $$
CREATE  PROCEDURE `get_sap_award_recursive`()
BEGIN
    declare ls_error_msg varchar(4000);
	BEGIN
      DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
		BEGIN
			GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
			 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
			SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
			SELECT @full_error INTO LS_ERROR_MSG;
            insert into integration_error_log (SECTION, ERROR_MESSAGE, AWARD_NUMBER)
				values('sap_award_recursive', LS_ERROR_MSG, LS_GRANT_NUMBER );
		END;
				insert into sap_award_time_log (section, Execution_start_time )
				values('sap_award_recursive 1st begin', UTC_TIMESTAMP());
					set sql_safe_updates = 0;
					UPDATE sap_interfaces SET    coeus_award_update ='1990-01-01';
					set sql_safe_updates = 1;
					call get_sap_award_changes();
				insert into sap_award_time_log (section, Execution_start_time )
				values('sap_award_recursive 1st end', UTC_TIMESTAMP());
				insert into sap_award_time_log (section, Execution_start_time )
				values('sap_award_recursive 2nd begin', UTC_TIMESTAMP());
					set sql_safe_updates = 0;
					UPDATE sap_interfaces SET    coeus_award_update ='1990-01-01';
					set sql_safe_updates = 1;
					call get_sap_award_changes();
				insert into sap_award_time_log (section, Execution_start_time )
				values('sap_award_recursive 2nd end', UTC_TIMESTAMP());
				insert into sap_award_time_log (section, Execution_start_time )
				values('sap_award_recursive 3rd begin', UTC_TIMESTAMP());
					set sql_safe_updates = 0;
					UPDATE sap_interfaces SET    coeus_award_update ='1990-01-01';
					set sql_safe_updates = 1;
					call get_sap_award_changes();
				insert into sap_award_time_log (section, Execution_start_time )
				values('sap_award_recursive 3rd end', UTC_TIMESTAMP());
				insert into sap_award_time_log (section, Execution_start_time )
				values('sap_award_recursive 4th begin', UTC_TIMESTAMP());
					set sql_safe_updates = 0;
					UPDATE sap_interfaces SET    coeus_award_update ='1990-01-01';
					set sql_safe_updates = 1;
					call get_sap_award_changes();
				insert into sap_award_time_log (section, Execution_start_time )
				values('sap_award_recursive 4th end', UTC_TIMESTAMP());
				insert into sap_award_time_log (section, Execution_start_time )
				values('sap_award_recursive 5th begin', UTC_TIMESTAMP());
					set sql_safe_updates = 0;
					UPDATE sap_interfaces SET    coeus_award_update ='1990-01-01';
					set sql_safe_updates = 1;
					call get_sap_award_changes();
				insert into sap_award_time_log (section, Execution_start_time )
				values('sap_award_recursive 5th end', UTC_TIMESTAMP());
				insert into sap_award_time_log (section, Execution_start_time )
				values('sap_award_recursive 6th begin', UTC_TIMESTAMP());
					set sql_safe_updates = 0;
					UPDATE sap_interfaces SET    coeus_award_update ='1990-01-01';
					set sql_safe_updates = 1;
					call get_sap_award_changes();
				insert into sap_award_time_log (section, Execution_start_time )
				values('sap_award_recursive 6th end', UTC_TIMESTAMP());
				insert into sap_award_time_log (section, Execution_start_time )
				values('sap_award_recursive 7th begin', UTC_TIMESTAMP());
					set sql_safe_updates = 0;
					UPDATE sap_interfaces SET    coeus_award_update ='1990-01-01';
					set sql_safe_updates = 1;
					call get_sap_award_changes();
				insert into sap_award_time_log (section, Execution_start_time )
				values('sap_award_recursive 7th end', UTC_TIMESTAMP());
				insert into sap_award_time_log (section, Execution_start_time )
				values('sap_award_recursive 8th begin', UTC_TIMESTAMP());
					set sql_safe_updates = 0;
					UPDATE sap_interfaces SET    coeus_award_update ='1990-01-01';
					set sql_safe_updates = 1;
					call get_sap_award_changes();
				insert into sap_award_time_log (section, Execution_start_time )
				values('sap_award_recursive 8th end', UTC_TIMESTAMP());
                create table  sap_award_error as
                select distinct substr(AWARD_NUMBER,1,6) as grant_number from integration_error_log ;
                truncate integration_error_log;
                call get_sap_award_error();
	END;
END
$$
DELIMITER ;
