DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `RPT_GET_410_INFO_bkp`(IN report_start_date  VARCHAR(50)
                  ,IN report_end_date  VARCHAR(50)
                  ,IN report_unit  VARCHAR(8))
BEGIN
  SELECT pr.FULL_NAME
        ,p.proposal_number MIT_AWARD_NUMBER
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
        ,'1' BUDGET_PERIOD
        ,ibh.TOTAL_DIRECT_COST DIRECT_COST
        ,ibh.TOTAL_INDIRECT_COST INDIRECT_COST
        ,(ibh.TOTAL_DIRECT_COST + ibh.TOTAL_INDIRECT_COST) TOTAL_COST
  FROM   proposal p
		 JOIN ip_budget_header ibh ON ibh.proposal_id=p.proposal_id
		 JOIN proposal_persons pi ON pi.proposal_number=p.proposal_number
         JOIN prop_person_units pu ON pu.proposal_person_id=pi.proposal_person_id
         JOIN person pr ON pr.person_id=pi.person_id
         JOIN jhu_unit ju ON ju.unit_number= pu.unit_number
         LEFT OUTER JOIN jhu_unit ju1 ON ju1.sort_value = CONCAT(SUBSTR(ju.sort_value, 1, 3) , '000000000000000000000000000')
         LEFT OUTER JOIN jhu_unit ju2 ON ju2.sort_value = CONCAT(SUBSTR(ju.sort_value, 1, 6) , '000000000000000000000000' )
         LEFT OUTER JOIN jhu_unit ju3 ON ju3.sort_value = CONCAT(SUBSTR(ju.sort_value, 1, 9) , '000000000000000000000')
         LEFT OUTER JOIN jhu_unit ju4 ON ju4.sort_value = CONCAT(SUBSTR(ju.sort_value, 1, 12) , '000000000000000000')
         LEFT OUTER JOIN jhu_unit ju5 ON ju5.sort_value = CONCAT(SUBSTR(ju.sort_value, 1, 15) , '000000000000000')
         LEFT OUTER JOIN jhu_unit ju6 ON ju6.sort_value = CONCAT(SUBSTR(ju.sort_value, 1, 18) , '000000000000')
         LEFT OUTER JOIN jhu_unit ju7 ON ju7.sort_value = CONCAT(SUBSTR(ju.sort_value, 1, 21) , '000000000')
  WHERE  DATE(p.start_date) >= STR_TO_DATE(report_start_date, '%m/%d/%Y')
  AND    DATE(p.end_date) <= STR_TO_DATE(report_end_date, '%m/%d/%Y')
  AND    ibh.TOTAL_DIRECT_COST > 0
  AND    p.status_code = 1
  AND    p.type_code IN (1, 4, 5, 6, 9)
  AND    pi.sequence_number = (SELECT MAX(sequence_number)
                               FROM   proposal_persons
                               WHERE  proposal_number = p.proposal_number)
  AND    FIND_IN_SET(pu.unit_number,fn_get_temp_unit (report_unit))
  AND    pu.lead_unit_flag = 'Y'
  AND    p.SEQUENCE_number = (select MAX(sequence_number)
							   FROM proposal WHERE proposal_number = p.proposal_number)
  AND    pu.sequence_number = (SELECT MAX(sequence_number)
                               FROM   prop_person_units
                               WHERE  proposal_number = p.proposal_number)
  UNION
  SELECT pr.FULL_NAME
        ,p.proposal_number MIT_AWARD_NUMBER
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
        ,'1' BUDGET_PERIOD
        ,ibh.TOTAL_DIRECT_COST * (cast((datediff(DATE(p.end_date) , STR_TO_DATE(report_start_date, '%m/%d/%Y')) + 1) as decimal(20,10)) / cast((datediff(DATE(p.end_date) , DATE(p.start_date)) + 1)as decimal(20,10))) DIRECT_COST
        ,ibh.TOTAL_INDIRECT_COST * (cast((datediff(DATE(p.end_date), STR_TO_DATE(report_start_date, '%m/%d/%Y')) + 1) as decimal(20,10)) / cast((datediff(DATE(p.end_date) , DATE(p.start_date)) + 1)as decimal(20,10)))  INDIRECT_COST
        ,ibh.TOTAL_DIRECT_COST * (cast((datediff(DATE(p.end_date) , STR_TO_DATE(report_start_date, '%m/%d/%Y')) + 1) as decimal(20,10)) / cast((datediff(DATE(p.end_date) , DATE(p.start_date)) + 1)as decimal(20,10)))  +
         ibh.TOTAL_INDIRECT_COST * (cast((datediff(DATE(p.end_date) , STR_TO_DATE(report_start_date, '%m/%d/%Y')) + 1) as decimal(20,10)) / cast((datediff(DATE(p.end_date) , DATE(p.start_date)) + 1)as decimal(20,10)))  TOTAL_COST
 FROM   proposal p
		 JOIN ip_budget_header ibh ON ibh.proposal_id=p.proposal_id
		 JOIN proposal_persons pi ON pi.proposal_number=p.proposal_number
         JOIN prop_person_units pu ON pu.proposal_person_id=pi.proposal_person_id
         JOIN person pr ON pr.person_id=pi.person_id
         JOIN jhu_unit ju ON ju.unit_number= pu.unit_number
         LEFT OUTER JOIN jhu_unit ju1 ON ju1.sort_value = CONCAT(SUBSTR(ju.sort_value, 1, 3) , '000000000000000000000000000')
         LEFT OUTER JOIN jhu_unit ju2 ON ju2.sort_value = CONCAT(SUBSTR(ju.sort_value, 1, 6) , '000000000000000000000000' )
         LEFT OUTER JOIN jhu_unit ju3 ON ju3.sort_value = CONCAT(SUBSTR(ju.sort_value, 1, 9) , '000000000000000000000')
         LEFT OUTER JOIN jhu_unit ju4 ON ju4.sort_value = CONCAT(SUBSTR(ju.sort_value, 1, 12) , '000000000000000000')
         LEFT OUTER JOIN jhu_unit ju5 ON ju5.sort_value = CONCAT(SUBSTR(ju.sort_value, 1, 15) , '000000000000000')
         LEFT OUTER JOIN jhu_unit ju6 ON ju6.sort_value = CONCAT(SUBSTR(ju.sort_value, 1, 18) , '000000000000')
         LEFT OUTER JOIN jhu_unit ju7 ON ju7.sort_value = CONCAT(SUBSTR(ju.sort_value, 1, 21) , '000000000')
  WHERE  DATE(p.start_date) <  STR_TO_DATE(report_start_date, '%m/%d/%Y')
  AND    DATE(p.end_date) >= STR_TO_DATE(report_start_date, '%m/%d/%Y')
  AND    DATE(p.end_date) <= STR_TO_DATE(report_end_date, '%m/%d/%Y')
  AND    ibh.TOTAL_DIRECT_COST > 0
  AND    p.status_code = 1
  AND    p.type_code IN (1, 4, 5, 6, 9)
  AND    pi.sequence_number = (SELECT MAX(sequence_number)
                               FROM   proposal_persons
                               WHERE  proposal_number = p.proposal_number)
  AND    FIND_IN_SET(pu.unit_number,fn_get_temp_unit (report_unit))
  AND    pu.lead_unit_flag = 'Y'
  AND    p.SEQUENCE_number = (select MAX(sequence_number)
							   FROM proposal WHERE proposal_number = p.proposal_number)
  AND    pu.sequence_number = (SELECT MAX(sequence_number)
                               FROM   prop_person_units
                               WHERE  proposal_number = p.proposal_number)
  UNION
  SELECT pr.FULL_NAME
        ,p.proposal_number MIT_AWARD_NUMBER
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
        ,'1' BUDGET_PERIOD
        ,ibh.TOTAL_DIRECT_COST * (cast((datediff(STR_TO_DATE(report_end_date, '%m/%d/%Y') , DATE(p.start_date)) + 1) as decimal(20,10)) / (datediff(DATE(p.end_date) , DATE(p.start_date)) + 1)) DIRECT_COST
        ,ibh.TOTAL_INDIRECT_COST * (cast((datediff(STR_TO_DATE(report_end_date, '%m/%d/%Y') , DATE(p.start_date)) + 1)as decimal(20,10)) / (datediff(DATE(p.end_date) , DATE(p.start_date)) + 1)) INDIRECT_COST
        ,ibh.TOTAL_DIRECT_COST * (cast((datediff(STR_TO_DATE(report_end_date, '%m/%d/%Y') , DATE(p.start_date)) + 1)as decimal(20,10)) / (datediff(DATE(p.end_date) , DATE(p.start_date)) + 1)) +
         ibh.TOTAL_INDIRECT_COST * (cast((datediff(STR_TO_DATE(report_end_date, '%m/%d/%Y') , DATE(p.start_date)) + 1)as decimal(20,10)) / (datediff(DATE(p.end_date) , DATE(p.start_date)) + 1)) TOTAL_COST
  FROM   proposal p
		 JOIN ip_budget_header ibh ON ibh.proposal_id=p.proposal_id
		 JOIN proposal_persons pi ON pi.proposal_number=p.proposal_number
         JOIN prop_person_units pu ON pu.proposal_person_id=pi.proposal_person_id
         JOIN person pr ON pr.person_id=pi.person_id
         JOIN jhu_unit ju ON ju.unit_number= pu.unit_number
         LEFT OUTER JOIN jhu_unit ju1 ON ju1.sort_value = CONCAT(SUBSTR(ju.sort_value, 1, 3) , '000000000000000000000000000')
         LEFT OUTER JOIN jhu_unit ju2 ON ju2.sort_value = CONCAT(SUBSTR(ju.sort_value, 1, 6) , '000000000000000000000000' )
         LEFT OUTER JOIN jhu_unit ju3 ON ju3.sort_value = CONCAT(SUBSTR(ju.sort_value, 1, 9) , '000000000000000000000')
         LEFT OUTER JOIN jhu_unit ju4 ON ju4.sort_value = CONCAT(SUBSTR(ju.sort_value, 1, 12) , '000000000000000000')
         LEFT OUTER JOIN jhu_unit ju5 ON ju5.sort_value = CONCAT(SUBSTR(ju.sort_value, 1, 15) , '000000000000000')
         LEFT OUTER JOIN jhu_unit ju6 ON ju6.sort_value = CONCAT(SUBSTR(ju.sort_value, 1, 18) , '000000000000')
         LEFT OUTER JOIN jhu_unit ju7 ON ju7.sort_value = CONCAT(SUBSTR(ju.sort_value, 1, 21) , '000000000')
  WHERE  DATE(p.start_date) >= STR_TO_DATE(report_start_date, '%m/%d/%Y')
  AND    DATE(p.start_date) <= STR_TO_DATE(report_end_date, '%m/%d/%Y')
  AND    DATE(p.end_date) >  STR_TO_DATE(report_end_date, '%m/%d/%Y')
  AND    ibh.TOTAL_DIRECT_COST > 0
  AND    p.status_code = 1
  AND    p.type_code IN (1, 4, 5, 6, 9)
  AND    pi.sequence_number = (SELECT MAX(sequence_number)
                               FROM   proposal_persons
                               WHERE  proposal_number = p.proposal_number)
  AND    FIND_IN_SET(pu.unit_number,fn_get_temp_unit (report_unit))
  AND    pu.lead_unit_flag = 'Y'
  AND    p.SEQUENCE_number = (select MAX(sequence_number)
							   FROM proposal WHERE proposal_number = p.proposal_number)
  AND    pu.sequence_number = (SELECT MAX(sequence_number)
                               FROM   prop_person_units
                               WHERE  proposal_number = p.proposal_number)
  UNION
  SELECT pr.FULL_NAME
        ,p.proposal_number MIT_AWARD_NUMBER
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
        ,'1' BUDGET_PERIOD
        ,ibh.TOTAL_DIRECT_COST * ((datediff(STR_TO_DATE(report_end_date, '%m/%d/%Y') , STR_TO_DATE(report_start_date, '%m/%d/%Y')) + 1) / (datediff(DATE(p.end_date) , DATE(p.start_date)) + 1)) DIRECT_COST
        ,ibh.TOTAL_INDIRECT_COST * ((datediff(STR_TO_DATE(report_end_date, '%m/%d/%Y') , STR_TO_DATE(report_start_date, '%m/%d/%Y')) + 1) / (datediff(DATE(p.end_date) , DATE(p.start_date)) + 1)) INDIRECT_COST
        ,ibh.TOTAL_DIRECT_COST * ((datediff(STR_TO_DATE(report_end_date, '%m/%d/%Y') , STR_TO_DATE(report_start_date, '%m/%d/%Y')) + 1) / (datediff(DATE(p.end_date) , DATE(p.start_date)) + 1)) +
         ibh.TOTAL_INDIRECT_COST * ((datediff(STR_TO_DATE(report_end_date, '%m/%d/%Y') , STR_TO_DATE(report_start_date, '%m/%d/%Y')) + 1) / (datediff(DATE(p.end_date) , DATE(p.start_date)) + 1)) TOTAL_COST
  FROM   proposal p
		 JOIN ip_budget_header ibh ON ibh.proposal_id=p.proposal_id
		 JOIN proposal_persons pi ON pi.proposal_number=p.proposal_number
         JOIN prop_person_units pu ON pu.proposal_person_id=pi.proposal_person_id
         JOIN person pr ON pr.person_id=pi.person_id
         JOIN jhu_unit ju ON ju.unit_number= pu.unit_number
         LEFT OUTER JOIN jhu_unit ju1 ON ju1.sort_value = CONCAT(SUBSTR(ju.sort_value, 1, 3) , '000000000000000000000000000')
         LEFT OUTER JOIN jhu_unit ju2 ON ju2.sort_value = CONCAT(SUBSTR(ju.sort_value, 1, 6) , '000000000000000000000000' )
         LEFT OUTER JOIN jhu_unit ju3 ON ju3.sort_value = CONCAT(SUBSTR(ju.sort_value, 1, 9) , '000000000000000000000')
         LEFT OUTER JOIN jhu_unit ju4 ON ju4.sort_value = CONCAT(SUBSTR(ju.sort_value, 1, 12) , '000000000000000000')
         LEFT OUTER JOIN jhu_unit ju5 ON ju5.sort_value = CONCAT(SUBSTR(ju.sort_value, 1, 15) , '000000000000000')
         LEFT OUTER JOIN jhu_unit ju6 ON ju6.sort_value = CONCAT(SUBSTR(ju.sort_value, 1, 18) , '000000000000')
         LEFT OUTER JOIN jhu_unit ju7 ON ju7.sort_value = CONCAT(SUBSTR(ju.sort_value, 1, 21) , '000000000')
  WHERE  DATE(p.start_date) < STR_TO_DATE(report_start_date, '%m/%d/%Y')
  AND    DATE(p.end_date) > STR_TO_DATE(report_end_date, '%m/%d/%Y')
  AND    ibh.TOTAL_DIRECT_COST > 0
  AND    p.status_code = 1
  AND    p.type_code IN (1, 4, 5, 6, 9)
  AND    pi.sequence_number = (SELECT MAX(sequence_number)
                               FROM   proposal_persons
                               WHERE  proposal_number = p.proposal_number)
  AND    FIND_IN_SET(pu.unit_number,fn_get_temp_unit (report_unit))
  AND    pu.lead_unit_flag = 'Y'
  AND    p.SEQUENCE_number = (select MAX(sequence_number)
							   FROM proposal WHERE proposal_number = p.proposal_number)
  AND    pu.sequence_number = (SELECT MAX(sequence_number)
                               FROM   prop_person_units
                               WHERE  proposal_number = p.proposal_number)
  ORDER BY 4, 1, 2;
END
$$
DELIMITER ;
