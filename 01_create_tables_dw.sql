create table if not exists company_dim (
    company_id int primary key,
    name varchar,
);

create table if not exists skills_dim (
    skill_id int primary key,
    skill varchar,
    type varchar
);

create table if not exists job_postings_fact (
    job_id int primary key,
    company_id int,
    job_title_short varchar,
    job_title varchar,
    job_location varchar,
    job_via varchar,
    job_schedule_type varchar,
    job_work_from_home boolean,
    search_location varchar,
    job_posted_date timestamp,
    job_no_degree_mention boolean,
    job_health_insurance boolean,
    job_country varchar,
    salary_rate varchar,
    salary_year_avg double,
    salary_hour_avg double,
    foreign key (company_id) references company_dim(company_id)
);

create table if not exists skills_job_dim (
    skill_id int,
    job_id int,
    primary key (skill_id, job_id),
    foreign key (skill_id) references skills_dim(skill_id),
    foreign key (job_id) references job_postings_fact(job_id)
);

select table_name
from information_schema.tables
where table_schema = 'main';