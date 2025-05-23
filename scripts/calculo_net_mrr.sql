WITH
intervalo_datas AS (
	SELECT 
	'2023-01-01'::date AS data_inicio, 
	'2024-01-01'::date AS data_fim
),

clientes_inicio AS 
(
	SELECT account_id, sum(mrr) AS mrr_total
	FROM SUBSCRIPTION s INNER JOIN intervalo_datas d ON
		s.start_date <= d.data_inicio 
		AND (s.end_date > d.data_inicio OR s.end_date IS NULL)
	GROUP BY account_id
),

clientes_fim AS
(
	SELECT account_id, sum(mrr) AS mrr_total
	FROM SUBSCRIPTION s INNER JOIN intervalo_datas d ON 
		s.start_date <= d.data_fim 
		AND (s.end_date > d.data_fim OR s.end_date IS NULL)
	GROUP BY account_id
), 

clientes_mantidos AS 
(
	SELECT s.account_id, sum(e.mrr_total) AS mrr_total
	FROM clientes_inicio s 
	INNER JOIN clientes_fim e ON s.account_id = e.account_id
	GROUP BY s.account_id
),

mrr_inicio AS (
	SELECT sum(clientes_inicio.mrr_total) AS mrr_total_inicio
	FROM clientes_inicio
), 

mrr_mantido AS (
	SELECT sum(clientes_mantidos.mrr_total) AS mrr_total_mantido
	FROM clientes_mantidos
)

SELECT
	mrr_total_mantido / mrr_total_inicio AS net_mrr_taxa_retencao, 
	1.0 - mrr_total_mantido / mrr_total_inicio AS net_mrr_taxa_churn, 
	mrr_total_inicio, 
	mrr_total_mantido
FROM mrr_inicio, mrr_mantido
















