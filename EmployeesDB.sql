/* 
Creating the database EmployeesDB.
*/
if exists
(
select name from master.dbo.sysdatabases
where name = 'EmployeesDB'
)
begin
select 'Database EmployeesDB already exists'
end

else
begin
create database EmployeesDB
select 'Database EmployeesDB Created'
end;