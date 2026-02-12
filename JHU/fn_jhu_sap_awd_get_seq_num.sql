DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` FUNCTION `fn_jhu_sap_awd_get_seq_num`(av_award_number VARCHAR(12)
      ,av_sponsored_program_number VARCHAR(8)
      ,av_end_date VARCHAR(10)
      ,av_obligated DECIMAL(12,2)
      ,av_anticipated DECIMAL(12,2)
      ) RETURNS int
    DETERMINISTIC
BEGIN
        DECLARE li_return_number INT(4) DEFAULT NULL;
        DECLARE li_award_count INT(4) DEFAULT NULL;
        DECLARE ls_sap_pi_string VARCHAR(200) DEFAULT '';
        DECLARE ls_coeus_pi_string VARCHAR(200) DEFAULT '';
        DECLARE ls_sap_grant_number VARCHAR(200) DEFAULT NULL;
		DECLARE ls_sap_person_id VARCHAR(40) DEFAULT NULL;
		DECLARE ls_award_number VARCHAR(12) DEFAULT NULL ;
		DECLARE li_sequence_number INT(4) DEFAULT NULL ;
	    DECLARE  ls_coeus_person_id	VARCHAR(40) DEFAULT NULL;
		DECLARE DONE1 INT DEFAULT FALSE;
		DECLARE DONE2 INT DEFAULT FALSE;
		DECLARE sap_pi_cur CURSOR FOR
		SELECT gp.person_id AS person_id
          FROM sap_grant_person gp
          WHERE gp.grant_number = ls_sap_grant_number
          AND gp.responsibility_code = 'PRIN'
          UNION
          SELECT spp.person_id AS person_id
          FROM sap_sponsored_program_person spp
          WHERE spp.sponsored_program_number = av_sponsored_program_number
          AND spp.responsibility_code = 'PRIN'
          ORDER BY 1;
		DECLARE coeus_pi_cur CURSOR FOR
          SELECT ai.person_id AS person_id,
                 ai.award_number AS award_number,
                 ai.sequence_number AS sequence_number
          FROM  award_persons ai
          WHERE ai.award_number = av_award_number
          AND ai.sequence_number = li_return_number
          AND (ai.pi_flag = 'Y'
          OR ai.is_multi_pi = 'Y')
        --   and ai.person_id != '99999880'
          ORDER BY ai.person_id;
		SELECT COUNT(*)
        INTO li_award_count
        FROM award
        WHERE award_number = av_award_number;
        IF li_award_count = 0 THEN
          SET li_return_number = 1;
        ELSE
          SELECT MAX(sequence_number)
          INTO li_return_number
          FROM award
          WHERE award_number = av_award_number;
          IF av_sponsored_program_number IS NOT NULL THEN
            SET ls_sap_grant_number = 'XXXXXX';
          ELSE
            SET ls_sap_grant_number = SUBSTR(av_award_number, 1, 6);
          END IF;
		  BEGIN
		  	  DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE1 = TRUE;
			  OPEN sap_pi_cur;
				sap_pi_cur_loop : LOOP
						FETCH sap_pi_cur INTO ls_sap_person_id;
						IF DONE1 THEN
							LEAVE sap_pi_cur_loop;
						END IF;
						SET ls_sap_pi_string = CONCAT(ls_sap_pi_string,ls_sap_person_id);
				END LOOP;
			  CLOSE sap_pi_cur;
		 END;
		  BEGIN
		  	  DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE2 = TRUE;
			  OPEN coeus_pi_cur;
				coeus_pi_cur_loop : LOOP
						FETCH coeus_pi_cur INTO ls_coeus_person_id,ls_award_number,li_sequence_number;
						IF DONE2 THEN
							LEAVE coeus_pi_cur_loop;
						END IF;
						SET ls_coeus_pi_string = CONCAT(ls_coeus_pi_string,ls_coeus_person_id);
				END LOOP;
			  CLOSE coeus_pi_cur;
		 END;
		  IF IFNULL(ls_sap_pi_string,'') <> IFNULL(ls_coeus_pi_string,'') THEN
			SET  li_return_number = li_return_number + 1;
		  END IF;
        END IF;
        RETURN li_return_number;
    END
$$
DELIMITER ;
