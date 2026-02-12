DELIMITER $$
CREATE  PROCEDURE `RPT_GET_415_INFO`(IN report_start_date  VARCHAR(500)
                  ,IN report_end_date  VARCHAR(500)
                  ,IN report_unit  VARCHAR(8)
                  )
Begin
DECLARE LI_DIV_PRECISION_INCREMENT int;
 SET li_div_precision_increment=@@div_precision_increment;
 SET div_precision_increment = 30;
WITH fna as  ( SELECT 	fna2.award_number,
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
				AND 	 fna2.SEQUENCE_NUMBER=fna1.max_seq)
SELECT  distinct fna.award_number MIT_AWARD_NUMBER
        ,p.FULL_NAME
        ,fna.BUDGET_PERIOD
        ,fna.total_direct_cost DIRECT_COST
        ,fna.total_indirect_cost INDIRECT_COST
        ,(fna.total_direct_cost + fna.total_indirect_cost) TOTAL_COST
  FROM   fna
		join award_persons ai on    ai.award_id = fna.award_id
							  AND    ai.sequence_number = (SELECT MAX(sequence_number)
															FROM   award_persons
															WHERE  award_number = ai.award_number)
        join award_person_unit au on   au.AWARD_PERSON_ID = ai.AWARD_PERSON_ID
								  AND    au.sequence_number = (SELECT MAX(sequence_number)
															FROM   award_person_unit
															WHERE  award_number = au.award_number)
		join person p on    p.person_id = ai.person_id
  WHERE  date(fna.start_date) >= str_to_date(report_start_date, '%m/%d/%Y')
  AND    date(fna.end_date) <= str_to_date(report_end_date, '%m/%d/%Y')
  AND    fna.total_direct_cost > 0
  AND    find_in_set(au.unit_number,fn_get_temp_unit(report_unit))
  AND    au.lead_unit_flag = 'Y'
  UNION
  SELECT distinct fna.award_number MIT_AWARD_NUMBER
        ,p.FULL_NAME
        ,fna.BUDGET_PERIOD
        ,fna.total_direct_cost * ((datediff(date(fna.end_date),str_to_date(report_start_date, '%m/%d/%Y')) + 1) / (datediff(date(fna.end_date),date(fna.start_date)) + 1)) DIRECT_COST
        ,fna.total_indirect_cost * ((datediff(date(fna.end_date),str_to_date(report_start_date, '%m/%d/%Y')) + 1) / (datediff(date(fna.end_date),date(fna.start_date)) + 1)) INDIRECT_COST
        ,fna.total_direct_cost * ((datediff(date(fna.end_date),str_to_date(report_start_date, '%m/%d/%Y')) + 1) / (datediff(date(fna.end_date),date(fna.start_date)) + 1)) +
         fna.total_indirect_cost * ((datediff(date(fna.end_date),str_to_date(report_start_date, '%m/%d/%Y')) + 1) / (datediff(date(fna.end_date),date(fna.start_date)) + 1)) TOTAL_COST
  FROM   fna
		join award_persons ai on    ai.award_id = fna.award_id
							  AND    ai.sequence_number = (SELECT MAX(sequence_number)
															FROM   award_persons
															WHERE  award_number = ai.award_number)
        join award_person_unit au on   au.AWARD_PERSON_ID = ai.AWARD_PERSON_ID
								  AND    au.sequence_number = (SELECT MAX(sequence_number)
															FROM   award_person_unit
															WHERE  award_number = au.award_number)
		join person p on    p.person_id = ai.person_id
  WHERE  date(fna.start_date) <  str_to_date(report_start_date,'%m/%d/%Y')
  AND    date(fna.end_date) >= str_to_date(report_start_date, '%m/%d/%Y')
  AND    date(fna.end_date) <= str_to_date(report_end_date, '%m/%d/%Y')
  AND    fna.total_direct_cost > 0
   AND    find_in_set(au.unit_number,fn_get_temp_unit(report_unit))
  AND    au.lead_unit_flag = 'Y'
  UNION
   SELECT distinct fna.award_number MIT_AWARD_NUMBER
        ,p.FULL_NAME
        ,fna.BUDGET_PERIOD
        ,fna.total_direct_cost * ((datediff(str_to_date(report_end_date, '%m/%d/%Y'),date(fna.start_date)) + 1) / (datediff(date(fna.end_date),date(fna.start_date)) + 1)) DIRECT_COST
        ,fna.total_indirect_cost * ((datediff(str_to_date(report_end_date, '%m/%d/%Y'),date(fna.start_date)) + 1) / (datediff(date(fna.end_date),date(fna.start_date)) + 1)) INDIRECT_COST
        ,fna.total_direct_cost * ((datediff(str_to_date(report_end_date, '%m/%d/%Y'),date(fna.start_date)) + 1) / (datediff(date(fna.end_date),date(fna.start_date)) + 1)) +
         fna.total_indirect_cost * ((datediff(str_to_date(report_end_date, '%m/%d/%Y'),date(fna.start_date)) + 1) / (datediff(date(fna.end_date),date(fna.start_date)) + 1)) TOTAL_COST
  FROM   fna
		join award_persons ai on    ai.award_id = fna.award_id
							  AND    ai.sequence_number = (SELECT MAX(sequence_number)
															FROM   award_persons
															WHERE  award_number = ai.award_number)
        join award_person_unit au on   au.AWARD_PERSON_ID = ai.AWARD_PERSON_ID
								  AND    au.sequence_number = (SELECT MAX(sequence_number)
															FROM   award_person_unit
															WHERE  award_number = au.award_number)
		join person p on    p.person_id = ai.person_id
  WHERE  date(fna.start_date) >= str_to_date(report_start_date, '%m/%d/%Y')
  AND    date(fna.start_date) <= str_to_date(report_end_date, '%m/%d/%Y')
  AND    date(fna.end_date) >  str_to_date(report_end_date, '%m/%d/%Y')
  AND    fna.total_direct_cost > 0
  AND    find_in_set(au.unit_number,fn_get_temp_unit(report_unit))
  AND    au.lead_unit_flag = 'Y'
  UNION
  SELECT distinct fna.award_number MIT_AWARD_NUMBER
        ,p.FULL_NAME
        ,fna.BUDGET_PERIOD
        ,fna.total_direct_cost * ((datediff(str_to_date(report_end_date, '%m/%d/%Y'),str_to_date(report_start_date, '%m/%d/%Y')) + 1) / (datediff(date(fna.end_date),date(fna.start_date)) + 1)) DIRECT_COST
        ,fna.total_indirect_cost * ((datediff(str_to_date(report_end_date, '%m/%d/%Y'),str_to_date(report_start_date, '%m/%d/%Y')) + 1) / (datediff(date(fna.end_date),date(fna.start_date)) + 1)) INDIRECT_COST
        ,fna.total_direct_cost * ((datediff(str_to_date(report_end_date, '%m/%d/%Y'),str_to_date(report_start_date, '%m/%d/%Y')) + 1) / (datediff(date(fna.end_date),date(fna.start_date)) + 1)) +
         fna.total_indirect_cost * ((datediff(str_to_date(report_end_date, '%m/%d/%Y'),str_to_date(report_start_date, '%m/%d/%Y')) + 1) / (datediff(date(fna.end_date),date(fna.start_date)) + 1)) TOTAL_COST
  FROM   fna
		join award_persons ai on    ai.award_id = fna.award_id
							  AND    ai.sequence_number = (SELECT MAX(sequence_number)
															FROM   award_persons
															WHERE  award_number = ai.award_number)
        join award_person_unit au on   au.AWARD_PERSON_ID = ai.AWARD_PERSON_ID
								  AND    au.sequence_number = (SELECT MAX(sequence_number)
															FROM   award_person_unit
															WHERE  award_number = au.award_number)
		join person p on    p.person_id = ai.person_id
  WHERE  date(fna.start_date) < str_to_date(report_start_date, '%m/%d/%Y')
  AND    date(fna.end_date) > str_to_date(report_end_date, '%m/%d/%Y')
  AND    fna.total_direct_cost > 0
  AND    find_in_set(au.unit_number,fn_get_temp_unit(report_unit))
  AND    au.lead_unit_flag = 'Y'
  ORDER BY 2, 1;
 SET div_precision_increment = LI_DIV_PRECISION_INCREMENT;
End
$$
DELIMITER ;
