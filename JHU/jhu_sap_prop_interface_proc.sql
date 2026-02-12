DELIMITER $$
CREATE  PROCEDURE `jhu_sap_prop_interface_proc`()
BEGIN
BEGIN
DROP TABLE IF EXISTS TMP_SAP_PROP_INTERFACE ;
CREATE TABLE TMP_SAP_PROP_INTERFACE AS
with i as (select * from proposal_persons
),
u as (select * from prop_person_units
),
s as (select * from sponsor
)
SELECT distinct p.proposal_number as PROPOSAL_NUMBER,
	 SUBSTRING(REPLACE(p.title, '\n',''),1,50) as TITLE,
	 i.FULL_NAME as PERSON_NAME,
	 p.sponsor_code as SPONSOR_CODE,
	 s.sponsor_name as SPONSOR_NAME,
	 p.status_code as PROPOSAL_STATUS,
	 u.unit_number as LEAD_UNIT,
	 (SELECT date_format(MAX(update_timestamp), '%Y%m%d')
		  FROM (SELECT update_timestamp	FROM proposal WHERE proposal_number = p.proposal_number
				   UNION
				SELECT update_timestamp FROM proposal_persons WHERE proposal_number = p.proposal_number and PROP_PERSON_ROLE_ID in(1,3)
				UNION
				SELECT update_timestamp FROM proposal_keywords WHERE proposal_number = p.proposal_number
				UNION
				SELECT update_timestamp FROM proposal_special_review WHERE proposal_number = p.proposal_number
				UNION
				SELECT update_timestamp FROM prop_person_units WHERE proposal_number = p.proposal_number)
			t) as LAST_UPDATED
FROM proposal p
inner JOIN  i ON  p.proposal_number = i.proposal_number  and i.PROP_PERSON_ROLE_ID in(1,3) AND i.PI_FLAG = 'Y'
inner JOIN  u ON   p.proposal_number = u.proposal_number  AND u.LEAD_UNIT_FLAG = 'Y'
inner JOIN  s ON  p.sponsor_code = s.sponsor_code
and (p.update_timestamp >=   (SELECT proposal_interface_timestamp FROM sap_interfaces)
OR     i.update_timestamp >=  (SELECT proposal_interface_timestamp FROM sap_interfaces)
OR     s.update_timestamp >=  (SELECT proposal_interface_timestamp FROM sap_interfaces)
)
AND    p.sequence_number = (SELECT MAX(sequence_number)
						  FROM proposal
						  WHERE proposal_number = p.proposal_number)
AND    i.sequence_number = (SELECT MAX(sequence_number)
						  FROM proposal_persons
						  WHERE proposal_number = i.proposal_number and PROP_PERSON_ROLE_ID in(1,3))
AND    u.sequence_number = (SELECT MAX(sequence_number)
						  FROM prop_person_units
						  WHERE proposal_number = u.proposal_number);
end ;
begin
DECLARE DONE1 INT DEFAULT FALSE;
DECLARE li_loop_counter  INT(10) DEFAULT 1;
DECLARE ls_mail_host VARCHAR(30) DEFAULT 'smtp.johnshopkins.edu';
DECLARE ls_sender VARCHAR(30) DEFAULT'ret@jhu.edu';
DECLARE ls_recipient VARCHAR(30) DEFAULT 'ret@jhu.edu';
DECLARE ls_update_timestamp VARCHAR(8) DEFAULT NULL;
DECLARE ls_message_text  VARCHAR(1000) DEFAULT CONCAT('The Proposal interface failed - ' ,DATE_FORMAT(UTC_TIMESTAMP(), '%m/%d/%Y'));
DECLARE ls_error VARCHAR(1000);
DECLARE ls_file_text LONGTEXT DEFAULT  '';
DECLARE ls_proposal_number VARCHAR(100);
DECLARE ls_title VARCHAR(1000);
DECLARE ls_person_name VARCHAR(100);
DECLARE ls_sponsor_code VARCHAR(6);
DECLARE ls_sponsor_name VARCHAR(200);
DECLARE ls_proposal_status VARCHAR(200);
DECLARE ls_lead_unit VARCHAR(10);
DECLARE ls_file_sequence  varchar(20) DEFAULT CONCAT(DATE_FORMAT(UTC_TIMESTAMP(),'%Y%m%d%h%i%s'));
DECLARE ls_file_path     VARCHAR(40) DEFAULT '/var/lib/mysql-files/';
DECLARE ls_out_file_name VARCHAR(40) DEFAULT 'sap_proposal_interface_';
DECLARE ls_full_file_path varchar(200) DEFAULT concat(ls_file_path,ls_out_file_name,ls_file_sequence,'.log');
DECLARE ls_sql_statement LONGTEXT DEFAULT  '';
DECLARE ls_mail_text LONGTEXT DEFAULT  '';
DECLARE li_jhu_sap_interface_log_ID INT(12);
DECLARE li_count INT(12);
DECLARE ls_mail_subject  LONGTEXT DEFAULT  '';
DECLARE prop_cur CURSOR FOR
SELECT PROPOSAL_NUMBER,
	 TITLE,
	 PERSON_NAME,
	 SPONSOR_CODE,
	 SPONSOR_NAME,
	 PROPOSAL_STATUS,
	 LEAD_UNIT,
	 LAST_UPDATED FROM TMP_SAP_PROP_INTERFACE;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE1 = TRUE;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
	GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
	 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
	SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
	SELECT @full_error INTO LS_ERROR;
	SET ls_file_text = concat(IFNULL(ls_message_text,''),'\n',IFNULL(LS_ERROR,''),'\n');
	SET ls_mail_text = CONCAT(IFNULL(ls_message_text,''),'.  ',IFNULL(SUBSTR(LS_ERROR,1,999),'') );
    SET ls_mail_subject = 'Proposal Interface Failed';
	SELECT COUNT(*) INTO li_count
	FROM jhu_sap_interface_sub_log
	WHERE jhu_sap_interface_log_ID = li_jhu_sap_interface_log_ID;
	IF li_count > 0 THEN
		DELETE FROM jhu_sap_interface_sub_log WHERE jhu_sap_interface_log_ID = li_jhu_sap_interface_log_ID;COMMIT;
	END IF;
	SELECT COUNT(*) INTO li_count
	FROM jhu_sap_interface_log
	WHERE jhu_sap_interface_log_ID = li_jhu_sap_interface_log_ID;
	IF li_count > 0 THEN
		UPDATE jhu_sap_interface_log
		SET MODULE_ITEM_ID = ls_proposal_number,
		RESULT_TYPE = 'SQLEXCEPTION',
		ERROR_MESSAGE = SUBSTR(LS_ERROR,1,999),
		FILE_TEXT = ls_file_text,
		MAIL_TEXT = ls_mail_text,
		MAIL_SUBJECT = ls_mail_subject,
        MAIL_RECIPIENT = ls_recipient,
		MAIL_SENDER = ls_sender
		WHERE jhu_sap_interface_log_ID = li_jhu_sap_interface_log_ID;COMMIT;
	ELSE
		INSERT INTO jhu_sap_interface_log (MODULE_ITEM_ID,RESULT_TYPE,FILE_NAME,ERROR_MESSAGE,FILE_TEXT,MAIL_TEXT,MAIL_SUBJECT,MAIL_RECIPIENT,MAIL_SENDER)
		VALUES (ls_proposal_number,'SQLEXCEPTION','sap_prop_interface',SUBSTR(LS_ERROR,1,999),ls_file_text,ls_mail_text,ls_mail_subject,ls_recipient,ls_sender);
		COMMIT;
	END IF;
END;
SET SQL_SAFE_UPDATES =0;
BEGIN
SELECT IFNULL(MAX(jhu_sap_interface_log_ID),0)+1 INTO li_jhu_sap_interface_log_ID
FROM jhu_sap_interface_log ;
INSERT INTO jhu_sap_interface_log (jhu_sap_interface_log_ID,MODULE_ITEM_ID,RESULT_TYPE,FILE_NAME,ERROR_MESSAGE,FILE_TEXT)
VALUES (li_jhu_sap_interface_log_ID,ls_proposal_number,'VALIDATION_SUCCESS','sap_prop_interface',null,'Refer_sub_tab');COMMIT;
SET ls_file_text = CONCAT(ls_file_text,'Interface Started - ',DATE_FORMAT(UTC_TIMESTAMP(), '%m/%d/%Y:%H:%i:%S'));
INSERT INTO jhu_sap_interface_sub_log (jhu_sap_interface_log_id,file_text) VALUES (li_jhu_sap_interface_log_ID,ls_file_text);COMMIT;
OPEN prop_cur;
prop_cur_loop : LOOP
	  FETCH prop_cur INTO  ls_proposal_number,
								ls_title,
								ls_person_name,
								ls_sponsor_code,
								ls_sponsor_name,
								ls_proposal_status,
								ls_lead_unit,
								ls_update_timestamp;
		IF DONE1 THEN
			LEAVE prop_cur_loop;
		END IF;
        SET ls_file_text =CONCAT('\n', 'Row ' , IFNULL(ls_proposal_number,'') , ' sent ('
								, IFNULL(ls_title,'') , ','
								, IFNULL( ls_person_name,'') , ','
								, IFNULL(ls_sponsor_code,'') , ','
								, IFNULL(ls_sponsor_name,'') , ','
								, IFNULL(ls_proposal_status,'') , ','
								, IFNULL(ls_lead_unit,'') , ','
								, IFNULL(ls_update_timestamp,'') , ')');
		 INSERT INTO jhu_sap_interface_sub_log (jhu_sap_interface_log_id,file_text) VALUES (li_jhu_sap_interface_log_ID,ls_file_text);COMMIT;
        SET  li_loop_counter = li_loop_counter + 1;
   END LOOP;
CLOSE prop_cur;
end;
SET ls_file_text = CONCAT('\nInterface Ended - ',DATE_FORMAT(UTC_TIMESTAMP(), '%m/%d/%Y:%H:%i:%S'),'\n');
INSERT INTO jhu_sap_interface_sub_log (jhu_sap_interface_log_id,file_text) VALUES (li_jhu_sap_interface_log_ID,ls_file_text);COMMIT;
end;
 END
$$
DELIMITER ;
