/*
Project:		Reggio Evaluation
Authors:		Anna Ziff
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

gen D = .
replace D = 2 if (ReggioMaterna == 0) & (maternaType == 0)
replace D = 1 if (ReggioMaterna == 0) & (maternaType > 0)
replace D = 0 if (ReggioMaterna == 1)

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
