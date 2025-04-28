CREATE SCHEMA IF NOT EXISTS silver_train;
CREATE SCHEMA IF NOT EXISTS silver_test;

DROP TABLE IF EXISTS silver_train.event_type;
DROP TABLE IF EXISTS silver_test.event_type;

-- Tabela event_type sem alterações de nulos ou erros

CREATE TABLE silver_train.event_type AS 
SELECT
	CAST(event_type_id AS int) AS event_type_id,
	CAST(event_type_name AS text) AS event_type_name
FROM bronze.event_type;

-- Tabela event_type sem alterações de nulos ou erros

CREATE TABLE silver_test.event_type AS 
SELECT
	CAST(event_type_id AS int) AS event_type_id,
	CAST(event_type_name AS text) AS event_type_name
FROM bronze.event_type;