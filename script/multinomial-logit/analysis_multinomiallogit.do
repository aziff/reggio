/*
Project:		Reggio Evaluation
Authors:		Anna Ziff
Date:			November 5, 2016

This file:		Multinomial logit for selection

Functions to install:	parmest
			texsave
*/


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

gen grouping = .
replace grouping = 0 if maternaType == 0
replace grouping = 1 if maternaType == 1
replace grouping = 2 if maternaType > 1
lab var grouping ""
								
								 
global adult_baseline_vars		Male  ///
								momBornProvince ///
								dadBornProvince  ///
								numSibling_1 numSibling_2 numSibling_more cgRelig ///
								momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni  
								
foreach var in $adult_baseline_vars {
	lab var `var' "${`var'_lab}"
}

local city_val = 1
foreach city in Reggio /*Parma Padova*/ {
	local cohort_val = 4
	foreach cohort in /*Child Adolesecent*/ Adult30 Adult40 {
		
		mlogit grouping $adult_baseline_vars if Cohort_tmp == `cohort_val' & City == `city_val', baseoutcome(1) iterate(20)
		eststo, title(`city'`cohort')
		
		preserve
			// put results from lmogit into dataset
			parmest, norestore omit empty label 
			
			// drop if omitted or empty
			drop if omit == 1 | empty == 1
			
			// drop some unecessary variables
			drop parm omit empty min95 max95 z
			
			// reshape
			reshape wide estimate stderr p, i(label) j(eq) string
			
			// bring standard errors below
			rename estimate0 est0`cohort_val'_1
			rename stderr0 est0`cohort_val'_2
			rename estimate2 est2`cohort_val'_1
			rename stderr2 est2`cohort_val'_2
			
			gen N = _n
			reshape long est0`cohort_val'_ est2`cohort_val'_ , i(N) j(type) 
			drop N
			format est* %9.3f
			
			if "`cohort'" == "Adult30" {
				tempfile `city'`cohort'
				save	``city'`cohort''
				restore
			}
			else {
				merge 1:1 type label using ``city'Adult30'
				order est04_ est24_ est05_ est25_
				sort type label
				
				// export
				mkmat est*, matrix(`city')
				tostring(type), replace
				gen row = label + type
				levelsof row, local(row)
				matrix rownames `city' = `row'
				matrix list `city'
				esttab matrix(`city') using /home/aziff/Desktop/test2.tex, replace
			}
		local cohort_val = `cohort_val' + 1
	}
	local city_val = `city_val' + 1
}
