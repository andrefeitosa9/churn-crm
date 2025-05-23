with 
-- intervalo de datas padrão
date_range as (
	select '2023-01-01'::date as start_date, '2024-01-01'::date as end_date,
		   interval '14 day' as inactivity_interval
),

-- 1. Churn padrão
start_accounts_churn as (
	select distinct account_id
	from subscription s, date_range d
	where s.start_date <= d.start_date
	  and (s.end_date > d.start_date or s.end_date is null)
),
end_accounts_churn as (
	select distinct account_id
	from subscription s, date_range d
	where s.start_date <= d.end_date
	  and (s.end_date > d.end_date or s.end_date is null)
),
churned_accounts as (
	select s.account_id
	from start_accounts_churn s
	left join end_accounts_churn e on s.account_id = e.account_id
	where e.account_id is null
),
churn_counts as (
	select 
		count(*) as n_start,
		(select count(*) from churned_accounts) as n_churn
	from start_accounts_churn
),

-- 2. Net MRR Retention
start_accounts_mrr as (
	select account_id, sum(mrr) as total_mrr
	from subscription s, date_range d
	where s.start_date <= d.start_date
	  and (s.end_date > d.start_date or s.end_date is null)
	group by account_id
),
end_accounts_mrr as (
	select account_id, sum(mrr) as total_mrr
	from subscription s, date_range d
	where s.start_date <= d.end_date
	  and (s.end_date > d.end_date or s.end_date is null)
	group by account_id
),
retained_accounts as (
	select s.account_id, e.total_mrr
	from start_accounts_mrr s
	join end_accounts_mrr e on s.account_id = e.account_id
),
net_retention_calc as (
	select 
		(sum(r.total_mrr) / nullif(sum(s.total_mrr), 0)) as net_mrr_retention_rate,
		1.0 - (sum(r.total_mrr) / nullif(sum(s.total_mrr), 0)) as net_mrr_churn_rate,
		sum(s.total_mrr) as start_mrr,
		sum(r.total_mrr) as retain_mrr
	from start_accounts_mrr s
	join retained_accounts r on s.account_id = r.account_id
),

-- 3. Churn de atividade
start_active_accounts as (
	select distinct id
	from event e, date_range d
	where e.event_time > d.start_date - d.inactivity_interval
	  and e.event_time <= d.start_date
),
end_active_accounts as (
	select distinct id
	from event e, date_range d
	where e.event_time > d.end_date - d.inactivity_interval
	  and e.event_time <= d.end_date
),
churned_active_accounts as (
	select s.id
	from start_active_accounts s
	left join end_active_accounts e on s.id = e.id
	where e.id is null
),
activity_churn_counts as (
	select 
		(select count(*) from start_active_accounts) as n_start,
		(select count(*) from churned_active_accounts) as n_churn
),

-- 4. MRR Churn
churned_mrr_accounts as (
	select s.account_id, sum(s.total_mrr) as total_mrr
	from start_accounts_mrr s
	left join end_accounts_mrr e on s.account_id = e.account_id
	where e.account_id is null
	group by s.account_id
),
downsell_accounts as (
	select s.account_id, s.total_mrr - e.total_mrr as downsell_amount
	from start_accounts_mrr s
	join end_accounts_mrr e on s.account_id = e.account_id
	where e.total_mrr < s.total_mrr
),
mrr_churn_calc as (
	select
		(sum(c.total_mrr) + coalesce(sum(d.downsell_amount), 0.0)) / nullif(sum(s.total_mrr), 0) as mrr_churn_rate,
		sum(s.total_mrr) as start_mrr,
		sum(c.total_mrr) as churn_mrr,
		coalesce(sum(d.downsell_amount), 0.0) as downsell_mrr
	from start_accounts_mrr s
	left join churned_mrr_accounts c on s.account_id = c.account_id
	left join downsell_accounts d on s.account_id = d.account_id
)

-- Resultado final com mensalizados
select 
	-- churn padrão
	c.n_churn::float / nullif(c.n_start,0) as churn_rate_padrao,
	-- net mrr
	n.net_mrr_churn_rate,
	-- churn de atividade
	a.n_churn::float / nullif(a.n_start,0) as churn_rate_atividade,
	-- mrr churn
	m.mrr_churn_rate

from churn_counts c, net_retention_calc n, activity_churn_counts a, mrr_churn_calc m;
