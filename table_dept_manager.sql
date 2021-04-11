-- Using EmployeesDB
use EmployeesDB;

if not exists
(
select TABLE_NAME from INFORMATION_SCHEMA.TABLES
where TABLE_NAME = 'dept_manager'
)
begin
create table dept_manager
(
emp_no int not null,
dept_no varchar(4) NOT NULL,
from_date DATE NOT NULL,
to_date DATE NOT NULL
)

if not exists
(
select TABLE_NAME from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
where TABLE_NAME = 'dept_manager'
)
begin

-- Adding foreign key constraint to emp_no
alter table dept_manager
add constraint emp_no_fk foreign key(emp_no) references employees(emp_no) on delete cascade;

-- Adding foreign key constraint to dept_no 
alter table dept_manager
add constraint dept_no_fk foreign key(dept_no) references departments(dept_no) on delete cascade;

end;

-- Inserting data into dept_manager
insert into dept_manager values 
(10022,'d001','1995-08-22','1999-10-01'),
(10039,'d001','1988-01-19','9999-01-01'),
(10085,'d002','1994-04-09','1999-12-17'),
(10114,'d002','1992-07-17','9999-01-01'),
(10133,'d007','1985-12-15','9999-01-01'),
(10140,'d008','1991-03-14','1991-04-08'),
(10153,'d008','1987-04-08','9999-01-01'),
(10169,'d009','1992-07-24','1998-10-17'),
(10178,'d009','1986-10-07','1992-09-08'),
(10187,'d009','1991-06-01','1996-01-03'),
(10193,'d009','1991-07-28','9999-01-01'),
(10183,'d003','1996-08-11','2002-03-21'),
(10228,'d003','1991-08-26','9999-01-01'),
(10303,'d004','1990-02-05','2008-09-09'),
(10344,'d004','1994-06-25','2002-08-02'),
(10386,'d004','1985-08-02','1996-08-30'),
(10420,'d004','1988-01-17','9999-01-01'),
(10511,'d005','1992-01-27','2002-04-25'),
(10567,'d005','1992-10-18','9999-01-01'),
(10725,'d006','1990-09-08','1999-05-06'),
(10765,'d006','1994-05-07','2001-09-12'),
(10800,'d006','1993-05-20','2004-06-28'),
(10854,'d006','1998-07-13','9999-01-01'),
(11000,'d007','1988-08-20','1991-03-07');
end
else
begin
select 'Table dept_manager already exists'
end;

-- Printing the dept_manager table
select * from dept_manager
order by emp_no;

-- drop table dept_manager;