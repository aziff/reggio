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

import excel using Election_data_Chamber.xlsx, sheet("1953_1992") firstrow cellrange(A1:E11) clear
rename Party Name
gen Variable = "perc"
replace Name = "% voted "+Name
tempfile file1
save `file1'

import excel using Election_data_Chamber.xlsx, sheet("1953_1992") firstrow cellrange(F1:J11) clear
rename Party Name
gen Variable = "perc"
replace Name = "% voted "+Name
append using `file1'
rename Year year

rename ReggioEmilia Reggio
foreach v in Reggio Parma Padova{
	replace `v' = `v'/100
}

cd $output_data
save election, replace
