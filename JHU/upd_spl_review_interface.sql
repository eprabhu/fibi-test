DELIMITER $$
CREATE  PROCEDURE `upd_spl_review_interface`(AV_INT INT)
BEGIN
	DECLARE ls_award_number varchar(12);
    DECLARE li_sequence_number  INT(4);
    DECLARE ls_proposal_number VARCHAR(20);
	DECLARE DONE1 INT DEFAULT FALSE;
		  DECLARE spl_rvw_cur CURSOR FOR
				select distinct a.award_number, a.sequence_number, p.proposal_number
			from award a, award_funding_proposals afp, proposal p
			where a.award_id = afp.award_id
            and a.award_number LIKE '%00001'
			and afp.proposal_id = p.proposal_id
			and p.proposal_number in (SELECT distinct proposal_number
										FROM proposal_special_review)
			and a.update_user = 'INTRFACE'
            and afp.update_user = 'INTRFACE'
            order by a.award_number, a.sequence_number;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE1 = TRUE;
	SET SQL_SAFE_UPDATES= 0;
	BEGIN
			OPEN spl_rvw_cur;
			spl_rvw_cur_loop : LOOP
					FETCH spl_rvw_cur INTO ls_award_number,
											li_sequence_number,
											ls_proposal_number;
			IF DONE1 THEN
						LEAVE spl_rvw_cur_loop;
			END IF;
						   CALL jhu_sap_awd_upd_awd_spclrev_tb(ls_award_number
											  ,li_sequence_number
											  ,ls_proposal_number
											  ,current_date() );
               END LOOP;
			CLOSE spl_rvw_cur;
            end;
	END
$$
DELIMITER ;
