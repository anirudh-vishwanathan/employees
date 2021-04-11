-- Using EmployeesDB as the database
use EmployeesDB;

/*
Creating departments table
*/ 
if not exists
(
select table_name from INFORMATION_SCHEMA.TABLES
where TABLE_NAME = 'departments'
)
begin
create table departments
(
dept_no varchar(4) not null,
dept_name varchar(30)
)

/*
Adding Constraints to the departments table
*/
if not exists(
select table_name from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
where TABLE_NAME = 'departments'
)
begin

-- adding primary key constraint to dept_no
alter table departments
add constraint dept_no_pk primary key(dept_no);

-- adding unique constraint to dept_name
alter table departments
add constraint dept_name_uk unique(dept_name);

end;

-- Inserting data into the departments table
insert into departments values
('d001','Marketing'),
('d002','Finance'),
('d003','Human Resources'),
('d004','Production'),
('d005','Development'),
('d006','Quality Management'),
('d007','Sales'),
('d008','Research'),
('d009','Customer Service');
end
else
begin
select 'Table name departments already exists'
end;


-- Printing departments table
select * from departments
order by dept_no;

-- drop table departments;