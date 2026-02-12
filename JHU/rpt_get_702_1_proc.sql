DELIMITER $$
CREATE  PROCEDURE `rpt_get_702_1_proc`(
                                       in person_id_in                varchar(40)
                                     , in other_support_as_of_date_in varchar(40)
                                   )
begin
			  with prop_number_1 as ( select
                           substr(CONCAT(DATE_FORMAT(ap.create_timestamp,'%Y%m%d'),ap.PROPOSAL_number), 9,16) as time_prop_num
                            from
                             (
                                    select
                                           p.create_timestamp
                                         , afp.award_id as award_id
                                         , p.PROPOSAL_number
                                    from
                                           Proposal                p
                                         join award_funding_proposals afp on  afp.PROPOSAL_id=p.PROPOSAL_id
                                     )
                             ap
							group by
                             ap.PROPOSAL_number)
  SELECT
               'Pending'                                  as PROPOSAL_STATUS
             , DATE_FORMAT(p.start_date,'%m/%d/%Y')       PROJECT_START_DATE
             , DATE_FORMAT(p.end_date, '%m/%d/%Y')        PROJECT_END_DATE
             , DATE_FORMAT(p.start_date, '%m/%d/%Y')    PERIOD_START_DATE
             , DATE_FORMAT(p.end_date, '%m/%d/%Y')      PERIOD_END_DATE
             ,'NA'                                                    as AWARD_ACTION
			 , ibh.TOTAL_COST                                      TOTAL_COST
			 , ibh.TOTAL_INDIRECT_COST                             TOTAL_INDIRECT_COST
             , ibh.TOTAL_DIRECT_COST                               PERIOD_DIRECT_COST
             , ibh.TOTAL_DIRECT_COST                               TOT_PROJ_DIRECT_COST
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
             , utc_timestamp()                                              as RUN_TIME
             ,'Other Support'                                      as REPORT_TITLE
             , @@hostname                 						   as HOST_NAME
             , NULL                                                as NOTE
        FROM
               proposal               p
			  LEFT JOIN ip_budget_header ibh ON ibh.proposal_id=p.proposal_id
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
				    SELECT
           'Funded'                                             	as PROPOSAL_STATUS
         , DATE_FORMAT(a.AWARD_EFFECTIVE_DATE, '%m/%d/%Y')    		as PROJECT_START_DATE
         , DATE_FORMAT(aai.FINAL_EXPIRATION_DATE, '%m/%d/%Y') 		as PROJECT_END_DATE
         , DATE_FORMAT(amfd.START_DATE, '%m/%d/%Y')           		as PERIOD_START_DATE
         , DATE_FORMAT(amfd.END_DATE, '%m/%d/%Y')             		as PERIOD_END_DATE
         , sga.GRANT_AWARD_ACTION                               	as AWARD_ACTION
		 , sum(amfd.Total_DIRECT_COST + amfd.TOTAL_INDIRECT_COST)   as TOTAL_COST
		 , amfd.TOTAL_INDIRECT_COST                                 as TOTAL_INDIRECT_COST
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
         , (select time_prop_num from  prop_number_1 where time_prop_num = p.PROPOSAL_number) 	as PROPOSAL_NUMBER
         , oas.description                                   		as GRANT_STATUS
         ,'702-1'                                            		as REPORT_NUMBER
         , person_id_in                                     		as PARAM_ENTERED_1
         , ai.full_name                                  		as TARGET_INVESTIGATOR
         , other_support_as_of_date_in 		as PARAM_ENTERED_2
         , utc_timestamp()                                           		as RUN_TIME
         ,'Other Support'                                    		as REPORT_TITLE
         , @@hostname 							              		as HOST_NAME
         , NULL                                              		as NOTE
    FROM
           award                      	a
            join award_funding_proposals afp on a.award_id = afp.award_id
            join proposal                   	p on p.proposal_id     	 =afp.proposal_id
            join sponsor s on s.sponsor_code = a.sponsor_code
            join person    pe on  pe.person_id in
           (
                  SELECT
                         person_id
                  FROM
                         award_persons
                  WHERE
                         award_number    = a.award_number
                         AND pi_flag = 'Y'
           )
          join proposal_persons     		pi on pi.proposal_id =afp.proposal_id
          join PROPOSAL_TYPE              	pt on pt.type_code=p.type_code
		  join award_type at on  a.award_type_code = at.award_type_code
          join activity_type act on a.activity_type_code = act.activity_type_code
          join AWARD_STATUS oas on a.status_code = oas.status_code
          left outer join award_persons ai on a.award_id = ai.award_id
		  left outer join AWARD_AMOUNT_INFO       aai on a.award_number = aai.award_number
		 left outer join AWARD_AMT_FNA_DISTRIBUTION 	amfd on  a.award_id = amfd.award_id
		  join sap_grant_award sga on   amfd.BUDGET_PERIOD =sga.COEUS_PERIOD and substr(a.award_number, 1,6) = sga.grant_number
		  join  person person on person.person_id=pi.person_id
    where
     a.status_code         = '1'
	AND a.award_number LIKE '%-00001'
    AND a.sequence_number  =
           (
                  SELECT
                         MAX(sequence_number)
                  FROM
                         award
                  WHERE
                         award_number = a.award_number
           )
	 and pi.SEQUENCE_NUMBER =
           (
                  SELECT
                         MAX(sequence_number)
                  FROM
                         proposal_persons
                  WHERE
                         proposal_number = pi.proposal_number
           )
    and ai.person_id =person_id_in
	and ai.SEQUENCE_NUMBER    in
           (
                  SELECT
                         MAX(SEQUENCE_NUMBER)
                  FROM
                         award_persons
                  WHERE
                         award_number = ai.award_number
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
           AND  	aai.AWARD_AMOUNT_INFO_ID= (select max(AWARD_AMOUNT_INFO_ID)
												   from award_amount_info
												   where award_number=aai.award_number
												   and SEQUENCE_NUMBER=aai.SEQUENCE_NUMBER)
   -- and person.person_id =person_id_in
    AND amfd.sequence_number =
           (
                  SELECT
                         MAX(sequence_number)
                  FROM
                         AWARD_AMT_FNA_DISTRIBUTION
                  WHERE
                         award_number = a.award_number
           )
          and str_to_date(other_support_as_of_date_in,'%m/%d/%Y') between amfd.start_date and amfd.end_date
		  group by a.award_id
		   UNION
		    SELECT
           'Funded'                                          as PROPOSAL_STATUS
         , DATE_FORMAT(a.AWARD_EFFECTIVE_DATE,'%m/%d/%Y')      as PROJECT_START_DATE
         , DATE_FORMAT(aai.FINAL_EXPIRATION_DATE, '%m/%d/%Y') as PROJECT_END_DATE
         ,'NO AYB DATA'                                      as PERIOD_START_DATE
         , NULL                                              as PERIOD_END_DATE
         ,'NA'                                               as AWARD_ACTION
		 , NULL                                              AS TOTAL_COST
		 , NULL                                              AS TOTAL_INDIRECT_COST
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
         , (select time_prop_num from  prop_number_1 where time_prop_num = p.PROPOSAL_number )                    as PROPOSAL_NUMBER
         , oas.description                                    as GRANT_STATUS
         ,'702-1'                                             as REPORT_NUMBER
         , person_id_in                                       as PARAM_ENTERED_1
         , ai.full_name                                   as TARGET_INVESTIGATOR
         , other_support_as_of_date_in as PARAM_ENTERED_2
         , utc_timestamp()                                            as RUN_TIME
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
                                         , max(str_to_date(GRANT_BUDGET_END_DATE, '%Y%m%d')) as max_budget_end_date
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
                         and str_to_date(GRANT_END_DATE, '%Y%m%d') > sgag.max_budget_end_date
                         and str_to_date(other_support_as_of_date_in,'%m/%d/%Y') >sgag.max_budget_end_date
           )
           potential_aw
    where
           ai.person_id              =person_id_in
           and p.proposal_id     =afp.proposal_id
           and a.sponsor_code        = s.sponsor_code
           AND a.award_number LIKE '%-00001'
           and ai.sequence_number    =
           (
                  SELECT
                         MAX(sequence_number)
                  FROM
                         award_persons
                  WHERE
                         AWARD_NUMBER = ai.AWARD_NUMBER
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
                                       AWARD_NUMBER = ai.AWARD_NUMBER
                         )
                         AND pi_flag = 'Y'
           )
           -- and person.person_id   =person_id_in
           AND a.sequence_number  =
           (
                  SELECT
                         MAX(sequence_number)
                  FROM
                         award
                  WHERE
                         AWARD_NUMBER = a.AWARD_NUMBER
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
            AND  	aai.AWARD_AMOUNT_INFO_ID= (select max(AWARD_AMOUNT_INFO_ID)
												   from award_amount_info
												   where award_number=aai.award_number
												   and SEQUENCE_NUMBER=aai.SEQUENCE_NUMBER)
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
