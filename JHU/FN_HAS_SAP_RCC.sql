DELIMITER $$
CREATE  FUNCTION `FN_HAS_SAP_RCC`(a1s_proposal int) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE proposal_count INT;
DECLARE EXIT HANDLER FOR NOT FOUND BEGIN
RETURN 'FALSE';
END;
                SELECT  count(*)
                INTO    proposal_count
                FROM    custom_data
                WHERE   MODULE_ITEM_CODE = '3'
               and      MODULE_ITEM_KEY = a1s_proposal
                AND     CUSTOM_DATA_ELEMENTS_ID = '8';
                IF proposal_count > 0 then
                        return 'TRUE';
                else
                        return 'FALSE';
                end if;
END
$$
DELIMITER ;
