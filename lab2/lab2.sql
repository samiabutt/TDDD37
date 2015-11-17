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

create table jbcustomer (
	id int not null,
	name varchar(20),
	address varchar(40),
	city int,
	primary key (id),
	constraint fk_cust_living foreign key (city) references jbcity (id)
);

create table jbaccount (
	id int not null,
	balance int not null default 0,
	customer int not null,
	primary key (id),
	constraint fk_cust_acc foreign key (customer) references jbcustomer (id)
);

create table jbwithdrawal (
	id int,
	sdate timestamp not null default current_timestamp,
	amount int not null,
	account int not null,
	employee int not null,
	primary key (id),
	constraint fk_with_acc foreign key (account) references jbaccount (id),
	constraint fk_with_employee foreign key (employee) references jbemployee (id)
);

create table jbdeposit (
	id int,
	sdate timestamp not null default current_timestamp,
	amount int not null,
	account int not null,
	employee int not null,
	primary key (id),
	constraint fk_depo_acc foreign key (account) references jbaccount (id),
	constraint fk_depo_employee foreign key (employee) references jbemployee (id)
);

delete from jbsale;

alter table jbdebit add constraint fk_debit_acc foreign key (account) references jbaccount (id);