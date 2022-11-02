
/*ЛР3 ЛЕТС ГОУ*/

/*
4 функции
1) Скалярная
2) Подставляемая Табличная
3) Многооператорная
4) Рекурсивная или с рекурсивным ОТВ
  */

-- 1) Количество автомобилей c ЛС выше среднего в зависимости от типа двигателя
create or replace function get_avg_vehicle_hp(engine varchar(30))
    returns int as
$$
begin
    return (select avg(hp) from pts where pts.engine_type = engine);
end;
$$ language plpgsql;

select * from pts
where engine_type = 'Электрический' and hp > get_avg_vehicle_hp('Электрический');


-- 2) Посчитать количество машин по марке и модели
create or replace function count_veh_by_mark_and_model(find_mark varchar(30))
    returns table
    (
        tmp_mark varchar(30),
        tmp_model varchar(30),
        tmp_cnt int
    ) as
$$
    begin
    return query
        select mark, model, count(*)::int as cnt
        from pts
        where mark = find_mark group by mark, model;
    end;
$$ language plpgsql;

select * from count_veh_by_mark_and_model('Toyota');

-- 3) Получить информацию о компании по id
create or replace function get_company_info(find_id int)
    returns table
    (
        id int,
        name text,
        yopen int,
        close int,
        value bigint,
        profit bigint
    ) as
$$
    begin
        drop table if exists tmp;

        create temp table tmp
        (
            id int,
            name text,
            yopen int,
            close int,
            value bigint,
            profit bigint
        );

        insert into tmp(id, name, yopen, close, value, profit)
        select c.company_id, company_name, open_year, close_year, company_value, fi.profit
        from company c join financial_indicators fi on c.company_id = fi.company_id
        where c.company_id = find_id;

        return query

        select * from tmp;

    end;
$$ language plpgsql;

select * from get_company_info(644);

-- 4)
DROP FUNCTION rec_func();

create or replace function rec_func()
    returns table
    (
        id int,
        name varchar(30),
        country varchar(30),
        open int,
        close int
    ) as
$$
begin
    return query
    (
        with recursive otv_company(id, name, country, open, close) as (
            select c.company_id, company_name, c.country, open_year, close_year
            from company c
            where close_year = (select min(close_year) from company)

            union all

            select company_id, company_name, c.country, open_year, close_year
            from company c join otv_company o on true
            where o.close = c.open_year and close_year is not null
        )
        select * from otv_company
    );
end;
$$ language plpgsql;

select * from rec_func();

/*
 4 хранимые процедуры
 1) хр проц без параметров или с параметрами
 2) Рекурсивную хранимую процедуру или хранимую процедур с
рекурсивным ОТВ
 3) Хранимую процедуру с курсором
 4) Хранимую процедуру доступа к метаданным
 */

-- 1) Обнулить финансовые показатели закрывшихся компаний
create or replace procedure update_fin_ind() as
$$
begin
    update financial_indicators
    set company_value = null,
        profit = null,
        year_div_profit = null,
        debt_or_capital = null,
        mounth_trading_volume = null
    where company_id in (select company_id
                                      from company where close_year is not null);
end;
$$ language plpgsql;


call update_fin_ind();
select * from financial_indicators join company c on financial_indicators.company_id = c.company_id
where close_year is not null


-- 2 Рекурсивная хранимая процедура
create or replace procedure print_companies_info(beg_id int, end_id int) as
$$
    declare
        next_id int;
        name varchar(30);
        country varchar(30);
        yo int;
        ye int;
begin
    select * from company c
    where c.company_id = beg_id
    into next_id, name, country, yo, ye;

    raise notice 'id: % Company: % Country: % Year: % - %', next_id, name, country, yo, ye;

    if next_id < end_id and next_id is not null then
        call print_companies_info(next_id + 1, end_id);
    else
        raise notice '--end of procedure--';
    end if;
end;
$$ language plpgsql;

call print_companies_info(1, 10);

-- 3 С курсором
create or replace procedure find_pts_by_hp_engine(min_hp int, max_hp int, etype varchar(30)) as
$$
    declare
        pts_cursor cursor for
        select * from pts
        where hp between min_hp and max_hp and engine_type = etype;
begin
    for note in pts_cursor loop
        raise notice 'ID: % Mark: % Model: % HP: % Engine type: %', note.pts_id, note.mark, note.model, note.hp, note.engine_type;
        end loop;
end;
$$ language plpgsql;

call find_pts_by_hp_engine(500, 550, 'Бензиновый');

-- 4) Метаинформация таблицы
create or replace procedure get_table_metainformation(name text) as
$$
    declare
        info record;
begin
    for info in select *
    from vehicl_db.information_schema.tables
    where table_name like name
        loop
            raise notice 'Name: % Type: % Catalog: % Schema: % Ref_generation: %', info.table_name, info.table_type,
                info.table_catalog, info.table_schema, info.reference_generation;
        end loop;
end;
$$ language plpgsql;

call get_table_metainformation('vehicle');

/*
 2 DML триггера
 1) Триггер AFTER
 2) Триггер INSTEAD OF
 */

-- 1) Вывод информации о любом измменнеии в таблице
create or replace function describe_action()
returns trigger as
$$
    declare
        rec record;
        str text := '';
begin
    if tg_level = 'ROW' then
        case tg_op
            when 'DELETE' then rec := OLD; str := OLD::text;
            when 'UPDATE' then rec := NEW; str := OLD || ' -> ' || NEW;
            when 'INSERT' then rec := NEW; str := NEW::text;
        end case;
    end if;

    raise notice 'Table: % When: % OP: % Level: % Info: %', tg_table_name, tg_when, tg_op, tg_level, str;
    return rec;
end;
$$ language plpgsql;

create trigger t_after_row
after insert or update or delete on vehicle_owner
for each row execute function describe_action();

update vehicle_owner
set age = age + 1
where owner_id = 111;

-- 2)

create view company_vw as
    select * from company;

create or replace function insert_company_vw()
returns trigger as
$$
    declare
        rec record;
        str text := '';
begin
    if tg_level = 'ROW' then
        case tg_op
            when 'DELETE' then rec := OLD; str := OLD::text;
                delete from company where company_id = old.company_id;
            when 'UPDATE' then rec := NEW; str := OLD || ' -> ' || NEW;
                update company set company_id = new.company_id,
                                   company_name = new.company_name,
                                   country = new.country,
                                   open_year = new.open_year,
                                   close_year = new.close_year
                where company_id = old.company_id;
            when 'INSERT' then rec := NEW; str := NEW::text;
                insert into company values (new.company_id, new.company_name, new.country,
                                            new.open_year, new.close_year);
        end case;
    end if;

    raise notice 'Table: % When: % OP: % Level: % Info: %', tg_table_name, tg_when, tg_op, tg_level, str;
    return rec;
end;
$$ language plpgsql;

create trigger t_insteadof_row
instead of insert or update or delete on company_vw
for each row execute function insert_company_vw();


update company_vw
set open_year = open_year + 1
where company_id = 111;