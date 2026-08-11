drop schema if exists skills_mart cascade;

create schema skills_mart;

create table skills_mart.dim_skills (
    skill_id int primary key,
    skill varchar,
    type varchar
);

insert into skills_mart.dim_skills (
    skill_id,
    skill,
    type
)
select skill_id,skill,type
from skills_dim;

create table skills_mart.dim_date_month (
    month_start_date date primary key,
    year int,
    month int,
    quarter int,
    quarter_name varchar,
    year_quarter varchar
);

insert into skills_mart.dim_date_month (
    month_start_date,
    year,
    month,
    quarter,
    quarter_name,
    year_quarter
)
select distinct
    date_trunc('month', job_posted_date) as month_start_date,
    extract(year from job_posted_date) as year,
    extract(month from job_posted_date) as month,
    extract(quarter from job_posted_date) as quarter,
    'Q-' || extract(quarter from job_posted_date)::varchar as quarter_name,
    extract(year from job_posted_date)::varchar || '-Q' ||
    extract(quarter from job_posted_date)::varchar as year_quarter
from job_postings_fact
order by month_start_date;

create table skills_mart.fact_skill_demand_monthly (
    skill_id int,
    month_start_date date,
    job_title_short varchar,
    postings_count int,
    remote_postings_count int,
    health_insurance_postings_count int,
    no_degree_mentioned_postings_count int,
    primary key (skill_id, month_start_date, job_title_short),
    foreign key (skill_id) references skills_mart.dim_skills(skill_id),
    foreign key (month_start_date) references skills_mart.dim_date_month(month_start_date)
);

insert into skills_mart.fact_skill_demand_monthly (
    skill_id,
    month_start_date,
    job_title_short,
    postings_count ,
    remote_postings_count ,
    health_insurance_postings_count ,
    no_degree_mentioned_postings_count
)

with job_postings_prep as (
select 
    sjd.skill_id,
    date_trunc('month', jpf.job_posted_date) as month_start_date,
    jpf.job_title_short,
    case when jpf.job_work_from_home = true then 1 else 0 end as is_remote,
    case when jpf.job_health_insurance = true then 1 else 0 end as has_health_insurance,
    case when jpf.job_no_degree_mention = true then 1 else 0 end as no_degree_mentioned
from job_postings_fact as jpf
inner join skills_job_dim as sjd
    on sjd.job_id = jpf.job_id
)

select 
    skill_id, 
    month_start_date, 
    job_title_short,
    count(*) as postings_cost,
    sum(is_remote) as remote_postings_count,
    sum(has_health_insurance) as health_insurance_postings_count,
    sum(no_degree_mentioned) as no_degree_mentioned_postings_count
from job_postings_prep,
group by all
order by skill_id, month_start_date, job_title_short;