WITH
intervalo_datas AS (
	SELECT 
	'2023-01-01'::date AS data_inicio, 
	'2024-01-01'::date AS data_fim
), 

contas_inicio AS
(
SELECT DISTINCT account_id
FROM SUBSCRIPTION s INNER JOIN intervalo_datas d ON
	s.start_date <= d.data_inicio
	AND (s.end_date > d.data_inicio OR s.end_date IS NULL)
), 

contas_fim AS 
(
SELECT DISTINCT account_id
FROM SUBSCRIPTION s INNER JOIN intervalo_datas d ON
	s.start_date <= d.data_fim
	AND (s.end_date > d.data_fim OR s.end_date IS NULL)
), 

contas_churn AS 
(
SELECT DISTINCT s.account_id 
FROM contas_inicio s
LEFT OUTER JOIN contas_fim e ON 
	s.account_id = e.account_id
WHERE e.account_id IS NULL
), 

contagem_inicio AS (
SELECT count(*) AS qtde_inicio 
FROM contas_inicio
), 

contagem_churn AS (
SELECT count(*) AS qtde_churn
FROM contas_churn
)

SELECT
	qtde_churn::float/qtde_inicio::float AS taxa_churn, 
	1.0-qtde_churn::float / qtde_inicio AS taxa_retencao, 
	qtde_inicio, 
	qtde_churn
FROM contagem_inicio, contagem_churn

