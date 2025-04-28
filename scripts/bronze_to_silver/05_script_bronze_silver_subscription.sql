-- Criar schemas se não existirem
CREATE SCHEMA IF NOT EXISTS silver_train;
CREATE SCHEMA IF NOT EXISTS silver_test;

-- Dropar tabelas se já existirem
DROP TABLE IF EXISTS silver_train.subscription;
DROP TABLE IF EXISTS silver_test.subscription;

-- Criar tabela de treino
CREATE TABLE silver_train.subscription AS 
SELECT
    CAST(s.account_id AS int) AS account_id,
    LOWER(TRIM(s.product)) AS product,
    CAST(s.start_date AS date) AS start_date,
    CAST(s.end_date AS date) AS end_date,
    CAST(s.mrr AS float8) AS mrr,
    CAST(s.quantity AS float8) AS quantity,
    CAST(s.units AS text) AS units,
    CAST(s.bill_period_months AS int) AS bill_period_months,
    CAST(s.discount AS float8) AS discount
FROM bronze.subscription s
INNER JOIN bronze.train_account_ids t ON s.account_id = t.account_id;

-- Criar tabela de teste
CREATE TABLE silver_test.subscription AS 
SELECT
    CAST(s.account_id AS int) AS account_id,
    LOWER(TRIM(s.product)) AS product,
    CAST(s.start_date AS date) AS start_date,
    CAST(s.end_date AS date) AS end_date,
    CAST(s.mrr AS float8) AS mrr,
    CAST(s.quantity AS float8) AS quantity,
    CAST(s.units AS text) AS units,
    CAST(s.bill_period_months AS int) AS bill_period_months,
    CAST(s.discount AS float8) AS discount
FROM bronze.subscription s
INNER JOIN bronze.test_account_ids t ON s.account_id = t.account_id;
