DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` FUNCTION `FN_ANY_INV_NON_MIT`(as_proposal INT) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE ls_nonmit_flag INT;
DECLARE EXIT HANDLER FOR NOT FOUND BEGIN
RETURN 'FALSE';
END;
  SELECT count(*)
   INTO      ls_nonmit_flag
   FROM   eps_proposal_persons
   WHERE PROPOSAL_ID = as_proposal
   and ROLODEX_ID is not null;
   IF (ls_nonmit_flag > 0) then
     return 'TRUE';
   else
     return 'FALSE';
   end if;
END
$$
DELIMITER ;
