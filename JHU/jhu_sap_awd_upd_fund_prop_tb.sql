DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` PROCEDURE `jhu_sap_awd_upd_fund_prop_tb`(av_award_id INT
  ,av_award_number  VARCHAR(12)
  ,av_sequence_number  INT(4)
  ,av_proposal_number  varchar(20)
  ,av_update_timestamp  DATE
  )
BEGIN
DECLARE li_proposal_count INT(3) DEFAULT NULL;
DECLARE li_proposal_id	int(11);
DECLARE LS_ERROR_MSG VARCHAR(1000);
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
	BEGIN
			GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
			 @errno = MYSQL_ERRNO, @msg = MESSAGE_TEXT;
			SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @msg);
			SELECT @full_error INTO LS_ERROR_MSG;
            insert into integration_error_log (SECTION, ERROR_MESSAGE, AWARD_NUMBER, sequence_number)
				values('AWARD FUNDING PROPOSALS', concat(LS_ERROR_MSG,' - ',av_proposal_number), av_award_number, av_sequence_number);
		END;
SET SQL_SAFE_UPDATES= 0;
	SELECT proposal_id INTO li_proposal_id
	FROM proposal
	WHERE proposal_number = av_proposal_number
	AND sequence_number in (SELECT MAX(sequence_number) FROM proposal where proposal_number = av_proposal_number );
	SELECT COUNT(*)
	INTO   li_proposal_count
	FROM   award_funding_proposals
	WHERE  award_id = av_award_id
	AND    update_user = 'INTRFACE';
	DELETE FROM award_funding_proposals
	WHERE award_id = av_award_id
	AND   proposal_id in (select proposal_id from proposal where proposal_number = av_proposal_number)
	AND   update_user = 'INTRFACE';
	INSERT INTO award_funding_proposals (award_id
										  ,proposal_id
										  ,update_timestamp
										  ,update_user
										  )
	VALUES (av_award_id
		,li_proposal_id
		,av_update_timestamp
		,'INTRFACE'); COMMIT;
	IF li_proposal_count = 0 THEN
				SELECT proposal_id INTO li_proposal_id
				FROM proposal p
				WHERE p.proposal_number = (SELECT p.proposal_number
													 FROM   award t1
													 INNER JOIN award_funding_proposals afp ON t1.award_id = afp.award_id
													 INNER JOIN proposal p ON p.proposal_id = afp.proposal_id
													 WHERE  t1.award_number = av_award_number
													 AND    t1.sequence_number = (av_sequence_number - 1)
													 AND afp.update_user <> 'INTRFACE')
				AND p.sequence_number in (SELECT MAX(s.sequence_number)
										FROM proposal s
										where s.proposal_number = p.proposal_number );
				INSERT
                INTO award_funding_proposals (award_id
														,proposal_id
														,update_timestamp
														,update_user
														)
				SELECT av_award_id
					  ,li_proposal_id
					  ,av_update_timestamp
					  ,afp.update_user
				FROM  award_funding_proposals afp
				WHERE afp.proposal_id = li_proposal_id
				AND afp.award_id = av_award_id
				AND afp.update_user <> 'INTRFACE'; COMMIT;
	END IF;
COMMIT;
END
$$
DELIMITER ;
