INSERT INTO claim_number_system_generator (`next_val`,`FISCAL_YEAR`) VALUES (1,(SELECT YEAR(CURDATE())));
