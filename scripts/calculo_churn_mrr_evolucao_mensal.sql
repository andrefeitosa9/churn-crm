WITH 
intervalo_datas AS (
SELECT generate_series('2023-01-01'::date
					, '2024-01-01'::date
					, interval '1 month') AS data_inicio
),

contas_inicio AS (
SELECT DISTINCT d.data_inicio, account_id, sum(mrr) AS mrr_total, avg(bill_period_months) AS tempo_assinatura
FROM SUBSCRIPTION s INNER JOIN intervalo_datas d ON 
	s.start_date <= (d.data_inicio)
	AND (s.end_date > (d.data_inicio) OR s.end_date IS NULL)
GROUP BY account_id, d.data_inicio
),


contas_fim AS (
SELECT DISTINCT d.data_inicio, account_id, sum(mrr) AS mrr_total, avg(bill_period_months) AS tempo_assinatura
FROM SUBSCRIPTION s INNER JOIN intervalo_datas d ON 
	s.start_date <= (d.data_inicio+INTERVAL '1 month')
	AND (s.end_date > (d.data_inicio+INTERVAL '1 month') OR s.end_date IS NULL)
GROUP BY account_id, d.data_inicio
),

contas_churned AS (
SELECT s.data_inicio, s.account_id, sum(s.mrr_total) AS mrr_total
FROM contas_inicio s
LEFT OUTER JOIN contas_fim e ON 
	s.account_id = e.account_id
	AND s.data_inicio = e.data_inicio
WHERE e.account_id IS NULL
GROUP BY s.data_inicio, s.account_id	
),

contas_downsell AS (
SELECT s.data_inicio, s.account_id, s.mrr_total-e.mrr_total AS valor_downsell
FROM contas_inicio s 
INNER JOIN contas_fim e 
	ON s.account_id = e.account_id
	AND s.data_inicio = e.data_inicio
WHERE e.mrr_total < s.mrr_total
AND e.tempo_assinatura <= s.tempo_assinatura --exceto qdo faz o upgrade para plano anual, conoseguindo desconto
),

contas_extensao AS (
SELECT s.data_inicio, s.account_id, s.mrr_total-e.mrr_total AS valor_extensao
FROM contas_inicio s 
INNER JOIN contas_fim e ON
	s.account_id = e.account_id
	AND s.data_inicio = e.data_inicio
WHERE e.mrr_total < s.mrr_total
AND e.tempo_assinatura > s.tempo_assinatura --casos de extensão de mensal para anual
),

mrr_inicio AS (
SELECT data_inicio, sum(contas_inicio.mrr_total) AS mrr_inicio
FROM contas_inicio
GROUP BY data_inicio
),

mrr_churned AS (
SELECT data_inicio, sum(contas_churned.mrr_total) AS mrr_churn
FROM contas_churned
GROUP BY data_inicio
),

mrr_downsell AS (
SELECT data_inicio, COALESCE(sum(contas_downsell.valor_downsell),0.0) AS mrr_downsell
FROM contas_downsell
GROUP BY data_inicio
),

mrr_extensao AS (
SELECT data_inicio, COALESCE(sum(contas_extensao.valor_extensao), 0.0) AS mrr_extensao
FROM contas_extensao
GROUP BY data_inicio
)

SELECT s.data_inicio, (s.data_inicio + INTERVAL '1 month')::date AS data_fim, 
mrr_inicio, COALESCE(mrr_churn, 0) AS churn_mrr, COALESCE(mrr_downsell,0) AS mrr_downsell, COALESCE(mrr_extensao, 0) AS mrr_extensao,
(COALESCE(mrr_churn,0) + COALESCE(mrr_downsell, 0))/ mrr_inicio AS taxa_churn_mrr,
1.0-(1-((COALESCE(mrr_churn, 0) + coalesce(mrr_downsell,0)) / mrr_inicio))^12 AS taxa_anual_churn_mrr, 
(COALESCE(mrr_extensao, 0)) / mrr_inicio AS taxa_extensao_mrr, 
1.0-(1-((COALESCE(mrr_extensao,0))/mrr_inicio))^12 AS taxa_anual_extensao_mrr
FROM mrr_inicio s
FULL OUTER JOIN mrr_churned c
ON s.data_inicio = c.data_inicio
FULL OUTER JOIN mrr_downsell d
ON d.data_inicio = s.data_inicio
FULL OUTER JOIN mrr_extensao x
ON x.data_inicio = s.data_inicio
ORDER BY s.data_inicio;





