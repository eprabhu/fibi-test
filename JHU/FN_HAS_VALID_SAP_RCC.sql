DELIMITER $$
CREATE  FUNCTION `FN_HAS_VALID_SAP_RCC`(a1s_proposal int) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE proposal_count INT;
DECLARE EXIT HANDLER FOR NOT FOUND BEGIN
RETURN 'FALSE';
END;
				SELECT  count(*)
                INTO    proposal_count
                FROM    eps_proposal p
                       ,custom_data pcd
                WHERE   p.PROPOSAL_ID = a1s_proposal
               AND pcd.MODULE_ITEM_CODE = '3'
               AND pcd.CUSTOM_DATA_ELEMENTS_ID = '8'
               AND pcd.MODULE_ITEM_KEY = p.PROPOSAL_ID;
                IF proposal_count > 0 then
                        return 'TRUE';
                else
                        return 'FALSE';
                end if;
END
$$
DELIMITER ;
