WITH
intervalo_datas AS (
SELECT '2023-01-01'::date AS data_inicio, '2024-01-01'::date AS data_fim
),

contas_inicio AS (
SELECT account_id, sum(mrr) AS mrr_total
FROM SUBSCRIPTION s INNER JOIN intervalo_datas d ON 
	s.start_date <= d.data_inicio
	AND (s.end_date > d.data_inicio OR s.end_date IS NULL)
GROUP BY s.account_id
	), 

contas_fim AS (
SELECT account_id, sum(mrr) AS mrr_total
FROM SUBSCRIPTION s INNER JOIN intervalo_datas d ON 
	s.start_date <= d.data_fim
	AND (s.end_date > d.data_fim OR s.end_date IS NULL)
GROUP BY s.account_id
	),

contas_churned AS (
SELECT s.account_id, sum(s.mrr_total) AS mrr_total
FROM contas_inicio s
LEFT OUTER JOIN contas_fim e ON
	s.account_id = e.account_id
WHERE e.account_id IS NULL
GROUP BY s.account_id
),

contas_downsell AS (
SELECT s.account_id, s.mrr_total - e.mrr_total AS valor_downsell
FROM contas_inicio s 
INNER JOIN contas_fim e ON
	s.account_id = e.account_id
WHERE e.mrr_total < s.mrr_total
),

mrr_inicio AS (
SELECT sum(contas_inicio.mrr_total)  AS mrr_inicio
FROM contas_inicio
),

mrr_churn AS (
SELECT sum(contas_churned.mrr_total) AS mrr_churn
FROM contas_churned
),

mrr_downsell AS (
SELECT COALESCE(sum(contas_downsell.valor_downsell), 0.0) AS mrr_downsell
FROM contas_downsell
)

SELECT
(c.mrr_churn+d.mrr_downsell)/s.mrr_inicio AS taxa_churn_mrr, 
s.mrr_inicio, 
c.mrr_churn, 
d.mrr_downsell
FROM mrr_inicio s, mrr_churn c, mrr_downsell d















