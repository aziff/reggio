* ------------------------*---------------------------------------------------- *
* Drawing Density Plots for 
* Authors: Sidharth Moktan
* Created: 10/07/2016
* Edited: 10/07/2016
* ---------------------------------------------------------------------------- *
clear all
set more off

global klmReggio	: 	env klmReggio		
global data_reggio	: 	env data_reggio
global git_reggio	:	env git_reggio
global output		= 	"${git_reggio}/Output"

*-----------------------------------------------------------------------------------------
include "${klmReggio}/data_other/Demographics_data_working/Sidharth/script/prepare_dataForTable"

gen sort_order = 0
replace sort_order = 1 if strpos(Name,"Employed ")>0 
replace sort_order = 2 if strpos(Name,"Unemployed ")>0 
replace sort_order = 3 if strpos(Name,"Homemaker ")>0 
replace sort_order = 4 if strpos(Name,"Pensioner ")>0
replace sort_order = 5 if strpos(Name,"Student ")>0
replace sort_order = 6 if strpos(Name,"Other ")>0

local lab_economic_activity Employment
local lab_educational_attainment Education
local lab_Industry Industry
tempfile preparedData
save `preparedData'
*-----------------------------------------------------------------------------------------
foreach c in Reggio Parma Padova{
	foreach y in 1971 1981 1991 2001 2011{
		use `preparedData', clear
		keep Name `c'`y' sex source
		rename `c'`y' value
		gen year = `y'
		gen city = "`c'"
		
		tempfile interm`c'`y'
		save `interm`c'`y''
	}
}
clear all
foreach c in Reggio Parma Padova{
	foreach y in 1971 1981 1991 2001 2011{
		append using `interm`c'`y''
	}
}

format Name %50s
order Name year
label var Name ""
label var value ""

tempfile master
save `master'

*-----------------------------------------------------------------------------------------
foreach s in /*Industry*/ MaritalStatus /*Population RentedProperties demographic_balance economic_activity educational_attainment*/{
	foreach c in Reggio Parma Padova{
		foreach y in  2001 /*1981 1991 2001 2011*/{
			use `master', clear
			keep if source == "`s'" & city == "`c'" & year == `y' & sex == "Both"
			
			local numVars = _N
			sxpose, clear destring force
			foreach var of varlist * {
				label variable `var' "`=`var'[1]'"
			}
			
			gen n = _n
			destring * , force replace
			local graph_body
			forvalues v = 1/`numVars'{
				if (`v' == `numVars') local graph_body `graph_body' bar _var`v' n in 3
				if (`v' != `numVars') local graph_body  `graph_body' bar _var`v' n in 3 || 
			}
			di "`graph_body'"
			
		}
	}	
}

