copy vehicle_owner(first_name, last_name, middle_name, age, gender, email)
from '/Users/maksim/PycharmProjects/pythonProject3/owner.csv' null as '' csv;

copy company(company_name, country, open_year, close_year) 
from '/Users/maksim/PycharmProjects/pythonProject3/companies.csv' null as '' csv;

copy financial_indicators(company_id, company_value, profit, debt_or_capital, year_div_profit, mounth_trading_volume)
from '/Users/maksim/PycharmProjects/pythonProject3/indicators.csv' null as '' csv;

copy pts(owner_id, mark, model, color, body_type, create_year, engine_type, kpp, mass, category, hp)
from '/Users/maksim/PycharmProjects/pythonProject3/ptc.csv' null as ''  csv;

copy vehicle(pts_id, owner_id, company_id)
from '/Users/maksim/PycharmProjects/pythonProject3/car.csv' null as '' csv;



select * from vehicle_owner;
select * from company;
select * from financial_indicators;
select * from pts;
select * from vehicle;


delete from vehicle where id_vehicle = 13;
