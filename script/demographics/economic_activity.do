/*
Project:			Reggio Evaluation
Authors: 			Sidharth Moktan
Original date:		10/07/2016
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
	import excel using Economic_Activity_1971_2011.xlsx, sheet("`yr'_n") cellrange(A1:T15)clear
	tostring B, replace
	replace B = A if C == ""
	replace B = B[_n-1] if B == "."

	foreach i of varlist _all{
		if(`i'[1] =="resident population (absolute values)") local 1varLabel = "count"
		if(`i'[1] =="resident population (percentage)") local 1varLabel = "perc"
		if(`i'[2]!="" & `i'[3]=="") local 2varLabel = subinstr(`i'[2]," ","",.)
		if(`i'[3]!="") local 2varLabel
		if(`i'[3]!="") local 3varLabel = subinstr(`i'[3]," ","",.)
		if(`i'[3]=="") local 3varLabel
		
		local varLabel`i' "`1varLabel'_`2varLabel'_`3varLabel'"
		
		replace `i' = "`varLabel`i''" if _n == 1
	}

	drop if _n == 2 | _n == 3
	drop if C == ""
	replace A = trim(A)
	replace A = "Reggio" if A == "Reggio nell'Emilia"
	replace A = A+"_"+B
	ed

	sxpose, clear firstnames
	drop if _n == 1
	reshape long Reggio Parma Padova, i(_var1) j(group) string

	gen Variable = ""
	foreach v in count perc{
		replace Variable = "`v'" if strpos(_var1,"`v'")>0
		replace _var1 = subinstr(_var1,"`v'","",.)
		replace _var1 = subinstr(_var1,"_","",.)
	}
	rename _var1 Name
	replace Name =Name+group
	drop group
	gen year = `yr'
	order Name Variable year
	tempfile econActivity_`yr'
	save `econActivity_`yr''
}
clear
foreach yr in 1971 1981 1991 2001 2011{
	append using `econActivity_`yr''
}

foreach var in Padova Parma Reggio {
	destring(`var'), replace
}

cd $output_data
save economic_activity, replace
