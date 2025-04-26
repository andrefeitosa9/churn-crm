CREATE SCHEMA IF NOT EXISTS silver;

DROP TABLE IF EXISTS silver.account;

-- Tabela account
-- Coluna country tem valores nulos.

CREATE TABLE silver.account AS 
SELECT
	CAST (id AS int) AS id,
	lower(trim(channel) AS channel,
	COALESCE(country, 'Not Informed') AS country,
	CAST (date_of_birth AS date) AS date_of_birth
FROM bronze.account;