DELIMITER $$
CREATE  PROCEDURE `UPD_MYLEARN_USERS_EFFORT`()
BEGIN
	/*INSERT INTO JHU_EFFORT_CERTIFIERS
						SELECT P.PERSON_ID
								,DATE(NOW())
						FROM PERSON P
						WHERE TRIM(p.person_id) IN (SELECT TRIM(TO_CHAR(person_id, '00000000'))
													 FROM   hopkins1.coeus_ers_cert@dashboard)
						and P.PERSON_ID NOT IN (SELECT PERSON_ID
													FROM JHU_EFFORT_CERTIFIERS);
		UPDATE jhu_effort_certifiers
		SET faculty_flag = 'Y'
		WHERE person_id IN (SELECT TRIM(TO_CHAR(person_id, '00000000'))
							FROM hopkins1.coeus_ers_cert@dashboard
							WHERE faculty_flag = 'Y');*/
END
$$
DELIMITER ;
