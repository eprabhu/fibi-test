DELIMITER $$
CREATE  FUNCTION `fn_jhu_narrative_title_rule`(as_proposal INT) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
declare li_pos double;
declare ls_FileName varchar(4000);
DECLARE not_found INT DEFAULT 0;
DECLARE cur_narr_title CURSOR for
    select MODULE_TITLE
    from eps_proposal_attachments
    where PROPOSAL_ID = as_proposal
    and ATTACHMNT_TYPE_CODE in (8);
DECLARE CONTINUE HANDLER FOR NOT FOUND SET not_found = 1;
    open cur_narr_title;
    loop_label:
    loop
        fetch cur_narr_title into ls_FileName;
        if not_found = 1 then LEAVE loop_label; END IF;
        if ls_fileName is not null then
            set li_Pos = instr(ls_FileName, ' ') +
                      instr(ls_FileName, '`') +
                      instr(ls_FileName, '@') +
                      instr(ls_FileName, '#') +
                      instr(ls_FileName, '!') +
                      instr(ls_FileName, '$') +
                      instr(ls_FileName, '%') +
                      instr(ls_FileName, '^') +
                      instr(ls_FileName, '&') +
                      instr(ls_FileName, '*') +
                      instr(ls_FileName, '(') +
                      instr(ls_FileName, ')') +
                      instr(ls_FileName, '{') +
                      instr(ls_FileName, '}') +
                      instr(ls_FileName, '[') +
                      instr(ls_FileName, ']') +
                      instr(ls_FileName, '|') +
                      instr(ls_FileName, '') +
                      instr(ls_FileName, '/') +
                      instr(ls_FileName, '?') +
                      instr(ls_FileName, '<') +
                      instr(ls_FileName, '>') +
                      instr(ls_FileName, ',') +
                      instr(ls_FileName, ';') +
                      instr(ls_FileName, ':') +
                      instr(ls_FileName, '"') +
                      instr(ls_FileName, '''') +
                      instr(ls_FileName, '`') +
                      instr(ls_FileName, '+') ;
            if li_Pos > 0 then
                return 'FALSE';
            end if;
        end if;
    end loop;
    close cur_narr_title;
return 'TRUE';
END
$$
DELIMITER ;
