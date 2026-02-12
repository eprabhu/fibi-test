DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` PROCEDURE `AWARD_INTEGRATION_POST_VAL_MATRIX_DELTA`(AV_TYPE INT)
BEGIN
DECLARE LI_SOURCE_COUNT          int;
DECLARE LI_DESTINATION_COUNT     int;
DECLARE PM_GR_COUNT int;
declare LS_GRANT_NUMBER varchar(12);
BEGIN
			DECLARE DONE1 INT DEFAULT FALSE;
			DECLARE grant_version CURSOR FOR
			select sv.grant_number, sv.version_count, av.version_count from sap_version sv, award_version av
			where sv.grant_number = av.grant_number;
			 DECLARE grant_inv CURSOR FOR
            select si.grant_number, si.inv_count, ai.inv_count from sap_inv si, award_inv ai
			where si.grant_number = ai.grant_number;
            DECLARE grant_fund CURSOR FOR
			select sf.grant_number, sf.proposal_number, af.proposal_number
			from sap_fund sf, award_fund af
			where sf.grant_number = af.grant_number;
            DECLARE grant_budget CURSOR FOR
			select sac.grant_number, sac.direct_cost+sac.indirect_cost,  ac.direct_cost+ac.indirect_cost
			from sap_award_cost sac , award_cost ac
			where sac.grant_number = ac.grant_number;
           DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE1 = TRUE;
truncate AWARD_INTEGRATION_POST_VAL_MATRIX;
-- drop table if exists sap_matrix;
drop table if exists sap_version;
drop table if exists award_version;
drop table if exists sap_inv;
drop table if exists award_inv;
drop table if exists sap_fund;
drop table if exists award_fund;
drop table if exists sap_award_cost;
drop table if exists award_cost;
/*create  table sap_matrix
 select grant_number from (
SELECT DISTINCT(TRIM(g.grant_number)) AS grant_number
			  FROM sap_grant g INNER JOIN  sap_sponsored_program s ON g.grant_number = s.grant_number
			  WHERE   (g.update_timestamp > '1900-01-01'
					OR CONCAT(g.grant_number,'-00001')  not IN (SELECT award_number from award)
					OR g.grant_number IN (SELECT grant_number
										FROM   staged_awards
										WHERE  sponsored_program_number IS NULL)
					OR s.update_timestamp > '1900-01-01'
					or CONCAT(g.grant_number,'-00001') in (select a.award_number FROM award a
														where a.sequence_number = (select max(sequence_number)
																			   from award
																			   where award_number = a.award_number)
														and a.update_timestamp < s.update_timestamp )
					or CONCAT(g.grant_number,'-00001') in (select a.award_number FROM award a
														where a.sequence_number = (select max(sequence_number)
																			   from award
																			   where award_number = a.award_number)
														and a.update_timestamp < g.update_timestamp )
					or CONCAT(g.grant_number,'-00001') in ( SELECT   award_number
												  FROM    award
												  WHERE  update_timestamp >= '1900-01-01'
												  AND     update_user <> 'INTRFACE')
					)
				AND g.proposal_number NOT IN ('00000000', '05011234')
		 	AND g.proposal_number IN (select proposal_number from proposal)
			  UNION
			  SELECT g.grant_number
			  FROM   sap_grant g
			  INNER JOIN award a ON  g.grant_number = SUBSTR(a.award_number, 1, 6)
			  WHERE  TRIM(g.grant_start_date) <> TRIM(DATE_FORMAT(a.begin_date, '%Y%m%d'))
			  AND    a.award_number LIKE '%-00001'
			  AND    a.sequence_number = (SELECT MAX(sequence_number)
										  FROM award
										  WHERE award_number = a.award_number)
			AND g.proposal_number NOT IN ('00000000', '05011234')
			AND g.proposal_number IN (select proposal_number from proposal)
			  UNION
			  SELECT g.grant_number
			  FROM   sap_grant g
			  INNER JOIN award_amount_info a ON  g.grant_number = SUBSTR(a.award_number, 1, 6)
			  WHERE  (ROUND(CAST(g.grant_value AS DECIMAL)) <> a.amount_obligated_to_date
			  OR      TRIM(g.grant_end_date) <> TRIM(DATE_FORMAT(a.final_expiration_date, '%Y%m%d'))
			  OR      ROUND(CAST((g.grant_funded_amount) AS DECIMAL)) <> a.anticipated_total_amount)
			  AND    a.award_number LIKE '%-00001'
			  AND    a.sequence_number = (SELECT MAX(sequence_number)
										  FROM award_amount_info
										  WHERE award_number = a.award_number)
					AND g.proposal_number NOT IN ('00000000', '05011234')
			AND g.proposal_number IN (select proposal_number from proposal)
		) SAP ;
Alter table sap_matrix add primary key sap_matrix_PK(grant_number);
select count(grant_number) into LI_SOURCE_COUNT from sap_matrix;*/
select count(grant_number) into LI_SOURCE_COUNT from grant_delta;
select count(distinct substr(award_number,1,6)) into LI_DESTINATION_COUNT from award
where substr(award_number,1,6) in (select grant_number from grant_delta)
and update_user = 'INTRFACE';
INSERT INTO AWARD_INTEGRATION_POST_VAL_MATRIX(MODULE,CRITERIA,SOURCE_COUNT,DESTINATION_COUNT,STATUS)
VALUES('GRANT','TOTAL NUMBER OF DISTINCT GRANTS FROM SAP',LI_SOURCE_COUNT,LI_DESTINATION_COUNT,IF(LI_SOURCE_COUNT = LI_DESTINATION_COUNT,'SUCCESS','FAILED'));
COMMIT;
-- to get the count of awards with any sequence missing
set LI_SOURCE_COUNT = 0;
SET LI_DESTINATION_COUNT = NULL;
select count(*) INTO LI_DESTINATION_COUNT from(
select distinct substr(award_number,1,6) from award where sequence_number = 0
and award_number not in (select award_number from award where sequence_number = 1)
and substr(award_number,1,6) in (select grant_number from grant_delta)
union
select distinct substr(award_number,1,6) from award where sequence_number = 1
and award_number not in (select award_number from award where sequence_number = 0)
and substr(award_number,1,6) in (select grant_number from grant_delta)
) t;
INSERT INTO AWARD_INTEGRATION_POST_VAL_MATRIX(MODULE,CRITERIA,SOURCE_COUNT,DESTINATION_COUNT,STATUS)
VALUES('GRANT_SEQUENCE','AWARD COUNT WITH SEQUENCE DIFFERENCE : ',LI_SOURCE_COUNT,LI_DESTINATION_COUNT,IF(LI_SOURCE_COUNT = LI_DESTINATION_COUNT,'SUCCESS','FAILED'));
-- to get the count of awards with any sequence missing
create  table sap_version
								select T.grant_number as grant_number, count(T.grant_number) as version_count from
                                (  SELECT TRIM(g.grant_number) AS grant_number,
										 NULL AS sponsored_program_number
								  FROM sap_grant g INNER JOIN sap_sponsored_program s ON  g.grant_number = s.grant_number
								  WHERE g.grant_number in (select grant_number  from grant_delta)
								  AND s.sponsored_program_type = 'PM'
								  UNION
								  SELECT TRIM(s.grant_number) AS grant_number,
										 TRIM(s.sponsored_program_number) AS sponsored_program_number
											FROM sap_grant g INNER JOIN sap_sponsored_program s ON  g.grant_number = s.grant_number
								  WHERE g.grant_number in (select grant_number  from grant_delta)
								  AND   s.sponsored_program_type <> 'CS')
								  T
                                  group by T.grant_number ;
create  table award_version
select substr(award_number,1,6) as grant_number,  count(distinct award_number) as version_count from award
where substr(award_number,1,6) in (select grant_number from grant_delta)
and update_user = 'INTRFACE'
group by substr(award_number,1,6) ;
OPEN grant_version;
		grant_version_loop : LOOP
				FETCH grant_version INTO LS_GRANT_NUMBER, LI_SOURCE_COUNT, LI_DESTINATION_COUNT;
				IF DONE1 THEN
					LEAVE grant_version_loop;
				END IF;
				IF LI_SOURCE_COUNT != LI_DESTINATION_COUNT THEN
				set PM_GR_COUNT = 0;
				-- sap_sponsored_program.sponsored_program_type = 'GM' merges to 00001
				select count(*) into PM_GR_COUNT from (
				SELECT distinct TRIM(s.grant_number) AS grant_number,
										 TRIM(s.sponsored_program_number) AS sponsored_program_number
                                         , s.sponsored_program_type
											FROM sap_grant g INNER JOIN sap_sponsored_program s ON  g.grant_number = s.grant_number
								  WHERE g.grant_number = LS_GRANT_NUMBER
								  AND   s.sponsored_program_type in( 'GM')) PM;
					 IF PM_GR_COUNT > 1 THEN
					set LI_SOURCE_COUNT = LI_SOURCE_COUNT - PM_GR_COUNT+1;
					 END IF;
				set PM_GR_COUNT = 0;
				-- sap_sponsored_program.sponsored_program_type = 'PM' merges to 00002
				select count(*) into PM_GR_COUNT from (
				SELECT distinct TRIM(s.grant_number) AS grant_number,
										 TRIM(s.sponsored_program_number) AS sponsored_program_number
                                         , s.sponsored_program_type
											FROM sap_grant g INNER JOIN sap_sponsored_program s ON  g.grant_number = s.grant_number
								  WHERE g.grant_number = LS_GRANT_NUMBER
								   and s.sponsored_program_number is not null
								  AND   s.sponsored_program_type in( 'PM')) PM;
					 IF PM_GR_COUNT > 0 THEN
					set LI_SOURCE_COUNT = LI_SOURCE_COUNT - PM_GR_COUNT;
					 END IF;
				END IF;
					INSERT INTO AWARD_INTEGRATION_POST_VAL_MATRIX(MODULE,CRITERIA,SOURCE_COUNT,DESTINATION_COUNT,STATUS)
					VALUES('GRANT_VERSION',concat('VERSIONS TO BE GENERATED FOR THE GRANT : ', LS_GRANT_NUMBER),LI_SOURCE_COUNT,LI_DESTINATION_COUNT,IF(LI_SOURCE_COUNT = LI_DESTINATION_COUNT,'SUCCESS','FAILED'));
		END LOOP;
CLOSE grant_version;
set done1 = FALSE;
create  table sap_inv
 SELECT  T.grant_number as grant_number, count(T.person_id) as inv_count
	FROM (SELECT gp.grant_number  as grant_number, p.person_id AS person_id
			  FROM sap_grant_person gp
			  INNER JOIN person p  ON gp.person_id = p.person_id
			  WHERE gp.grant_number in (select grant_number from grant_delta)
			  AND gp.responsibility_code IN ('PRIN', 'COIN')
	  UNION
		  SELECT ssp.grant_number as grant_number , p.person_id  AS person_id
		  FROM sap_sponsored_program_person spp
		  INNER JOIN person p ON spp.person_id = p.person_id
          INNER JOIN sap_sponsored_program ssp ON ssp.sponsored_program_number = spp.sponsored_program_number
		  WHERE spp.sponsored_program_number in (select sponsored_program_number from sap_sponsored_program where grant_number  in (select grant_number from grant_delta))
		  AND spp.responsibility_code IN ('PRIN', 'COIN'))T
	group BY  T.grant_number;
 create  table award_inv
select substr(award_number,1,6) as grant_number , count(distinct PERSON_ID) as inv_count from award_persons
 where  substr(award_number,1,6) in (select grant_number from grant_delta)
 and update_user = 'INTRFACE' and PERSON_ID != '99999880'
 and sequence_number = 0
group by substr(award_number,1,6) ;
OPEN grant_inv;
		grant_inv_loop : LOOP
				FETCH grant_inv INTO LS_GRANT_NUMBER, LI_SOURCE_COUNT, LI_DESTINATION_COUNT;
				IF DONE1 THEN
					LEAVE grant_inv_loop;
				END IF;
					INSERT INTO AWARD_INTEGRATION_POST_VAL_MATRIX(MODULE,CRITERIA,SOURCE_COUNT,DESTINATION_COUNT,STATUS)
					VALUES('GRANT_PERSON',concat('DISTINCT INVESTIGATORS IN THE GRANT : ', LS_GRANT_NUMBER),LI_SOURCE_COUNT,LI_DESTINATION_COUNT,IF(LI_SOURCE_COUNT = LI_DESTINATION_COUNT,'SUCCESS','FAILED'));
		END LOOP;
CLOSE grant_inv;
set done1 = FALSE;
create  table sap_fund
select distinct grant_number, proposal_number from sap_grant
where grant_number in (select grant_number from grant_delta);
create  table award_fund
select distinct substr(a.award_number,1,6) as grant_number ,  p.proposal_number as proposal_number
 from award_funding_proposals afp,
award a , proposal p
 where afp.AWARD_ID = a.AWARD_ID
 and afp.PROPOSAL_ID = p.PROPOSAL_ID
 and substr(a.award_number,1,6)  in (select grant_number from grant_delta)
 and afp.update_user = 'INTRFACE';
OPEN grant_fund;
		grant_fund_loop : LOOP
				FETCH grant_fund INTO LS_GRANT_NUMBER, LI_SOURCE_COUNT, LI_DESTINATION_COUNT;
				IF DONE1 THEN
					LEAVE grant_fund_loop;
				END IF;
					INSERT INTO AWARD_INTEGRATION_POST_VAL_MATRIX(MODULE,CRITERIA,SOURCE_COUNT,DESTINATION_COUNT,STATUS)
					VALUES('GRANT_FUNDED_PROPOSAL',concat('PROPOSAL FUNDED BY THE GRANT : ', LS_GRANT_NUMBER),LI_SOURCE_COUNT,LI_DESTINATION_COUNT,IF(LI_SOURCE_COUNT = LI_DESTINATION_COUNT,'SUCCESS','FAILED'));
		END LOOP;
CLOSE grant_fund;
set done1 = FALSE;
create  table sap_award_cost
select distinct grant_number, sum(cast(grant_budget_direct as decimal(12,2))) as direct_cost, sum(cast(grant_budget_indirect as decimal(12,2))) as indirect_cost
from sap_grant_award where grant_number in(select grant_number from grant_delta)
group by grant_number;
create  table award_cost
select distinct substr(award_number,1,6) as grant_number, sum(total_direct_cost)  as direct_cost, sum(total_indirect_cost) as indirect_cost from award_budget_header
where  sequence_number = 0
and IS_LATEST_VERSION = 'Y'
and total_direct_cost is not null and total_indirect_cost is not null
and substr(award_number,1,6)  in (select grant_number from grant_delta)
and update_user = 'INTRFACE' group by award_number;
OPEN grant_budget;
		grant_budget_loop : LOOP
				FETCH grant_budget INTO LS_GRANT_NUMBER, LI_SOURCE_COUNT, LI_DESTINATION_COUNT;
				IF DONE1 THEN
					LEAVE grant_budget_loop;
				END IF;
					INSERT INTO AWARD_INTEGRATION_POST_VAL_MATRIX(MODULE,CRITERIA,SOURCE_COUNT,DESTINATION_COUNT,STATUS)
					VALUES('GRANT_BUDGET',concat('TOTAL COST OF THE GRANT  : ', LS_GRANT_NUMBER),LI_SOURCE_COUNT,LI_DESTINATION_COUNT,IF(LI_SOURCE_COUNT = LI_DESTINATION_COUNT,'SUCCESS','FAILED'));
		END LOOP;
CLOSE grant_budget;
commit;
select * from AWARD_INTEGRATION_POST_VAL_MATRIX;
END;
END
$$
DELIMITER ;
