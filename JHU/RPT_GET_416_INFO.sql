DELIMITER $$
CREATE  PROCEDURE `RPT_GET_416_INFO`(
                                IN report_start_date VARCHAR(50)
                              , IN report_end_date   VARCHAR(50)
                              , IN report_unit       VARCHAR(8)
                            )
BEGIN
DECLARE LI_DIV_PRECISION_INCREMENT int;
 SET li_div_precision_increment=@@div_precision_increment;
 SET div_precision_increment = 30;
         SELECT
               p.proposal_number MIT_AWARD_NUMBER
             , pr.FULL_NAME
             ,'1'                                           BUDGET_PERIOD
             , ibh.TOTAL_DIRECT_COST                          DIRECT_COST
             , ibh.TOTAL_INDIRECT_COST                        INDIRECT_COST
             ,(ibh.TOTAL_DIRECT_COST + ibh.TOTAL_INDIRECT_COST) TOTAL_COST
        FROM
               proposal          p
             , ip_budget_header  ibh
             , proposal_persons  pi
             , prop_person_units pu
             , person            pr
        WHERE
                   DATE(p.start_date) >= STR_TO_DATE(report_start_date, '%m/%d/%Y')
               AND DATE(p.end_date)   <= STR_TO_DATE(report_end_date, '%m/%d/%Y')
               AND p.status_code       = 1
               AND p.type_code IN (1
                                 , 4
                                 , 5
                                 , 6
                                 , 9)
               AND ibh.proposal_id=p.proposal_id
			   AND ibh.TOTAL_DIRECT_COST > 0
               AND pi.proposal_number = p.proposal_number
               AND FIND_IN_SET (pu.unit_number,fn_get_temp_unit(report_unit))
               AND pu.lead_unit_flag     = 'Y'
               AND pu.proposal_person_id = pi.proposal_person_id
               AND pu.sequence_number    =
               (
                      SELECT
                             MAX(sequence_number)
                      FROM
                             prop_person_units
                      WHERE
                             proposal_number = pu.proposal_number
               )
               AND pr.person_id = pi.person_id
        UNION
        SELECT
               p.proposal_number MIT_AWARD_NUMBER
             , pr.FULL_NAME
             ,'1'                                                                                                                                                                                                                                                                                                BUDGET_PERIOD
             , ibh.TOTAL_DIRECT_COST   * ((datediff(DATE(p.end_date) , STR_TO_DATE(report_start_date, '%m/%d/%Y')) + 1) / (datediff(DATE(p.end_date) , DATE(p.start_date)) + 1))                                                                                                                                                   DIRECT_COST
             , ibh.TOTAL_INDIRECT_COST * ((datediff(DATE(p.end_date) , STR_TO_DATE(report_start_date, '%m/%d/%Y')) + 1) / (datediff(DATE(p.end_date) , DATE(p.start_date)) + 1))                                                                                                                                                   INDIRECT_COST
             , ibh.TOTAL_DIRECT_COST   * ((datediff(DATE(p.end_date) , STR_TO_DATE(report_start_date, '%m/%d/%Y')) + 1) / (datediff(DATE(p.end_date) , DATE(p.start_date)) + 1)) +
             ibh.TOTAL_INDIRECT_COST * ((datediff(DATE(p.end_date) , STR_TO_DATE(report_start_date, '%m/%d/%Y')) + 1) / (datediff(DATE(p.end_date) , DATE(p.start_date)) + 1)) TOTAL_COST
        FROM
               proposal          p
			 , ip_budget_header  ibh
             , proposal_persons  pi
             , prop_person_units pu
             , person            pr
        WHERE
                   DATE(p.start_date)  < STR_TO_DATE(report_start_date, '%m/%d/%Y')
               AND DATE(p.end_date)   >= STR_TO_DATE(report_start_date, '%m/%d/%Y')
               AND DATE(p.end_date)   <= STR_TO_DATE(report_end_date, '%m/%d/%Y')
               AND p.status_code       = 1
               AND p.type_code IN (1
                                 , 4
                                 , 5
                                 , 6
                                 , 9)
               AND ibh.proposal_id=p.proposal_id
			   AND ibh.TOTAL_DIRECT_COST > 0
               AND pi.proposal_number = p.proposal_number
               AND FIND_IN_SET (pu.unit_number,fn_get_temp_unit(report_unit))
               AND pu.lead_unit_flag     = 'Y'
               AND pu.proposal_person_id = pi.proposal_person_id
               AND pu.sequence_number    =
               (
                      SELECT
                             MAX(sequence_number)
                      FROM
                             prop_person_units
                      WHERE
                             proposal_number = pu.proposal_number
               )
               AND pr.person_id = pi.person_id
        UNION
        SELECT
               p.proposal_number MIT_AWARD_NUMBER
             , pr.FULL_NAME
             ,'1'                                                                                                                                                                                                                                                                                                BUDGET_PERIOD
             , ibh.TOTAL_DIRECT_COST   * ((datediff(STR_TO_DATE(report_end_date, '%m/%d/%Y') , DATE(p.start_date)) + 1) / (datediff(DATE(p.end_date) , DATE(p.start_date)) + 1))                                                                                                                                                   DIRECT_COST
             , ibh.TOTAL_INDIRECT_COST * ((datediff(STR_TO_DATE(report_end_date, '%m/%d/%Y') , DATE(p.start_date)) + 1) / (datediff(DATE(p.end_date) , DATE(p.start_date)) + 1))                                                                                                                                                   INDIRECT_COST
             , ibh.TOTAL_DIRECT_COST   * ((datediff(STR_TO_DATE(report_end_date, '%m/%d/%Y') , DATE(p.start_date)) + 1) / (datediff(DATE(p.end_date) , DATE(p.start_date)) + 1)) +
				ibh.TOTAL_INDIRECT_COST * ((datediff(STR_TO_DATE(report_end_date, '%m/%d/%Y') , DATE(p.start_date)) + 1) / (datediff(DATE(p.end_date) , DATE(p.start_date)) + 1)) TOTAL_COST
        FROM
               proposal          p
			 , ip_budget_header  ibh
             , proposal_persons  pi
             , prop_person_units pu
             , person            pr
        WHERE
                   DATE(p.start_date) >= STR_TO_DATE(report_start_date, '%m/%d/%Y')
               AND DATE(p.start_date) <= STR_TO_DATE(report_end_date, '%m/%d/%Y')
               AND DATE(p.end_date)    > STR_TO_DATE(report_end_date, '%m/%d/%Y')
               AND p.status_code       = 1
               AND p.type_code IN (1
                                 , 4
                                 , 5
                                 , 6
                                 , 9)
               AND ibh.proposal_id=p.proposal_id
			   AND ibh.TOTAL_DIRECT_COST > 0
               AND pi.proposal_number = p.proposal_number
               AND FIND_IN_SET (pu.unit_number,fn_get_temp_unit(report_unit))
               AND pu.lead_unit_flag     = 'Y'
               AND pu.proposal_person_id = pi.proposal_person_id
               AND pu.sequence_number    =
               (
                      SELECT
                             MAX(sequence_number)
                      FROM
                             prop_person_units
                      WHERE
                             proposal_number = pu.proposal_number
               )
               AND pr.person_id = pi.person_id
        UNION
        SELECT
                 p.proposal_number MIT_AWARD_NUMBER
               , pr.FULL_NAME
               ,'1'                                                                                                                                                                                                                                                                                                                                                BUDGET_PERIOD
               , ibh.TOTAL_DIRECT_COST   * ((datediff(STR_TO_DATE(report_end_date, '%m/%d/%Y') , STR_TO_DATE(report_start_date, '%m/%d/%Y')) + 1) / (datediff(DATE(p.end_date) , DATE(p.start_date)) + 1))                                                                                                                                                                           DIRECT_COST
               , ibh.TOTAL_INDIRECT_COST * ((datediff(STR_TO_DATE(report_end_date, '%m/%d/%Y') , STR_TO_DATE(report_start_date, '%m/%d/%Y')) + 1) / (datediff(DATE(p.end_date) , DATE(p.start_date)) + 1))                                                                                                                                                                           INDIRECT_COST
               , ibh.TOTAL_DIRECT_COST   * ((datediff(STR_TO_DATE(report_end_date, '%m/%d/%Y') , STR_TO_DATE(report_start_date, '%m/%d/%Y')) + 1) / (datediff(DATE(p.end_date) , DATE(p.start_date)) + 1)) +
				ibh.TOTAL_INDIRECT_COST * ((datediff(STR_TO_DATE(report_end_date, '%m/%d/%Y') , STR_TO_DATE(report_start_date, '%m/%d/%Y')) + 1) / (datediff(DATE(p.end_date) , DATE(p.start_date)) + 1)) TOTAL_COST
        FROM
                 proposal          p
			   , ip_budget_header  ibh
               , proposal_persons  pi
               , prop_person_units pu
               , person            pr
        WHERE
                     DATE(p.start_date)  < STR_TO_DATE(report_start_date, '%m/%d/%Y')
                 AND DATE(p.end_date)    > STR_TO_DATE(report_end_date, '%m/%d/%Y')
                 AND p.status_code       = 1
                 AND p.type_code IN (1
                                   , 4
                                   , 5
                                   , 6
                                   , 9)
                 AND ibh.proposal_id=p.proposal_id
                 AND ibh.TOTAL_DIRECT_COST > 0
                 AND pi.proposal_number = p.proposal_number
                 AND FIND_IN_SET (pu.unit_number,fn_get_temp_unit(report_unit))
                 AND pu.lead_unit_flag     = 'Y'
                 AND pu.proposal_person_id = pi.proposal_person_id
                 AND pu.sequence_number    =
                 (
                        SELECT
                               MAX(sequence_number)
                        FROM
                               prop_person_units
                        WHERE
                               proposal_number = pu.proposal_number
                 )
                 AND pr.person_id = pi.person_id
        ORDER BY
                 2
               , 1
        ;
   SET div_precision_increment = LI_DIV_PRECISION_INCREMENT;
    END
$$
DELIMITER ;
