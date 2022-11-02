/*1 Инструкция SELECT, использующая предикат сравнения*/
/*Информация о машинах, произведенных компаниями США, основанными после 2000 года*/
select distinct mark, model, create_year
from pts join company on mark = company_name
where (create_year > 2000 and country = 'USA')
group by mark, model, create_year;

/*2 Инструкция SELECT, использующая предикат BETWEEN.*/
/*Информация о машинах, у которых ЛС между 300 и 500*/
select distinct mark, model, hp, owner_id
from pts
where hp between 300 and 500;

/*3 Инструкция SELECT, использующая предикат LIKE.*/
/*Информауия о Мерседесах Е и С класса*/
select distinct mark, model
from pts
where mark = 'Mercedes-Benz' and (model like 'E%' or model like 'C%');

/* 4 Инструкция SELECT, использующая предикат IN с вложенным подзапросом.*/
/*Айди птс и владельцев, которым 18 лет*/
select pts_id, owner_id from pts
where owner_id in (select owner_id from vehicle_owner where age = 18);

/*5 Инструкция SELECT, использующая предикат § с вложенным подзапросом. */
/*Информация о машинах, производители которых работают по сей день*/
select pts_id, company_id, owner_id from vehicle
where exists (select company_id from company
                                where vehicle.company_id = company.company_id
                                      and close_year is null)
order by  pts_id, company_id, owner_id;

/*6 Инструкция SELECT, использующая предикат сравнения с квантором. */
/*Информация о компаниях, у которых годовая дивидендная доходность менее 10%,
а прибыль больше, чем у компаний с годовой ддивидентной доходностью более 30%.*/
select fi.company_id, company_name, fi.profit
from company join financial_indicators fi on company.company_id = fi.company_id
where year_div_profit < 10 and fi.profit > all (select profit from financial_indicators
                                                              where year_div_profit > 30);

/*7 Инструкция SELECT, использующая агрегатные функции в выражениях
столбцов.*/
/*Средний возраст владельцев авто*/
select avg(age) as actaavg, sum(age) / count(owner_id) as calcavg
from (select age, owner_id from vehicle_owner) as foo;


/*8 Инструкция SELECT, использующая скалярные подзапросы в выражениях
столбцов.*/
/*Автомобили с бензиновым типом двигателя с максимальным и минимальным показателем ЛС*/
select owner_id, mark, model, hp
from pts
where hp = (select max(hp) from pts where engine_type = 'Бензиновый')
   or hp = (select min(hp) from pts where engine_type = 'Бензиновый');

/* 9 Инструкция SELECT, использующая простое выражение CASE. */
/*Информация о компаниях и их стоимости в зависимости от страны компании*/
select company.company_id, company_name,
       case CAST(company_value as varchar(30))
           when country = 'Russia'
               then CAST(company_value AS varchar(30)) + '₽'
           when country = 'United Kingdom'
                then CAST(company_value AS varchar(30)) + '£'
           else CAST(company_value AS varchar(30)) + '$'
       end as check
from company join financial_indicators fi on company.company_id = fi.company_id
where profit > 0;

/*10 Инструкция SELECT, использующая поисковое выражение CASE.*/
/*Налог для каждой машины в зависимости от ЛС*/
select pts_id, model, mark,
       case
           when hp <= 150 and age >= 61 then 'Налогом не облагается'
           when hp <= 100 then '24 ₽ за 1 л.с.'
           when hp <= 250 then '35-150 ₽ за 1 л.с'
           else '150 ₽ за 1 л.с'
       end as price_for_ls
from pts join vehicle_owner on pts.owner_id = vehicle_owner.owner_id;

/*11 Создание новой временной локальной таблицы из результирующего набора
данных инструкции SELECT. */
/*Инф-ия о компаниях и автомобилях, произведенных в Великобритании*/
select mark, model, create_year, c.company_id, company_name
into temp markcompany
from (company c join vehicle v on c.company_id = v.company_id) join pts on v.pts_id = pts.pts_id
where country = 'United Kingdom';

drop table markcompany;
select * from markcompany;

/*12 Инструкция SELECT, использующая вложенные коррелированные
подзапросы в качестве производных таблиц в предложении FROM. */
select * from company
where company_id in (select company.company_id
                     from company join financial_indicators fi on company.company_id = fi.company_id
                                       where close_year is null);

/* 13 Инструкция SELECT, использующая вложенные подзапросы с уровнем
вложенности 3.  hp = 1498 ptsid=129*/
/*Найти айди владельца и электрического автомобиля, с максимальным показателем ЛС*/
select pts_id, owner_id from vehicle
where pts_id = (select pts_id from pts
                              where engine_type = 'Электрический' and
                                    hp = (select max(hp) from (select hp from pts
                                                                where engine_type = 'Электрический'
                                                                         group by pts_id) as foo
                                                          )
                              );

select pts_id, hp, engine_type from pts
                               where hp = (select max(hp) from pts where engine_type = 'Электрический');

/*14 Инструкция SELECT, консолидирующая данные с помощью предложения
GROUP BY, но без предложения HAVING.*/
select mark, model, engine_type, avg(hp) as avghp, avg(mass) as avhmass
from pts where engine_type = 'Дизельный'
group by mark, model, engine_type;

/*15 Инструкция SELECT, консолидирующая данные с помощью предложения
GROUP BY и предложения HAVING. */
/*Компании, у которых средняя годовая дивидендная доходность между 5% и 15%*/

select c.company_id, company_name, year_div_profit as ydpavg
from company c join financial_indicators fi on c.company_id = fi.company_id
group by c.company_id, company_name, year_div_profit
having year_div_profit < 15 and year_div_profit > 5;

/* 16 Однострочная инструкция INSERT, выполняющая вставку в таблицу одной
строки значений. */
select * from vehicle_owner where owner_id = 1001;
insert into vehicle_owner (first_name, last_name, middle_name, age, gender, email)
values ('Максим', 'Вязовцев', 'Алексеевич', 20, 'Мужской', 'aemax4@gmail.com');

/* 17 Многострочная инструкция INSERT, выполняющая вставку в таблицу
результирующего набора данных вложенного подзапроса.*/
insert into pts (owner_id, mark, model, color, body_type, create_year, engine_type, kpp, mass, category, hp)
values (1001, 'ВАЗ', '2106', 'Голубой', 'нинаю', 1990, 'Электрический', 'Автоматическая', 1500, 'B', 300);
insert into pts (owner_id, mark, model, color, body_type, create_year, engine_type, kpp, mass, category, hp)
values (1001, 'Nissan', 'Skyline GTR R34', 'Серебристый', 'Кроссовер', 2002, 'Бензиновый', 'Механическая', 1600, 'B', 1100);
insert into vehicle(pts_id, owner_id, company_id)
values (2003, 1001, 14)
insert into vehicle(pts_id, owner_id)
values (2003, 1001)

insert into vehicle (pts_id, owner_id, company_id)
select (select max(pts_id) from pts),
(select owner_id from vehicle_owner where last_name = 'Вязовцев'), 155 from pts;

/* 18 Простая инструкция UPDATE*/
update financial_indicators
set company_value = 100 where company_value = 0;

/* 19 Инструкция UPDATE со скалярным подзапросом в предложении SET. */
select * from financial_indicators where company_id = 155;
update financial_indicators
set year_div_profit = (select avg(year_div_profit) from financial_indicators)
where company_id = 155;

/* 20 Простая инструкция DELETE. */
delete from company where close_year is null;

/* 21 Инструкция DELETE с вложенным коррелированным подзапросом в
предложении WHERE*/
delete from company
where company_id in (select company.company_id
                     from company join financial_indicators fi on company.company_id = fi.company_id
                     where close_year is not null);

/* 22 Инструкция SELECT, использующая простое обобщенное табличное
выражение*/
/*Выбор машин с массой менее 2т, группируя по марке модели и типу двигателя и находим самый частовстречающийся*/
with otv(mk, ml, eng, num) as (
    select mark, model, engine_type, count(*)
        from pts where mass < 2000
                    group by mark, model, engine_type
)
select max(num) as max_num from otv;

/* 23 Инструкция SELECT, использующая рекурсивное обобщенное табличное /*********************************************/
выражение.*/
--накопить сумму профита существующих компаний с 2000 по 2010

with recursive otv_company(id, name, open, close) as (
    select c.company_id, company_name, open_year, close_year
    from company c
    where close_year = (select min(close_year) from company)

    union all

    select company_id, company_name, open_year, close_year
    from company c join otv_company o on true
    where o.close = c.open_year and close_year is not null
)
select * from otv_company;

/* 24 Оконные функции. Использование конструкций MIN/MAX/AVG OVER() */
/*Информация о машинах и МАКСИМАЛЬНЫХ МИНИМАЛЬНЫХ И СРЕДНИХ ЛС  в зависимости от типа двигателя*/
select mark, model, engine_type, kpp, mass,
    avg(hp) over (partition by engine_type) as avggp,
    max(hp) over (partition by engine_type) as maxhp,
    min(hp) over (partition by engine_type) as minhp
from pts;

/* 25 Оконные фнкции для устранения дублей*/
/*Придумать запрос, в результате которого в данных появляются полные дубли.
Устранить дублирующиеся строки с использованием функции ROW_NUMBER().*/
drop table tmp;
drop table newtmp;

create table tmp as
(select * from company
union all
select * from company);

select * from tmp;

select company_name, country, open_year, close_year,
       row_number() over (partition by company_name) as row_n into newtmp from tmp;
delete from newtmp where row_n > 1;
select * from newtmp;


/*Доп задание*/
drop table t1, t2;

create table t1 (id int, var1 varchar, from_ date, to_ date);
create table t2 (id int, var2 varchar, from_ date, to_ date);

insert into t1 (id, var1, from_, to_) values
(1, 'A', '2018-09-01', '2018-09-15'), (1, 'B', '2018-09-16', '5999-12-31');
insert into t2 (id, var2, from_, to_) values
(1, 'A', '2018-09-01', '2018-09-18'), (1, 'B', '2018-09-19', '5999-12-31');

select * from t1, t2;

select t1.id, var1, var2, greatest(t1.from_, t2.from_) as dtfrom, least(t1.to_, t2.to_) as dtto from t1, t2
where  (
    (t1.from_ >= t2.from_ and t1.to_ <= t2.to_) or (t1.from_ <= t2.from_ and t1.to_ >= t2.to_))
   or (t1.from_ >= t2.from_ and t1.to_ >= t2.to_ and (t2.from_ <= t1.to_))
   or ((t1.from_ <= t2.from_ and t1.to_ <= t2.to_ and (t1.to_ >= t2.from_)));


-- все компании и количество владельцев всех машин

select company_name, count(owner_id) as cnt
from (company c join vehicle v on c.company_id = v.company_id) as vc
    join vehicle_owner vo on vc.owner_id = vo.owner_id
group by company_name


select distinct company_name, vo.owner_id from (company c join vehicle v on c.company_id = v.company_id) as vc
    join vehicle_owner vo on vc.owner_id = vo.owner_id
group by company_name, vo.owner_id;


with otv(owner_id, company_id) as (
select distinct owner_id, company_id from vehicle where company_id is not null)
select distinct company_name,
                count(owner_id) over (partition by company_name) as cnt
from otv join company c on otv.company_id = c.company_id;






select mark, count(pts.owner_id) over (partition by pts_id)
from vehicle join pts on pts.pts_id = vehicle.pts_id group by mark;




with otv(owner_id, company_id) as (
select owner_id, company_id from vehicle where company_id is not null)
select distinct company_id,
                count(owner_id) over (partition by company_id) from otv;

