-- 1 Из таблиц базы данных, созданной в первой лабораторной работе, извлечь
-- данные в XML (MSSQL) или JSON(Oracle, Postgres). Для выгрузки в XML
-- проверить все режимы конструкции FOR XML

copy lsb1_pts(owner_id, mark, model, color, body_type, create_year, engine_type, kpp, mass, category, hp)
from '/Users/maksim/PycharmProjects/pythonProject3/ptc.csv' null as '' csv;
select * from lsb1_pts;

-- В консоли
psql -h localhost postgres -d vehicl_db
\t
\a
\o /Users/maksim/PycharmProjects/pythonProject3/pts.json
SELECT row_to_json(p) FROM lsb1_pts AS p;


-- 2 Выполнить загрузку и сохранение XML или JSON файла в таблицу.
-- Созданная таблица после всех манипуляций должна соответствовать таблице
-- базы данных, созданной в первой лабораторной работе.

create table pts_copy (
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

drop table pts_json;
create temp table pts_json(
    data json
);

copy pts_json(data) from '/Users/maksim/PycharmProjects/pythonProject3/pts.json';

select * from pts_copy;

insert into pts_copy
select
    (data->>'pts_id')::int,
    (data->>'owner_id')::int,
    (data->>'mark')::varchar,
    (data->>'model')::varchar,
    (data->>'color')::varchar,
    (data->>'body_type')::varchar,
    (data->>'create_year')::int,
    (data->>'engine_type')::varchar,
    (data->>'kpp')::varchar,
    (data->>'mass')::int,
    (data->>'category')::varchar,
    (data->>'hp')::int
from pts_json;

select * from pts_copy;

-- Создать таблицу, в которой будет атрибут(-ы) с типом XML или JSON, или
-- добавить атрибут с типом XML или JSON к уже существующей таблице.
-- Заполнить атрибут правдоподобными данными с помощью команд INSERT
-- или UPDATE


drop table if exists json_tuning_studio;
create table if not exists json_tuning_studio
(
    id int not null primary key,
    studio_name varchar(30),
    contacts jsonb not null
);

insert into json_tuning_studio values
(1, 'Fat-Tony', '{"phone":"+7 (926) 704-55-33", "url":"fat-tony.ru", "address":"Нижегородская"}'),
(2, 'Pro-Service', '{"phone":"+7 (495) 772-44-75", "url":"pro-service.cc", "address":"Ростокино"}'),
(3, 'Zr Perfomance', '{"phone":"+7 (499) 999-01-21", "url":"vk.com/zrperformance_msk", "address":"Кутузовская"}'),
(4, 'Uct', '{"phone":"+7 (495) 207-75-70", "url":"uct.ru", "address":"Лужники"}');
select * from json_tuning_studio;

-- Выполнить следующие действия:
-- 1. Извлечь XML/JSON фрагмент из XML/JSON документа

select contacts from json_tuning_studio;

-- 2. Извлечь значения конкретных узлов или атрибутов XML/JSON
-- документа

select contacts->'phone' as phone, contacts->'url' as url, contacts->'address' as address
from json_tuning_studio;

-- 3. Выполнить проверку существования узла или атрибута

create or replace function key_exists_check(data json, key text)
returns boolean
as
$$
begin
    return (data->key) is not null;
end;
$$ language plpgsql;

select key_exists_check(contacts, 'address')
from json_tuning_studio;

-- 4. Изменить XML/JSON документ

update json_tuning_studio
set contacts = contacts || '{"phone":"+7 (926) 704-55-33", "url":"fat-tony.ru", "address":"Домодедовская"}'::jsonb
where contacts->>'address' = 'Нижегородская';

-- 5. Разделить XML/JSON документ на несколько строк по узлам

drop table arr_pts_json;
create temp table arr_pts_json(
    data jsonb
);

insert into arr_pts_json values
('[
  {"id" : 1, "name" : "Fat-Tony", "contents" :  {"phone":"+7 (926) 704-55-33", "url":"fat-tony.ru", "address":"Нижегородская"}},
  {"id" : 2, "name" : "Pro-Service", "contents" :  {"phone":"+7 (495) 772-44-75", "url":"pro-service.cc", "address":"Ростокино"}},
  {"id" : 3, "name" : "Zr Perfomance", "contents" :  {"phone":"+7 (499) 999-01-21", "url":"vk.com/zrperformance_msk", "address":"Кутузовская"}},
  {"id" : 4, "name" : "Uct", "contents" :  {"phone":"+7 (495) 207-75-70", "url":"uct.ru", "address":"Лужники"}}
]');

select * from arr_pts_json;

select jsonb_array_elements(data) from arr_pts_json;
