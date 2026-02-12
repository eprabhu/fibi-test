DELIMITER $$
CREATE  PROCEDURE `RPT_GET_414_INFO`(
                                                 IN report_start_date VARCHAR(50)
                                               , IN report_end_date   VARCHAR(50)
                                               , IN report_unit       VARCHAR(8)
                                             )
BEGIN
DECLARE LI_DIV_PRECISION_INCREMENT int;
 SET li_div_precision_increment=@@div_precision_increment;
 SET div_precision_increment = 30;
        SELECT	distinct
                        p.proposal_number                            MIT_AWARD_NUMBER
                      , s.unit_number                                SCHOOL_NUMBER
                      , s.unit_name                                  SCHOOL_NAME
                      ,'1'                                           BUDGET_PERIOD
                      , ibh.TOTAL_DIRECT_COST                          DIRECT_COST
                      , ibh.TOTAL_INDIRECT_COST                        INDIRECT_COST
                      ,(ibh.TOTAL_DIRECT_COST + ibh.TOTAL_INDIRECT_COST) TOTAL_COST
        FROM
                        proposal p
						JOIN ip_budget_header ibh ON ibh.proposal_id=p.proposal_id
                        JOIN
                                        prop_person_units pu
                                        ON
                                                        pu.proposal_number = p.proposal_number
                        LEFT OUTER JOIN
                                        unit s
                                        ON
                                                        s.unit_number=CONCAT(SUBSTR(pu.unit_number, 1, 3) , '00000')
        WHERE
                            DATE(p.start_date) >= STR_TO_DATE(report_start_date, '%m/%d/%Y')
                        AND DATE(p.end_date)   <= STR_TO_DATE(report_end_date, '%m/%d/%Y')
                        AND ibh.TOTAL_DIRECT_COST > 0
                        AND p.status_code       = 1
                        AND p.type_code IN (1
                                          , 4
                                          , 5
                                          , 6
                                          , 9)
                        AND FIND_IN_SET(pu.unit_number,fn_get_temp_unit(report_unit))
                        AND pu.lead_unit_flag  = 'Y'
                        AND pu.sequence_number =
                        (
                               SELECT
                                      MAX(sequence_number)
                               FROM
                                      prop_person_units
                               WHERE
                                      proposal_number = pu.proposal_number
                        )
        UNION
        SELECT			distinct
                        p.proposal_number                                                                                                                                                                                                                                                                                 MIT_AWARD_NUMBER
                      , s.unit_number                                                                                                                                                                                                                                                                                     SCHOOL_NUMBER
                      , s.unit_name                                                                                                                                                                                                                                                                                       SCHOOL_NAME
                      ,'1'                                                                                                                                                                                                                                                                                                BUDGET_PERIOD
                      , ibh.TOTAL_DIRECT_COST   * ((datediff(DATE(p.end_date) , STR_TO_DATE(report_start_date, '%m/%d/%Y')) + 1) / (datediff(DATE(p.end_date) , DATE(p.start_date)) + 1))                                                                                                                                                   DIRECT_COST
                      , ibh.TOTAL_INDIRECT_COST * ((datediff(DATE(p.end_date) , STR_TO_DATE(report_start_date, '%m/%d/%Y')) + 1) / (datediff(DATE(p.end_date) , DATE(p.start_date)) + 1))                                                                                                                                                   INDIRECT_COST
                      , ibh.TOTAL_DIRECT_COST   * ((datediff(DATE(p.end_date) , STR_TO_DATE(report_start_date, '%m/%d/%Y')) + 1) / (datediff(DATE(p.end_date) , DATE(p.start_date)) + 1)) +
                        ibh.TOTAL_INDIRECT_COST * ((datediff(DATE(p.end_date) , STR_TO_DATE(report_start_date, '%m/%d/%Y')) + 1) / (datediff(DATE(p.end_date) , DATE(p.start_date)) + 1)) TOTAL_COST
        FROM
                        proposal p
						JOIN ip_budget_header ibh ON ibh.proposal_id=p.proposal_id
                        JOIN
                                        prop_person_units pu
                                        ON
                                                        pu.proposal_number = p.proposal_number
                        LEFT OUTER JOIN
                                        unit s
                                        ON
                                                        s.unit_number=CONCAT(SUBSTR(pu.unit_number, 1, 3) , '00000')
        WHERE
                            DATE(p.start_date)  < STR_TO_DATE(report_start_date, '%m/%d/%Y')
                        AND DATE(p.end_date)   >= STR_TO_DATE(report_start_date, '%m/%d/%Y')
                        AND DATE(p.end_date)   <= STR_TO_DATE(report_end_date, '%m/%d/%Y')
                        AND ibh.TOTAL_DIRECT_COST > 0
                        AND p.status_code       = 1
                        AND p.type_code IN (1
                                          , 4
                                          , 5
                                          , 6
                                          , 9)
                        AND FIND_IN_SET(pu.unit_number,fn_get_temp_unit(report_unit))
                        AND pu.lead_unit_flag  = 'Y'
                        AND pu.sequence_number =
                        (
                               SELECT
                                      MAX(sequence_number)
                               FROM
                                      prop_person_units
                               WHERE
                                      proposal_number = pu.proposal_number
                        )
        UNION
        SELECT			distinct
                        p.proposal_number                                                                                                                                                                                                                                                                                 MIT_AWARD_NUMBER
                      , s.unit_number                                                                                                                                                                                                                                                                                     SCHOOL_NUMBER
                      , s.unit_name                                                                                                                                                                                                                                                                                       SCHOOL_NAME
                      ,'1'                                                                                                                                                                                                                                                                                                BUDGET_PERIOD
                      , ibh.TOTAL_DIRECT_COST   * ((datediff(STR_TO_DATE(report_end_date, '%m/%d/%Y') , DATE(p.start_date)) + 1) / (datediff(DATE(p.end_date) , DATE(p.start_date)) + 1))                                                                                                                                                   DIRECT_COST
                      , ibh.TOTAL_INDIRECT_COST * ((datediff(STR_TO_DATE(report_end_date, '%m/%d/%Y') , DATE(p.start_date)) + 1) / (datediff(DATE(p.end_date) , DATE(p.start_date)) + 1))                                                                                                                                                   INDIRECT_COST
                      , ibh.TOTAL_DIRECT_COST   * ((datediff(STR_TO_DATE(report_end_date, '%m/%d/%Y') , DATE(p.start_date)) + 1) / (datediff(DATE(p.end_date) , DATE(p.start_date)) + 1)) +
                      ibh.TOTAL_INDIRECT_COST * ((datediff(STR_TO_DATE(report_end_date, '%m/%d/%Y') , DATE(p.start_date)) + 1) / (datediff(DATE(p.end_date) , DATE(p.start_date)) + 1)) TOTAL_COST
        FROM
                        proposal p
						JOIN ip_budget_header ibh ON ibh.proposal_id=p.proposal_id
                        JOIN
                                        prop_person_units pu
                                        ON
                                                        pu.proposal_number = p.proposal_number
                        LEFT OUTER JOIN
                                        unit s
                                        ON
                                                        s.unit_number=CONCAT(SUBSTR(pu.unit_number, 1, 3) , '00000')
        WHERE
                            DATE(p.start_date) >= STR_TO_DATE(report_start_date, '%m/%d/%Y')
                        AND DATE(p.start_date) <= STR_TO_DATE(report_end_date, '%m/%d/%Y')
                        AND DATE(p.end_date)    > STR_TO_DATE(report_end_date, '%m/%d/%Y')
                        AND ibh.TOTAL_DIRECT_COST > 0
                        AND p.status_code       = 1
                        AND p.type_code IN (1
                                          , 4
                                          , 5
                                          , 6
                                          , 9)
                        AND FIND_IN_SET(pu.unit_number,fn_get_temp_unit(report_unit))
                        AND pu.lead_unit_flag  = 'Y'
                        AND pu.sequence_number =
                        (
                               SELECT
                                      MAX(sequence_number)
                               FROM
                                      prop_person_units
                               WHERE
                                      proposal_number = pu.proposal_number
                        )
        UNION
        SELECT		distinct
                        p.proposal_number                                                                                                                                                                                                                                                                                                                                 MIT_AWARD_NUMBER
                      , s.unit_number                                                                                                                                                                                                                                                                                                                                     SCHOOL_NUMBER
                      , s.unit_name                                                                                                                                                                                                                                                                                                                                       SCHOOL_NAME
                      ,'1'                                                                                                                                                                                                                                                                                                                                                BUDGET_PERIOD
                      , ibh.TOTAL_DIRECT_COST   * ((datediff(STR_TO_DATE(report_end_date, '%m/%d/%Y') , STR_TO_DATE(report_start_date, '%m/%d/%Y')) + 1) / (datediff(DATE(p.end_date) , DATE(p.start_date)) + 1))                                                                                                                                                                           DIRECT_COST
                      , ibh.TOTAL_INDIRECT_COST * ((datediff(STR_TO_DATE(report_end_date, '%m/%d/%Y') , STR_TO_DATE(report_start_date, '%m/%d/%Y')) + 1) / (datediff(DATE(p.end_date) , DATE(p.start_date)) + 1))                                                                                                                                                                           INDIRECT_COST
                      , ibh.TOTAL_DIRECT_COST   * ((datediff(STR_TO_DATE(report_end_date, '%m/%d/%Y') , STR_TO_DATE(report_start_date, '%m/%d/%Y')) + 1) / (datediff(DATE(p.end_date) , DATE(p.start_date)) + 1)) +
                      ibh.TOTAL_INDIRECT_COST * ((datediff(STR_TO_DATE(report_end_date, '%m/%d/%Y') , STR_TO_DATE(report_start_date, '%m/%d/%Y')) + 1) / (datediff(DATE(p.end_date) , DATE(p.start_date)) + 1)) TOTAL_COST
        FROM
                        proposal p
						JOIN ip_budget_header ibh ON ibh.proposal_id=p.proposal_id
                        JOIN
                                        prop_person_units pu
                                        ON
                                                        pu.proposal_number = p.proposal_number
                        LEFT OUTER JOIN
                                        unit s
                                        ON
                                                        s.unit_number=CONCAT(SUBSTR(pu.unit_number, 1, 3) , '00000')
        WHERE
                            DATE(p.start_date)  < STR_TO_DATE(report_start_date, '%m/%d/%Y')
                        AND DATE(p.end_date)    > STR_TO_DATE(report_end_date, '%m/%d/%Y')
                        AND ibh.TOTAL_DIRECT_COST > 0
                        AND p.status_code       = 1
                        AND p.type_code IN (1
                                          , 4
                                          , 5
                                          , 6
                                          , 9)
                        AND FIND_IN_SET(pu.unit_number,fn_get_temp_unit(report_unit))
                        AND pu.lead_unit_flag  = 'Y'
                        AND pu.sequence_number =
                        (
                               SELECT
                                      MAX(sequence_number)
                               FROM
                                      prop_person_units
                               WHERE
                                      proposal_number = pu.proposal_number
                        )
        ORDER BY
                        2
                      , 1
        ;
    SET div_precision_increment = LI_DIV_PRECISION_INCREMENT;
    END
$$
DELIMITER ;
