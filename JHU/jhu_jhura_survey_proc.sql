DELIMITER $$
CREATE  PROCEDURE `jhu_jhura_survey_proc`()
BEGIN
DECLARE filename VARCHAR(200) DEFAULT '/var/lib/mysql-files/jhura_survey_';
DECLARE survey_proposal VARCHAR(20);
DECLARE survey_person_id VARCHAR(40);
DECLARE survey_full_name VARCHAR(90);
DECLARE survey_email_address VARCHAR(60);
DECLARE survey_title VARCHAR(1000);
DECLARE survey_submission_date VARCHAR(20);
DECLARE survey_sponsor_name VARCHAR(1000);
DECLARE done INT DEFAULT FALSE;
DECLARE proposal_cursor CURSOR FOR
  SELECT ip.proposal_number
		,p.person_id
        ,p.full_name
        ,COALESCE(p.email_address, 'ret@jhu.edu') email_address
        ,TRIM(REPLACE(REPLACE(REPLACE(REGEXP_REPLACE(ip.title, '^0-9A-Za-z"!()@#$%^*.\n          ,;:/?><+=|/~`', ''), '\n', ' '), '''', ''), '"', '')) AS title
        ,DATE_FORMAT(ip.submission_date, '%m/%d/%Y') submission_date
        ,TRIM(REPLACE(REPLACE(REPLACE(REGEXP_REPLACE(s.sponsor_name, '^0-9A-Za-z"!()@#$%^*.\n          ,;:/?><+=|/~`', ''), '\n', ' '), '''', ''), '"', '')) AS sponsor_name
  FROM   proposal ip
        ,proposal_persons ipi
        ,person p
        ,sponsor s
        ,report_school rs
  WHERE  ip.submission_date >= (SELECT MAX(last_survey_date)
								FROM   jhu_jhura_last_surveyed)
  AND    p.person_id NOT IN (SELECT person_id
                             FROM   jhu_jhura_last_surveyed)
  AND    ip.proposal_sequence_status = 'ACTIVE'
  AND    ipi.pi_flag = 'Y'
  AND    rs.ora_office = 'JHURA'
  AND    ip.proposal_id = ipi.proposal_id
  AND    ipi.person_id = p.person_id
  AND    SUBSTR(ip.home_unit_number, 1, 3) = rs.business_area
  AND    ip.sponsor_code = s.sponsor_code
  UNION
  SELECT ip.proposal_number
		,p.person_id
        ,p.full_name
        ,COALESCE(p.email_address, 'ret@jhu.edu') email_address
        ,TRIM(REPLACE(REPLACE(REPLACE(REGEXP_REPLACE(ip.title, '^0-9A-Za-z"!()@#$%^*.\n          ,;:/?><+=|/~`', ''), '\n', ' '), '''', ''), '"', '')) AS title
        ,DATE_FORMAT(ip.submission_date, '%m/%d/%Y') submission_date
        ,TRIM(REPLACE(REPLACE(REPLACE(REGEXP_REPLACE(s.sponsor_name, '^0-9A-Za-z"!()@#$%^*.\n          ,;:/?><+=|/~`', ''), '\n', ' '), '''', ''), '"', '')) AS sponsor_name
  FROM   eps_proposal pd
        ,proposal_admin_details pad
        ,proposal ip
		,person p
        ,sponsor s
		,report_school rs
  WHERE  pd.submission_date >= (SELECT MAX(last_survey_date)
								FROM   jhu_jhura_last_surveyed)
  AND    p.person_id NOT IN (SELECT person_id
                             FROM   jhu_jhura_last_surveyed)
  AND    rs.ora_office = 'JHURA'
  AND    pd.proposal_id = pad.dev_proposal_id
  AND    pad.inst_proposal_id = ip.proposal_id
  AND    pd.create_user = p.user_name
  AND    SUBSTR(pd.home_unit_number, 1, 3) = rs.business_area
  AND    ip.sponsor_code = s.sponsor_code
  ORDER BY 1 DESC
  ;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
DELETE FROM jhu_jhura_last_surveyed
WHERE last_survey_date < date_add(NOW(), INTERVAL -3 month);
OPEN proposal_cursor;
read_proposals: LOOP
  FETCH proposal_cursor INTO survey_proposal, survey_person_id, survey_full_name, survey_email_address, survey_title, survey_submission_date, survey_sponsor_name;
  IF done THEN
    LEAVE read_proposals;
  END IF;
select survey_proposal, survey_person_id, survey_full_name, survey_email_address, survey_title, survey_submission_date, survey_sponsor_name;
  SET filename = CONCAT('''/var/lib/mysql-files/jhura_survey_', survey_person_id, survey_proposal,'.txt''');
SET @survey = CONCAT('SELECT ''', survey_person_id, '|'
                             , survey_proposal, '|'
                             , survey_full_name, '|'
                             , survey_email_address, '|'
                             , survey_title, '|'
                             , survey_submission_date, '|'
                             , survey_sponsor_name, '|'
                             , ''' INTO OUTFILE ', filename);
  PREPARE stmt FROM @survey;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;
  SET done = FALSE;
  INSERT INTO jhu_jhura_last_surveyed
  VALUES(survey_person_id, NOW());
  END LOOP read_proposals;
  CLOSE proposal_cursor;
END
$$
DELIMITER ;
