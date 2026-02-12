DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` FUNCTION `FN_DEADLINE_DATE_ISNULL`(as_proposal int) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE ld_deadline datetime;
DECLARE EXIT HANDLER FOR NOT FOUND BEGIN
RETURN 'FALSE';
END;
 SELECT INTERNAL_DEADLINE_DATE
    INTO    ld_deadline
    FROM   eps_proposal
    WHERE PROPOSAL_ID = as_proposal;
    if ld_deadline is null then
      return 'TRUE';
    else
      return 'FALSE';
    end if;
END
$$
DELIMITER ;
