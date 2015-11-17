create table jbmanager (
	id int NOT NULL,
	bonus int NOT NULL DEFAULT 0,
	primary key (id),
	constraint fk_employee_id foreign key (id) references jbemployee (id)
);

insert into jbmanager (id) 
select manager from jbemployee where jbemployee.manager is not null
union 
select manager from jbdept where jbdept.manager is not null;

alter table jbemployee drop foreign key fk_emp_mgr;

alter table jbemployee add constraint fk_emp_mgr foreign key (manager) references jbmanager (id);

alter table jbdept drop foreign key fk_dept_mgr;

alter table jbdept add constraint fk_dept_mgr foreign key (manager) references jbmanager (id);

update jbmanager
set bonus=bonus+10000
where id in (select manager from jbdept);