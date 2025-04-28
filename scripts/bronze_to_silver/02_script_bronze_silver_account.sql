CREATE SCHEMA IF NOT EXISTS silver_train;
CREATE SCHEMA IF NOT EXISTS silver_test;

DROP TABLE IF EXISTS silver_train.account;
DROP TABLE IF EXISTS silver_test.account;

-- Criar tabela de treino
CREATE TABLE silver_train.account AS 
SELECT
    CAST(a.id AS int) AS id,
    LOWER(TRIM(a.channel)) AS channel,
    COALESCE(a.country, 'Not Informed') AS country,
    CAST(a.date_of_birth AS date) AS date_of_birth
FROM bronze.account a
INNER JOIN bronze.train_account_ids t ON a.id = t.account_id;

-- Criar tabela de teste
CREATE TABLE silver_test.account AS 
SELECT
    CAST(a.id AS int) AS id,
    LOWER(TRIM(a.channel)) AS channel,
    COALESCE(a.country, 'Not Informed') AS country,
    CAST(a.date_of_birth AS date) AS date_of_birth
FROM bronze.account a
INNER JOIN bronze.test_account_ids t ON a.id = t.account_id;
