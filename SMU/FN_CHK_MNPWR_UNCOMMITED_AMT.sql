DELIMITER $$
CREATE  FUNCTION `FN_CHK_MNPWR_UNCOMMITED_AMT`(
AV_AWARD_ID    DECIMAL(22)
) RETURNS varchar(6) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
        DECLARE LI_COUNT INT;
		select count(z.UNCOMMITTED_AMOUNT) INTO LI_COUNT
		from
		(
			select z1.BUDGET_REFERENCE_NUMBER, z2.LINE_ITEM_COST - z1.TOTAL_AMOUNT as UNCOMMITTED_AMOUNT
			from
			(
				select t.BUDGET_REFERENCE_NUMBER, sum(t.amt) as TOTAL_AMOUNT
				from
				(
					select t1.BUDGET_REFERENCE_NUMBER,t2.PERSON_ID,t2.FULL_NAME, COMMITTED_COST,PLANNED_SALARY,coalesce(COMMITTED_COST,PLANNED_SALARY) amt
					from award_manpower  t1
					inner join award_manpower_resource t2 on t1.AWARD_MANPOWER_ID = t2.AWARD_MANPOWER_ID
					where  t1.AWARD_ID = AV_AWARD_ID
					and t1.MANPOWER_TYPE_CODE = 1
				) t group by t.BUDGET_REFERENCE_NUMBER
			) z1
			INNER JOIN
			(
				select t1.INTERNAL_ORDER_CODE, t1.LINE_ITEM_COST, t1.BUDGET_DETAILS_ID from award_budget_detail t1
				inner join award_budget_header t2 on t1.BUDGET_HEADER_ID = t2.BUDGET_HEADER_ID
				where  t1.BUDGET_CATEGORY_CODE = 'EOM'
				and t2.AWARD_ID = AV_AWARD_ID
				and t2.VERSION_NUMBER  = (select max(s1.VERSION_NUMBER) from award_budget_header s1 where
											s1.AWARD_ID = t2.AWARD_ID)
			) z2 on (z1.BUDGET_REFERENCE_NUMBER = z2.INTERNAL_ORDER_CODE or z1.BUDGET_REFERENCE_NUMBER = z2.BUDGET_DETAILS_ID)
		) z
		where z.UNCOMMITTED_AMOUNT < 0;
		IF LI_COUNT > 0 THEN
                RETURN 'FALSE';
        END IF;
        RETURN 'TRUE';
END
$$
DELIMITER ;
