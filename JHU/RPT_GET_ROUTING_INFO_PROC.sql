DELIMITER $$
CREATE  PROCEDURE `RPT_GET_ROUTING_INFO_PROC`(IN UNIT  VARCHAR(500)
,IN BEFORE_DATE_IN  VARCHAR(50)
,IN AFTER_DATE_IN  VARCHAR(50))
begin
 select
 extt.Proposal_Number  as PROP_DEVELOPMENT
,extt.Type as PROPOSAL_TYPE
,extt.Activity_Type as ACTIVITY_TYPE
,extt.Award_Type as ANTICIPATED_AWARD_TYPE
,extt.Status as STATUS
,extt.Title as TITLE
,extt.BA as BUSINESS_AREA
,extt.Lead_Unit as UNIT_NUMBER
,extt.Lead_Unit_Name as UNIT_NAME
,get_999_department(extt.Lead_Unit) as DEPARTMENT
,sc.unit_name DIVISION
,rs.unit_name AGGREGATED_DIVISION
,extt.PI_Name as PRINCIPAL_INV
,extt.sponsor_code as SPONSOR_CODE
,extt.sponsor_name as SPONSOR
,st.description as SPONSOR_TYPE
,SH.Hierarchy_name as AGGREGATED_SPONSOR_TYPE
,extt.prime_sponsor_code as PRIME_SPONSOR_CODE
,extt.CFDA_Number as CFDA_NUMBER
,extt.Program_Announcement_Number as ANNOUNCEMENT_NUMBER
,extt.S2SType as S2S_TYPE
,extt.S2SSTATUS as S2S_SUBMISSION_STATUS
,extt.deadline_date as DEADLINE
,extt.Start_User as ROUTING_START_USER
,extt.Start_date as ROUTING_START
,working_days(extt.start_date,date(extt.deadline_date))  as WEEKDAYS_ROUTED_BEFORE_DL
,extt.Next_Approver as ROUTING_NEXT_APPROVER
,extt.ORA_Receipt_Date_Orig as ORA_RECEIPT_FIRST_ATTEMPT
,working_days(str_to_date(extt.ora_receipt_date_orig, '%m/%d/%Y'), date(extt.deadline_date)) as WEEKDAYS_ORARECEIVED_BEFORE_DL
,extt.ora_receipt_date_final as ORA_RECEIPT_FINAL_ATTEMPT
,extt.End_User as ROUTING_END_USER
,extt.End_date as ROUTING_END
,extt.Attempts as ROUTING_ATTEMPTS
,rs.ora_office as ORA
,extt.FY as FISCAL_YEAR
,extt.FM as FISCAL_MONTH
,extt.IPN as INST_PROPOSAL
,'500e' REPORT_NUMBER
,'Routing Analysis' REPORT_TITLE
,STR_TO_DATE(BEFORE_DATE_IN, '%m/%d/%Y') as PARAM_ENTERED_1
,STR_TO_DATE(AFTER_DATE_IN , '%m/%d/%Y') as PARAM_ENTERED_2
,UNIT PARAM_ENTERED_3
,sysdate()  as RUN_TIME
,@@hostname HOST_NAME
from ext_table_routing extt
LEFT OUTER JOIN report_school rs ON extt.ba=rs.business_area
LEFT OUTER JOIN Sponsor s on extt.sponsor_code=s.sponsor_code
LEFT OUTER JOIN sponsor_type st on s.sponsor_type_code = st.sponsor_type_code
LEFT OUTER JOIN(SELECT sponsor_code sponsor_code, parent_name hierarchy_name
            FROM   report_sponsor_hierarchy
            UNION
            SELECT isp.sponsor_code sponsor_code,
                   CASE WHEN isp.sponsor_type_code= '2' THEN 'State/Local Government'
                        WHEN isp.sponsor_type_code= '3' THEN 'Private Profit'
                        WHEN isp.sponsor_type_code= '0' THEN 'Other Federal'
                        WHEN isp.sponsor_type_code= '1' THEN 'State/Local Government'
                        WHEN isp.sponsor_type_code= '4' THEN 'Foundation/Non-Profit'
                        WHEN isp.sponsor_type_code= '5' THEN 'Foundation/Non-Profit'
                        WHEN isp.sponsor_type_code= '6' THEN 'Institution of Higher Education'
                        WHEN isp.sponsor_type_code= '10' THEN 'Foreign'
                        WHEN isp.sponsor_type_code= '11' THEN 'Foreign'
                        WHEN isp.sponsor_type_code= '12' THEN 'Foreign'
                        WHEN isp.sponsor_type_code= '13' THEN 'Foreign'
                        WHEN isp.sponsor_type_code= '14' THEN 'Foreign'
                        WHEN isp.sponsor_type_code= '15' THEN 'Foreign'
                        WHEN isp.sponsor_type_code= '16' THEN 'Foreign'
                        WHEN isp.sponsor_type_code= '99' THEN 'Other' END hierarchy_name
            FROM   sponsor isp
            WHERE  isp.sponsor_code NOT IN (SELECT sponsor_code FROM report_sponsor_hierarchy)) sh on sh.sponsor_code=extt.sponsor_code
  INNER JOIN  bw_view_zgm_062 sc on extt.ba = sc.business_area
where FIND_IN_SET(extt.lead_unit ,fn_get_temp_unit(unit))
and extt.start_date between STR_TO_DATE(before_date_in,'%m/%d/%Y') and STR_TO_DATE(after_date_in,'%m/%d/%Y')
order by extt.Proposal_Number DESC;
end
$$
DELIMITER ;
