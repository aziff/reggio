/*
Project:		Reggio Evaluation
Authors:		Chiara Pronzato, Anna Ziff
Date:			November 5, 2016

This file:		Propensity score matching for all cohorts
				Old results with previous set of outcomes and controls
*/

cap log close
set more off



global klmReggio 	:	env klmReggio
global git_reggio	:	env git_reggio
global data_reggio	: 	env data_reggio
global output_psm	= 	"${git_reggio}/output/psm"
global code			= 	"${git_reggio}/script"

// bring in project-level macros
cd $code
include macros

// bring in function
cd ${code}/psm/function
include psmweight


// DATA PREPARATION

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

gen sample1 			= (Reggio == 1)
gen sample_nido2 		= ((Reggio == 1 & ReggioAsilo == 1) 	| (Parma == 1) | (Padova == 1))
gen sample_materna2 	= ((Reggio == 1 & ReggioMaterna == 1) 	| (Parma == 1) | (Padova == 1))
gen sample3 			= (Reggio == 1 	| Parma == 1)
gen sample4 			= (Reggio == 1 	| Padova == 1)
			
// ANALYSIS
cap log close
local day=subinstr("$S_DATE"," ","",.)
log using "${code}/psm/PSM`day'pweight", replace


local child_cat_groups	CN S H B 
local adol_cat_groups	CN S H B
local adult_cat_groups 	E W L H N S R

local child_cohorts		Child Migrant
local adol_cohorts		Adolescent
local adult_cohorts		Adult30 Adult40 Adult50

local nido_var			ReggioAsilo
local materna_var		ReggioMaterna

local Child_num 		= 1
local Migrant_num 		= 2
local Adolescent_num 	= 3
local Adult30_num 		= 4
local Adult40_num 		= 5
local Adult50_num 		= 6

foreach group in /*child adol*/ adult { 						// group: children, adol, adults
	foreach school in nido materna {							// school: asilo, materna 
		foreach cohort in ``group'_cohorts' {					// ``group'_cohorts'  cohort: childeren, adolescent, adults 30s, adults 40s, adults 50s
			foreach cat in ``group'_cat_groups' {				// outcome category (differs by group)			
			
				foreach outcome in ${`group'_outcome_`cat'} { 	// outcome (differs by outcome category)
					
				preserve
					di "*---------------------------------------------------------------------------------------------*"
					di "Cohort `cohort_val', outcome `outcome' "
					
					// check that the probit will be possible
					sum ``school'_var' if Reggio == 1 & Cohort == ``cohort'_num'
					if r(mean) > 0 {
					
						psmweight, yvar("``school'_var'") xvars(${`cohort'_baseline_vars}) cohort_num(``cohort'_num') school_type("`school'")
						tab weight
						
						// use weights in regression
						reg `outcome' ``school'_var' `school' ${`cohort'_baseline_vars} [pweight = weight] if (sample_`school'2 == 1 & Cohort == ``cohort'_num'), robust
					
						/*
						// delete current file
						capture confirm file "${output}/`cat'_`school'_`cohort'.tex"
						if !_rc {
							erase "${output}/`cat'_`school'_`cohort'.tex"
						}

						# delimit ;
						cd ${output};
						outreg2 using "`cat'_`school'_`cohort'.tex", 
								append
								tex(frag) 
								bracket 
								dec(3) 
								ctitle("${`outcome'_lab}") 
								keep(``school'_var')
								alpha(.01, .05, .10) 
								sym (***, **, *);
								//addtext(Sample, RAvsPP, Mean, `varmean');
						# delimit cr
						*/
					}				
				restore
				}
			}
		}
	}
}
