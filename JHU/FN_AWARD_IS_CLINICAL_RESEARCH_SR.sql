DELIMITER $$
CREATE  FUNCTION `FN_AWARD_IS_CLINICAL_RESEARCH_SR`(
  AV_SR_HEADER_ID   int(10)
) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE LI_COUNT int;
DECLARE RETURN_STRING VARCHAR(5) DEFAULT 'FALSE';
 SELECT COUNT(*)
 INTO   li_count
 FROM   sr_header sr
	   ,(
			SELECT *
			FROM assoc_sr a1
			WHERE a1.ASSOC_SR_ID = (
				SELECT MAX(a2.ASSOC_SR_ID)
				FROM assoc_sr a2
				WHERE a2.SR_HEADER_ID = a1.SR_HEADER_ID
				)
		) asr
       ,award a
       ,award_funding_proposals afp
       ,proposal p
 WHERE  sr.sr_header_id = AV_SR_HEADER_ID
 AND    p.activity_type_code = 8
 AND    sr.CATEGORY_CODE = 1
 AND 	asr.MODULE_CODE = 1
 AND 	asr.SR_HEADER_ID = sr.sr_header_id
 AND 	asr.MODULE_ITEM_ID = a.award_id
 AND    a.award_id = afp.award_id
 AND    afp.proposal_id = p.proposal_id;
IF LI_COUNT > 0 THEN
   SET RETURN_STRING = 'TRUE';
END IF;
RETURN RETURN_STRING;
END
$$
DELIMITER ;
