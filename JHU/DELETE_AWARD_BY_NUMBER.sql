DELIMITER $$
CREATE DEFINER=`jhufibi`@`%` PROCEDURE `DELETE_AWARD_BY_NUMBER`(IN input_award_number VARCHAR(6))
BEGIN
    DECLARE finished INT DEFAULT 0;
    DECLARE current_award_id INT;
    -- Ensure necessary constraints are disabled only temporarily
    DECLARE award_cursor CURSOR FOR
    SELECT DISTINCT award_id
    FROM award
    WHERE SUBSTR(AWARD_NUMBER, 1, 6) = input_award_number;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
    SET SQL_SAFE_UPDATES = 0;
    -- Delete from associated tables first based on AWARD_NUMBER
    DELETE FROM award_amount_info
        WHERE SUBSTR(AWARD_NUMBER, 1, 6) = input_award_number;
    DELETE FROM award_amount_transaction
        WHERE SUBSTR(AWARD_NUMBER, 1, 6) = input_award_number;
    -- Process each related award_id
    OPEN award_cursor;
    award_loop: LOOP
        FETCH award_cursor INTO current_award_id;
        IF finished = 1 THEN
            LEAVE award_loop;
        END IF;
        -- Safely removing or delegating logic in related parts.
        CALL DELETE_AWARD_BY_ID(current_award_id);
    END LOOP;
    CLOSE award_cursor;
    SET SQL_SAFE_UPDATES = 1; -- Always revert to ensure good practice.
END
$$
DELIMITER ;
