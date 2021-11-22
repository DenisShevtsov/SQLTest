IF (SCHEMA_ID('test') IS NULL) 
BEGIN
    EXEC ('CREATE SCHEMA [test] AUTHORIZATION [dbo]')
END
-- CREATE SCHEMA test;

-- люди
create table test.tPerson (
	pid	int, -- идентификатор человека
	name nvarchar(100),
	oid	int, -- ссылка на организацию, в которой трудоустроен данный человек
	primary key(pid)
);

-- организации (и подразделения)
create table test.tOrg (
	oid	int, -- идентификатор организации
	name nvarchar(100), 
	poid int, -- ссылка на oid родительской организации. Для «корневых» - NULL
	primary key(oid)
	);

-- счета
create table test.tAccount (
	aid int, -- идентификатор счета
	pid	int, -- ссылка на Person которому принадлежит счет
	accNumber nvarchar(20), -- номер счета
	primary key(aid)
);

-- остатки по счетам на дату
-- для каждого идентификатора счета aid в таблице хранится набор записей с разными датами stDate
-- каждый раз как по счету происходит движение денег, в tAccountRest на соответствующую
-- дату вставляется запись т.е. по каждому из счетов записи есть не на каждый день, 
-- а только на те даты когда состояние счетов менялось.
create table test.tAccountRest (
	aid int, -- идентификатор счета
	stDate	datetime, -- дата  остатка
	balance float, -- остаток на счете на эту дату
	primary key(aid, stDate)
);


delete from test.tOrg
insert into test.tOrg (oid, name) values (1,'IBM');
insert into test.tOrg (oid, name) values (2,'M$');
insert into test.tOrg (oid, name) values (3,'Oracle');
insert into test.tOrg (oid, name) values (4,'Google')
insert into test.tOrg (oid, name) values (5,'Lukoil')
insert into test.tOrg (oid, name, poid) values (6,'OOO VolgogradNP',5);
insert into test.tOrg (oid, name, poid) values (7,'OOO Perm NP',5);
insert into test.tOrg (oid, name, poid) values (8,'IT',7);
insert into test.tOrg (oid, name, poid) values (9,'Accounting',7);
insert into test.tOrg (oid, name, poid) values (10,'Sales',7);
insert into test.tOrg (oid, name, poid) values (11,'ITD',6);
insert into test.tOrg (oid, name, poid) values (12,'AccountingD',6);
insert into test.tOrg (oid, name, poid) values (13,'SalesD',6);

delete from test.tPerson
insert into test.tPerson (pid, name, oid) values (1, 'Ivan Ivanov', 1);
insert into test.tPerson (pid, name, oid) values ((select MAX(pid)+1 from test.tPerson), 'Ivan Petrov', 1);
insert into test.tPerson (pid, name, oid) values ((select MAX(pid)+1 from test.tPerson), 'Petr Kalinin', 2);
insert into test.tPerson (pid, name, oid) values ((select MAX(pid)+1 from test.tPerson), 'Denis Uljanov', 2);
insert into test.tPerson (pid, name, oid) values ((select MAX(pid)+1 from test.tPerson), 'Larisa Tretyakova', 9);
insert into test.tPerson (pid, name, oid) values ((select MAX(pid)+1 from test.tPerson), 'Tatjana Rybina', 8);
insert into test.tPerson (pid, name, oid) values ((select MAX(pid)+1 from test.tPerson), 'Semen Tsarkin', null);
insert into test.tPerson (pid, name, oid) values ((select MAX(pid)+1 from test.tPerson), 'Kirill Ustinov', null);

insert into test.tAccount (aid,pid,accNumber) values (1,1,'40807810000000000001')
insert into test.tAccount (aid,pid,accNumber) values (2,2,'40807810000000000002')
insert into test.tAccount (aid,pid,accNumber) values (3,3,'40807810000000000003')
insert into test.tAccount (aid,pid,accNumber) values (4,4,'40807810000000000004')
insert into test.tAccount (aid,pid,accNumber) values (5,5,'40807810000000000005')
insert into test.tAccount (aid,pid,accNumber) values (6,4,'40807810000000020004')
insert into test.tAccount (aid,pid,accNumber) values (7,4,'40807810000120020004')
