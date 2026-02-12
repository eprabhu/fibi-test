DELIMITER $$
CREATE  PROCEDURE `RPT_GET_301_INFO`(IN person_id_in varchar(40))
BEGIN
SELECT NULL AWARD_ID,
  s.ACRONYM SPONSOR,
  s.sponsor_name SPONSOR_NAME,
  pi.PI_FLAG AS PRINCIPAL_INVESTIGATOR_FLAG,
  pe.full_name PI_NAME,
  at.description AWARD_TYPE,
  act.description PURPOSE,
  p.title TITLE,
  pt.description PROPOSAL_TYPE,
  DATE_ADD(p.START_DATE, INTERVAL 1 DAY) START_DATE,
   DATE_ADD(p.END_DATE, INTERVAL 1 DAY) END_DATE,
  ibh.TOTAL_DIRECT_COST DIRECT_AMOUNT,
  ibh.TOTAL_DIRECT_COST + ibh.TOTAL_INDIRECT_COST TOTAL_AMOUNT,
  p.proposal_number PROPOSAL_NUMBER,
  ps.description STATUS,
  null SAP_NUMBER,
CASE
    WHEN ps.description = 'Pending' THEN 20
    WHEN ps.description = 'Not Funded' THEN 40
    WHEN ps.description = 'Withdrawn' THEN 50
    ELSE 99
  END STATUS_ORDER,
  p.proposal_id PROPOSAL_ID
FROM proposal p
  LEFT JOIN ip_budget_header ibh ON ibh.proposal_id=p.proposal_id
  LEFT OUTER JOIN sponsor s ON p.sponsor_code = s.sponsor_code
  LEFT JOIN proposal_persons pi ON p.PROPOSAL_ID = pi.PROPOSAL_ID
  LEFT JOIN proposal_status ps ON p.STATUS_CODE = ps.STATUS_CODE
  LEFT OUTER JOIN activity_type act ON p.activity_type_code = act.activity_type_code
  LEFT OUTER JOIN award_type at ON p.AWARD_TYPE_CODE = at.AWARD_TYPE_CODE
  LEFT OUTER JOIN proposal_type pt ON P.TYPE_CODE = PT.TYPE_CODE,
  person pe
WHERE pi.person_id = person_id_in
  AND pi.PI_FLAG = 'Y'
  AND PI.PROP_PERSON_ROLE_ID = 3
  AND p.status_code NOT IN (2, 7)
  AND p.TYPE_CODE IN (1, 4, 5, 6, 9)
  AND pi.sequence_number IN (
    SELECT MAX(sequence_number)
    FROM proposal_persons
    WHERE PROPOSAL_ID = p.PROPOSAL_ID
  )
  AND pe.person_id IN (
    SELECT person_id
    FROM proposal_persons
    WHERE PROPOSAL_ID = p.PROPOSAL_ID
      AND PI_FLAG = 'Y'
  )
  AND p.sequence_number IN (
    SELECT MAX(sequence_number)
    FROM proposal
    WHERE proposal_number = p.proposal_number
  )
UNION
SELECT NULL AWARD_ID,
  s.ACRONYM SPONSOR,
  s.sponsor_name SPONSOR_NAME,
  pi.PI_FLAG AS PRINCIPAL_INVESTIGATOR_FLAG,
  pe.full_name PI_NAME,
  at.description AWARD_TYPE,
  act.description PURPOSE,
  p.title TITLE,
  pt.description PROPOSAL_TYPE,
  DATE_ADD(p.START_DATE, INTERVAL 1 DAY) START_DATE,
  DATE_ADD(p.END_DATE, INTERVAL 1 DAY) END_DATE,
  NULL DIRECT_AMOUNT,
  NULL TOTAL_AMOUNT,
  p.proposal_number PROPOSAL_NUMBER,
  ps.description STATUS,
  null SAP_NUMBER,
CASE
    WHEN ps.description = 'Pending' THEN 20
    WHEN ps.description = 'Not Funded' THEN 40
    WHEN ps.description = 'Withdrawn' THEN 50
    ELSE 99
  end STATUS_ORDER,
    p.proposal_id PROPOSAL_ID
FROM proposal p
  LEFT OUTER JOIN sponsor s ON p.sponsor_code = s.sponsor_code
  LEFT JOIN proposal_persons pi ON p.PROPOSAL_ID = pi.PROPOSAL_ID
  LEFT JOIN proposal_status ps ON p.STATUS_CODE = ps.STATUS_CODE
  LEFT OUTER JOIN activity_type act ON p.activity_type_code = act.activity_type_code
  LEFT OUTER JOIN award_type at ON p.AWARD_TYPE_CODE = at.AWARD_TYPE_CODE
  LEFT OUTER JOIN proposal_type pt ON P.TYPE_CODE = PT.TYPE_CODE,
  person pe
WHERE pi.person_id = person_id_in
  AND p.status_code NOT IN (2, 7)
  AND p.type_code IN (1, 4, 5, 6, 9)
  AND pi.sequence_number IN (
    SELECT MAX(sequence_number)
    FROM PROPOSAL_PERSONS
    WHERE PROPOSAL_ID = p.PROPOSAL_ID
  )
  AND pe.person_id IN (
    SELECT person_id
    FROM PROPOSAL_PERSONS
    WHERE PROPOSAL_ID = p.PROPOSAL_ID
      AND PI_FLAG = 'Y'
  )
  AND p.sequence_number IN (
    SELECT MAX(sequence_number)
    FROM proposal
    WHERE proposal_number = p.proposal_number
  )
  AND pi.PI_FLAG = 'N'
  -- AND PI.PROP_PERSON_ROLE_ID  IN (1,5,6,7,9)
union
SELECT a.sponsor_award_number AWARD_ID,
  s.ACRONYM SPONSOR,
  s.sponsor_name SPONSOR_NAME,
  ai.PI_FLAG AS PRINCIPAL_INVESTIGATOR_FLAG,
  pe.full_name PI_NAME,
  at.description AWARD_TYPE,
  act.description PURPOSE,
  a.title TITLE,
  null as PROPOSAL_TYPE,
 DATE_ADD( av.start_date, INTERVAL 1 DAY) START_DATE,
  DATE_ADD(av.end_date, INTERVAL 1 DAY) END_DATE,
  av.direct DIRECT_AMOUNT,
  av.total TOTAL_AMOUNT,
  null as PROPOSAL_NUMBER,
  oas.description STATUS,
  substr(a.award_number, 1, 6) SAP_NUMBER,
CASE
    WHEN oas.DESCRIPTION = 'Active' THEN 1
    WHEN oas.DESCRIPTION = 'Hold' THEN 10
    WHEN oas.DESCRIPTION = 'Terminated' THEN 30
    ELSE 99
  END STATUS_ORDER,
 NULL PROPOSAL_ID
FROM award a
  LEFT OUTER JOIN ( SELECT aafd.AWARD_id,
    aafd.AWARD_NUMBER,
      sum(TOTAL_DIRECT_COST) AS direct,
      sum(TOTAL_DIRECT_COST + TOTAL_INDIRECT_COST) AS total,
      min(start_date) AS start_date,
      max(end_date) AS end_date
    FROM award_amt_fna_distribution aafd,
    (SELECT max(SEQUENCE_NUMBER) as max_seq ,AWARD_NUMBER
        FROM award_amt_fna_distribution
		GROUP BY AWARD_NUMBER) amfd1
    WHERE aafd.SEQUENCE_NUMBER =amfd1.max_seq
    and aafd.award_number=amfd1.award_number
    GROUP BY aafd.AWARD_NUMBER ) av on a.AWARD_NUMBER = av.AWARD_NUMBER
  LEFT JOIN sponsor s on a.sponsor_code = s.sponsor_code
  LEFT JOIN award_persons ai on a.AWARD_ID = ai.AWARD_ID
  LEFT JOIN award_funding_proposals afp on a.AWARD_ID = afp.AWARD_ID
  LEFT JOIN activity_type act ON a.activity_type_code = act.activity_type_code
  LEFT JOIN award_type at ON a.award_type_code = at.award_type_code
  LEFT JOIN award_status oas ON a.status_code = oas.status_code,
  person pe
WHERE ai.person_id = person_id_in
  AND ai.PI_FLAG = 'Y'
  AND ai.PERSON_ROLE_ID =3
  AND a.AWARD_NUMBER LIKE '%-00001'
  AND ai.sequence_number IN (
    SELECT MAX(sequence_number)
    FROM award_persons
    WHERE AWARD_NUMBER = a.AWARD_NUMBER
  )
  AND pe.person_id IN (
    SELECT person_id
    FROM award_persons
    WHERE AWARD_ID = a.AWARD_ID
      AND sequence_number = ai.sequence_number
      AND PI_FLAG = 'Y'
  )
  AND a.sequence_number = (
    SELECT MAX(sequence_number)
    FROM award
    WHERE AWARD_NUMBER = a.AWARD_NUMBER
  )
  AND a.status_code != 3
union
SELECT a.sponsor_award_number AWARD_ID,
  s.ACRONYM SPONSOR,
  s.sponsor_name SPONSOR_NAME,
  ai.PI_FLAG AS PRINCIPAL_INVESTIGATOR_FLAG,
  pe.full_name PI_NAME,
  at.description AWARD_TYPE,
  act.description PURPOSE,
  a.title TITLE,
  null AS PROPOSAL_TYPE,
 DATE_ADD( avd.start_date, INTERVAL 1 DAY) START_DATE,
  DATE_ADD(avd.end_date, INTERVAL 1 DAY) END_DATE,
  NULL DIRECT_AMOUNT,
  NULL TOTAL_AMOUNT,
  null as PROPOSAL_NUMBER,
  oas.description STATUS,
  substr(a.award_number, 1, 6) SAP_NUMBER,
CASE
    WHEN oas.DESCRIPTION = 'Active' THEN 1
    WHEN oas.DESCRIPTION = 'Hold' THEN 10
    WHEN oas.DESCRIPTION = 'Terminated' THEN 30
    ELSE 99
  END STATUS_ORDER,
NULL PROPOSAL_ID
FROM award a
  LEFT OUTER JOIN ( SELECT 	aafd.AWARD_id,
							aafd.AWARD_NUMBER,
							min(start_date) AS start_date,
							max(end_date) AS end_date
    FROM award_amt_fna_distribution aafd,
    (SELECT max(SEQUENCE_NUMBER) as max_seq ,AWARD_NUMBER
        FROM award_amt_fna_distribution
		GROUP BY AWARD_NUMBER) amfd1
    WHERE aafd.SEQUENCE_NUMBER =amfd1.max_seq
    and aafd.award_number=amfd1.award_number
    GROUP BY aafd.AWARD_NUMBER
   ) avd ON a.AWARD_NUMBER = avd.AWARD_NUMBER
  LEFT JOIN sponsor s ON a.sponsor_code = s.sponsor_code
  LEFT JOIN award_persons ai ON a.AWARD_ID = ai.AWARD_ID
  LEFT JOIN award_funding_proposals afp ON a.AWARD_ID = afp.AWARD_ID
  LEFT JOIN activity_type act ON a.activity_type_code = act.activity_type_code
  LEFT JOIN award_type at ON a.award_type_code = at.award_type_code
  LEFT JOIN award_status oas ON a.status_code = oas.status_code,
  person pe
WHERE ai.person_id = person_id_in
  AND ai.PI_FLAG = 'N'
  -- AND ai.PERSON_ROLE_ID IN (1,5,6,7,9)
  AND a.AWARD_NUMBER LIKE '%-00001'
  AND ai.sequence_number IN (
    SELECT MAX(sequence_number)
    FROM award_persons
    WHERE AWARD_NUMBER = a.AWARD_NUMBER
  )
  AND pe.person_id IN (
    SELECT person_id
    FROM award_persons
    WHERE AWARD_ID = a.AWARD_ID
      AND sequence_number = ai.sequence_number
      AND PI_FLAG = 'Y'
  )
  AND a.sequence_number = (
    SELECT MAX(sequence_number)
    FROM award
    WHERE AWARD_NUMBER = a.AWARD_NUMBER
  )
  AND a.status_code != 3;
END
$$
DELIMITER ;
