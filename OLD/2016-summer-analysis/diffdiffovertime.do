/**********************************************************
	
	Analyzing the Reggio Children Evaluation Survey
	
	Diff-in-Diff Comparison For Change over Time
	
	Author: Chase Owen Corbin (cocorbin@uchicago.edu)
	
	Created: 31 July 2016

	Edited:  31 July 2016

************************************************************/

clear all

cap file 	close outcomes
cap log 	close

global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio


use Reggio, clear

include "${git_reggio}/prepare-data"

** Dummy variables for Reggio vs Padova and Reggio vs Parma pooling all preschool types

local school "Municipal Pooled "
local adult "Age50 Age40 Age30"
local younger "Adolescent Children"
local city "Padova Parma"


foreach i in `city' {
replace `i' = . 
}

foreach y in `adult' {
gen `y' = .
}



** Standardizing IQ as rank in cumulative distribution

bys Cohort City CAPI: cumul IQ_score, gen(IQ_v1)


do did.do

/*
diffdiff.do contains a program written to estimate the difference in difference coefficients
and return two tables, one of the adjusted means, fixed effect estimates, and did-estimates
and one with coefficients for all covariates, fixed effects, and did-estimates.

the command is written to accept three arguments
	1. the older cohort

	2. the more recent cohort

	3. whether preschool categories should be pooled 
	or estimated only for municipal / state / religious schools

examples:

. DiffDiff Age50 Children Pooled

. DiffDiff Age30 Adolescent Municipal

The following loop does this for all possible combinations of Age 50 / Age 40 / Age 30
*/

foreach a in Age50 Age40 Age30 {
	foreach y in Children Adolescent {
		foreach s in Municipal Religious State Pooled {
		
		DiffDiff `a' `y' `s'
		
		}
	}
}



** Cleaning up created variables and returning Padova and Parma variables to original format

drop Age50 Age40 Age30 Padova Parma 

gen Padova = 1 if City == 3
replace Padova = 0 if City != 3
gen Parma = 1 if City == 2
replace Parma = 0 if City !=2

