CREATE SCHEMA IF NOT EXISTS silver;

DROP TABLE IF EXISTS silver.event;

-- Tabela event
-- Valor de evento tem nulos. Colocar 0

CREATE TABLE silver.event AS 
SELECT
	CAST(account_id AS int) AS id,
	CAST(event_time AS timestamp) AS event_time,
	CAST(event_type_id AS int) AS event_type_id,
	CAST(user_id AS int) AS user_id,
	COALESCE(event_value, 0) AS event_value
FROM bronze.event;