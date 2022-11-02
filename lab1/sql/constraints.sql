alter table pts 
	add constraint pos_owner_id check(owner_id > 0),
	add constraint pos_create_year check(create_year > 0),
	add constraint pos_mass check(mass > 0),
	add constraint pos_hp check(hp > 0);
	
alter table vehicle_owner
	add constraint adult_age check(age >= 18 and age <= 100);

alter table company
	add constraint pos_open_year check(open_year > 0),
	add constraint pos_close_year check(close_year >= open_year);
	
alter table financial_indicators
	add constraint pos_company_id check(company_id > 0),
	add constraint pos_company_value check(company_value >= 0),
	add constraint pos_debt_or_capital check(debt_or_capital >= 0 and debt_or_capital < 100),
	add constraint pos_year_div_profit check(year_div_profit >= 0 and year_div_profit < 100),
	add constraint pos_mounth_trading_volume check(mounth_trading_volume >= 0);
	
alter table vehicle
	add constraint pos_pts_id check(pts_id > 0),
	add constraint pos_owner_id check(owner_id > 0),
	add constraint pos_company_id check(company_id > 0);
	