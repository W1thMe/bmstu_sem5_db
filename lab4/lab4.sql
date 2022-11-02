create extension plpython3u;

/*
	Создать, развернуть определяемую пользователем скалярную функцию CLR
	Вывести информацию об автомобилях с показателем ЛС больше среднего
*/
drop function get_avg_hp();
create or replace function get_avg_hp(type text)
returns float as
$$
	res = plpy.execute(f"select avg(hp) as avg_hp\
		   from pts\
		   where pts.engine_type = '{type}'");
	if res:
		return res[0]['avg_hp']
$$
language plpython3u;

select * from pts
where engine_type = 'Дизельный' and hp > get_avg_hp('Дизельный');

/*
	Создать, развернуть пользовательскую агрегатную функцию CLR
	Вывести общее число какой-либо модели авто
*/

create or replace function get_count_mark(find_mark varchar(30))
returns integer as
$$
	count = 0
	result = plpy.execute("select * from pts");
	if result:
		for elem in result:
			if elem["mark"] == find_mark:
				count += 1
	return count
$$
language plpython3u;

select get_count_mark('Toyota') as cnt
from pts
group by cnt;

/*
	Создать, развернуть определяемую пользователем табличную функцию CLR.
	Информация о количестве владельцев аавто для каждой компании.
*/


create or replace function get_veh_cnt_info()
returns table
    (
        name varchar(30),
        cnt int
    ) as
$$
	query = f"with otv(owner_id, company_id) as ( \
            select distinct owner_id, company_id from vehicle where company_id is not null) \
            select distinct company_name, \
                count(owner_id) over (partition by company_name) as cnt \
            from otv join company c on otv.company_id = c.company_id;"
	result = plpy.execute(query)
	for elem in result:
		yield(elem["company_name"], elem["cnt"])
$$
language plpython3u;

select * from get_veh_cnt_info();


/*
	Создать, развернуть хранимую процедуру CLR
	Найти id владельцев машин по фамилии.
*/

drop function  update_owner_age;
create or replace procedure find_owner(surname varchar(30))
as
$$
    id = plpy.execute(f"select owner_id \
                        from vehicle_owner \
                        where last_name = '{surname}'")
    if len(id) == 0:
        plpy.notice(f"No owners with surname: '{surname}' ")
    else:
        for each in id:
            plpy.notice(f"ID: '{each}' for owner with surname: '{surname}' ")
$$
language plpython3u;

call find_owner('Сидоров');

/*
	Создать, развернуть триггер CLR
	Удаление/обновление  представления отражается на базовой таблице и выводится информация о том, информацию о какой
	компании изменили
*/

create or replace view fin_ind as
select * from financial_indicators
where company_id in (select company_id from company
                                       where close_year is null);
select * from fin_ind;

create or replace function update_fin_ind_info()
returns trigger
as
$$
    if TD['event'] == 'DELETE':
        old_ind = TD["old"]["company_id"]
        plpy.notice(f"Удалена информация о финансовых показателях компании с id: {old_ind}")
        plpy.execute(f"delete from financial_indicators \
                       where company_id = {old_ind};")
    elif TD['event'] == 'UPDATE':
        old_ind = TD["old"]["company_id"]
        new_value = TD["new"]["company_value"]

        plpy.notice(f"Обновлена информация о финансовых показателях компании с id: {old_ind}")
        plpy.execute(f"update financial_indicators\
                       set company_value = {new_value}\
                       where company_id = {old_ind};")

$$
language plpython3u;

drop trigger update_fin_ind_info on fin_ind;
create trigger update_fin_ind_info
instead of update or delete on fin_ind
for each row execute function update_fin_ind_info();

delete from fin_ind
where company_id = 112;

update fin_ind
set company_value = company_value + 1
where company_id = 113;


/*
    Определяемый пользователем тип данных CLR.
*/


drop type veh_kind;
create type veh_kind as
(
	--kpp_type varchar,
	cnt int
);

drop function get_count_kind;
create or replace function get_count_kind(find_kind varchar)
returns SETOF veh_kind as
$$
    query = '''select count(*) as cnt \
               from pts where mark = '%s';''' % (find_kind)

    result = plpy.execute(query)

    if result is not None:
        return result
$$

language plpython3u;

select * from get_count_kind('BMW');


select mark, model, count(*) as cnt
               from pts where mark = 'BMW'
               group by mark, model;

select * from vehicle_owner v
join
(select pts.owner_id, count(pts_id) from pts join
(select distinct owner_id, count(*) as cnt
from vehicle
group by owner_id) as vo on pts.owner_id = vo.owner_id
where cnt > 1 group by pts.owner_id) as owncnt
    on owncnt.owner_id = v.owner_id;


select distinct owner_id, count(*) as cnt
            from vehicle
            group by owner_id;