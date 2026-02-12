DELIMITER $$
CREATE  FUNCTION `fn_pd_has_rdt_user`(
  av_proposal_id   int(10)
) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE li_count INT;
DECLARE return_string VARCHAR(5) DEFAULT 'FALSE';
 SELECT COUNT(*)
 INTO li_count
 FROM eps_proposal pd
     ,eps_proposal_person_roles pdr
     ,person_roles pr
 WHERE pr.role_id = 1335
 AND   pd.proposal_id = av_proposal_id
 AND   pd.proposal_id = pdr.proposal_id
 AND   pdr.person_id = pr.person_id;
IF li_count > 0 THEN
   SET return_string = 'TRUE';
END IF;
RETURN return_string;
END
$$
DELIMITER ;
