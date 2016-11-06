/*
Project:			Reggio Evaluation
Authors:			Sidharth Moktan
Original date: 		10/07/2016
*/
 
clear all
set more off

local c1 Reggio
local c2 Parma
local c3 Padova
local p1 Reggio
local p2 Parma
local p3 Padova

cd $input_data

import excel using Demographic_balance_all_v2.xlsx, sheet("all")
foreach i of varlist _all{
	if(`i'[2] != "") local a = subinstr(`i'[2]," ","",.)
	if(`i'[3] == "Reggio Emilia") local city = 1
	if(`i'[3] == "Parma") local city = 2
	if(`i'[3] == "Padova") local city = 3

	rename `i' c`city'_`a'
}
drop if _n == 1 | _n == 2 | _n == 3
drop ???TotalPopulation
rename cReggio_ year
destring *, replace
keep if year == 1971 | year == 1981 | year == 1991 | year == 2001 | year == 2011

reshape long c1 c2 c3, i(year) j(Name) string
forvalues i = 1/3{
	rename c`i' `c`i''
}
gen Variable = "perc"
order Name Variable year
sort Name year

cd $output_data
save demographic_balance, replace
