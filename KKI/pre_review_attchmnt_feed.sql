DELIMITER $$
CREATE  PROCEDURE `pre_review_attchmnt_feed`(av_type int)
BEGIN
declare ls_ATTACHMENT_ID int(11);
declare ls_ATTACHMENT longblob;
declare unique_id varchar(36);
DECLARE DONE1 INT DEFAULT FALSE;
DECLARE EXP_CURSOR CURSOR FOR
SELECT PRE_REVIEW_ATTACHMENT_ID,ATTACHMENT FROM kki_prod.EPS_PROP_PRE_REVIEW_ATTACHMENT;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE1 = TRUE;
OPEN EXP_CURSOR;
EXP_CURSOR_LOOP : LOOP
        FETCH EXP_CURSOR INTO  ls_ATTACHMENT_ID,ls_ATTACHMENT ;
        select uuid() into unique_id from dual;
		IF DONE1 THEN
			LEAVE EXP_CURSOR_LOOP;
		END IF;
		update fibikki_prod.pre_review_attachment set FILE_DATA_ID = unique_id
        where PRE_REVIEW_ATTACHMENT_ID = ls_ATTACHMENT_ID;
        insert into fibikki_prod.pre_review_attachment_file values(unique_id,ls_ATTACHMENT);
END LOOP;
CLOSE EXP_CURSOR;
END
$$
DELIMITER ;
