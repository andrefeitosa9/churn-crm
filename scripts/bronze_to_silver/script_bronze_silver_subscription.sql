CREATE SCHEMA IF NOT EXISTS silver;

DROP TABLE IF EXISTS silver.subscription;

-- Tabela subscription

CREATE TABLE silver.subscription AS 
SELECT
	CAST (account_id AS int) AS account_id,
	lower(trim(product) AS product,
	CAST (start_date AS date) AS start_date,
	CAST (end_date AS date) AS end_date,
	CAST (mrr AS float8) AS mrr,
	CAST (quantity AS float8) AS quantity,
	CAST (units AS text) AS units
	CAST (bill_period_months AS int) AS bill_period_months,
	CAST (discount AS float8) AS discount,
FROM bronze.subscription;