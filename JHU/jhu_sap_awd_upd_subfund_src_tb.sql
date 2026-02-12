DELIMITER $$
CREATE  PROCEDURE `jhu_sap_awd_upd_subfund_src_tb`(av_grant_number  varchar(12)
									   ,av_sponsored_program_number  varchar(8)
									   ,av_coeus_update_timestamp date
									   )
begin
declare li_subcontract_row_count int(3) default null;
declare li_subcontract_sequence_number int(3) default 1;
set sql_safe_updates= 0;
select count(*)
into li_subcontract_row_count
from subcontract_funding_source
where subcontract_code = av_sponsored_program_number;
if (li_subcontract_row_count = 0) then
  insert into subcontract_funding_source (subcontract_code
											 ,sequence_number
											 ,award_number
											 ,update_timestamp
											 ,update_user
											 )
  VALUES (av_sponsored_program_number
		 ,li_subcontract_sequence_number
		 ,av_grant_number
		 ,av_coeus_update_timestamp
		 ,'INTRFACE'
		 );
  COMMIT;
ELSE
  SELECT MAX(sequence_number)
  INTO li_subcontract_sequence_number
  FROM subcontract_funding_source
  WHERE subcontract_code = av_sponsored_program_number;
  UPDATE subcontract_funding_source
  SET award_number = av_grant_number
	 ,update_timestamp = DATE(av_coeus_update_timestamp)
	 ,update_user = 'INTRFACE'
  WHERE subcontract_code = av_sponsored_program_number
  AND   sequence_number = li_subcontract_sequence_number;
  COMMIT;
END IF;
END
$$
DELIMITER ;
