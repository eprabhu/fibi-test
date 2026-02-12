DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `RPT_GET_409_INFO`(IN report_start_date  VARCHAR(500)
                  ,IN report_end_date  VARCHAR(500)
                  ,IN report_unit  VARCHAR(8))
begin
DECLARE LI_DIV_PRECISION_INCREMENT int;
 SET li_div_precision_increment=@@div_precision_increment;
 SET div_precision_increment = 30;
SELECT DISTINCT p.FULL_NAME
        ,au.award_number MIT_AWARD_NUMBER
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
        ,fna.BUDGET_PERIOD
        ,fna.total_direct_cost DIRECT_COST
        ,fna.total_indirect_cost INDIRECT_COST
        ,(fna.total_direct_cost + fna.total_indirect_cost) TOTAL_COST
  FROM   award_amt_fna_distribution fna
		join award_persons ai on ai.award_id = fna.award_id
		join award_person_unit au on au.AWARD_PERSON_ID = ai.AWARD_PERSON_ID
		join person p on  p.person_id = ai.person_id
		join jhu_unit ju on ju.unit_number = au.unit_number
        left outer join jhu_unit ju1 on CONCAT(SUBSTR(ju.sort_value, 1, 3) , '000000000000000000000000000') = ju1.sort_value
        left outer join jhu_unit ju2 on CONCAT(SUBSTR(ju.sort_value, 1, 6) , '000000000000000000000000') = ju2.sort_value
        left outer join jhu_unit ju3 on CONCAT(SUBSTR(ju.sort_value, 1, 9) , '000000000000000000000') = ju3.sort_value
        left outer join jhu_unit ju4 on CONCAT(SUBSTR(ju.sort_value, 1, 12) , '000000000000000000') = ju4.sort_value
        left outer join jhu_unit ju5 on CONCAT(SUBSTR(ju.sort_value, 1, 15) , '000000000000000') = ju5.sort_value
        left outer join jhu_unit ju6 on CONCAT(SUBSTR(ju.sort_value, 1, 18) , '000000000000') = ju6.sort_value
        left outer join jhu_unit ju7 on CONCAT(SUBSTR(ju.sort_value, 1, 21) , '000000000') = ju7.sort_value
  WHERE  date(fna.start_date) >= str_to_date(report_start_date, '%m/%d/%Y')
  AND    date(fna.end_date) <= str_to_date(report_end_date, '%m/%d/%Y')
  AND    fna.total_direct_cost > 0
  AND    find_in_set(au.unit_number,fn_get_temp_unit(report_unit))
  AND    au.lead_unit_flag = 'Y'
  AND    fna.sequence_number = (SELECT MAX(sequence_number)
                                FROM   award_amt_fna_distribution
                                WHERE  award_number = fna.award_number)
  AND    au.sequence_number = (SELECT MAX(sequence_number)
                                FROM   award_person_unit
                                WHERE  award_number = au.award_number)
  union
  SELECT DISTINCT p.FULL_NAME
        ,au.award_number MIT_AWARD_NUMBER
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
        ,fna.BUDGET_PERIOD
        ,fna.total_direct_cost * ((datediff(date(fna.end_date) , str_to_date(report_start_date, '%m/%d/%Y')) + 1) / (datediff(date(fna.end_date) , date(fna.start_date)) + 1)) DIRECT_COST
        ,fna.total_indirect_cost * ((datediff(date(fna.end_date) , str_to_date(report_start_date, '%m/%d/%Y')) + 1) / (datediff(date(fna.end_date) , date(fna.start_date)) + 1)) INDIRECT_COST
        ,fna.total_direct_cost * ((datediff(date(fna.end_date) , str_to_date(report_start_date, '%m/%d/%Y')) + 1) / (datediff(date(fna.end_date) , date(fna.start_date)) + 1)) +
         fna.total_indirect_cost * ((datediff(date(fna.end_date) , str_to_date(report_start_date, '%m/%d/%Y')) + 1) / (datediff(date(fna.end_date) , date(fna.start_date)) + 1)) TOTAL_COST
  FROM   award_amt_fna_distribution fna
        join award_persons ai on ai.award_id = fna.award_id
		join award_person_unit au on au.AWARD_PERSON_ID = ai.AWARD_PERSON_ID
		join person p on  p.person_id = ai.person_id
		join jhu_unit ju on ju.unit_number = au.unit_number
        left outer join jhu_unit ju1 on CONCAT(SUBSTR(ju.sort_value, 1, 3) , '000000000000000000000000000') = ju1.sort_value
        left outer join jhu_unit ju2 on CONCAT(SUBSTR(ju.sort_value, 1, 6) , '000000000000000000000000') = ju2.sort_value
        left outer join jhu_unit ju3 on CONCAT(SUBSTR(ju.sort_value, 1, 9) , '000000000000000000000') = ju3.sort_value
        left outer join jhu_unit ju4 on CONCAT(SUBSTR(ju.sort_value, 1, 12) , '000000000000000000') = ju4.sort_value
        left outer join jhu_unit ju5 on CONCAT(SUBSTR(ju.sort_value, 1, 15) , '000000000000000') = ju5.sort_value
        left outer join jhu_unit ju6 on CONCAT(SUBSTR(ju.sort_value, 1, 18) , '000000000000') = ju6.sort_value
        left outer join jhu_unit ju7 on CONCAT(SUBSTR(ju.sort_value, 1, 21) , '000000000') = ju7.sort_value
  WHERE  date(fna.start_date) <  str_to_date(report_start_date, '%m/%d/%Y')
  AND    date(fna.end_date) >= str_to_date(report_start_date, '%m/%d/%Y')
  AND    date(fna.end_date) <= str_to_date(report_end_date, '%m/%d/%Y')
  AND   fna.total_direct_cost > 0
  AND    find_in_set(au.unit_number,fn_get_temp_unit(report_unit))
  AND    au.lead_unit_flag = 'Y'
  AND    fna.sequence_number = (SELECT MAX(sequence_number)
                                FROM   award_amt_fna_distribution
                                WHERE  award_number = fna.award_number)
  AND    au.sequence_number = (SELECT MAX(sequence_number)
                                FROM   award_person_unit
                                WHERE  award_number = au.award_number)
 union
 SELECT DISTINCT p.FULL_NAME
        ,au.award_number MIT_AWARD_NUMBER
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
        ,fna.BUDGET_PERIOD
        ,fna.total_direct_cost * ((datediff(str_to_date(report_end_date, '%m/%d/%Y') , date(fna.start_date)) + 1) / (datediff(date(fna.end_date) , date(fna.start_date)) + 1)) DIRECT_COST
        ,fna.total_indirect_cost * ((datediff(str_to_date(report_end_date, '%m/%d/%Y') , date(fna.start_date)) + 1) / (datediff(date(fna.end_date) , date(fna.start_date)) + 1)) INDIRECT_COST
        ,fna.total_direct_cost * ((datediff(str_to_date(report_end_date, '%m/%d/%Y') , date(fna.start_date)) + 1) / (datediff(date(fna.end_date) , date(fna.start_date)) + 1)) +
         fna.total_indirect_cost * ((datediff(str_to_date(report_end_date, '%m/%d/%Y') , date(fna.start_date)) + 1) / (datediff(date(fna.end_date) , date(fna.start_date)) + 1)) TOTAL_COST
  FROM   award_amt_fna_distribution fna
        join award_persons ai on ai.award_id = fna.award_id
		join award_person_unit au on au.AWARD_PERSON_ID = ai.AWARD_PERSON_ID
		join person p on  p.person_id = ai.person_id
		join jhu_unit ju on ju.unit_number = au.unit_number
        left outer join jhu_unit ju1 on CONCAT(SUBSTR(ju.sort_value, 1, 3) , '000000000000000000000000000') = ju1.sort_value
        left outer join jhu_unit ju2 on CONCAT(SUBSTR(ju.sort_value, 1, 6) , '000000000000000000000000') = ju2.sort_value
        left outer join jhu_unit ju3 on CONCAT(SUBSTR(ju.sort_value, 1, 9) , '000000000000000000000') = ju3.sort_value
        left outer join jhu_unit ju4 on CONCAT(SUBSTR(ju.sort_value, 1, 12) , '000000000000000000') = ju4.sort_value
        left outer join jhu_unit ju5 on CONCAT(SUBSTR(ju.sort_value, 1, 15) , '000000000000000') = ju5.sort_value
        left outer join jhu_unit ju6 on CONCAT(SUBSTR(ju.sort_value, 1, 18) , '000000000000') = ju6.sort_value
        left outer join jhu_unit ju7 on CONCAT(SUBSTR(ju.sort_value, 1, 21) , '000000000') = ju7.sort_value
  WHERE  date(fna.start_date) >= str_to_date(report_start_date, '%m/%d/%Y')
  AND    date(fna.start_date) <= str_to_date(report_end_date, '%m/%d/%Y')
  AND    date(fna.end_date) >  str_to_date(report_end_date, '%m/%d/%Y')
  AND    fna.total_direct_cost > 0
  AND    find_in_set(au.unit_number,fn_get_temp_unit(report_unit))
  AND    au.lead_unit_flag = 'Y'
  AND    fna.sequence_number = (SELECT MAX(sequence_number)
                                FROM   award_amt_fna_distribution
                                WHERE  award_number = fna.award_number)
  AND    au.sequence_number = (SELECT MAX(sequence_number)
                                FROM   award_person_unit
                                WHERE  award_number = au.award_number)
                                union
SELECT DISTINCT p.FULL_NAME
        ,au.award_number MIT_AWARD_NUMBER
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
        ,fna.BUDGET_PERIOD
        ,fna.total_direct_cost * ((datediff(str_to_date(report_end_date, '%m/%d/%Y') , str_to_date(report_start_date, '%m/%d/%Y')) + 1) / (datediff(date(fna.end_date) , date(fna.start_date)) + 1)) DIRECT_COST
        ,fna.total_indirect_cost * ((datediff(str_to_date(report_end_date, '%m/%d/%Y') , str_to_date(report_start_date, '%m/%d/%Y')) + 1) / (datediff(date(fna.end_date) , date(fna.start_date)) + 1)) INDIRECT_COST
        ,fna.total_direct_cost * ((datediff(str_to_date(report_end_date, '%m/%d/%Y') , str_to_date(report_start_date, '%m/%d/%Y')) + 1) / (datediff(date(fna.end_date) , date(fna.start_date)) + 1)) +
         fna.total_indirect_cost * ((datediff(str_to_date(report_end_date, '%m/%d/%Y') , str_to_date(report_start_date, '%m/%d/%Y')) + 1) / (datediff(date(fna.end_date) , date(fna.start_date)) + 1)) TOTAL_COST
  FROM   award_amt_fna_distribution fna
		join award_persons ai on ai.award_id = fna.award_id
		join award_person_unit au on au.AWARD_PERSON_ID = ai.AWARD_PERSON_ID
		join person p on  p.person_id = ai.person_id
		join jhu_unit ju on ju.unit_number = au.unit_number
        left outer join jhu_unit ju1 on CONCAT(SUBSTR(ju.sort_value, 1, 3) , '000000000000000000000000000') = ju1.sort_value
        left outer join jhu_unit ju2 on CONCAT(SUBSTR(ju.sort_value, 1, 6) , '000000000000000000000000') = ju2.sort_value
        left outer join jhu_unit ju3 on CONCAT(SUBSTR(ju.sort_value, 1, 9) , '000000000000000000000') = ju3.sort_value
        left outer join jhu_unit ju4 on CONCAT(SUBSTR(ju.sort_value, 1, 12) , '000000000000000000') = ju4.sort_value
        left outer join jhu_unit ju5 on CONCAT(SUBSTR(ju.sort_value, 1, 15) , '000000000000000') = ju5.sort_value
        left outer join jhu_unit ju6 on CONCAT(SUBSTR(ju.sort_value, 1, 18) , '000000000000') = ju6.sort_value
        left outer join jhu_unit ju7 on CONCAT(SUBSTR(ju.sort_value, 1, 21) , '000000000') = ju7.sort_value
  WHERE  date(fna.start_date) < str_to_date(report_start_date, '%m/%d/%Y')
  AND    date(fna.end_date) > str_to_date(report_end_date, '%m/%d/%Y')
  AND    fna.total_direct_cost > 0
  AND    find_in_set(au.unit_number,fn_get_temp_unit (report_unit))
  AND    au.lead_unit_flag = 'Y'
  AND    fna.sequence_number = (SELECT MAX(sequence_number)
                                FROM   award_amt_fna_distribution
                                WHERE  award_number = fna.award_number)
  AND    au.sequence_number = (SELECT MAX(sequence_number)
                                FROM   award_person_unit
                                WHERE  award_number = au.award_number)
  ORDER BY 4, 1, 2;
   SET div_precision_increment = LI_DIV_PRECISION_INCREMENT;
end
$$
DELIMITER ;
