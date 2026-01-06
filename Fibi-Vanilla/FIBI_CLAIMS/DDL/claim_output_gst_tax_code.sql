

--
--  `claim_output_gst_tax_code`
--

DROP TABLE IF EXISTS `claim_output_gst_tax_code`;

CREATE TABLE `claim_output_gst_tax_code` (
  `OUTPUT_GST_CATEGORY` varchar(20) NOT NULL,
  `TAX_CODE` varchar(2) NOT NULL,
  `TAX_DESCRIPTION` varchar(50) DEFAULT NULL,
  `IS_ACTIVE` varchar(1) DEFAULT 'Y',
  `UPDATE_TIMESTAMP` datetime NOT NULL,
  `UPDATE_USER` varchar(60) NOT NULL,
  PRIMARY KEY (`OUTPUT_GST_CATEGORY`)
);

