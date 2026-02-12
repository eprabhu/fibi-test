DELIMITER $$
CREATE  FUNCTION `FN_INCOMPLETE_NARR_RULE`(as_proposal INT) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE li_count INT;
DECLARE EXIT HANDLER FOR NOT FOUND BEGIN
RETURN 'FALSE';
END;
select count(*)
        into   li_count
        from   eps_proposal_attachments
        where  PROPOSAL_ID = as_proposal
        and   NARRATIVE_STATUS_CODE = 'I';
          IF li_count > 0 then
            return 'FALSE';
        else
            return 'TRUE';
        end if;
END
$$
DELIMITER ;
