WITH intervalo_datas AS (
SELECT generate_series('2023-01-01'::date 
					,'2024-01-01'::date
					, INTERVAL '1 month') AS data_inicio
),

contas_inicio AS (
SELECT DISTINCT d.data_inicio, account_id, sum(mrr) AS mrr_total
FROM SUBSCRIPTION s INNER JOIN intervalo_datas d ON 
	s.start_date <= d.data_inicio
	AND (s.end_date > d.data_inicio OR s.end_date IS NULL)
GROUP BY account_id, d.data_inicio
),

contas_fim AS (
SELECT DISTINCT d.data_inicio, account_id, sum(mrr) AS mrr_total
FROM SUBSCRIPTION s INNER JOIN intervalo_datas d ON 
	s.start_date <= (d.data_inicio+INTERVAL '1 month')
	AND (s.end_date>(d.data_inicio + INTERVAL '1 month') OR s.end_date IS NULL)
GROUP BY account_id, d.data_inicio
),

contas_mantidas AS (
SELECT s.data_inicio, s.account_id, sum(e.mrr_total) AS mrr_total
FROM contas_inicio s
INNER JOIN contas_fim e ON 
	s.account_id = e.account_id
	AND s.data_inicio = e.data_inicio
GROUP BY s.account_id, s.data_inicio
),

mrr_inicio AS (
SELECT data_inicio, sum(contas_inicio.mrr_total) AS mrr_inicio
FROM contas_inicio
GROUP BY data_inicio
),

mrr_mantido AS (
SELECT data_inicio, sum(contas_mantidas.mrr_total) AS mrr_mantido
FROM contas_mantidas
GROUP BY data_inicio
)

SELECT s.data_inicio, (s.data_inicio + INTERVAL '1 month')::date AS data_fim, 
	mrr_mantido / mrr_inicio AS taxa_retencao,
	mrr_inicio, mrr_mantido,
	(mrr_mantido / mrr_inicio)^12 AS taxa_anual_retencao
FROM mrr_inicio s
INNER JOIN mrr_mantido m ON 
	s.data_inicio = m.data_inicio
ORDER BY s.data_inicio;



