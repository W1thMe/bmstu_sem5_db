drop table if exists pts, vehicle_owner, company, financial_indicators, vehicle;

create table pts (
	pts_id serial primary key,
	owner_id INT not NULL,
	mark VARCHAR(30) not NULL,
	model VARCHAR(30) not NULL,
	color VARCHAR(30) not NULL,
	body_type VARCHAR(30) not NULL,
	create_year int not NULL,
	engine_type VARCHAR(30) not NULL,
	kpp varchar(30) not NULL,
	mass int not NULL,
	category VARCHAR(30) not NULL,
	hp int not NULL
);

create table vehicle_owner (
	owner_id serial PRIMARY KEY,
	first_name VARCHAR(30) not NULL,
	last_name VARCHAR(30) not NULL,
	middle_name VARCHAR(30) not NULL,
	age int not NULL,
	gender VARCHAR(10) not NULL,
	email VARCHAR(30) UNIQUE not NULL
);

create table company (
	company_id serial PRIMARY KEY,
	company_name VARCHAR(30) UNIQUE not NULL,
	country VARCHAR(30) not NULL,
	open_year INT,
	close_year INT
);

create table financial_indicators (
	company_id int not null,
	company_value bigint,
	profit bigint,
	debt_or_capital numeric(4,2),
	year_div_profit numeric(4,2),
	mounth_trading_volume int
);

create table vehicle (
	id_vehicle serial primary key,
	pts_id int not null,
	owner_id int not null,
	company_id int
);

/*
  Внешние ключи для таблицы ТС
*/
alter table vehicle add foreign key (owner_id) references vehicle_owner (owner_id) ON DELETE SET NULL;
alter table vehicle add foreign key (pts_id) references pts (pts_id) ON DELETE set null;
alter table vehicle add foreign key (company_id) references company (company_id) on delete set null;

/*
	Внешние ключи для таблицы ПТС
*/
alter table pts add foreign key (owner_id) references vehicle_owner (owner_id) on delete cascade;

/*
	Внешние ключи для таблицы финансовых показателей
*/
alter table financial_indicators add foreign key (company_id) references company (company_id) on delete cascade;




