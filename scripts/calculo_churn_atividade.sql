WITH
intervalo_datas AS (
SELECT 
	'2023-01-01'::date AS data_inicio, 
	'2024-01-01'::date AS data_fim, 
	INTERVAL '14 day' AS inatividade_permitida
),

contas_inicio AS (
SELECT DISTINCT id
FROM event e INNER JOIN intervalo_datas d ON 
	e.event_time > d.data_inicio-d.inatividade_permitida
	AND e.event_time <= d.data_inicio
), 

contagem_inicio AS (
SELECT count(*) AS qtde_inicio FROM contas_inicio
), 

contas_fim AS (
SELECT DISTINCT id
FROM EVENT e INNER JOIN intervalo_datas d ON 
	e.event_time > d.data_fim - d.inatividade_permitida
	AND e.event_time <= d.data_fim
),

contagem_fim AS (
SELECT count(*) AS qtde_fim FROM contas_fim
), 

contas_churn AS (
SELECT DISTINCT s.id 
FROM contas_inicio s LEFT OUTER JOIN contas_fim e ON
	s.id = e.id
	WHERE e.id IS NULL
),

contagem_churn AS (
SELECT count(*) AS qtde_churn
FROM contas_churn
)


SELECT
	qtde_churn::float / qtde_inicio::float AS taxa_churn, 
	1.0-qtde_churn::float / qtde_inicio::float AS taxa_retencao, 
	qtde_inicio, 
	qtde_churn
FROM contagem_inicio, contagem_fim, contagem_churn
	
	




















