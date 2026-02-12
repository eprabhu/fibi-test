DELIMITER $$
CREATE  FUNCTION `FN_IS_YNQ_Z1_Y_FOR_SOM`(a1s_proposal INT) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
        DECLARE proposal_count  INT;
              select count(qa.ANSWER)
                INTO proposal_count
                from quest_answer qa
                    ,quest_answer_header qah
					,eps_proposal_persons p
                    ,eps_prop_person_units pu
                where
                    qa.QUESTIONNAIRE_ANS_HEADER_ID = qah.QUESTIONNAIRE_ANS_HEADER_ID
                    and qa.QUESTION_ID ='1078' -- will be 1078 in PR
                    and qah.MODULE_ITEM_KEY=a1s_proposal
                    AND qah.MODULE_SUB_ITEM_CODE = 6
                    and pu.unit_number like '170%'
					and p.proposal_person_id=pu.proposal_person_id
                    and p.proposal_id=qah.MODULE_ITEM_KEY
                    and pu.LEAD_UNIT_FLAG='Y'
                    and upper(trim(qa.answer))='YES';
					IF proposal_count > 0 then
							return 'TRUE';
					else
							return 'FALSE';
					end if;
        end
$$
DELIMITER ;
