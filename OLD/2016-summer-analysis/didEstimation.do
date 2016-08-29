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

foreach program in did_ReggioVsPadova.do did_ReggioParmaVsPadova.do{
	cd "$data_reggio"
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


	do "${git_reggio}/`program'"

	cd "$git_reggio"

	foreach s in Municipal Religious State Pooled {
			
		DiffDiff Age50 Age40 `s'
		DiffDiff Age50 Age30 `s'
		DiffDiff Age40 Age30 `s'

	}



	** Cleaning up created variables and returning Padova and Parma variables to original format

	drop Age50 Age40 Age30 Padova Parma 

	gen Padova = 1 if City == 3
	replace Padova = 0 if City != 3
	gen Parma = 1 if City == 2
	replace Parma = 0 if City !=2
}
