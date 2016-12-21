/*
Project:		Reggio Evaluation
Authors:		Anna Ziff
Date:			November 5, 2016

This file:		Multinomial logit for selection
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
replace grouping = 0 if maternaType == 0 // NONE
replace grouping = 1 if maternaType > 1  // OTHER
replace grouping = 2 if maternaType == 1 // MUNICIPAL
lab var grouping ""
								
// define baseline variables			
global child_baseline_vars  		Male lowbirthweight birthpremature ///
					momBornProvince dadBornProvince ///
					momMaxEdu_low momMaxEdu_middle momMaxEdu_HS   ///
					dadMaxEdu_low dadMaxEdu_middle dadMaxEdu_HS  ///
					numSibling_2 numSibling_more ///
					cgCatholic cgIslam cgRelig ///
					cgMigrant 
								
								
global adol_baseline_vars		Male lowbirthweight birthpremature ///
					momBornProvince dadBornProvince ///
					momMaxEdu_low momMaxEdu_middle momMaxEdu_HS   ///
					dadMaxEdu_low dadMaxEdu_middle dadMaxEdu_HS  ///
					numSibling_2 numSibling_more ///
					cgCatholic cgIslam cgRelig ///
					cgMigrant 

					 
global adult_baseline_vars		Male  ///
					momBornProvince ///
					dadBornProvince  ///
					numSibling_2 numSibling_more cgRelig ///
					momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni  
								
foreach var in $adult_baseline_vars {
	lab var `var' "${`var'_lab}"
}


// multinomial analysis
local city_val = 1
foreach city in Reggio Parma Padova {
	local cohort_val = 1	// change number if adding in other cohorts
	foreach cohort in Child Adolescent Adult30 Adult40 {
		if ("`cohort'" == "Adult40" & "`city'" == "Reggio") | ("`cohort'" != "Adult40") {
		
		
			if "`cohort'" == "Adolescent" {
				local cohort_val = 3
			}
		
			// multinomial logit
			if "`cohort'" == "Adult30" | "`cohort'" == "Adult40" {
				mlogit grouping $adult_baseline_vars if Cohort_tmp == `cohort_val' & City == `city_val', baseoutcome(2) iterate(20)
			}
			else if "`cohort'" == "Adolescent" {
				mlogit grouping $adol_baseline_vars if Cohort_tmp == `cohort_val' & City == `city_val', baseoutcome(2) iterate(20)
			}
			else {
				mlogit grouping $child_baseline_vars if Cohort_tmp == `cohort_val' & City == `city_val', baseoutcome(2) iterate(20)
			}
			eststo `city'`cohort'
		
			// calculate marginal effects
			forvalues o = 0/2 {
				margins, dydx(*) predict(outcome(`o')) post
				eststo `city'`cohort'`o', title(Outcome `o')
				estimates restore `city'`cohort'
			}
			//eststo drop `city'`cohort'
			// write child/adolescent table
			if "`cohort'" == "Adolescent"  {
				cd "${output}"
				# delimit ;
				esttab `city'Child0 `city'Child1 `city'Child2 `city'Adolescent0 `city'Adolescent1 `city'Adolescent2 using "mlogit_`city'_chi-ado.tex", 
						b(3)
						booktabs
						label
						unstack 
						nonumbers
						nonotes
						se
						mtitles("None" "Other" "Municipal" "None" "Other" "Municipal")
						replace;
				# delimit cr
			}
			
			
			// write adult table
			if "`cohort'" == "Adult40"  {
				cd "${output}"
				# delimit ;
				esttab `city'Adult300 `city'Adult301 `city'Adult302 `city'Adult400 `city'Adult401 `city'Adult402 using "${output}/mlogit_`city'.tex", 
						b(3)
						booktabs
						label
						unstack 
						nonumbers
						nonotes
						se
						mtitles("None" "Other" "Municipal" "None" "Other" "Municipal")
						replace;
				# delimit cr
			}
		}
		else {
			cd "${output}"
			# delimit ;
			esttab `city'Adult300 `city'Adult301 `city'Adult302 using "${output}/mlogit_`city'.tex", 
					b(3)
					booktabs
					label
					unstack 
					nonumbers
					nonotes
					se
					mtitles("None" "Other" "Municipal")
					replace;
				# delimit cr
		}
		local cohort_val = `cohort_val' + 1

	}
	local city_val = `city_val' + 1
}
