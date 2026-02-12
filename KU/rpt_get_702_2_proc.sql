DELIMITER $$
CREATE PROCEDURE `rpt_get_702_2_proc`(
                                  IN person_id_in                VARCHAR(40)
                                , IN other_support_as_of_date_in VARCHAR(40)
                              )
BEGIN
        select distinct
                        'Funded'                                          as PROPOSAL_STATUS
                      , date_format(a.AWARD_EFFECTIVE_DATE,'%M/%d/%Y')    as PROJECT_START_DATE
                      , date_format(aai.FINAL_EXPIRATION_DATE,'%M/%d/%Y') as PROJECT_END_DATE
                      , date_format (amfd.start_date, '%M/%d/%Y')            PERIOD_START_DATE
                      , date_format (amfd.end_date, '%M/%d/%Y')              PERIOD_END_DATE
                      , sga.GRANT_AWARD_ACTION                            as AWARD_ACTION
                      , amfd.TOTAL_DIRECT_COST                               PERIOD_DIRECT_COST
                      , aai.ANTICIPATED_TOTAL_DIRECT                         TOT_PROJ_DIRECT_COST
                      , amfd.BUDGET_PERIOD
                      , pi.PERCENTAGE_OF_EFFORT as "IP EFFORT %"
                      , CASE
                                        WHEN pi.prop_person_role_id in (1, 3, 5)
                                                        then pi.PI_FLAG
                                                        else 'N'
                        end AS PRINCIPAL_INVESTIGATOR_FLAG
                      ,'-'                          as PERSON_NAME
                      , a.sponsor_award_number         AWARD_ID
                      , p.title                        TITLE
                      , ai.FULL_NAME                as AWARD_PI
                      , s.ACRONYM                      SPONSOR_ACRO
                      , s.sponsor_name                 SPONSOR
                      , act.description                PURPOSE
                      , pt.description                 PROPOSAL_TYPE
                      , at.description                 AWARD_TYPE
                      , substr(a.award_number, 1,6) as SAP_NUMBER
                      , p.PROPOSAL_NUMBER
                      , oas.description as GRANT_STATUS
                      ,'702-2'          as REPORT_NUMBER
                      , person_id_in    as PARAM_ENTERED_1
                      , pi.FULL_NAME    as TARGET_INVESTIGATOR
                      , other_support_as_of_date_in as PARAM_ENTERED_2
                      , sysdate()                                            as RUN_TIME
                      ,'Other Support part2'                                 as REPORT_TITLE
                      , @@hostname                                           as HOST_NAME
                      , NULL                                                 as NOTE
        from
                        award_funding_proposals afp
                        left join
                                        award a
                                        on
                                                        afp.AWARD_ID = a.AWARD_ID
                        left join
                                        award_status oas
                                        on
                                                        a.status_code = oas.status_code
                        left join
                                        AWARD_AMOUNT_INFO aai
                                        on
                                                        aai.AWARD_ID=a.AWARD_ID
                        left outer join
                                        proposal p
                                        on
                                                        p.PROPOSAL_ID = afp.PROPOSAL_ID
                        left join
                                        proposal_persons pi
                                        on
                                                        p.PROPOSAL_ID = pi.PROPOSAL_ID
                        left join
                                        award_persons ai
                                        on
                                                        ai.AWARD_ID = afp.AWARD_ID
                        left outer join
                                        sponsor s
                                        on
                                                        a.sponsor_code = s.sponsor_code
                        left outer join
                                        activity_type act
                                        on
                                                        p.activity_type_code = act.activity_type_code
                        left outer join
                                        PROPOSAL_TYPE pt
                                        on
                                                        P.TYPE_CODE = PT.TYPE_CODE
                        left outer join
                                        award_type at
                                        on
                                                        p.AWARD_TYPE_CODE =at.AWARD_TYPE_CODE
                        left outer join
                                        AWARD_AMT_FNA_DISTRIBUTION amfd
                                        on
                                                        a.AWARD_ID = amfd.AWARD_ID
                        left join
                                        sap_grant_award sga
                                        on
                                                        amfd.BUDGET_PERIOD=sga.COEUS_PERIOD
        where
                        p.type_code in (1, 4, 5, 6, 9)
                        and aai.sequence_number =
                        (
                               select
                                      max(SEQUENCE_NUMBER)
                               from
                                      award_amount_info
                               where
                                      award_number = aai.award_number
                        )
                        AND amfd.sequence_number =
                        (
                               SELECT
                                      MAX(sequence_number)
                               FROM
                                      AWARD_AMT_FNA_DISTRIBUTION
                               WHERE
                                      award_number = amfd.award_number
                        )
                        and pi.SEQUENCE_NUMBER =
                        (
                               select
                                      max(SEQUENCE_NUMBER)
                               from
                                      proposal_persons
                               where
                                      proposal_number = pi.proposal_number
                        )
                        and p.SEQUENCE_NUMBER =
                        (
                               select
                                      max(SEQUENCE_NUMBER)
                               from
                                      proposal_persons
                               where
                                      proposal_number = p.proposal_number
                        )
                        and p.status_code = '2'
                        and a.sequence_number =
                        (
                               select
                                      max(SEQUENCE_NUMBER)
                               from
                                      award
                               where
                                      award_number = a.award_number
                        )
                        and a.status_code ='1'
                        and pi.person_id  =person_id_in
                        and a.award_number  like '%-00001'
                        and ai.sequence_number =
                        (
                               select
                                      max(sequence_number)
                               from
                                      award_persons
                               where
                                      award_number =ai.award_number
                        )
                        and str_to_date(other_support_as_of_date_in,'%m/%d/%Y') between amfd.start_date and amfd.end_date
                        and ai.PI_FLAG                  ='Y'
                        and pi.person_id               !=ai.person_id
                        and substr(a.award_number, 1,6) = sga.grant_number
        union
        select distinct
                        'Funded'                                          as PROPOSAL_STATUS
                      , DATE_FORMAT(a.AWARD_EFFECTIVE_DATE, '%M/%d/%Y')   as PROJECT_START_DATE
                      , DATE_FORMAT(aai.FINAL_EXPIRATION_DATE,'%M/%d/%Y') as PROJECT_END_DATE
                      ,'NO AYB DATA'                                      as PERIOD_START_DATE
                      , NULL                                              as PERIOD_END_DATE
                      ,'NA'                                               as AWARD_ACTION
                      , null                                              as PERIOD_DIRECT_COST
                      , aai.ANTICIPATED_TOTAL_DIRECT                         TOT_PROJ_DIRECT_COST
                      , null                                              as BUDGET_PERIOD
                      , pi.PERCENTAGE_OF_EFFORT                           as "IP EFFORT %"
                      , CASE
                                        WHEN pi.prop_person_role_id in (1, 3, 5)
                                                        then pi.PI_FLAG
                                                        else 'N'
                        end AS PRINCIPAL_INVESTIGATOR_FLAG
                      ,'-'                          as PERSON_NAME
                      , a.sponsor_award_number         AWARD_ID
                      , p.title                        TITLE
                      , ai.FULL_NAME                as AWARD_PI
                      , s.ACRONYM                      SPONSOR_ACRO
                      , s.sponsor_name                 SPONSOR
                      , act.description                PURPOSE
                      , pt.description                 PROPOSAL_TYPE
                      , at.description                 AWARD_TYPE
                      , substr(a.award_number, 1,6) as SAP_NUMBER
                      , p.PROPOSAL_NUMBER
                      , oas.description                                     as GRANT_STATUS
                      ,'702-2'                                              as REPORT_NUMBER
                      , person_id_in                                        as PARAM_ENTERED_1
                      , pi.FULL_NAME                                        as TARGET_INVESTIGATOR
                      , other_support_as_of_date_in as PARAM_ENTERED_2
                      , sysdate()                                           as RUN_TIME
                      ,'Other Support part2'                                as REPORT_TITLE
                      , @@HOSTNAME                                          as HOST_NAME
                      , NULL                                                as NOTE
        from
                        award_funding_proposals afp
                        left join
                                        award a
                                        on
                                                        afp.award_ID= a.award_ID
                        left join
                                        award_status oas
                                        on
                                                        a.status_code = oas.status_code
                        left outer join
                                        proposal p
                                        on
                                                        p.proposal_id = afp.proposal_id
                        left join
                                        proposal_persons pi
                                        on
                                                        p.proposal_id = pi.proposal_id
                        left join
                                        award_persons ai
                                        on
                                                        ai.award_ID=a.award_ID
                        left outer join
                                        sponsor s
                                        on
                                                        a.sponsor_code = s.sponsor_code
                        left outer join
                                        activity_type act
                                        on
                                                        p.activity_type_code = act.activity_type_code
                        left outer join
                                        PROPOSAL_TYPE pt
                                        on
                                                        P.TYPE_CODE = PT.TYPE_CODE
                        left outer join
                                        award_type at
                                        on
                                                        p.AWARD_TYPE_CODE =at.AWARD_TYPE_CODE
                        left join
                                        AWARD_AMOUNT_INFO aai
                                        on
                                                        aai.award_ID = afp.award_ID
                        left outer join
                                        AWARD_AMT_FNA_DISTRIBUTION amfd
                                        on
                                                        a.award_ID = amfd.award_ID
                        left join
                                        sap_grant_award sga
                                        on
                                                        amfd.BUDGET_PERIOD=sga.COEUS_PERIOD
                        left join
                                        (
                                               select
                                                      sg.grant_number
                                               from
                                                      sap_grant sg
                                                    , (
                                                               select
                                                                        grant_number
                                                                      , max(STR_TO_DATE(GRANT_BUDGET_END_DATE,'%Y/%m%d')) as max_budget_end_date
                                                               from
                                                                        sap_grant_award
                                                               group by
                                                                        grant_number
                                                      )
                                                      sgag
                                               where
                                                      sg.grant_number                            =sgag.grant_number
                                                      and sg.user_status                         ='E0003'
                                                      and sg.proposal_number                    !='00000000'
                                                      and STR_TO_DATE(GRANT_END_DATE, '%Y/%m%d') > sgag.max_budget_end_date
                                                      and str_to_date(other_support_as_of_date_in,'%m/%d/%Y') >sgag.max_budget_end_date
                                        )
                                        potential_aw
                                        on
                                                        potential_aw.grant_number = sga.grant_number
        where
                        p.type_code in (1, 4, 5, 6, 9)
                        and aai.sequence_number =
                        (
                               select
                                      max(SEQUENCE_NUMBER)
                               from
                                      award_amount_info
                               where
                                      award_number = aai.award_number
                        )
                        AND amfd.sequence_number =
                        (
                               SELECT
                                      MAX(sequence_number)
                               FROM
                                      AWARD_AMT_FNA_DISTRIBUTION
                               WHERE
                                      award_number = amfd.award_number
                        )
                        and pi.SEQUENCE_NUMBER =
                        (
                               select
                                      max(SEQUENCE_NUMBER)
                               from
                                      Proposal_PERSONS
                               where
                                      proposal_number = pi.proposal_number
                        )
                        and p.SEQUENCE_NUMBER =
                        (
                               select
                                      max(SEQUENCE_NUMBER)
                               from
                                      Proposal_PERSONS
                               where
                                      proposal_number = p.proposal_number
                        )
                        and p.status_code = '2'
                        and a.sequence_number =
                        (
                               select
                                      max(SEQUENCE_NUMBER)
                               from
                                      award
                               where
                                      award_number = a.award_number
                        )
                        and a.status_code      ='1'
                        and pi.person_id       =person_id_in
                        and a.award_number  like '%-00001'
                        and ai.sequence_number =
                        (
                               select
                                      max(sequence_number)
                               from
                                      award_persons
                               where
                                      award_number =ai.award_number
                        )
                        and ai.PI_FLAG                  ='Y'
                        and pi.person_id               !=ai.person_id
                        and substr(a.award_number, 1,6) = sga.grant_number
        ;
    END
$$
DELIMITER ;
