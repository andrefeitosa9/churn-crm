-- Remover tabelas antigas, se existirem
DROP TABLE IF EXISTS bronze.train_account_ids;
DROP TABLE IF EXISTS bronze.test_account_ids;

-- Criar tabela de treino com clientes ativos em 2022-12-01
CREATE TABLE bronze.train_account_ids AS
WITH 
parametros AS (
    SELECT '2023-01-01'::date AS data_base
),
train_accounts AS (
    SELECT DISTINCT s.account_id
    FROM bronze.subscription s
    JOIN parametros p ON TRUE
    WHERE s.start_date <= p.data_base
      AND (s.end_date > p.data_base OR s.end_date IS NULL)
)
SELECT * FROM train_accounts;

-- Criar tabela de teste com TODOS os outros clientes que NÃO estão em treino
CREATE TABLE bronze.test_account_ids AS
WITH 
all_accounts AS (
    SELECT DISTINCT account_id
    FROM bronze.subscription
),
test_accounts AS (
    SELECT a.account_id
    FROM all_accounts a
    LEFT JOIN bronze.train_account_ids t ON a.account_id = t.account_id
    WHERE t.account_id IS NULL
)
SELECT * FROM test_accounts;
