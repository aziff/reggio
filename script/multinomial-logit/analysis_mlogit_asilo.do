/*
Project:		Reggio Evaluation
Authors:		Anna Ziff
Date:			November 5, 2016

This file:		Multinomial logit for selection with interactions
Useful:			http://www.stata.com/support/faqs/statistics/chi-squared-and-f-distributions/
			http://www.stata.com/manuals13/rtest.pdf
			http://www.stata.com/manuals13/u13.pdf
*/


cap log close
clear all
set more off
set maxvar 3000

global klmReggio 	:	env klmReggio
global git_reggio	:	env git_reggio
global data_reggio	: 	env data_reggio
global code			= 	"${git_reggio}/script"

// bring in project-level macros
cd $code
include macros

global output		= 	"${git_reggio}/output"

// prepare variables needed for PSM
cd $data_reggio
use Reggio_reassigned, clear

gen Cohort_tmp = Cohort
replace Cohort_tmp = 1 if Cohort == 1 | Cohort == 2
gen migrant_tmp = (Cohort == 2)

gen grouping = .
replace grouping = 0 if asiloType == 0 // NONE
replace grouping = 1 if asiloType > 1  // OTHER
replace grouping = 2 if asiloType == 1 // MUNICIPAL
lab var grouping ""
								
// define baseline variables			
global child_baseline_vars		Male lowbirthweight birthpremature 	///
					momMaxEdu_UniorGrad			///
					cgReddito_above50k 			///
					cgCatholic int_cgCatFaith		///
					momBornProvince migrant 		///
					numSibling_2 numSibling_more	
								
								
global adol_baseline_vars		Male lowbirthweight birthpremature 	///
					momMaxEdu_UniorGrad 			///
					cgReddito_above50k 			///
					cgCatholic int_cgCatFaith		///
					momBornProvince cgMigrant		///
					numSibling_2 numSibling_more 

					 
global adult_baseline_vars		Male  					///
					momMaxEdu_HS momMaxEdu_UniorGrad	///
					cgRelig					///
					momBornProvince dadBornProvince		///
					numSibling_2 numSibling_more

local lowbirthweight_n 			"Lowbirthweight"
local birthpremature_n			"Premature"
local momMaxEdu_UniorGrad_n 		"MomatleastUni"
local cgReddito_above50k_n 		"Incomeatleast50000"
local cgCatholic_n			"Catholiccaregiver"
local cgIslam_n				"Islamiccaregiver"
local momBornProvince_n			"Momborninprovince"
local migrant_n				"Migrant"
local numSibling_2_n			"Atleast2siblings"
local numSibling_more_n			"Morethan2siblings"
local Male_n				"Male"
local cgMigrant_n			"Migrantcaregiver"
local momMaxEdu_HS_n			"Momonlyhighschool"
local cgRelig_n				"Religiouscaregiver"
local dadBornProvince_n			"Dadborninprovince"
local int_cgCatFaith_n			"ReligCathcaregiver"

foreach a in child adol adult {				
	global `a'_mlogit			
	foreach v in $`a'_baseline_vars {
		global `a'_mlogit $`a'_mlogit `v'##City
	}
	
	global `a'_table
	global `a'_names
	foreach v in $`a'_baseline_vars {
		if "`v'" == "City" {
			global `a'_table $`a'_table 2.`v' 3.`v'
			global `a'_names $`a'_names Parma Padova
		}
		else {
			global `a'_table $`a'_table 1.`v' 1.`v'#2.City 1.`v'#3.City
			global `a'_names $`a'_names ``v'_n' ``v'_n'xParma ``v'_n'xPadova
		}
	}
	local n`a' : word count ${`a'_table}
}
					 
/*								
foreach var in $adult_baseline_vars {
	lab var `var' "${`var'_lab}"
}
*/

gen momMaxEdu_UniorGrad = (momMaxEdu_Uni == 1 | momMaxEdu_Grad == 1)
gen cgReddito_above50k	= (cgReddito_5 == 1 | cgReddito_6 == 1 | cgReddito_7 == 1)

// multinomial analysis
local cohort_val = 1	// change number if adding in other cohorts
foreach cohort in Child Adolescent Adult30 Adult40 {
	if "`cohort'" == "Adolescent" {
		local cohort_val = 3
		local cohort_short "adol"
	}
	else if "`cohort'" == "Child" {
		local cohort_short "child"
	}
	else {
		local cohort_short "adult"
	}
		
	// multinomial logit
	mlogit grouping ${`cohort_short'_mlogit} if Cohort_tmp == `cohort_val', baseoutcome(2) iterate(20)
	local `cohort_short'_conv = e(converged)
	matrix B = e(b)
	matrix V = e(V)
	foreach eq in 0 1 {
		foreach v in ${`cohort_short'_baseline_vars} {
			test [`eq']_b[1.`v'#2.City] = [`eq']_b[1.`v'#3.City]
			local `v'testp`eq' = r(p)
		}
	}
	
	// write table
	file open tabfile using "${output}/mlogit_asilo_`cohort'.tex", replace write
	file write tabfile "\begin{tabular}{l c c c}" _n
	file write tabfile "\toprule" _n
	file write tabfile "& None & Other \\" _n
	file write tabfile "\midrule" _n
	
	forvalues i = 1/`n`cohort_short'' {
		local v : word `i' of ${`cohort_short'_table}
		local vn : word `i' of ${`cohort_short'_names}
		forval j = 0/1 {
			local b`vn'`j' = [`j']_b[`v']
			local se`vn'`j' = [`j']_se[`v']
			foreach s in b se {
				local `s'`vn'`j' : di %9.3f ``s'`vn'`j'' 
			}
			local t`vn'`j' = `b`vn'`j''/`se`vn'`j''
			if abs(`t`vn'`j'') >= 1.64 {
				local b`vn'`j' `b`vn'`j''*
			}
			if (strlen("`vn'") > 5 & substr("`vn'", -5, .) == "Parma") | (strlen("`vn'") > 6 & substr("`vn'", -6, .) == "Padova") {
				foreach z in ${`cohort_short'_baseline_vars} {
					local n = strlen("`z'")
					if substr("`v'", 3, `n') == "`z'" {
						if ``z'testp`j'' <= 0.1 {
							local b`vn'`j' "\textbf{`b`vn'`j''}"
						}
					}
				}
			}
		}
			
		file write tabfile "`vn' & `b`vn'0' & `b`vn'1' \\" _n
	}
	
	file write tabfile "\bottomrule" _n
	file write tabfile "\end{tabular}" _n
	file write tabfile "% This mlogit converged? ``cohort_short'_conv'" _n
	file write tabfile "% This file is generated using reggio/script/multinomial-logit/analysis_mlogit_interaction.do" _n
	file close tabfile
		
	local cohort_val = `cohort_val' + 1
}
