DROP TABLE IF EXISTS bronze.train_account_ids;
DROP TABLE IF EXISTS bronze.test_account_ids;

CREATE TABLE bronze.train_account_ids AS
SELECT sa.account_id
FROM (
    WITH 
    parametros AS (
        SELECT '2023-01-01'::date AS data_base
    ),
    start_accounts AS (
        SELECT DISTINCT d.start_date, s.account_id
        FROM bronze.subscription s
        INNER JOIN (
            SELECT (SELECT data_base FROM parametros) AS start_date
        ) d ON
            s.start_date <= d.start_date
            AND (s.end_date > d.start_date OR s.end_date IS NULL)
    )
    SELECT * FROM start_accounts
) sa
WHERE sa.start_date = (SELECT '2023-01-01'::date);

CREATE TABLE bronze.test_account_ids AS 
SELECT sa.account_id
FROM (
    WITH 
    parametros AS (
        SELECT 
            '2023-01-01'::date AS data_base,
            '2024-01-01'::date AS data_comparacao
    ),
    start_accounts AS (
        SELECT DISTINCT d.start_date, s.account_id
        FROM bronze.subscription s
        INNER JOIN (
            SELECT unnest(ARRAY[
                (SELECT data_base FROM parametros),
                (SELECT data_comparacao FROM parametros)
            ]) AS start_date
        ) d ON
            s.start_date <= d.start_date
            AND (s.end_date > d.start_date OR s.end_date IS NULL)
    ),
    train_accounts AS (
        SELECT account_id
        FROM start_accounts
        WHERE start_date = (SELECT data_base FROM parametros)
    )
    SELECT * 
    FROM start_accounts
    WHERE start_date = (SELECT data_comparacao FROM parametros)
      AND account_id NOT IN (SELECT account_id FROM train_accounts)
) sa;

