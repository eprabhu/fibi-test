DELIMITER $$
CREATE  PROCEDURE `GET_RPT_104E_INFO_2018`(IN start_date_in  VARCHAR(500),IN end_date_in  VARCHAR(500),IN unit  VARCHAR(8))
BEGIN
select DISTINCT
substr(a.award_number, 1,6) as GRANT_NUMBER
,ai.full_name as PERSON_NAME
,au.UNIT_NUMBER
,a.TITLE
,s.SPONSOR_NAME
,act.DESCRIPTION as ACTIVITY_TYPE
,oat.DESCRIPTION as AWARD_TYPE
,sag.AWARD_YEAR
,amfd.BUDGET_PERIOD
,sag.GRANT_AWARD_ACTION
,date_format(amfd.START_DATE,'%d/%m/%Y') START_DATE
,date_format(amfd.END_DATE,'%d/%m/%Y')END_DATE
,amfd.TOTAL_DIRECT_COST as DIRECT_COST
,amfd.TOTAL_INDIRECT_COST as INDIRECT_COST
,fn_get_rpt_sch_name(au.unit_number) as SCHOOL_NAME
,fn_get_rpt_sch_number(au.unit_number) as SCHOOL_NUMBER
,FN_GET_RPT_ORA_NAME(au.unit_number) as ORA_NAME
,FN_GET_RPT_ORA_NUMBER(au.unit_number) as ORA_NUMBER
,fn_get_rpt_parent_unit_name (au.unit_number) as PARENT_UNIT_NAME
,fn_get_rpt_parent_unit_number (au.unit_number) as PARENT_UNIT_NUMBER
,fn_get_unit_name (au.unit_number) as UNIT_NAME
,'104e' as REPORT_NUMBER
,start_date_in as PARAM_ENTERED_1
,end_date_in as PARAM_ENTERED_2
,unit as PARAM_ENTERED_3
,sysdate() as RUN_TIME
,'Award Years Received' as REPORT_TITLE
from
award a
left join AWARD_AMT_FNA_DISTRIBUTION amfd on  amfd.award_number = a.award_number  and amfd.SEQUENCE_NUMBER =
        (select max(SEQUENCE_NUMBER)
        from AWARD_AMT_FNA_DISTRIBUTION
        where AWARD_NUMBER = amfd.award_number)
left join award_persons ai on  ai.award_number = a.award_number and ai.SEQUENCE_NUMBER =
        (select max(SEQUENCE_NUMBER)
        from award_persons
        where AWARD_NUMBER = ai.award_number)
left join award_person_unit au on  au.AWARD_PERSON_ID = ai.AWARD_PERSON_ID  and au.SEQUENCE_NUMBER =
        (select max(SEQUENCE_NUMBER)
        from award_person_unit
        where AWARD_NUMBER = au.award_number)
left join sponsor s on  s.sponsor_code = a.sponsor_code
left join activity_type act on act.ACTIVITY_TYPE_CODE=a.ACTIVITY_TYPE_CODE
left join award_type oat on oat.award_type_code =a.award_type_code
left join saP_grant_award sag on amfd.BUDGET_PERIOD = sag.COEUS_PERIOD
and substr(a.award_number, 1,6) =sag.GRANT_NUMBER
where
a.SEQUENCE_NUMBER =
        (select max(SEQUENCE_NUMBER)
        from award
        where AWARD_NUMBER = a.award_number)
and amfd.START_DATE between str_to_date(start_date_in,'%m/%d/%Y') and str_to_date(end_date_in, '%m/%d/%Y')
and ai.pi_flag='Y'
and au.AWARD_PERSON_ID = ai.AWARD_PERSON_ID
and au.lead_unit_flag='Y'
and find_in_set(au.unit_number,fn_get_temp_unit(unit))
order by unit_number, person_name, substr(a.award_number, 1,6), sag.award_year,  sag.AWARD_EFFECTIVE_DATE;
END
$$
DELIMITER ;
