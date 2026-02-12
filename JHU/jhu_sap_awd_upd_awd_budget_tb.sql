DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` PROCEDURE `jhu_sap_awd_upd_awd_budget_tb`(av_award_id  INT
  ,av_award_number VARCHAR(12)
  ,av_sequence_number INT(4)
  ,av_obligated DECIMAL(12,2)
  ,av_anticipated DECIMAL(12,2)
  ,av_start_date VARCHAR(10)
  ,av_end_date VARCHAR(10)
  ,av_update_timestamp  DATE
  )
BEGIN
DECLARE li_budget_header_id INT(11);
DECLARE LI_total_indirect_cost DECIMAL(12,2);
DECLARE LI_total_direct_cost DECIMAL(12,2);
DECLARE AL_ready_exists INT ;
DECLARE LS_ERROR_MSG VARCHAR(1000);
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
		BEGIN
			GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
			 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
			SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
			SELECT @full_error INTO LS_ERROR_MSG;
            insert into integration_error_log (SECTION, ERROR_MESSAGE, AWARD_NUMBER, sequence_number)
				values('AWARD Budget', LS_ERROR_MSG, av_award_number, av_sequence_number);
		END;
SET SQL_SAFE_UPDATES= 0;
  DELETE from award_budget_period
  where budget_header_id in (select budget_header_id FROM award_budget_header
					  WHERE award_number = av_award_number
					  AND sequence_number = av_sequence_number
                    );
  DELETE FROM award_rates where  BUDGET_HEADER_ID in(select BUDGET_HEADER_ID from award_budget_header
													  WHERE award_number = av_award_number
													   AND sequence_number = av_sequence_number
                                                    );
  DELETE FROM award_budget_header
  WHERE award_number = av_award_number
   AND sequence_number = av_sequence_number
  ;
SELECT SUM(CAST(IFNULL(grant_budget_direct,'0.00') as DECIMAL(12,2)))
	  into LI_total_direct_cost
      FROM   sap_grant_award
	  WHERE grant_number = SUBSTR(av_award_number, 1, 6);
	  SELECT SUM(CAST(IFNULL(grant_budget_indirect,'0.00')  as DECIMAL(12,2)))
	  into LI_total_indirect_cost
      FROM   sap_grant_award
	  WHERE grant_number = SUBSTR(av_award_number, 1, 6);
set AL_ready_exists = 0;
select count(*) into AL_ready_exists
from award_budget_header
where award_id = av_award_id
and award_number = av_award_number
and sequence_number = av_sequence_number;
if AL_ready_exists = 0 THEN
  INSERT INTO award_budget_header (award_id
									,award_number
									,sequence_number
									,anticipated_total
									,obligated_total
									,update_timestamp
									,update_user
									,budget_type_code
									,comments
									,create_timestamp
									,create_user
									,start_date
									,end_date
									,total_cost
									,total_direct_cost
									,total_indirect_cost
									,version_number
									,award_budget_status_code
									,is_latest_version
									,available_fund_type
									,virement
									,cumulative_virement
									,is_auto_calc
									,on_off_campus_flag
									,rate_class_code
									,rate_type_code
							   )
  VALUES (av_award_id
		,av_award_number
		,av_sequence_number
		,(IFNULL(av_anticipated,0) - IFNULL(av_obligated,0))
		,av_obligated
		,av_update_timestamp
		,'INTRFACE'
		,1
		,'INTRFACE'
		,av_update_timestamp
		,'INTRFACE'
		,DATE_FORMAT(av_start_date, '%Y-%m-%d')
        ,DATE_FORMAT(av_end_date, '%Y-%m-%d')
		,LI_TOTAL_DIRECT_COST+LI_TOTAL_INDIRECT_COST
		,LI_TOTAL_DIRECT_COST
		,LI_TOTAL_INDIRECT_COST
		,1
		,10
		,'Y'
		,'A'
		,0
		,0
		,'N'
		,'N'
		,1
		,1
		);
END IF;
		--  set li_budget_header_id = (SELECT LAST_INSERT_ID());
        select 	budget_header_id into li_budget_header_id
		from  award_budget_header
		WHERE award_number = av_award_number
		AND sequence_number = av_sequence_number;
		INSERT INTO award_budget_period(budget_period,
										start_date,
										end_date,
										total_cost,
										total_direct_cost,
										total_indirect_cost,
										update_timestamp,
										update_user,
										version_number,
										budget_header_id,
										award_number)
		VALUES(1,
				DATE_FORMAT(av_start_date, '%Y-%m-%d'),
				DATE_FORMAT(av_end_date, '%Y-%m-%d'),
				LI_total_direct_cost+LI_total_indirect_cost,
				LI_total_direct_cost,
				LI_total_indirect_cost,
				av_update_timestamp,
				'INTRFACE',
				1,
				li_budget_header_id,
				av_award_number
		);
		COMMIT;
END
$$
DELIMITER ;
