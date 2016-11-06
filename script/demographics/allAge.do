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
	import excel using age_distribution_1971_2011.xlsx, sheet("`yr'") firstrow cellrange(B2:H18) clear
	rename ReggioEmilia Reggio_count
	rename Parma Parma_count
	rename Padova Padova_count
	rename B Name
	drop F G H

	foreach v in Padova Parma Reggio{
		egen `v'_pop = total(`v'_count)
		gen `v'_perc = `v'_count/`v'_pop
		drop `v'_pop
	}
	
	tempfile first
	save `first'
	
	foreach v in count perc{
		use `first', clear
		keep Name Reggio_`v' Parma_`v' Padova_`v'
		gen Variable = "`v'"
		rename Reggio_`v' Reggio
		rename Parma_`v' Parma
		rename Padova_`v' Padova
		
		tempfile intermed`v'
		save `intermed`v''
	}

	clear

	foreach v in count perc{
		append using `intermed`v''
	}

	gen year = `yr'
	
	tempfile age`yr'
	save `age`yr''
}
clear
foreach yr in 1971 1981 1991 2001 2011{
	append using `age`yr''
}

cd $output_data

save all_age, replace
