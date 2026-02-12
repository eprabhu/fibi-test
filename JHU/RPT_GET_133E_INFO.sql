DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `RPT_GET_133E_INFO`(IN report_unit VARCHAR(8)                   )
BEGIN
    SELECT Distinct	  ip.PROPOSAL_NUMBER
			,SUBSTR(a.award_number, 1, 6) GRANT_NUMBER
			,pm.sponsored_program_number PRIMARY_SPONSORED_PROGRAM
			,SUBSTR(pu.unit_number, 1, 3) LEAD_UNIT
			,(CAST(REPLACE(asr.protocol_number,' ','') AS CHAR CHARACTER SET utf8) COLLATE utf8_bin) PROTOCOL_NUMBER
			,p.FULL_NAME
			,p.user_name JHED_ID
			,s.SPONSOR_NAME
			,s.SPONSOR_CODE
			,'133e' REPORT_NUMBER
			,'Active Awards with IRB Data' REPORT_TITLE
			,report_unit PARAMETER_ENTERED_1
			,DATE(SYSDATE()) RUN_TIME
			,@@hostname HOST_NAME
    FROM   	 proposal ip
			JOIN proposal_persons pi ON pi.proposal_number = ip.proposal_number
										  AND  pi.sequence_number = (SELECT MAX(sequence_number)
																		FROM   proposal_persons
																		WHERE  proposal_number = pi.proposal_number)
			JOIN prop_person_units pu ON pu.proposal_person_id = pi.proposal_person_id
										   AND pu.sequence_number = (SELECT MAX(sequence_number)
																		FROM   prop_person_units
																		WHERE  proposal_number = pu.proposal_number)
			JOIN award_funding_proposals afp ON afp.proposal_id = ip.proposal_id
			JOIN award a ON a.award_id = afp.award_id
							  AND a.sequence_number = (SELECT MAX(sequence_number)
															FROM   award
															WHERE  award_number = a.award_number)
			JOIN award_special_review asr ON asr.award_id = a.award_id
			JOIN  person p ON p.person_id = pi.person_id
			JOIN sponsor s ON s.sponsor_code = ip.sponsor_code
			LEFT OUTER JOIN (SELECT  distinct INST_PROPOSAL_ID
							,MIN(DEV_PROPOSAL_ID) dev_proposal_number
						FROM   proposal_admin_details
						GROUP BY INST_PROPOSAL_ID) pad ON  pad.inst_proposal_id = ip.proposal_id
			 JOIN (SELECT distinct ig.grant_number
										,MAX(isp.sponsored_program_number)sponsored_program_number
									FROM   sap_grant ig
										,sap_sponsored_program isp
									WHERE  isp.sponsored_program_type = 'PM'
									AND    ig.grant_status = 'I5616'
									AND    ig.grant_number = isp.grant_number
									GROUP BY ig.grant_number) pm ON pm.grant_number = SUBSTR(a.award_number, 1, 6)
	WHERE   ip.sequence_number = (SELECT MAX(sequence_number)
									FROM   proposal
									WHERE  proposal_number = ip.proposal_number)
	AND 	pi.pi_flag = 'Y'
    AND     pi.PROP_PERSON_ROLE_ID in (3)
	AND     pu.lead_unit_flag = 'Y'
	AND    	FIND_IN_SET(pu.unit_number,fn_get_temp_unit(report_unit))
	AND    	a.award_number NOT LIKE '0%'
	AND    	asr.special_review_code = 1
	AND    	asr.protocol_number IS NOT NULL
  UNION
  SELECT Distinct ip.PROPOSAL_NUMBER
        ,SUBSTR(a.award_number, 1, 6) GRANT_NUMBER
        ,pm.sponsored_program_number PRIMARY_SPONSORED_PROGRAM
        ,SUBSTR(pu.unit_number, 1, 3) LEAD_UNIT
        ,(CAST(REPLACE(psr.protocol_number,' ','') AS CHAR CHARACTER SET utf8) COLLATE utf8_bin) PROTOCOL_NUMBER
        ,p.FULL_NAME
        ,p.user_name JHED_ID
        ,s.SPONSOR_NAME
        ,s.SPONSOR_CODE
        ,'133e' REPORT_NUMBER
        ,'Active Awards with IRB Data' REPORT_TITLE
        ,report_unit PARAMETER_ENTERED_1
        ,DATE(SYSDATE()) RUN_TIME
        ,@@hostname HOST_NAME
  FROM  proposal ip
		JOIN proposal_persons pi ON pi.proposal_number = ip.proposal_number
									  AND  pi.sequence_number = (SELECT MAX(sequence_number)
																		FROM   proposal_persons
																		WHERE  proposal_number = pi.proposal_number)
		JOIN prop_person_units pu ON pu.proposal_person_id = pi.proposal_person_id
									    JOIN award_funding_proposals afp ON afp.proposal_id = ip.proposal_id
		JOIN award a ON a.award_id = afp.award_id
						  AND a.sequence_number = (SELECT MAX(sequence_number)
															FROM   award
															WHERE  award_number = a.award_number)
        JOIN proposal_special_review psr ON psr.proposal_id = ip.proposal_id
											  JOIN person p ON p.person_id = pi.person_id
		JOIN sponsor s ON s.sponsor_code = ip.sponsor_code
        LEFT OUTER JOIN (SELECT distinct INST_PROPOSAL_ID
							,MIN(DEV_PROPOSAL_ID) dev_proposal_number
						FROM   proposal_admin_details
						GROUP BY INST_PROPOSAL_ID) pad ON  pad.inst_proposal_id = ip.proposal_id
		 JOIN (SELECT distinct ig.grant_number
										,MAX(isp.sponsored_program_number)sponsored_program_number
									FROM   sap_grant ig
										,sap_sponsored_program isp
									WHERE  isp.sponsored_program_type = 'PM'
									AND    ig.grant_status = 'I5616'
									AND    ig.grant_number = isp.grant_number
									GROUP BY ig.grant_number) pm ON pm.grant_number = SUBSTR(a.award_number, 1, 6)
  WHERE   ip.sequence_number = (SELECT MAX(sequence_number)
								FROM   proposal
                                where proposal_number =ip.proposal_number)
  AND    pi.pi_flag = 'Y'
  AND    pi.PROP_PERSON_ROLE_ID in (3)
  AND    pu.lead_unit_flag = 'Y'
  AND    FIND_IN_SET(pu.unit_number,fn_get_temp_unit(report_unit))
  AND    psr.special_review_code = 1
  AND    a.award_number NOT LIKE '0%'
  AND    psr.protocol_number IS NOT NULL
  ORDER BY 1;
END
$$
DELIMITER ;
