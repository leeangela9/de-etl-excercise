drop schema if exists priority_mart cascade;

create schema priority_mart;

create table priority_mart.priority_roles (
    role_id int primary key,
    role_name varchar,
    priority_lvl int
);

insert into priority_mart.priority_roles (role_id, role_name, priority_lvl)
values
    (1, 'Data Engineer', 2),
    (2, 'Senior Data Engineer', 1),
    (3, 'Software Engineer', 3);

select * from priority_mart.priority_roles;

CREATE TABLE priority_mart.priority_jobs_snapshot (                   
  job_id              INTEGER PRIMARY KEY,
  job_title_short     VARCHAR,
  company_name        VARCHAR,
  job_posted_date     TIMESTAMP,
  salary_year_avg     DOUBLE,
  priority_lvl        INTEGER,
  updated_at          TIMESTAMP
);

INSERT INTO priority_mart.priority_jobs_snapshot (         
  job_id,
  job_title_short,
  company_name,
  job_posted_date,
  salary_year_avg,
  priority_lvl,
  updated_at
)
SELECT 
  jpf.job_id,
  jpf.job_title_short,
  cd.name AS company_name,
  jpf.job_posted_date,
  jpf.salary_year_avg,
  r.priority_lvl,
  CURRENT_TIMESTAMP
FROM
    job_postings_fact AS jpf                
LEFT JOIN company_dim AS cd                
    ON jpf.company_id = cd.company_id
INNER JOIN priority_mart.priority_roles AS r      
    ON jpf.job_title_short = r.role_name;
