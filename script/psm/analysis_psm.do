/*
Project:		Reggio Evaluation
Authors:		Chiara Pronzato, Anna Ziff
Date:			November 5, 2016

This file:		Propensity score matching for all cohorts
				Old results with previous set of outcomes and controls
*/
/*
cap log close
set more off

global klmReggio 	:	env klmReggio
global git_reggio	:	env git_reggio
global data_reggio	: 	env data_reggio
global output		= 	"${git_reggio}/Output/psm"
global code			= 	"${git_reggio}/script"

//local day=subinstr("$S_DATE"," ","",.)
//log using "${code}/psm/PSM`day'.log", text replace

// bring in project-level macros
cd $code
include macros

// prepare variables needed for PSM
cd $data_reggio
use Reggio_prepared, clear

cd $output
gen nido 		= (asilo == 1)
replace nido 	= . if(asilo > 3)

gen poorBHealth = (lowbirthweight == 1 | birthpremature==1) 

gen  oldsibs 	= 0

forvalues i = 3/10 {
	replace oldsibs = oldsibs + 1 * (Relation`i' == 11 & year`i' < 1994) 
}
replace oldsibs = 1 if oldsibs >= 1 & oldsibs < .

gen 	dadMaxEdu_Uni_F 	= dadMaxEdu_Uni
replace dadMaxEdu_Uni_F = 0 if dadMaxEdu_Uni == . 
gen 	dadMaxEdu_Uni_Miss 	= dadMaxEdu_Uni == .
gen 	momMaxEdu_Uni_F 	= momMaxEdu_Uni
replace momMaxEdu_Uni_F = 0 if momMaxEdu_Uni == .
gen 	momMaxEdu_Uni_Miss 	= momMaxEdu_Uni == .

tab 	cgIncomeCat, g(IncCat_)
gen 	HighInc 			= (IncCat_5==1 | IncCat_6==1) if !mi(cgIncomeCat)
gen 	HighInc_F 			= HighInc
replace HighInc_F 		= 0 if HighInc == .
gen 	HighInc_Miss 		= HighInc == .

gen 	houseOwn_F 			= houseOwn if(houseOwn! = .)
gen 	houseOwn_Miss 		= (houseOwn == .)
replace houseOwn_F 		= 0 if(houseOwn == .)

replace cgRelig 		= . if (cgRelig > 1)
gen 	cgRelig_F 			= cgRelig if (cgRelig != .)
gen 	cgRelig_Miss 		= (cgRelig == .)
replace cgRelig_F 		= 0 if (cgRelig == .)

local to_flip 	difficultiesSit difficultiesInterest difficultiesObey difficultiesEat 		///
				childAsthma_ childAllerg_ childDigest_ childEmot_diag childSleep_diag 		///
				childGums_diag childOther_diag childSnackNo childSnackCan childSnackRoll  	///
				childSnackChips childSnackOther worryMyself

foreach j in  `to_flip' {
	replace `j'= 1-`j'
} 

drop if(ReggioAsilo == . | ReggioMaterna == .)

gen sample1 		= (Reggio == 1)
gen sample_nido2 	= ((Reggio == 1 & ReggioAsilo == 1) 	| (Parma == 1) | (Padova == 1))
gen sample_materna2 	= ((Reggio == 1 & ReggioMaterna == 1) 	| (Parma == 1) | (Padova == 1))
gen sample3 		= (Reggio == 1 	| Parma == 1)
gen sample4 		= (Reggio == 1 	| Padova == 1)
*/

local child_cat_groups	CN S H B 
local adol_cat_groups	CN S H B
local adult_cat_groups 	E W L H N S R

local child_cohorts		Child
local adol_cohorts		Adolescent
local adult_cohorts		Adult30 Adult40 Adult50

local nido_var			ReggioAsilo
local materna_var		ReggioMaterna

foreach group in /*child adol*/ adult { 				// group: children, adol, adults
	foreach school in nido materna {					// school: asilo, materna 
		local cohort_val = 4
		foreach cohort in Adult30 Adult40 {			// ``group'_cohorts'  cohort: childeren, adolescent, adults 30s, adults 40s, adults 50s
			foreach cat in ``group'_cat_groups' {		// outcome category (differs by group)			
			
				foreach outcome in ${`group'_outcome_`cat'} { 	// outcome (differs by outcome category)
					
				preserve
					di "*---------------------------------------------------------------------------------------------*"
					di "Cohort `cohort_val', outcome `outcome' "
					// mean of var
					sum `outcome' if sample1 == 1 & Cohort == `cohort_val'
					local varmean =  round(r(mean),0.01) 
					
					// get weights
					probit ``school'_var' ${`cohort'_baseline_vars} if Reggio == 1 & Cohort == `cohort_val'
					
					qui predict pr_``school'_var' if sample_`school'2 == 1 & Cohort == `cohort_val'
					
					qui gen weight = (1 / pr_``school'_var') if ``school'_var' == 1 & Cohort == `cohort_val'
					qui replace weight = (1 / (1 - pr_``school'_var')) if ``school'_var' == 0
					
					// use weights
<<<<<<< 51900ee465c924369b62924f90b7662593f39e59
					reg `outcome' ``school'_var' `school' ${`cohort'_baseline_vars} [iweight = weight] if (sample_`school'2 == 1) 
					
					local check_file : dir "." file "${output}/`cat'_psm_`school'_`cohort'.tex"
					di "check file"
					di "`check_file'"
					if "`check_file'" != "" {
						rm "`check_file'"
					}
					
					cd ${output}
					# delimit ;
					outreg2 using "`cat'_psm_`school'_`cohort'.tex", 
=======
					reg `outcome' ``school'_var' `school' ${`cohort'_baseline_vars} [pweight = weight] if (sample_`school'2 == 1 & Cohort == `cohort_val'), robust
					# delimit ;

					outreg2 using "`cat'_`school'_`cohort'.csv", 
>>>>>>> Changes to the PSM pre-monday presentation. still something more to do
							append
							//tex(frag) 
							bracket 
							dec(3) 
							ctitle("${`outcome'_lab}") 
							keep(``school'_var')
							alpha(.01, .05, .10) 
							sym (***, **, *);
							//addtext(Sample, RAvsPP, Mean, `varmean');
					# delimit cr
				restore
				}
			}
		local cohort_val = `cohort_val' + 1
		}
	}
}
