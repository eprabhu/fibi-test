DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `RPT_GET_407_INFO`(IN report_start_date  VARCHAR(50)
                  ,IN report_end_date  VARCHAR(50)
                  ,IN report_unit  VARCHAR(500))
BEGIN
DECLARE LI_DIV_PRECISION_INCREMENT int;
 SET li_div_precision_increment=@@div_precision_increment;
 SET div_precision_increment = 30;
  WITH fna_110 as  ( SELECT 	fna2.award_number,
							fna2.SEQUENCE_NUMBER,
                            fna2.award_id,
                            fna2.start_date,
                            fna2.end_date,
                            fna2.BUDGET_PERIOD ,
                            fna2.total_direct_cost  ,
                            fna2.total_indirect_cost
				 FROM award_amt_fna_distribution fna2,
					 (SELECT max(SEQUENCE_NUMBER) as max_seq ,
							 AWARD_NUMBER
					FROM 	 award_amt_fna_distribution
					GROUP BY AWARD_NUMBER)fna1
				WHERE 	 fna2.award_number=fna1.award_number
				AND 	 fna2.SEQUENCE_NUMBER=fna1.max_seq),
       am as (	SELECT 	am2.SEQUENCE_NUMBER,
						am2.award_id,
                        am2.FINAL_EXPIRATION_DATE
				FROM award_amount_info am2,
					(SELECT max(SEQUENCE_NUMBER) as max_seq ,
							AWARD_NUMBER
							FROM 	 award_amount_info
							GROUP BY AWARD_NUMBER)am1
				WHERE 	am2.award_number=am1.award_number
				AND 	am2.SEQUENCE_NUMBER=am1.max_seq
				AND  	am2.AWARD_AMOUNT_INFO_ID= (select max(AWARD_AMOUNT_INFO_ID)
												   from award_amount_info
												   where award_number=am2.award_number
												   and SEQUENCE_NUMBER=am2.SEQUENCE_NUMBER))
 SELECT DISTINCT p.FULL_NAME
	    ,a.TITLE
        ,a.award_number MIT_AWARD_NUMBER
        ,ju.unit_name UNIT_NAME
        ,ju.unit_number UNIT_NUMBER
        ,ju1.unit_number ENTITY
        ,ju2.unit_number SCHOOL
        ,ju3.unit_number DEPT_1
        ,ju4.unit_number DEPT_2
        ,ju5.unit_number DEPT_3
        ,ju6.unit_number DEPT_4
        ,ju7.unit_number DEPT_5
        ,ju1.unit_name ENTITY_NAME
        ,ju2.unit_name SCHOOL_NAME
        ,ju3.unit_name DEPT_1_NAME
        ,ju4.unit_name DEPT_2_NAME
        ,ju5.unit_name DEPT_3_NAME
        ,ju6.unit_name DEPT_4_NAME
        ,ju7.unit_name DEPT_5_NAME
        ,s.SPONSOR_NAME
        ,at.description ACTIVITY_TYPE
        ,aw.description AWARD_TYPE
        ,am.FINAL_EXPIRATION_DATE
        ,fna.BUDGET_PERIOD
        ,fna.total_direct_cost DIRECT_COST
        ,fna.total_indirect_cost INDIRECT_COST
        ,(fna.total_direct_cost + fna.total_indirect_cost) TOTAL_COST
  FROM  award a
		 join award_persons ai on a.award_id = ai.award_id
								 AND    ai.pi_flag = 'Y'
								AND    ai.PERSON_ROLE_ID in (3)
         join person p on  ai.person_id = p.person_id
         join award_person_unit au on   au.award_id = ai.award_id
									AND    find_in_set(au.unit_number,fn_get_temp_unit(report_unit))
									AND    au.lead_unit_flag = 'Y'
									 join am  on am.award_id = ai.award_id
         join fna_110 fna on  fna.award_id = am.award_id
         join sponsor s on a.sponsor_code = s.sponsor_code
		 join activity_type at on   a.activity_type_code = at.activity_type_code
         join award_type aw on  a.award_type_code = aw.award_type_code
         join jhu_unit ju  on   au.unit_number = ju.unit_number
        left outer join jhu_unit ju1 on  concat(SUBSTR(ju.sort_value, 1, 3) , '000000000000000000000000000') = ju1.sort_value
		left outer join jhu_unit ju2 on  concat(SUBSTR(ju.sort_value, 1, 6) , '000000000000000000000000') = ju2.sort_value
        left outer join jhu_unit ju3 on  concat(SUBSTR(ju.sort_value, 1, 9) , '000000000000000000000') = ju3.sort_value
        left outer join jhu_unit ju4 on  concat(SUBSTR(ju.sort_value, 1, 12) , '000000000000000000') = ju4.sort_value
        left outer join jhu_unit ju5 on  concat(SUBSTR(ju.sort_value, 1, 15) , '000000000000000') = ju5.sort_value
        left outer join jhu_unit ju6 on  concat(SUBSTR(ju.sort_value, 1, 18) , '000000000000') = ju6.sort_value
        left outer join jhu_unit ju7 on   concat(SUBSTR(ju.sort_value, 1, 21) , '000000000') = ju7.sort_value
  WHERE   a.sequence_number = (SELECT MAX(sequence_number)
                                FROM   award
                                WHERE  award_number = a.award_number)
  AND 	 date(fna.start_date) >= str_to_date(report_start_date, '%m/%d/%Y')
  AND    date(fna.end_date) <= str_to_date(report_end_date, '%m/%d/%Y')
  AND    fna.total_direct_cost > 0
 UNION
  SELECT DISTINCT p.FULL_NAME
        ,a.TITLE
        ,a.award_number MIT_AWARD_NUMBER
        ,ju.unit_name UNIT_NAME
        ,ju.unit_number UNIT_NUMBER
        ,ju1.unit_number ENTITY
        ,ju2.unit_number SCHOOL
        ,ju3.unit_number DEPT_1
        ,ju4.unit_number DEPT_2
        ,ju5.unit_number DEPT_3
        ,ju6.unit_number DEPT_4
        ,ju7.unit_number DEPT_5
        ,ju1.unit_name ENTITY_NAME
        ,ju2.unit_name SCHOOL_NAME
        ,ju3.unit_name DEPT_1_NAME
        ,ju4.unit_name DEPT_2_NAME
        ,ju5.unit_name DEPT_3_NAME
        ,ju6.unit_name DEPT_4_NAME
        ,ju7.unit_name DEPT_5_NAME
        ,s.SPONSOR_NAME
        ,at.description ACTIVITY_TYPE
        ,aw.description AWARD_TYPE
        ,am.FINAL_EXPIRATION_DATE
        ,fna.BUDGET_PERIOD
        ,fna.total_direct_cost * ((datediff(date(fna.end_date),str_to_date(report_start_date, '%m/%d/%Y')) + 1) / (datediff(date(fna.end_date),date(fna.start_date)) + 1)) DIRECT_COST
        ,fna.total_indirect_cost * ((datediff(date(fna.end_date),str_to_date(report_start_date, '%m/%d/%Y')) + 1) / (datediff(date(fna.end_date),date(fna.start_date)) + 1)) INDIRECT_COST
        ,fna.total_direct_cost * ((datediff(date(fna.end_date),str_to_date(report_start_date, '%m/%d/%Y')) + 1) / (datediff(date(fna.end_date),date(fna.start_date)) + 1)) +
         fna.total_indirect_cost * ((datediff(date(fna.end_date),str_to_date(report_start_date, '%m/%d/%Y')) + 1) / (datediff(date(fna.end_date),date(fna.start_date)) + 1)) TOTAL_COST
  FROM  award a
		 join award_persons ai on a.award_id = ai.award_id
								 AND    ai.pi_flag = 'Y'
								AND    ai.PERSON_ROLE_ID in (3)
		 join person p on  ai.person_id = p.person_id
         join award_person_unit au on   au.award_number = ai.award_number
									AND    find_in_set(au.unit_number,fn_get_temp_unit(report_unit))
									AND    au.lead_unit_flag = 'Y'
									 join  am   on am.award_id = ai.award_id
         join  fna_110 fna on  fna.award_id = am.award_id
         join sponsor s on a.sponsor_code = s.sponsor_code
		 join activity_type at on   a.activity_type_code = at.activity_type_code
         join award_type aw on  a.award_type_code = aw.award_type_code
         join jhu_unit ju  on   au.unit_number = ju.unit_number
        left outer join jhu_unit ju1 on  concat(SUBSTR(ju.sort_value, 1, 3) , '000000000000000000000000000') = ju1.sort_value
		left outer join jhu_unit ju2 on  concat(SUBSTR(ju.sort_value, 1, 6) , '000000000000000000000000') = ju2.sort_value
        left outer join jhu_unit ju3 on  concat(SUBSTR(ju.sort_value, 1, 9) , '000000000000000000000') = ju3.sort_value
        left outer join jhu_unit ju4 on  concat(SUBSTR(ju.sort_value, 1, 12) , '000000000000000000') = ju4.sort_value
        left outer join jhu_unit ju5 on  concat(SUBSTR(ju.sort_value, 1, 15) , '000000000000000') = ju5.sort_value
        left outer join jhu_unit ju6 on  concat(SUBSTR(ju.sort_value, 1, 18) , '000000000000') = ju6.sort_value
        left outer join jhu_unit ju7 on   concat(SUBSTR(ju.sort_value, 1, 21) , '000000000') = ju7.sort_value
  WHERE  a.sequence_number = (SELECT MAX(sequence_number)
                                FROM   award
                                WHERE  award_number = a.award_number)
  AND 	 date(fna.start_date) <  str_to_date(report_start_date, '%m/%d/%Y')
  AND    date(fna.end_date) >= str_to_date(report_start_date, '%m/%d/%Y')
  AND    date(fna.end_date) <= str_to_date(report_end_date, '%m/%d/%Y')
  AND    fna.total_direct_cost > 0
  union
 SELECT DISTINCT p.FULL_NAME
        ,a.TITLE
        ,a.award_number MIT_AWARD_NUMBER
        ,ju.unit_name UNIT_NAME
        ,ju.unit_number UNIT_NUMBER
        ,ju1.unit_number ENTITY
        ,ju2.unit_number SCHOOL
        ,ju3.unit_number DEPT_1
        ,ju4.unit_number DEPT_2
        ,ju5.unit_number DEPT_3
        ,ju6.unit_number DEPT_4
        ,ju7.unit_number DEPT_5
        ,ju1.unit_name ENTITY_NAME
        ,ju2.unit_name SCHOOL_NAME
        ,ju3.unit_name DEPT_1_NAME
        ,ju4.unit_name DEPT_2_NAME
        ,ju5.unit_name DEPT_3_NAME
        ,ju6.unit_name DEPT_4_NAME
        ,ju7.unit_name DEPT_5_NAME
        ,s.SPONSOR_NAME
        ,at.description ACTIVITY_TYPE
        ,aw.description AWARD_TYPE
        ,am.FINAL_EXPIRATION_DATE
        ,fna.BUDGET_PERIOD
        ,fna.total_direct_cost * ((datediff(str_to_date(report_end_date, '%m/%d/%Y'),date(fna.start_date)) + 1) / (datediff(date(fna.end_date),date(fna.start_date)) + 1)) DIRECT_COST
        ,fna.total_indirect_cost * ((datediff(str_to_date(report_end_date, '%m/%d/%Y'),date(fna.start_date)) + 1) / (datediff(date(fna.end_date),date(fna.start_date)) + 1)) INDIRECT_COST
        ,fna.total_direct_cost * ((datediff(str_to_date(report_end_date, '%m/%d/%Y'),date(fna.start_date)) + 1) / (datediff(date(fna.end_date),date(fna.start_date)) + 1)) +
         fna.total_indirect_cost * ((datediff(str_to_date(report_end_date, '%m/%d/%Y'),date(fna.start_date)) + 1) / (datediff(date(fna.end_date),date(fna.start_date)) + 1)) TOTAL_COST
  FROM  award a
          join award_persons ai on a.award_id = ai.award_id
							    AND    ai.pi_flag = 'Y'
								AND 	ai.PERSON_ROLE_ID in (3)
		 join person p on  ai.person_id = p.person_id
         join award_person_unit au on   au.AWARD_PERSON_ID = ai.AWARD_PERSON_ID
									AND    find_in_set(au.unit_number,fn_get_temp_unit(report_unit))
									AND    au.lead_unit_flag = 'Y'
									 join  am   on am.award_id = ai.award_id
         join fna_110 fna on  fna.award_id = am.award_id
         join sponsor s on a.sponsor_code = s.sponsor_code
		 join activity_type at on   a.activity_type_code = at.activity_type_code
         join award_type aw on  a.award_type_code = aw.award_type_code
         join jhu_unit ju  on   au.unit_number = ju.unit_number
        left outer join jhu_unit ju1 on  concat(SUBSTR(ju.sort_value, 1, 3) , '000000000000000000000000000') = ju1.sort_value
		left outer join jhu_unit ju2 on  concat(SUBSTR(ju.sort_value, 1, 6) , '000000000000000000000000') = ju2.sort_value
        left outer join jhu_unit ju3 on  concat(SUBSTR(ju.sort_value, 1, 9) , '000000000000000000000') = ju3.sort_value
        left outer join jhu_unit ju4 on  concat(SUBSTR(ju.sort_value, 1, 12) , '000000000000000000') = ju4.sort_value
        left outer join jhu_unit ju5 on  concat(SUBSTR(ju.sort_value, 1, 15) , '000000000000000') = ju5.sort_value
        left outer join jhu_unit ju6 on  concat(SUBSTR(ju.sort_value, 1, 18) , '000000000000') = ju6.sort_value
        left outer join jhu_unit ju7 on   concat(SUBSTR(ju.sort_value, 1, 21) , '000000000') = ju7.sort_value
  WHERE	  a.sequence_number = (SELECT MAX(sequence_number)
                                FROM   award
                                WHERE  award_number = a.award_number)
  AND 	 date(fna.start_date) >= str_to_date(report_start_date, '%m/%d/%Y')
  AND    date(fna.start_date) <= str_to_date(report_end_date, '%m/%d/%Y')
  AND    date(fna.end_date) >  str_to_date(report_end_date, '%m/%d/%Y')
  AND    fna.total_direct_cost > 0
  UNION
  SELECT DISTINCT p.FULL_NAME
        ,a.TITLE
        ,a.award_number MIT_AWARD_NUMBER
        ,ju.unit_name UNIT_NAME
        ,ju.unit_number UNIT_NUMBER
        ,ju1.unit_number ENTITY
        ,ju2.unit_number SCHOOL
        ,ju3.unit_number DEPT_1
        ,ju4.unit_number DEPT_2
        ,ju5.unit_number DEPT_3
        ,ju6.unit_number DEPT_4
        ,ju7.unit_number DEPT_5
        ,ju1.unit_name ENTITY_NAME
        ,ju2.unit_name SCHOOL_NAME
        ,ju3.unit_name DEPT_1_NAME
        ,ju4.unit_name DEPT_2_NAME
        ,ju5.unit_name DEPT_3_NAME
        ,ju6.unit_name DEPT_4_NAME
        ,ju7.unit_name DEPT_5_NAME
        ,s.SPONSOR_NAME
        ,at.description ACTIVITY_TYPE
        ,aw.description AWARD_TYPE
        ,am.FINAL_EXPIRATION_DATE
        ,fna.BUDGET_PERIOD
        ,fna.total_direct_cost * ((datediff(str_to_date(report_end_date, '%m/%d/%Y'),str_to_date(report_start_date, '%m/%d/%Y')) + 1) / (datediff(date(fna.end_date),date(fna.start_date)) + 1)) DIRECT_COST
        ,fna.total_indirect_cost * ((datediff(str_to_date(report_end_date, '%m/%d/%Y'),str_to_date(report_start_date, '%m/%d/%Y')) + 1) / (datediff(date(fna.end_date),date(fna.start_date)) + 1)) INDIRECT_COST
        ,fna.total_direct_cost * ((datediff(str_to_date(report_end_date, '%m/%d/%Y'),str_to_date(report_start_date, '%m/%d/%Y')) + 1) / (datediff(date(fna.end_date),date(fna.start_date)) + 1)) +
         fna.total_indirect_cost * ((datediff(str_to_date(report_end_date, '%m/%d/%Y'),str_to_date(report_start_date, '%m/%d/%Y')) + 1) / (datediff(date(fna.end_date),date(fna.start_date)) + 1)) TOTAL_COST
  FROM  award a
         join award_persons ai on a.award_id = ai.award_id
									AND    ai.pi_flag = 'Y'
									AND    ai.PERSON_ROLE_ID in (3)
		 join person p on  ai.person_id = p.person_id
         join award_person_unit au on   au.AWARD_PERSON_ID = ai.AWARD_PERSON_ID
									AND    find_in_set(au.unit_number,fn_get_temp_unit(report_unit))
									AND    au.lead_unit_flag = 'Y'
									 join  am   on am.award_id = ai.award_id
         join fna_110 fna on  fna.award_id = am.award_id
         join sponsor s on a.sponsor_code = s.sponsor_code
		 join activity_type at on   a.activity_type_code = at.activity_type_code
         join award_type aw on  a.award_type_code = aw.award_type_code
         join jhu_unit ju  on   au.unit_number = ju.unit_number
        left outer join jhu_unit ju1 on  concat(SUBSTR(ju.sort_value, 1, 3) , '000000000000000000000000000') = ju1.sort_value
		left outer join jhu_unit ju2 on  concat(SUBSTR(ju.sort_value, 1, 6) , '000000000000000000000000') = ju2.sort_value
        left outer join jhu_unit ju3 on  concat(SUBSTR(ju.sort_value, 1, 9) , '000000000000000000000') = ju3.sort_value
        left outer join jhu_unit ju4 on  concat(SUBSTR(ju.sort_value, 1, 12) , '000000000000000000') = ju4.sort_value
        left outer join jhu_unit ju5 on  concat(SUBSTR(ju.sort_value, 1, 15) , '000000000000000') = ju5.sort_value
        left outer join jhu_unit ju6 on  concat(SUBSTR(ju.sort_value, 1, 18) , '000000000000') = ju6.sort_value
        left outer join jhu_unit ju7 on   concat(SUBSTR(ju.sort_value, 1, 21) , '000000000') = ju7.sort_value
  WHERE      a.sequence_number = (SELECT MAX(sequence_number)
                                FROM   award
                                WHERE  award_number = a.award_number)
  AND 	 date(fna.start_date) < str_to_date(report_start_date, '%m/%d/%Y')
  AND    date(fna.end_date) > str_to_date(report_end_date, '%m/%d/%Y')
  AND    fna.total_direct_cost > 0
  ORDER BY 5, 1, 3;
  SET div_precision_increment = LI_DIV_PRECISION_INCREMENT;
  END
$$
DELIMITER ;
