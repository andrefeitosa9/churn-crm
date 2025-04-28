-- Criar schemas se não existirem
CREATE SCHEMA IF NOT EXISTS silver_train;
CREATE SCHEMA IF NOT EXISTS silver_test;

-- Dropar tabelas se já existirem
DROP TABLE IF EXISTS silver_train.event;
DROP TABLE IF EXISTS silver_test.event;

-- Criar tabela de treino
CREATE TABLE silver_train.event AS 
SELECT
    CAST(e.account_id AS int) AS id,
    CAST(e.event_time AS timestamp) AS event_time,
    CAST(e.event_type_id AS int) AS event_type_id,
    CAST(e.user_id AS int) AS user_id,
    COALESCE(e.event_value, 0) AS event_value
FROM bronze.event e
INNER JOIN bronze.train_account_ids t ON e.account_id = t.account_id;

-- Criar tabela de teste
CREATE TABLE silver_test.event AS 
SELECT
    CAST(e.account_id AS int) AS id,
    CAST(e.event_time AS timestamp) AS event_time,
    CAST(e.event_type_id AS int) AS event_type_id,
    CAST(e.user_id AS int) AS user_id,
    COALESCE(e.event_value, 0) AS event_value
FROM bronze.event e
INNER JOIN bronze.test_account_ids t ON e.account_id = t.account_id;
