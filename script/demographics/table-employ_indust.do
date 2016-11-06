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
file open OLS using "${output}/table_employment_industry.tex", write replace
file write OLS "\begin{landscape}" _n
file write OLS "\begin{table}[ht!]" _n
file write OLS "\begin{center}" _n
file write OLS "\scriptsize{" _n
file write OLS "\caption{Proportion of individuals in different employment and industry categories (city-level data)} \label{table:demo-employ}" _n
file write OLS "\begin{tabular}{L{6.5cm} *{3}{*{5}{c} c}}" _n
file write OLS "\hline \\[-7pt]" _n
file write OLS "& \multicolumn{5}{c}{\textbf{Reggio}} & & \multicolumn{5}{c}{\textbf{Parma}} & & \multicolumn{5}{c}{\textbf{Padova}} \\[3pt]" _n
file write OLS "& \textbf{1971} & \textbf{1981} & \textbf{1991} & \textbf{2001} & \textbf{2011} & & \textbf{1971} & \textbf{1981} & \textbf{1991} & \textbf{2001} & \textbf{2011} & & \textbf{1971} & \textbf{1981} & \textbf{1991} & \textbf{2001} & \textbf{2011} \\[3pt]" _n
file write OLS "\hline \\" _n

foreach s in economic_activity Industry{
	use `preparedData', clear
	keep if source == "`s'" 
	sort source sort_order Name sex
	local Obs = _N
	forvalues i = 1/`Obs'{
		local element`i' = Name[`i']
		local row_`i' `element`i''

		foreach city in Reggio Parma Padova{
			foreach yr in 1971 1981 1991 2001 2011{
				local element :di %3.2f `= `city'`yr'[`i']'
				local row_`i' `row_`i'' & `element'
			}
			local row_`i' `row_`i'' &
		}
	}
	
	file write OLS "\textbf{`lab_`s''}\\" _n	
	forvalues i = 1/`Obs'{
		if (sex[`i'] == "Male") local newlineCond \\[5pt]
		if (sex[`i'] != "Male") local newlineCond \\

		file write OLS "\quad `row_`i'' `newlineCond' " _n
	}
}

file write OLS "\hline \\[-7pt]" _n
file write OLS "\multicolumn{19}{L{24cm}}{\textbf{Note:} This table presents the percentage of individuals in different employment and industry categories within each city during each of the 5 listed years. Percentages are reported for females (F), males (M), and both genders (B) combined. The percentages are calculated using the total number of individuals above age 15 for the denominator.}" _n
file write OLS "\end{tabular}" _n
file write OLS "}" _n
file write OLS "\end{center}" _n
file write OLS "\end{table}" _n
file write OLS "\end{landscape}" _n
file close OLS
