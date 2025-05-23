WITH
intervalo_datas AS (
SELECT generate_series('2023-01-01'::date
					, '2024-01-01'::date
					, INTERVAL '1 month') AS data_inicio
),

contas_inicio AS (
SELECT DISTINCT d.data_inicio, account_id
FROM SUBSCRIPTION s INNER JOIN intervalo_datas d ON
	s.start_date <= d.data_inicio
	AND (s.end_date>d.data_inicio OR s.end_date IS NULL)
),

contas_final AS (
SELECT DISTINCT d.data_inicio, account_id
FROM SUBSCRIPTION s INNER JOIN intervalo_datas d ON
	s.start_date <= (d.data_inicio+INTERVAL '1 month')
	AND (s.end_date > (d.data_inicio+INTERVAL '1 month') OR s.end_date IS NULL)

),

contas_churned AS (
SELECT s.data_inicio, s.account_id
FROM contas_inicio s
LEFT OUTER JOIN contas_final e ON 
	s.account_id = e.account_id
	AND s.data_inicio = e.data_inicio
WHERE e.account_id IS NULL
),

contagem_inicio AS (
SELECT data_inicio, count(*)::float AS n_inicio
FROM contas_inicio
GROUP BY data_inicio
),

contagem_churn AS (
SELECT data_inicio, count(*)::float AS n_churn
FROM contas_churned
GROUP BY data_inicio
)

SELECT 
s.data_inicio, (s.data_inicio+INTERVAL '1 month')::date AS data_final, 
n_inicio, n_churn, n_churn/n_inicio AS taxa_churn,
1.0-(1-(n_churn/n_inicio))^12 AS taxa_churn_anual
FROM contagem_inicio s
INNER JOIN contagem_churn c
ON s.data_inicio = c.data_inicio
ORDER BY s.data_inicio;














