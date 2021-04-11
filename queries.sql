-- Using EmployeesDB
 use EmployeesDB;

-- Checking Information Schema
select * from INFORMATION_SCHEMA.TABLES;
select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS;

-- Fetching all details about male employees born after 1960-01-01
select * from employees
where (gender = 'M') and (birth_date >= '1960-01-01')
order by birth_date;

/*
Fetching all details about female employees hired between 1980-01-01 and 1990-01-01
having first_name as either'Avishai','Aleksandar' or 'Arumugam'
*/
select * from employees
where (gender = 'F') and 
(hire_date between '1980-01-01' and '1990-01-01') and 
(first_name in ('Avishai','Aleksandar', 'Arumugam'))
order by first_name, hire_date;

/*
Fetching all details about employees having first_name or last_name starting and ending with 'a'
*/
select * from employees 
where (first_name like 'A%a') or (last_name like 'A%a')
order by first_name, last_name;

-- Fetching all details about employees and sorting them by their age (when they were hired) in descending order
select top(20) *, DATEDIFF(YEAR, birth_date, hire_date) as age
from employees 
order by age desc;

-- Count of number of salary changes (increments) corresponding to each employee
select emp_no, count(salary) as increments from salaries
group by emp_no
order by increments desc, emp_no;

-- Joining employees, titles, employees_dept and departments table
select e.*, ed.dept_no, d.dept_name, t.title, ed.from_date, ed.to_date from employees e
inner join titles t on e.emp_no = t.emp_no
inner join employees_dept ed on e.emp_no = ed.emp_no
inner join departments d on ed.dept_no = d.dept_no
order by e.emp_no;

-- Fetching data of all managers in the database
select e.emp_no, e.first_name, e.last_name, e.gender, dm.dept_no, d.dept_name, t.title, dm.from_date, dm.to_date 
from employees e
inner join titles t on e.emp_no = t.emp_no
inner join dept_manager dm on e.emp_no = dm.emp_no
inner join departments d on d.dept_no = dm.dept_no
order by e.emp_no;

-- Counting employees with salary > 100000
select count(*) as salary_count from salaries 
where salary > 100000;

-- Counting salaries > 80000 
select salary, count(salary) as salary_count from salaries
where salary > 80000
group by salary
order by salary;

-- Fetching emp_no and average salary of employees where average salary > 120000
select emp_no, round(AVG(salary), 2) as avg_salary from salaries
group by emp_no
having round(AVG(salary), 2) > 100000
order by emp_no;

-- Inserting new rows into departments table and then updating row with dept_no d010
if not exists
(
select dept_no from departments
where dept_no = 'd010'
)
begin
insert into departments values
('d010', 'Data Analysis');

update departments
set dept_name = 'Business Analysis'
where dept_no = 'd010';
end

select * from departments
order by dept_no;

-- Inserting null value in dept_name column and replacing it with a statement using coalesce
insert into departments values
('d011', null),
('d012', 'Business Intelligence Analysis');

select dept_no,
coalesce(dept_name, 'Department name not provided!!') as dept_name
from departments
order by dept_no;

-- Fetching the number of employees in each department
select d.dept_no, coalesce(d.dept_name, 'Department name not provided!!') as dept_name, 
count(e.emp_no) as employees_count
from departments d
left join employees_dept ed on d.dept_no = ed.dept_no
left join employees e on ed.emp_no = e.emp_no
group by d.dept_no, d.dept_name
order by d.dept_no;

-- Fetching top 5 departments with max salary
select top(5) d.dept_no, d.dept_name, max(s.salary) as max_salary
from departments d
left join employees_dept ed on d.dept_no = ed.dept_no
left join salaries s on ed.emp_no = s.emp_no
group by d.dept_no, d.dept_name
order by max_salary desc;

-- Fetching dept_name and avg salary of Senior Staff
select d.dept_name, round(avg(s.salary), 2) as avg_salary, t.title
from departments d 
left join employees_dept ed on d.dept_no = ed.dept_no
left join salaries s on s.emp_no = ed.emp_no
left join titles t on t.emp_no = s.emp_no
where t.title = 'Senior Staff'
group by d.dept_name, t.title
order by avg_salary desc;

-- Fetching number of male and female managers 
select e.gender, count(m.emp_no) as manager_count
from employees e 
inner join dept_manager m on e.emp_no = m.emp_no
group by e.gender
order by manager_count desc;

/*
Creating a CTE and fetching birth_month and birth_year for all the employees 
born in 'January', 'February', 'March'
*/
with emp_dates_cte(emp_no, birth_month, birth_year) 
as (
select emp_no, DATENAME(month, birth_date) as birth_month,
DATENAME(year, birth_date) as birth_year
from employees
)

select e.*, cte.birth_month, cte.birth_year
from employees e 
inner join emp_dates_cte cte on e.emp_no = cte.emp_no
where (cte.birth_month in ('January', 'February', 'March')) and 
(cte.birth_year between '1950' and '1960')
order by e.emp_no, cte.birth_year;

-- Checking distinct titles in titles table and replacing Technique Leader to Technical Leader
select distinct(title) from titles;

update titles
set title = replace(title, 'Technique Leader', 'Technical Leader')
where title = 'Technique Leader';

select distinct(title) from titles;

/*
Adding a raise of 30% to salary in salries table
*/
declare @raise_percent varchar(15) = 0.30

-- Using cast to cast raise to float
select *, (salary * CAST(@raise_percent as float)) as raise_amt, 
		  (salary + (salary * CAST(@raise_percent as float))) as new_salary
from salaries;

-- Using convert to cast raise to float
select *, (salary * convert(float, @raise_percent)) as raise_amt, 
		  (salary + (salary * convert(float, @raise_percent))) as new_salary
from salaries;

-- Using Union
select emp_no, dept_no, from_date, to_date, DATEDIFF(YEAR, from_date, to_date) as years_worked
from employees_dept
where year(to_date) != '9999'
union
select emp_no, dept_no, from_date, to_date, DATEDIFF(YEAR, from_date, to_date) as years_worked
from dept_manager
where year(to_date) != '9999'
order by years_worked desc

-- Using case statement
select emp_no, first_name, last_name,
	   DATEDIFF(year, birth_date, hire_date) as hire_age,
	   case 
	    when gender = 'M' then 'Male'
		when gender = 'F' then 'Female'
		end
	   as sex
from employees;

-- Using While loop to print top employees
declare @x int = 1;

while @x <= 5
  begin 
	select top (@x) emp_no, first_name, last_name
	from employees
	set @x = @x + 1
  end

-- Finding the second highest salary in the salaries table
declare @top int = 2;

with top_salary_cte (emp_no, salary)
as
(
select top(@top) emp_no, salary
from salaries
order by salary desc
)

select emp_no, min(salary) 
from top_salary_cte
group by emp_no;

----------------------------------------------------------------------------------------------------------
/*
Using window functions
*/
------------------------------ SUM -----------------------------------------------------------
-- Calculating total salary for each employee
select emp_no, salary, 
	   sum(salary) over(partition by emp_no) as total_emp_salary
from salaries
order by emp_no;

-- Calculating running salary for each employee by from_date
select emp_no, from_date, salary,
       sum(salary) over (partition by emp_no order by from_date) as running_emp_salary
from salaries
order by emp_no;

------------------------------ COUNT -----------------------------------------------------------
-- Calculating total count of employees in each department ordered by employee count
select distinct(dept_no),
	   count(emp_no) over (partition by dept_no) as emp_count
from employees_dept
order by emp_count desc

-- Calculating running count of employees in each department
select dept_no, emp_no,
	   count(emp_no) over (partition by dept_no order by emp_no) as running_emp_count
from employees_dept

--------------- ---------- FIRST_VALUE, LAST_VALUE, COUNT  --------------------------------------
-- Calculating initial salary, average salary, final salary and number of increments for each employee
select distinct(emp_no), 
	   FIRST_VALUE(salary) over (partition by emp_no order by emp_no) as initial_salary,
	   round(avg(salary) over (partition by emp_no order by emp_no), 2) as average_salary,
	   LAST_VALUE(salary) over (partition by emp_no order by emp_no) as final_salary,
	   count(salary) over (partition by emp_no) as num_increments
from salaries
order by emp_no

-------------------------- LEAD, LAG, ROW_NUMBER  -----------------------------------------------
-- Calculating previous_salary, next_salary and row_number for each employee
select ROW_NUMBER() over (partition by emp_no order by emp_no) as row_num,
	   emp_no, salary,
	   coalesce(lag(salary) over (partition by emp_no order by from_date), 0) as previous_sal,
	   coalesce(lead(salary) over (partition by emp_no order by from_date), 0) as next_sal
from salaries
order by emp_no

----------------------------------------------------------------------------------------------------------
-- Formating date to dd/MM/yyyy
select emp_no, FORMAT(birth_date, 'dd/MM/yyyy') as birth_date, 
	   format(hire_date, 'dd/MM/yyyy') as hire_date
from employees

-- Formating date to dddd, dd MMMM yyyy
select distinct(emp_no), 
	   round(avg(salary) over (partition by emp_no), 2) as avg_salary,
	   format(first_value(from_date) over (partition by emp_no order by emp_no), 'dddd, dd MMMM yyyy') as from_date,
	   format(last_value(to_date) over (partition by emp_no order by emp_no), 'dddd, dd MMMM yyyy') as to_date
from salaries;

/*
Creating view to store emp_no, first_name, last_name, dept_no, dept_name,
title, avg_salary and work_period
*/
-- drop view employee_details_view;
create view employee_details_view as 
select e.emp_no, e.first_name, e.last_name,
	   ed.dept_no, d.dept_name, t.title, 
	   round(avg(s.salary) over (partition by s.emp_no), 2) as avg_salary,
	   concat_ws(' - ', format(FIRST_VALUE(s.from_date) over (partition by s.emp_no order by s.emp_no), 'dddd, dd-MM-yyyy'), 
						format(LAST_VALUE(s.to_date) over (partition by s.emp_no order by s.emp_no), 'dddd, dd-MM-yyyy')
	   ) as work_period
from employees e
inner join employees_dept ed on e.emp_no = ed.emp_no
inner join departments d on ed.dept_no = d.dept_no
inner join titles t on e.emp_no = t.emp_no
inner join salaries s on e.emp_no = s.emp_no;

-- Printing employee_details_view
select * from employee_details_view;

-- Updating view by setting first_name to Adam where emp_no is 10001
update employee_details_view
set first_name = 'Adam'
where emp_no = 10001;

/*
Creating Table Variable
*/
declare @master_table table (
emp_no int not null,
first_name varchar(50) not null,
last_name varchar(50) not null,
gender varchar(7),
birth_date date not null,
dept_no varchar(10) not null,
dept_name varchar(50) not null,
title varchar(50) not null,
salary float not null,
from_date date not null,
to_date date not null);

insert into @master_table
select e.emp_no, e.first_name, e.last_name, e.gender, e.birth_date,
ed.dept_no, d.dept_name, t.title, s.salary, s.from_date, s.to_date
from employees e 
inner join employees_dept ed on e.emp_no = ed.emp_no
inner join departments d on ed.dept_no = d.dept_no
inner join titles t on e.emp_no = t.emp_no
inner join salaries s on e.emp_no = s.emp_no;

select * from @master_table
order by emp_no;

/*
------------------------------Creating Scalar Valued Functions ---------------------------------------
*/
-- Creating UDF with one input parameter
-- drop function dbo.getFormatedDate
create function getFormatedDate(@date date) 
returns varchar(20) as
begin
return 
(
select FORMAT(@date, 'dddd, dd-MM-yyyy')
)
end;

select e.emp_no, e.first_name, e.last_name,
	   dbo.getFormatedDate(e.birth_date) as birth_date,
	   dbo.getFormatedDate(e.hire_date) as hire_date
from employees e;

-- Creating function with multiple input parameters
-- drop function dbo.getSlashFormattedDate
create function getSlashFormattedDate(@start_date date , @end_date date)
returns varchar(255) as
begin
return
(
select concat_ws('-', format(@start_date, 'dd/MM/yyyy'), format(@end_date, 'dd/MM/yyyy'))
)
end;

select distinct(emp_no), 
	   round(avg(salary) over (partition by emp_no order by emp_no), 2) as avg_salary,
	   dbo.getSlashFormattedDate(FIRST_VALUE(from_date) over (partition by emp_no order by emp_no),
	   LAST_VALUE(to_date) over (partition by emp_no order by emp_no)) as work_period
from salaries

/*
Inline Table Valued Functions 
*/
-- drop function dbo.deptInfoTable
create function deptInfoTable(@dept_no varchar(5))
returns table as 
return
(
select e.emp_no, e.first_name, e.last_name, ed.dept_no, d.dept_name
from employees e
left join employees_dept ed on e.emp_no = ed.emp_no
left join departments d on ed.dept_no = d.dept_no
where ed.dept_no = @dept_no
);

select * from dbo.deptInfoTable('d001');

-- drop function dbo.managerInfoTable
create function managerInfoTable(@manager_id int)
returns table as
return
(
select row_number() over (partition by s.emp_no order by s.emp_no) as row_no,
	   m.emp_no, m.dept_no, d.dept_name,
	   first_value(s.salary) over (partition by s.emp_no order by s.emp_no) as initial_salary,
	   LAST_VALUE(s.salary) over (partition by s.emp_no order by s.emp_no) as recent_salary,
	   dbo.getSlashFormattedDate(FIRST_VALUE(s.from_date) over (partition by s.emp_no order by s.emp_no),
	   LAST_VALUE(s.to_date) over (partition by s.emp_no order by s.emp_no)) as work_period,
	   t.title
from dept_manager m 
left join departments d on m.dept_no = d.dept_no
left join salaries s on m.emp_no = s.emp_no
left join titles t on m.emp_no = t.emp_no
where m.emp_no = @manager_id
)

-- select * from dept_manager;
select * from dbo.managerInfoTable('10022')
where row_no = 1;

-- Creating table valued function - empInfoTable
-- drop function dbo.empInfoTable
create function empInfoTable()
returns table as 
return
(
select row_number() over (partition by e.emp_no order by e.emp_no) as row_num,
	   e.emp_no, e.first_name, e.last_name,
	   ed.dept_no, d.dept_name, t.title, 
	   round(avg(s.salary) over (partition by e.emp_no), 2) as avg_salary,
	   case 
	    when e.emp_no = m.emp_no then 'True'
		else 'False'
	   end as is_manager
from employees e 
left join employees_dept ed on e.emp_no = ed.emp_no
left join departments d on ed.dept_no = d.dept_no
left join titles  t on e.emp_no = t.emp_no
left join salaries s on e.emp_no = s.emp_no
left join dept_manager m on e.emp_no = m.emp_no
);

select emp_no, first_name, last_name,
	   dept_no, dept_name, title, avg_salary, is_manager
from dbo.empInfoTable()
where row_num = 1;

-- Creating multistatement TVF
-- drop function dbo.empInfoTable2
create function empInfoTable2 () 
returns @emp_dept_mapping table (
		row_num int not null,
		emp_no int not null,
		first_name varchar(50) not null,
		last_name varchar(50) not null,
		dept_no varchar(5) not null,
		dept_name varchar(20) not null,
		title varchar(50) not null,
		avg_salary float not null,
		is_manager varchar(5) not null
		) as  
begin
insert into @emp_dept_mapping
select row_number() over (partition by e.emp_no order by e.emp_no) as row_num,
	   e.emp_no, e.first_name, e.last_name,
	   ed.dept_no, d.dept_name, t.title, 
	   round(avg(s.salary) over (partition by e.emp_no), 2) as avg_salary,
	   case 
	    when e.emp_no = m.emp_no then 'True'
		else 'False'
	   end as is_manager
from employees e 
left join employees_dept ed on e.emp_no = ed.emp_no
left join departments d on ed.dept_no = d.dept_no
left join titles  t on e.emp_no = t.emp_no
left join salaries s on e.emp_no = s.emp_no
left join dept_manager m on e.emp_no = m.emp_no 
return
end;

select emp_no, first_name, last_name,
	   dept_no, dept_name, title, avg_salary, is_manager
from dbo.empInfoTable2()
where row_num = 1;

----------- REVISITING FUNCTIONS ------------------------------------------
-- SVF
create function getDateDiff(@start_date date, @end_date date)
returns int as 
begin
return
(
select datediff(year, @start_date, @end_date)
)
end;

select *, dbo.getDateDiff(birth_date, hire_date) as work_age
from employees

create function getGender(@gender varchar(3))
returns varchar(10) as 
begin
return
(
select case
		when @gender = 'M' then 'Male'
		when @gender = 'F' then 'Female'
	   end
)
end;

-- Calling getGender function using exec
declare @gender varchar(10);
exec @gender = dbo.getGender @gender = 'F';
select @gender as gender

select emp_no, first_name, last_name,
	   dbo.getGender(gender) as gender
from employees;

-- TVF
create function emp_dept_title_table()
returns table as 
return 
select e.emp_no, e.dept_no, d.dept_name,
	   t.title
from employees_dept e 
inner join departments d on e.dept_no = d.dept_no
inner join titles t on e.emp_no = t.emp_no

select * from dbo.emp_dept_title_table()

-- MTVF
create function emp_dept_salaries_table()
returns @emp_dept_salary table (
emp_no int,
dept_no varchar(6),
dept_name varchar(30),
salary float,
work_period varchar(50)
) as 
begin
insert into @emp_dept_salary 
select e.emp_no, e.dept_no, d.dept_name,
	   s.salary, dbo.getSlashFormattedDate(s.from_date, s.to_date)
from employees_dept e
inner join departments d on e.dept_no = d.dept_no
inner join salaries s on e.emp_no = s.emp_no
return
end;

select * from dbo.emp_dept_salaries_table()

create function getXFirstNames(@num int)
returns @first_names table 
(first_names varchar(1000)
) as
begin 
insert into @first_names 
select top(@num) first_name from employees;
return
end;

select string_agg(first_names, ',') as first_names 
from dbo.getXFirstNames(15)

/*
------------------------------------ Creating Stored Procedures -----------------------------------------
*/
alter procedure getEmpFullName (@emp_no int, @full_name varchar(100) output)
as
begin
set @full_name = (select concat_ws(' ', first_name, last_name) 
from employees
where emp_no = @emp_no)
return
end

declare @name varchar(100);
exec dbo.getEmpFullName @emp_no = 10001,
						@full_name = @name output;
select @name


