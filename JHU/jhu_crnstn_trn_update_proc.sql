DELIMITER $$
CREATE  PROCEDURE `jhu_crnstn_trn_update_proc`()
BEGIN
DECLARE training_table_id VARCHAR(30);
DECLARE training_person_id VARCHAR(8);
DECLARE training_cornerstone_id VARCHAR(20);
DECLARE training_fibi_id VARCHAR(40);
DECLARE training_completion_date DATE;
DECLARE training_date_acknowledged DATE;
DECLARE done INT DEFAULT FALSE;
DECLARE person_training_count INT;
DECLARE training_cursor CURSOR FOR
  SELECT c.table_id
        ,p.person_id
        ,UPPER(c.cornerstone_common_id) AS cornerstone_id
        ,m.coeus_training_code
        ,STR_TO_DATE(SUBSTR(c.completion_date, 1, 10), '%Y-%m-%d') AS completion_date
  FROM   jhu_cornerstone_training_data c
        ,mylearning_training_code m
        ,person p
  WHERE  c.processed IS NULL
  AND    UPPER(c.cornerstone_common_id) = UPPER(m.cornerstone_id)
  AND    LOWER(c.user_name) = LOWER(p.user_name)
  ;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
UPDATE jhu_cornerstone_training_data
SET    processed = 'I'
WHERE  LENGTH(cornerstone_common_id) != 36;
INSERT INTO jhu_cornerstone_user
SELECT DISTINCT(LOWER(TRIM(p.user_name))), NOW(), 'ORIS'
FROM   person p
	  ,jhu_cornerstone_training_data c
WHERE  processed IS NULL
AND    LOWER(TRIM(p.user_name)) = LOWER(TRIM(c.user_name));
UPDATE jhu_cornerstone_training_data
SET processed = 'I'
WHERE LOWER(TRIM(user_name)) NOT IN (SELECT DISTINCT(LOWER(TRIM(user_name)))
							   FROM jhu_cornerstone_user)
AND processed IS NULL;
UPDATE jhu_cornerstone_training_data
SET    processed = NULL
WHERE  processed = 'I'
AND    LOWER(TRIM(user_name)) IN (SELECT DISTINCT(LOWER(TRIM(user_name)))
						          FROM jhu_cornerstone_user) ;
OPEN training_cursor;
read_trainings: LOOP
  FETCH training_cursor INTO training_table_id, training_person_id, training_cornerstone_id, training_fibi_id, training_completion_date; -- , training_date_acknowledged;
  IF done THEN
    LEAVE read_trainings;
  END IF;
  SELECT COUNT(*)
  INTO   person_training_count
  FROM   person_training
  WHERE  person_id = training_person_id
  AND    training_code = training_fibi_id;
  IF person_training_count = 0 THEN
	INSERT INTO person_training (person_id, training_code, date_acknowledged, update_timestamp, update_user, is_non_employee)
	VALUES (training_person_id, training_fibi_id, training_completion_date, NOW(), 'ORIS', 'N');
	INSERT INTO person_training_ext (person_training_id,  update_timestamp, update_user, source_type_code, status)
	SELECT person_training_id, NOW(), 'ORIS', 1, 'A'
	FROM   person_training
	WHERE  person_id = training_person_id
	AND    person_training_id NOT IN (select person_training_id FROM person_training_ext);
  ELSE
    UPDATE person_training
    SET    date_acknowledged = training_completion_date
          ,update_timestamp = NOW()
          ,update_user = 'ORIS'
    WHERE  person_id = training_person_id
    AND    date_acknowledged < training_completion_date
    AND    training_code = training_fibi_id;
  END IF;
  UPDATE jhu_cornerstone_training_data
  SET processed = 'Y'
  WHERE table_id = training_table_id;
  END LOOP read_trainings;
  CLOSE training_cursor;
  DELETE FROM jhu_cornerstone_user;
END
$$
DELIMITER ;
