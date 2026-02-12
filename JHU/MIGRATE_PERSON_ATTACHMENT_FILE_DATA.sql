DELIMITER $$
CREATE  PROCEDURE `MIGRATE_PERSON_ATTACHMENT_FILE_DATA`()
BEGIN
DECLARE DONE TINYINT DEFAULT 0;
DECLARE C1 CURSOR FOR
	SELECT DISTINCT PROPOSAL_NUMBER FROM stage_eps_proposal_per_attach_reload WHERE PROPOSAL_NUMBER <= '00128253' ORDER BY 1 DESC ;
OPEN C1;
	LOOP1: LOOP BEGIN
	DECLARE LS_PROPOSAL_NUMBER VARCHAR(10);
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET DONE = 1;
	FETCH C1 INTO LS_PROPOSAL_NUMBER;
	IF DONE THEN
		LEAVE LOOP1;
	END IF;
		 -- SELECT LD_END_DATE,LD_START_DATE, datedifference((SELECT DATE_ADD(LD_END_DATE, INTERVAL 1 DAY)), LD_START_DATE) from proposal WHERE PROPOSAL_ID = LI_PROPOSAL_ID;
		update file_data f,
		eps_proposal_person_attachmnt e,
		stage_eps_proposal_person_attachmnt s,
		stage_eps_prop_pers_blob_dummy b ,
		stage_eps_proposal pp
		set f.data=b.bio_pdf
		where e.attachment_id=s.fibi_identifier
		and s.proposal_number=b.proposal_number
		and s.person_id=b.person_id
		and s.bio_number = b.bio_number
		and f.id=e.file_data_id
		and pp.PROPOSAL_NUMBER=s.PROPOSAL_NUMBER
		and length(f.data)=65535
		AND PP.PROPOSAL_NUMBER = LS_PROPOSAL_NUMBER;
END;
END LOOP;
CLOSE C1;
END
$$
DELIMITER ;
