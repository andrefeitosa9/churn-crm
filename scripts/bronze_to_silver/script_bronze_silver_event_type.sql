CREATE SCHEMA IF NOT EXISTS silver;

DROP TABLE IF EXISTS silver.event_type;

-- Tabela event_type sem alterações de nulos ou erros

CREATE TABLE silver.event_type AS 
SELECT
	CAST(event_type_id AS int) AS event_type_id,
	CAST(event_type_name AS text) AS event_type_name
FROM bronze.event_type;