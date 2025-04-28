WITH 
parametros AS (
    SELECT 
        '2023-01-01'::date AS data_base,
        '2024-01-01'::date AS data_comparacao
),
datas AS (
    SELECT unnest(ARRAY[
        (SELECT data_base FROM parametros),
        (SELECT data_comparacao FROM parametros)
    ]) AS start_date
),
start_accounts AS (
    SELECT DISTINCT d.start_date, s.account_id
    FROM bronze.subscription s
    INNER JOIN datas d ON
        s.start_date <= d.start_date
        AND (s.end_date > d.start_date OR s.end_date IS NULL)
),
clientes_base AS (
    SELECT account_id
    FROM start_accounts
    WHERE start_date = (SELECT data_base FROM parametros)
),
resultado AS (
    SELECT 
        CASE 
            WHEN sa.start_date = (SELECT data_base FROM parametros) THEN 'qtde_clientes_treino'
            WHEN sa.start_date = (SELECT data_comparacao FROM parametros) THEN 'qtde_clientes_teste'
        END AS tipo,
        COUNT(DISTINCT sa.account_id) AS quantidade_clientes
    FROM start_accounts sa
    LEFT JOIN clientes_base cb ON sa.account_id = cb.account_id
    WHERE 
        (sa.start_date = (SELECT data_base FROM parametros))
        OR (sa.start_date = (SELECT data_comparacao FROM parametros) AND cb.account_id IS NULL)
    GROUP BY sa.start_date
)
SELECT * FROM resultado;
