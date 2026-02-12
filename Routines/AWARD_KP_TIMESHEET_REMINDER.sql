DELIMITER $$
CREATE DEFINER=`fibi`@`%` PROCEDURE `AWARD_KP_TIMESHEET_REMINDER`( AV_DAYS INT )
BEGIN
DECLARE LS_AWARD_ID INT;
DECLARE LS_AWARD_PERSON_ID INT;
DECLARE LS_TIMESHEET_TYPE varchar(50);
DECLARE LI_TIMESHEET_COUNT int(11);
DECLARE LS_AWARD_START_DATE DATETIME;
DECLARE LS_AWARD_END_DATE DATETIME;
DECLARE LI_SPAN int(11);
DECLARE LI_YEARS int(11);
DECLARE LI_PREV_YEAR INT(11);
DECLARE LS_QUERY LONGTEXT;
SET LS_QUERY='';
BEGIN
DECLARE DONE1 INT DEFAULT FALSE;
DECLARE AWARD_CURSOR CURSOR FOR
select AWARD_ID, PERSON_ID from award_persons where award_id in (SELECT AWARD_ID FROM award WHERE AWARD_ID IN (
				SELECT  MODULE_ITEM_KEY FROM custom_data WHERE CUSTOM_DATA_ELEMENTS_ID in (
                select CUSTOM_DATA_ELEMENTS_ID from CUSTOM_DATA_ELEMENTS a where CUSTOM_ELEMENT_NAME = 'key person timesheet'
                and  COLUMN_VERSION_NUMBER = (SELECT MAX(COLUMN_VERSION_NUMBER) FROM CUSTOM_DATA_ELEMENTS b WHERE a.CUSTOM_ELEMENT_NAME = b.CUSTOM_ELEMENT_NAME))
                and VALUE = 'YES' and MODULE_ITEM_CODE = 1 and MODULE_SUB_ITEM_CODE = 0	AND AWARD_SEQUENCE_STATUS = 'ACTIVE'));
DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE1 = TRUE;
OPEN AWARD_CURSOR;
AWARD_CURSOR_LOOP : LOOP
        FETCH AWARD_CURSOR INTO
		LS_AWARD_ID,
		LS_AWARD_PERSON_ID;
                IF DONE1 THEN
                        LEAVE AWARD_CURSOR_LOOP;
                END IF;
			select value into LS_TIMESHEET_TYPE from parameter where parameter_name = 'AWARD_KEY_PERSON_TIMESHEET_TYPE';
			select BEGIN_DATE,FINAL_EXPIRATION_DATE into LS_AWARD_START_DATE, LS_AWARD_END_DATE from award
			where award_id = LS_AWARD_ID;
			select count(*) into LI_TIMESHEET_COUNT from award_keyperson_timesheet
			where award_id = LS_AWARD_ID
			and AWARD_PERSON_ID in (select  AWARD_PERSON_ID from award_persons where PERSON_ID = LS_AWARD_PERSON_ID)
			and TIMESHEET_TYPE = LS_TIMESHEET_TYPE ;
		if LI_TIMESHEET_COUNT > 0 THEN
			if trim(upper(LS_TIMESHEET_TYPE)) = 'YEARLY' then
				SELECT TIMESTAMPDIFF(YEAR, LS_AWARD_START_DATE, DATE_ADD(now(),interval AV_DAYS day)) into LI_SPAN;
				if LI_SPAN > LI_TIMESHEET_COUNT THEN
					set LS_QUERY := concat(LS_QUERY,'select 1 as MODULE_CODE, 0 as SUB_MODULE_CODE, ''',LS_AWARD_ID,''' as MODULE_ITEM_KEY, 0 as SUB_MODULE_ITEM_KEY,''',LS_AWARD_PERSON_ID,''' as PERSON_ID ',' union all ');
					iterate AWARD_CURSOR_LOOP;
				end if;
			elseif trim(upper(LS_TIMESHEET_TYPE)) = 'HALFYEARLY' then
				if CEILING(MONTH(now())/6) = 1 then
					SELECT TIMESTAMPDIFF(YEAR, LS_AWARD_START_DATE, DATE_ADD(now(),interval AV_DAYS day))*2 into LI_SPAN;
				elseif CEILING(MONTH(now())/6) = 2 then
					SELECT (TIMESTAMPDIFF(YEAR, LS_AWARD_START_DATE, DATE_ADD(now(),interval AV_DAYS day))*2)+1 into LI_SPAN;
				end if;
					if LI_SPAN > LI_TIMESHEET_COUNT THEN
                    set LS_QUERY := concat(LS_QUERY,'select 1 as MODULE_CODE, 0 as SUB_MODULE_CODE, ''',LS_AWARD_ID,''' as MODULE_ITEM_KEY, 0 as SUB_MODULE_ITEM_KEY,''',LS_AWARD_PERSON_ID,''' as PERSON_ID ',' union all ');
						iterate AWARD_CURSOR_LOOP;
					end if;
			elseif trim(upper(LS_TIMESHEET_TYPE)) = 'QUARTERLY' then
				if quarter(now()) = 1 THEN
					SELECT TIMESTAMPDIFF(YEAR, LS_AWARD_START_DATE, DATE_ADD(now(),interval AV_DAYS day))*4 into LI_SPAN;
				elseif quarter(now()) = 2 THEN
					SELECT (TIMESTAMPDIFF(YEAR, LS_AWARD_START_DATE, DATE_ADD(now(),interval AV_DAYS day))*4)+1 into LI_SPAN;
				elseif quarter(now()) = 3 THEN
					SELECT (TIMESTAMPDIFF(YEAR, LS_AWARD_START_DATE, DATE_ADD(now(),interval AV_DAYS day))*4)+2 into LI_SPAN;
				elseif quarter(now()) = 4 THEN
					SELECT (TIMESTAMPDIFF(YEAR, LS_AWARD_START_DATE, DATE_ADD(now(),interval AV_DAYS day))*4)+4 into LI_SPAN;
				END IF;
			if LI_SPAN > LI_TIMESHEET_COUNT THEN
				set LS_QUERY := concat(LS_QUERY,'select 1 as MODULE_CODE, 0 as SUB_MODULE_CODE, ''',LS_AWARD_ID,''' as MODULE_ITEM_KEY, 0 as SUB_MODULE_ITEM_KEY,''',LS_AWARD_PERSON_ID,''' as PERSON_ID ',' union all ');
				 iterate AWARD_CURSOR_LOOP;
			end if;
		end if;
		elseif LI_TIMESHEET_COUNT = 0 then
		SELECT TIMESTAMPDIFF(YEAR, LS_AWARD_START_DATE, DATE_ADD(now(),interval AV_DAYS day)) into LI_YEARS;
		select year((DATE_ADD(now(),interval AV_DAYS day))) - year(LS_AWARD_START_DATE) into LI_PREV_YEAR;
		if LI_YEARS > 0  THEN
			set LS_QUERY := concat(LS_QUERY,'select 1 as MODULE_CODE, 0 as SUB_MODULE_CODE, ''',LS_AWARD_ID,''' as MODULE_ITEM_KEY, 0 as SUB_MODULE_ITEM_KEY,''',LS_AWARD_PERSON_ID,''' as PERSON_ID ',' union all ');
					iterate AWARD_CURSOR_LOOP;
		elseif LI_YEARS = 0  THEN
			if trim(upper(LS_TIMESHEET_TYPE)) = 'HALFYEARLY' then
				 select CEILING(MONTH(DATE_ADD(now(),interval AV_DAYS day))/6) into LI_SPAN;
			if LI_SPAN > 0 and LI_PREV_YEAR > 0 THEN
			set LS_QUERY := concat(LS_QUERY,'select 1 as MODULE_CODE, 0 as SUB_MODULE_CODE, ''',LS_AWARD_ID,''' as MODULE_ITEM_KEY, 0 as SUB_MODULE_ITEM_KEY,''',LS_AWARD_PERSON_ID,''' as PERSON_ID ',' union all ');
					iterate AWARD_CURSOR_LOOP;
			end if;
			elseif  trim(upper(LS_TIMESHEET_TYPE)) = 'QUARTERLY' then
			 select  quarter(DATE_ADD(now(),interval AV_DAYS day)) into LI_SPAN;
			 if LI_SPAN > 0 and LI_PREV_YEAR > 0 THEN
			 set LS_QUERY := concat(LS_QUERY,'select 1 as MODULE_CODE, 0 as SUB_MODULE_CODE, ''',LS_AWARD_ID,''' as MODULE_ITEM_KEY, 0 as SUB_MODULE_ITEM_KEY,''',LS_AWARD_PERSON_ID,''' as PERSON_ID ',' union all ');
					iterate AWARD_CURSOR_LOOP;
				end if;
			end if;
		end if;
    end if;
END LOOP;
if LS_QUERY not like '' then
		set LS_QUERY := substring(LS_QUERY, 1 ,length(LS_QUERY)-10);
		set LS_QUERY := concat(LS_QUERY, ';');
	end if;
CLOSE AWARD_CURSOR;
END	;
SET @QUERY_STATEMENT = LS_QUERY;
PREPARE EXECUTABLE_STAEMENT FROM @QUERY_STATEMENT;
EXECUTE EXECUTABLE_STAEMENT;
end
$$
DELIMITER ;
