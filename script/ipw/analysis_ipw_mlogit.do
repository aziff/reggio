/*
Project:		Reggio Evaluation
Authors:		Chiara Pronzato, Anna Ziff
Date:			November 5, 2016

This file:		Propensity score matching for all cohorts
				Old results with previous set of outcomes and controls
*/

cap log close
set more off

global bootstrap = 10
set seed 1234

global klmReggio 	:	env klmReggio
global git_reggio	:	env git_reggio
global data_reggio	: 	env data_reggio
global output	= 	"${git_reggio}/output/psm"
global code			= 	"${git_reggio}/script"

// bring in project-level macros
cd $code
include macros

// bring in function
cd ${code}/ipw/function
include ipwmlogitweight

// DATA PREPARATION

// prepare variables needed for PSM
cd $data_reggio
use Reggio_prepared, clear

cd $output
gen nido 		= (asilo == 1)
replace nido 	= . if(asilo > 3)

drop if(ReggioAsilo == . | ReggioMaterna == .)

gen sample1 			= (Reggio == 1)
gen sample_nido2 		= ((Reggio == 1 & ReggioAsilo == 1) 	| (Parma == 1) | (Padova == 1))
gen sample_materna2 	= ((Reggio == 1 & ReggioMaterna == 1) 	| (Parma == 1) | (Padova == 1))
gen sample3 			= (Reggio == 1 	| Parma == 1)
gen sample4 			= (Reggio == 1 	| Padova == 1)

// DEFINE D
gen D = .
replace D = 2 if (ReggioMaterna == 0) & (maternaType == 0)
replace D = 1 if (ReggioMaterna == 0) & (maternaType > 0)
replace D = 0 if (ReggioMaterna == 1)

gen D0 = (D == 0)
gen D1 = (D == 1)
gen D2 = (D == 2)

// ANALYSIS
global adult_baseline_vars		Male ///
					momMaxEdu_low momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni  ///
					numSibling_2 numSibling_more

local child_cat_groups	CN S H B 
local adol_cat_groups	CN S H B
local adult_cat_groups 	E W L H N S R

local child_cohorts		Child Migrant
local adol_cohorts		Adolescent
local adult_cohorts		Adult30 Adult40 //Adult50

local nido_var			ReggioAsilo
local materna_var		ReggioMaterna

local Child_num 		= 1
local Migrant_num 		= 2
local Adolescent_num 	= 3
local Adult30_num 		= 4
local Adult40_num 		= 5
local Adult50_num 		= 6

// only look in Reggio Emilia
keep if City == 1


foreach group in /*child adol*/ adult { 							// group: children, adol, adults
	foreach school in /*nido*/ materna {							// school: asilo, materna 
		// loop through outcome categories
		foreach cat in ``group'_cat_groups' {
		
			// open and prepare file
			cap file close tabfile`cat'
			file open tabfile`cat' using "ipw_mlogit`group'_`cat'.tex", write replace
			file write tabfile`cat' "\begin{tabular}{l c c c c c}" _n
			file write tabfile`cat' "\toprule" _n
			file write tabfile`cat' " & \mc{2}{c}{Adults 30s} & \mc{2}{c}{Adults 40s} \\" _n
			file write tabfile`cat' " & No Preschool & Other Preschool & No Preschool & Other Preschool \\" _n
			
			// loop through outcomes
			foreach outcome in ${`group'_outcome_`cat'} { 
				di "OUTCOME: `outcome'"
				foreach cohort in ``group'_cohorts' {			
					matrix `outcome'`cohort' = J(1,2,.)
					// bootstrap
					forvalues b = 0/$bootstrap {
						preserve
						keep if Cohort == ``cohort'_num'
						if `b' != 0 { // 0 is point estimate with original sample
							bsample, strata(Male)
						}
							// predict probabilities and generate weights
							qui mlogit D ${`group'_baseline_vars}, base(2) vce(robust) iterate(30)
							if e(converged) {		// only proceed if converged
								if e(k_eq) == 3 { 	// only proceed if 3 outcomes
									gen weight = .
				
									forvalues d = 0/2 {
									
										predict Dhat``cohort'_num'`d', outcome(`d')
										replace weight = (1 / Dhat``cohort'_num'`d') if D == `d' 
									}
							
									// regress outcome on controls
									forvalues d = 0/2 {
										qui reg `outcome' ${`cohort'_baseline_vars} CAPI if D == `d'
										
										predict Yhat`d' 
									}
					
									// calculate estimator
									gen tmp2 = Yhat2 + D2/weight * (`outcome' - Yhat2)
									forvalues d = 0/1 {
								
										gen tmp`d' = Yhat`d' + D`d'/weight * (`outcome' - Yhat`d') 
									
										gen dr`d'`outcome'``cohort'_num' = tmp2 - tmp`d'
										di "results for D = `d'"
										sum dr`d'`outcome'``cohort'_num'
									}
				
									// store result
									collapse dr0`outcome'``cohort'_num' dr1`outcome'``cohort'_num' 
								
									// save point estimate
									if `b' == 0 {
										forvalues d = 0/1 {
											local a = `d' + 1 // because matrix changes it
											sum dr`d'`outcome'  
											local p`a'`outcome'`cohort' = r(mean)
										}
									}
							
									mkmat dr0`outcome'``cohort'_num' dr1`outcome'``cohort'_num', matrix(tmp)
								
									matrix `outcome'`cohort' = (`outcome'`cohort' \ tmp)
									matrix drop tmp
									matrix list `outcome'`cohort'
								}
							}
							restore
						}
						// calculate mean/se over bootstraps for each outcome and cohort
						preserve	
							clear
							svmat `outcome'`cohort'
							
							forval i = 1/2 {
								sum `outcome'`cohort'`i'
								
								local m`outcome'`cohort'`i' = r(mean)
								local s`outcome'`cohort'`i' = r(sd)
								local m`outcome'`cohort'`i' : di %9.2f `m`outcome'`cohort'`i''
								local s`outcome'`cohort'`i' : di %9.2f `s`outcome'`cohort'`i''
								
								// calculate pvalue 
								gen i`i' = .
								replace i`i' = 1 if abs(`outcome'`cohort'`i' - `m`outcome'`cohort'`i'') > abs(`p`i'`outcome'`cohort'') & `outcome'`cohort'`i' != . 
								sum i`i'
								if r(mean) <= 0.1 {
									local m`outcome'`cohort'`i' "\textbf{`m`outcome'`cohort'`i''}"
								}
								di "pvalue"
								di r(mean)
							}
						restore
						if ``cohort'_num' == 5 {
							di "${`outcome'_lab}"
							file write tabfile`cat' "${`outcome'_lab} & `m`outcome'Adult301' & `m`outcome'Adult302' & `m`outcome'Adult401' & `m`outcome'Adult402' \\" _n
							file write tabfile`cat' "	& (`s`outcome'Adult301') & (`s`outcome'Adult302') & (`s`outcome'Adult401') & (`s`outcome'Adult402') \\" _n
						}
					}
				}
			file write tabfile`cat' "\bottomrule" _n
			file write tabfile`cat' "\end{tabular}" _n
			file close tabfile`cat'
		}
	}
}
