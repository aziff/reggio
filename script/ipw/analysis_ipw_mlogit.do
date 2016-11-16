/*
Project:		Reggio Evaluation
Authors:		Chiara Pronzato, Anna Ziff
Date:			November 5, 2016

This file:		Propensity score matching for all cohorts
				Old results with previous set of outcomes and controls
*/

cap log close
set more off

global bootstrap = 3

global klmReggio 	:	env klmReggio
global git_reggio	:	env git_reggio
global data_reggio	: 	env data_reggio
global output_psm	= 	"${git_reggio}/output/psm"
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

foreach group in /*child adol*/ adult { 							// group: children, adol, adults
	foreach school in /*nido*/ materna {							// school: asilo, materna 
		foreach cohort in ``group'_cohorts' {						// ``group'_cohorts'  cohort: childeren, adolescent, adults 30s, adults 40s, adults 50s
			
					// loop through outcomes
					foreach cat in ``group'_cat_groups' {					// outcome category (differs by group)			
			
						foreach outcome in ${`group'_outcome_`cat'} { 		// outcome (differs by outcome category)
							matrix `outcome'`cohort' = J(${bootstrap},1,.)
							// bootstrap
							forvalues b = 0/$bootstrap {
							preserve
								if `b' != 0 { // 0 is point estimate with original sample
									bsample N
								}
								
								// predict probabilities and generate weights
								mlogit D ${`group'_outcome_`cat'} if Cohort == ``cohort'_num'
								
								drop weight_Cohort``cohort'_num'
								gen weight_Cohort``cohort'_num' = .
				
								forvalues d = 0/2 {
									
									predict Dhat``cohort'_num'`d' 									if Cohort == ``cohort'_num', outcome(`d')
									replace weight_Cohort``cohort'_num' = (1 / Dhat``cohort'_num'`d') if D == `d' & Cohort == ``cohort'_num'
								}
							
								// regress outcome on controls
								forvalues d = 0/2 {
									reg `outcome' ${`cohort'_baseline_vars} CAPI if Cohort == ``cohort'_num' & D == `d'
									
									predict Yhat`d' if Cohort == ``cohort'_num'
								}
					
								// calculate estimator
								gen tmp2 = Yhat2 + D2/weight_Cohort``cohort'_num' * (`outcome' - Yhat2)
								forvalues d = 0/1 {
								
									gen tmp`d' = Yhat`d' + D`d'/weight_Cohort``cohort'_num' * (`outcome' - Yhat`d')
									
									gen dr`d'`outcome'``cohort'_num' = tmp2 - tmp`d'
								}
				
								// store result
								collapse dr0`outcome'``cohort'_num' dr1`outcome'``cohort'_num' if Cohort == ``cohort'_num'
								
								mkmat dr`outcome'``cohort'_num', matrix(tmp)
								
								matrix `outcome'``cohort'_num' = (`outcome'``cohort'_num' \ tmp)
								matrix drop tmp
								
								// drop variables for this bootstrap
								drop Dhat* Yhat* tmp* dr*
					
							restore
						}

						// calculate mean for each outcome and cohort
						matrix list `outcome'``cohort'_num'
							
						// calculate standard error for each outcome and cohort
				}
			}
		}
	}
}
