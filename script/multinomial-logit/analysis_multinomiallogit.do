/*
Project:		Reggio Evaluation
Authors:		Anna Ziff
Date:			November 5, 2016

This file:		Multinomial logit for selection
*/

/*
cap log close
set more off

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
use Reggio_prepared, clear

gen Cohort_tmp = Cohort
replace Cohort_tmp = 1 if Cohort == 1 | Cohort == 2
gen migrant_tmp = (Cohort == 2)
*/ 						
								
								
global adult_baseline_vars		Male  ///
								momBornProvince ///
								dadBornProvince  ///
								numSibling_1 numSibling_2 numSibling_more cgRelig ///
								momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni  

local city_val = 1
foreach city in Reggio Parma Padova {
	local cohort_val = 4
	foreach cohort in /*Child Adolesecent*/ Adult30 Adult40 {
		
		mlogit maternaType $adult_baseline_vars if Cohort_tmp == `cohort_val' & City == `city_val', baseoutcome(1) iterate(20)
		
		outreg using "${output}/mlogit`city'`cohort'", replace  
		
		local cohort_val = `cohort_val' + 1
	}
	local city_val = `city_val' + 1
}
