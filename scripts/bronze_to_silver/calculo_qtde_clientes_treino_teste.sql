WITH 
data_referencia AS (
    SELECT 
        '2023-01-01'::date AS data_inicio,
        '2024-01-01'::date AS data_fim
),
ativos_inicio AS (
    SELECT DISTINCT s.account_id
    FROM subscription s, data_referencia d
    WHERE s.start_date <= d.data_inicio
      AND (s.end_date > d.data_inicio OR s.end_date IS NULL)
),
ativos_fim AS (
    SELECT DISTINCT s.account_id
    FROM subscription s, data_referencia d
    WHERE s.start_date <= d.data_fim
      AND (s.end_date > d.data_fim OR s.end_date IS NULL)
),
novos_clientes AS (
    SELECT afim.account_id
    FROM ativos_fim afim
    LEFT JOIN ativos_inicio ainicio ON afim.account_id = ainicio.account_id
    WHERE ainicio.account_id IS NULL
)
SELECT 
    (SELECT COUNT(*) FROM ativos_inicio) AS clientes_ativos,
    (SELECT COUNT(*) FROM novos_clientes) AS novos_clientes;
