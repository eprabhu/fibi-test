DELIMITER $$
CREATE  PROCEDURE `rpt_get_702_1_proc`(
                                       in person_id_in                varchar(40)
                                     , in other_support_as_of_date_in varchar(40)
                                   )
begin
  SELECT distinct
               'Pending'                                  as PROPOSAL_STATUS
             , DATE_FORMAT(p.start_date,'%M/%d/%Y')       PROJECT_START_DATE
             , DATE_FORMAT(p.end_date, '%M/%d/%Y')        PROJECT_END_DATE
             , DATE_FORMAT(p.start_date, '%M/%d/%Y')    PERIOD_START_DATE
             , DATE_FORMAT(p.end_date, '%M/%d/%Y')      PERIOD_END_DATE
             ,'NA'                                                    as AWARD_ACTION
             , p.TOTAL_DIRECT_COST                            PERIOD_DIRECT_COST
             , p.TOTAL_DIRECT_COST                               TOT_PROJ_DIRECT_COST
             , null                 as BUDGET_PERIOD
             , pi.PERCENTAGE_OF_EFFORT as "IP EFFORT %"
             , CASE WHEN pi.prop_person_role_id in (1,3,5) then  pi.PI_FLAG else 'N' end  as PRINCIPAL_INVESTIGATOR_FLAG
             , pe.full_name              PI_NAME
             , p.SPONSOR_PROPOSAL_NUMBER as "AWARD ID"
             , p.title                      TITLE
             ,'NA'                       as AWARD_PI
             , s.ACRONYM                    SPONSOR_ACRO
             , s.sponsor_name               SPONSOR
             , act.description              PURPOSE
             , pt.description               PROPOSAL_TYPE
             , at.description               AWARD_TYPE
             ,'NA'                       as SAP_NUMBER
             , p.proposal_number            PROPOSAL_NUMBER
             ,'NA'                       as GRANT_STATUS
             ,'702-1'                    as REPORT_NUMBER
             , person_id_in              as PARAM_ENTERED_1
             , person.full_name          as TARGET_INVESTIGATOR
             , other_support_as_of_date_in as PARAM_ENTERED_2
             , sysdate()                                              as RUN_TIME
             ,'Other Support'                                      as REPORT_TITLE
             , @@hostname                 						   as HOST_NAME
             , NULL                                                as NOTE
        FROM
               proposal               p
			  left outer join sponsor s on p.sponsor_code = s.sponsor_code
			  left outer join activity_type act on p.activity_type_code = act.activity_type_code
			  left outer join award_type at on p.AWARD_TYPE_CODE =at.AWARD_TYPE_CODE
			  left outer join PROPOSAL_TYPE pt on P.TYPE_CODE = PT.TYPE_CODE
             , prop_person_units      pu
             , proposal_persons 	  pi
             , person                 pe
             , person                 person
             , proposal_status        ps
        WHERE
               pi.person_id      = person_id_in
               AND p.status_code = 1
               AND p.type_code in (1, 4, 5, 6, 9)
               AND pi.sequence_number IN
               (
                      SELECT
                             MAX(sequence_number)
                      FROM
                             proposal_persons
                      WHERE
                             proposal_number = p.proposal_number
               )
               AND pe.person_id IN
               (
                      SELECT
                             person_id
                      FROM
                             proposal_persons
                      WHERE
                             proposal_number                 = p.proposal_number
                             AND sequence_number             = pi.sequence_number
                             AND PI_flag = 'Y'
               )
               AND p.proposal_number  = pi.proposal_number
               AND p.proposal_number  = pu.proposal_number
               AND pu.LEAD_UNIT_FLAG  ='Y'
               AND pu.sequence_number =
               (
                      SELECT
                             MAX(sequence_number)
                      FROM
                             prop_person_units
                      WHERE
                             proposal_number = p.proposal_number
               )
               AND p.sequence_number =
               (
                      SELECT
                             MAX(sequence_number)
                      FROM
                             proposal
                      WHERE
                             proposal_number = p.proposal_number
               )
               and person.person_id     = person_id_in
               AND p.status_code        = ps.status_code
			   union
				   SELECT distinct
           'Funded'                                             	as PROPOSAL_STATUS
         , DATE_FORMAT(a.AWARD_EFFECTIVE_DATE, '%M/%d/%Y')    		as PROJECT_START_DATE
         , DATE_FORMAT(aai.FINAL_EXPIRATION_DATE, '%M/%d/%Y') 		as PROJECT_END_DATE
         , DATE_FORMAT(amfd.START_DATE, '%M/%d/%Y')           		as PERIOD_START_DATE
         , DATE_FORMAT(amfd.END_DATE, '%M/%d/%Y')             		as PERIOD_END_DATE
         , sga.GRANT_AWARD_ACTION                               	as AWARD_ACTION
         , amfd.Total_DIRECT_COST                                     		PERIOD_DIRECT_COST
         , aai.ANTICIPATED_TOTAL_DIRECT                         		TOT_PROJ_DIRECT_COST
         , amfd.BUDGET_PERIOD
         , pi.PERCENTAGE_OF_EFFORT as "IP EFFORT %"
         , ai.PI_FLAG PRINCIPAL_INVESTIGATOR_FLAG
         , pe.full_name                                      			PI_NAME
         , a.sponsor_award_number                            		as "AWARD ID"
         , a.title                                          			TITLE
         , pe.full_name                                      			AWARD_PI
         , s.ACRONYM                                         			SPONSOR_ACRO
         , s.sponsor_name                                    			SPONSOR
         , act.description                                   			PURPOSE
         , pt.description                                    			PROPOSAL_TYPE
         , at.description                                    			AWARD_TYPE
         , substr(a.award_number, 1,6)                   			SAP_NUMBER
         , substr(apn.time_prop_num, 9,16)                   		as PROPOSAL_NUMBER
         , oas.description                                   		as GRANT_STATUS
         ,'702-1'                                            		as REPORT_NUMBER
         , person_id_in                                     		as PARAM_ENTERED_1
         , person.full_name                                  		as TARGET_INVESTIGATOR
         , other_support_as_of_date_in 		as PARAM_ENTERED_2
         , sysdate()                                           		as RUN_TIME
         ,'Other Support'                                    		as REPORT_TITLE
         , @@hostname 							              		as HOST_NAME
         , NULL                                              		as NOTE
    FROM
           award                      	a
		    left outer join award_persons ai on a.award_id = ai.award_id
		    left outer join AWARD_AMOUNT_INFO       aai on a.award_id = aai.award_id
		    left outer join AWARD_AMT_FNA_DISTRIBUTION 	amfd on  a.award_id = amfd.award_id
		    left outer join award_funding_proposals afp on a.award_id = afp.award_id
         left join proposal_persons     		pi on pi.proposal_id =afp.proposal_id
		 left join proposal                   	p on p.proposal_id     	 =afp.proposal_id
         left join PROPOSAL_TYPE              	pt on pt.type_code=p.type_code
		 left join award_type at on  a.award_type_code = at.award_type_code
         left join activity_type act on a.activity_type_code = act.activity_type_code
         left join AWARD_STATUS oas on a.status_code = oas.status_code
         left join sponsor s on a.sponsor_code = s.sponsor_code
         left join sap_grant_award sga on   amfd.BUDGET_PERIOD =sga.COEUS_PERIOD
		 left join (
                    select
                             ap.award_id
                           , min(CONCAT(DATE_FORMAT(ap.create_timestamp,'%Y%m%d'),ap.proposal_number)) as time_prop_num
                    from
                             (
                                    select
                                           p.create_timestamp
                                         , afp.award_id as award_id
                                         , p.proposal_number
                                    from
                                           Proposal                p
                                         , award_funding_proposals afp
                                    where
                                           afp.PROPOSAL_id=p.PROPOSAL_id
                             )
                             ap
                    group by
                             ap.award_id
           )apn on  p.proposal_number =substr(apn.time_prop_num, 9,16)
         , person                     	pe
         , person                     	person
    where
ai.person_id =person_id_in
AND a.award_number LIKE '%00001'
and ai.award_id    in
           (
                  SELECT
                         MAX(award_id)
                  FROM
                         award_persons
                  WHERE
                         award_number = ai.award_number
           )
           AND pe.person_id in
           (
                  SELECT
                         person_id
                  FROM
                         award_persons
                  WHERE
                         award_id    = a.award_id
                         AND pi_flag = 'Y'
           )
           and person.person_id =person_id_in
           and substr(a.award_number, 1,6) = sga.grant_number
           AND a.sequence_number  =
           (
                  SELECT
                         MAX(sequence_number)
                  FROM
                         award
                  WHERE
                         award_number = a.award_number
           )
           AND amfd.sequence_number =
           (
                  SELECT
                         MAX(sequence_number)
                  FROM
                         AWARD_AMT_FNA_DISTRIBUTION
                  WHERE
                         award_number = a.award_number
           )
           AND aai.sequence_number =
           (
                  SELECT
                         MAX(sequence_number)
                  FROM
                         AWARD_AMT_FNA_DISTRIBUTION
                  WHERE
                         award_number = a.award_number
           )
           and str_to_date(other_support_as_of_date_in,'%m/%d/%Y') between amfd.start_date and amfd.end_date
           and a.status_code         = '1'
           and pi.SEQUENCE_NUMBER =
           (
                  SELECT
                         MAX(sequence_number)
                  FROM
                         proposal_persons
                  WHERE
                         proposal_number = pi.proposal_number
           )
		   UNION
		    SELECT
           'Funded'                                          as PROPOSAL_STATUS
         , DATE_FORMAT(a.AWARD_EFFECTIVE_DATE,'%M/%d/%Y')      as PROJECT_START_DATE
         , DATE_FORMAT(aai.FINAL_EXPIRATION_DATE, '%M/%d/%Y') as PROJECT_END_DATE
         ,'NO AYB DATA'                                      as PERIOD_START_DATE
         , NULL                                              as PERIOD_END_DATE
         ,'NA'                                               as AWARD_ACTION
         , NULL                                              as PERIOD_DIRECT_COST
         , aai.ANTICIPATED_TOTAL_DIRECT                         TOT_PROJ_DIRECT_COST
         , NULL                                              as BUDGET_PERIOD
         , pi.PERCENTAGE_OF_EFFORT                              as "IP EFFORT %"
         , ai.PI_FLAG PRINCIPAL_INVESTIGATOR_FLAG
         , pe.full_name                                       PI_NAME
         , a.sponsor_award_number                             as "AWARD ID"
         , a.title                                            TITLE
         , pe.full_name                                       AWARD_PI
         , s.ACRONYM                                          SPONSOR_ACRO
         , s.sponsor_name                                     SPONSOR
         , act.description                                    PURPOSE
         , pt.description                                     PROPOSAL_TYPE
         , at.description                                     AWARD_TYPE
         , substr(a.award_number, 1,6)                   SAP_NUMBER
         , substr(apn.time_prop_num, 9,16)                    as PROPOSAL_NUMBER
         , oas.description                                    as GRANT_STATUS
         ,'702-1'                                             as REPORT_NUMBER
         , person_id_in                                       as PARAM_ENTERED_1
         , person.full_name                                   as TARGET_INVESTIGATOR
         , other_support_as_of_date_in as PARAM_ENTERED_2
         , sysdate()                                            as RUN_TIME
         ,'Other Support'                                     as REPORT_TITLE
         , @@hostname                 						  as HOST_NAME
         , NULL                                               as NOTE
    FROM
           award                  a
		 left outer join award_persons ai on a.award_id = ai.award_id
         left outer join award_funding_proposals afp on a.award_id = afp.award_id
         left outer join AWARD_AMOUNT_INFO       aai on a.award_id = aai.award_id
         , PROPOSAL_TYPE          pt
         , person                 pe
         , person                 person
         , proposal_persons pi
         , proposal               p
         , (
                    select
                             ap.award_id
                           , min(concat(DATE_FORMAT(ap.create_timestamp,'%Y%m%d') ,ap.proposal_number)) as time_prop_num
                    from
                             (
                                    select
                                           p.create_timestamp
                                         , afp.award_id as award_id
                                         , p.proposal_number
                                    from
                                           Proposal                p
                                         , award_funding_proposals afp
                                    where     afp.proposal_id=p.proposal_id
                             )
                             ap
                    group by
                             ap.award_id
           ) apn
         , award_type              at
         , activity_type           act
         , AWARD_STATUS            oas
         , sponsor                 s
         , (
                  select
                         sg.grant_number
                  from
                         sap_grant sg
                       , (
                                  select
                                           grant_number
                                         , max(str_to_date(GRANT_BUDGET_END_DATE, '%Y/%m/%d')) as max_budget_end_date
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
                         and str_to_date(GRANT_END_DATE, '%Y/%m/%d') > sgag.max_budget_end_date
                         and str_to_date(other_support_as_of_date_in,'%m/%d/%Y') >sgag.max_budget_end_date
           )
           potential_aw
    where
           ai.person_id              =person_id_in
           and p.proposal_id     =afp.proposal_id
           and p.proposal_number   =substr(apn.time_prop_num, 9,16)
           and a.sponsor_code        = s.sponsor_code
           AND a.award_number LIKE '%00001'
           and ai.sequence_number    =
           (
                  SELECT
                         MAX(sequence_number)
                  FROM
                         award_persons
                  WHERE
                         award_id = ai.award_id
           )
           AND pe.person_id =
           (
                  SELECT
                         person_id
                  FROM
                         award_persons
                  WHERE
                         award_id    = a.award_id
                         AND sequence_number =
                         (
                                select
                                       max(sequence_number)
                                from
                                       award_persons
                                where
                                       award_id = ai.award_id
                         )
                         AND pi_flag = 'Y'
           )
           and person.person_id   =person_id_in
           AND a.sequence_number  =
           (
                  SELECT
                         MAX(sequence_number)
                  FROM
                         award
                  WHERE
                         award_id = a.award_id
           )
           AND aai.sequence_number =
           (
                  SELECT
                         MAX(sequence_number)
                  FROM
                         AWARD_AMOUNT_INFO
                  WHERE
                         award_number = a.award_number
           )
           and pt.type_code     =p.type_code
           AND a.activity_type_code     = act.activity_type_code
           and a.award_type_code        = at.award_type_code
           and a.status_code             = oas.status_code
           and potential_aw.grant_number = substr(a.award_number,1,6)
           and pi.proposal_id =afp.proposal_id
           and pi.SEQUENCE_NUMBER =
           (
                  SELECT
                         MAX(sequence_number)
                  FROM
                         proposal_persons
                  WHERE
                         proposal_number = pi.proposal_number
           )
           and pi.person_id=ai.person_id;
 end
$$
DELIMITER ;
