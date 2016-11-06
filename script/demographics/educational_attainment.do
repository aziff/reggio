/*
Project:			Reggio Evaluation
Authors: 			Sidharth Moktan
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

foreach yr in 1971 1981 1991 2001 2011{
	if ("`yr'" == "2011") local end J35
	if ("`yr'" != "2011") local end J42

	local city =""
	local group =""
	import excel using educational_attainment_1971_2001.xlsx, sheet("`yr'") cellrange(A26:`end') clear
	foreach i of varlist _all{
		if(`i'[2] == "Reggio Emilia") local city = "Reggio"
		if(`i'[2] != "" & `i'[2] != "Reggio Emilia") local city = `i'[2]
		if(`i'[1] != "") local group = `i'[1]

		rename `i' `city'_`group'
	}

	gen year = `yr'

	drop if _n == 1 | _n == 2

	gen Variable = "count" if _n < _N/2
	replace Variable = "perc" if _n >= _N/2
	rename _ Name

	tempfile intermed
	save `intermed'

	foreach g in Male Female Total{
		use `intermed', clear
		keep Name Variable year Reggio_`g' Parma_`g' Padova_`g'
		replace Name = Name+"_"+"`g'"
		rename Reggio_`g' Reggio
		rename Parma_`g' Parma
		rename Padova_`g' Padova
		
		tempfile intermed_`g'
		save `intermed_`g''
	}
	clear
	foreach g in Male Female Total{
		append using `intermed_`g''
	}

	tempfile educ`yr'
	save `educ`yr''
}

clear
foreach yr in 1971 1981 1991 2001 2011{
	append using `educ`yr''
}

replace Variable = "perc" if year == 2011
