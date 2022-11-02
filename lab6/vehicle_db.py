import psycopg2


class VehDB:
    def __init__(self):
        try:
            self.__connection = psycopg2.connect(
                host='localhost',
                user='postgres',
                password='906036',
                database='vehicl_db'
            )
            self.__connection.autocommit = True
            self.__cursor = self.__connection.cursor()
            print("PostgreSQL connection opened ✅\n")

        except Exception as err:
            print("Error while working with PostgreSQL ❌\n", err)
            return

    def __del__(self):
        if self.__connection:
            self.__cursor.close()
            self.__connection.close()
            print("PostgreSQL connection closed ✅\n")

    def __sql_executer(self, sql_query):
        try:
            self.__cursor.execute(sql_query)
        except Exception as err:
            print("Error while working with PostgreSQL ❌\n", err)
            return

        return sql_query

    def scalar_query(self):
        print("Получить средний показатель ЛС для машин в зависимости от типа двигателя.\n")

        sql_query = \
        """
            select engine_type, avg(hp)
            from pts group by engine_type;
        """

        if self.__sql_executer(sql_query) is not None:

            row = self.__cursor.fetchone()
            table = list()

            while row is not None:
                table.append(row)
                row = self.__cursor.fetchone()

            return table

    def join_query(self):

        print("Информация о людях, владеющих более, чем 1 авто.\n")

        sql_query = \
            """
            select * from vehicle_owner v
            join
            (select pts.owner_id, count(pts_id) from pts join
            (select distinct owner_id, count(*) as cnt
            from vehicle
            group by owner_id) as vo on pts.owner_id = vo.owner_id
            where cnt > 1 group by pts.owner_id) as owncnt
                on owncnt.owner_id = v.owner_id;
            """

        if self.__sql_executer(sql_query) is not None:

            row = self.__cursor.fetchone()
            table = list()

            while row is not None:
                table.append(row)
                row = self.__cursor.fetchone()

            return table

    def cte_row_number_query(self):

        print("Вывести количество владеьцев автомобилей для каждой фирмы.\n")

        sql_query = \
            """
            with otv(owner_id, company_id) as (
            select distinct owner_id, company_id from vehicle where company_id is not null)
            select distinct company_name,
                            count(owner_id) over (partition by company_name) as cnt
            from otv join company c on otv.company_id = c.company_id;
            """

        if self.__sql_executer(sql_query) is not None:

            row = self.__cursor.fetchone()
            table = list()

            while row is not None:
                table.append(row)
                row = self.__cursor.fetchone()

            return table

    def metadata_query(self):

        print("Метаинформация таблицы Company.\n| Table | Type | Catalog | Schema | reference_generation |\n")

        sql_query = \
            """
            -- 4. Выполнить запрос к метаданным.
            select pg.table_name, pg.table_type,
            pg.table_catalog, pg.table_schema, pg.reference_generation
            from vehicl_db.information_schema.tables as pg
            where table_name = 'company';
            """

        if self.__sql_executer(sql_query) is not None:
            row = self.__cursor.fetchone()

            return [row]

    def scalar_function_call(self):

        print("Вывести информацию о машинах с электрическим двигателем, у которыхё\
        значение ЛС отличается не более чем на 100 единиц относительно среднего показателя ЛС.\n")

        sql_query = \
            """
            create or replace function get_avg_vehicle_hp(engine varchar(30))
                returns int as
            $$
            begin
                return (select avg(hp) from pts where pts.engine_type = engine);
            end;
            $$ language plpgsql;
            
            select * from pts
            where engine_type = 'Электрический' and
             hp > get_avg_vehicle_hp('Электрический') - 100 and hp < get_avg_vehicle_hp('Электрический') + 100;
            """

        if self.__sql_executer(sql_query) is not None:

            row = self.__cursor.fetchone()
            table = list()

            while row is not None:
                table.append(row)
                row = self.__cursor.fetchone()

            return table

    def tabular_function_call(self):
        print("Вернуть список марок и моделей автомобилей и их количество.\n")

        sql_query = \
            """
            create or replace function count_veh_by_mark_and_model()
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
                    group by mark, model;
                end;
            $$ language plpgsql;
            
            select * from count_veh_by_mark_and_model();
            """

        if self.__sql_executer(sql_query) is not None:

            row = self.__cursor.fetchone()
            table = list()

            while row is not None:
                table.append(row)
                row = self.__cursor.fetchone()

            return table

    def stored_procedure_call(self):

        print("Обнулить финансовые показатели закрывшихся компаний.\n")

        """
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
        """
        # if self.__sql_executer(sql_query) is not None:
        #
        #     row = self.__cursor.fetchone()
        #     table = list()
        #
        #     while row is not None:
        #         table.append(row)
        #         row = self.__cursor.fetchone()
        #
        #     return table

    def system_functionc_call(self):

        print("Информация о текущей версии PostgreSQL.\n")

        sql_query = \
            """
            SELECT * FROM version();
            """

        if self.__sql_executer(sql_query) is not None:
            row = self.__cursor.fetchone()

            return row

    def create_new_table(self):

        print("Создание таблицы тюнинг ателье.\n")

        sql_query = \
            """
            drop table if exists tuning_studio;
            create table if not exists tuning_studio
            (
                id int not null primary key,
                studio_name varchar(30),
                phone varchar(30),
                url varchar(30),
                address varchar(30)
            );
            """

        if self.__sql_executer(sql_query) is not None:
            print("Table was created")

    def insert_into_new_table(self):

        print("Выполнить вставку данных в созданную таблицу.\n")

        sql_query = \
            """
            insert into tuning_studio(id, studio_name, phone, url, address) values
            (1, 'Fat-Tony', '+7 (926) 704-55-33,', 'fat-tony.ru', 'Нижегородская'),
            (2, 'Pro-Service', '+7 (495) 772-44-75', 'pro-service.cc', 'Ростокино'),
            (3, 'Zr Perfomance', '+7 (499) 999-01-21', 'vk.com/zrperformance_msk', 'Кутузовская'),
            (4, 'Uct', '+7 (495) 207-75-70', 'uct.ru', 'Лужники');
            select * from tuning_studio;
            """

        if self.__sql_executer(sql_query) is not None:

            row = self.__cursor.fetchone()
            table = list()

            while row is not None:
                table.append(row)
                row = self.__cursor.fetchone()

            return table