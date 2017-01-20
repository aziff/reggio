/* --------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - OLS and Diff-in-Diff for Adult Cohorts
* Authors: Jessica Yu Kyung Koh
* Created: 06/16/2016
* Edited:  10/31/2016

* Note: This execution do file performs diff-in-diff estimates and generates tables
        by using "multipleanalysis" command that is programmed in 
		"reggio/script/ols/function/multipleanalysis.do"  
		To understand how the command is coded, please refer to the above do file.
* --------------------------------------------------------------------------- */

clear all

cap file 	close outcomes
cap log 	close

global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio

global here : pwd

use "${data_reggio}/Reggio_reassigned"

* Include scripts and functions
include "${here}/../macros" 

/*
* ---------------------------------------------------------------------------- *
* 					Reggio Muni vs. All:	Children		 				   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
preserve
keep if (Cohort == 1) | (Cohort == 2) 

* Set necessary global variables
local	outcomes			/*pos_childSDQ_score*/ BMI_obese	
local	controls			${bic_child_baseline_vars}

levelsof internr, local(list_interviewer)

foreach out in `outcomes' {
	foreach i in `list_interviewer' {
		di "for outcome: `outcome' and interviewer `i'"
		regress `out' maternaMuni `controls' if (internr != `i') & (Reggio == 1) & (maternaMuni == 1 | maternaOther == 1)
		estimates store `out'`i'
		local interview`out' `interview`out'' `out'`i' ||
		local labels`out' `labels`out'' `i'
	}
}

di "interviewpos_childSDQ_score: `interviewpos_childSDQ_score'"

foreach out in `outcomes' {
	coefplot `interview`out'', keep(maternaMuni) vertical bycoefs bylabels(`labels`out'')
}
restore
*/

* ---------------------------------------------------------------------------- *
* 					Reggio Muni vs. All:	Adolescent		 				   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
preserve
keep if (Cohort == 3) 

* Set necessary global variables
local	outcomes			pos_childSDQ_score /*BMI_obese*/
local	controls			${bic_adol_baseline_vars}

levelsof internr, local(list_interviewer)

foreach out in `outcomes' {
	foreach i in `list_interviewer' {
		di "for outcome: `outcome' and interviewer `i'"
		regress `out' maternaMuni `controls' if (internr != `i') & (Reggio == 1) & (maternaMuni == 1 | maternaOther == 1)
		estimates store `out'`i'
		local interview`out' `interview`out'' `out'`i' ||
		local labels`out' `labels`out'' `i'
	}
}

di "interviewpos_childSDQ_score: `interviewpos_childSDQ_score'"

foreach out in `outcomes' {
	coefplot `interview`out'', keep(maternaMuni) vertical bycoefs bylabels(`labels`out'')
}
restore

/*
* ---------------------------------------------------------------------------- *
* 					Reggio:	Adult-30						 				   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
preserve
keep if (Cohort == 4) 
drop if asilo == 1 

* Set necessary global variables
local	outcomes			/*votoMaturita*/ BMI_obese
local	controls			${bic_adult_baseline_vars}

levelsof internr, local(list_interviewer)

foreach out in `outcomes' {
	foreach i in `list_interviewer' {
		di "for outcome: `outcome' and interviewer `i'"
		regress `out' maternaMuni `controls' if (internr != `i') & (Reggio == 1) & (maternaMuni == 1 | maternaOther == 1)
		estimates store `out'`i'
		local interview`out' `interview`out'' `out'`i' ||
		local labels`out' `labels`out'' `i'
	}
}

foreach out in `outcomes' {
	coefplot `interview`out'', keep(maternaMuni) vertical bycoefs bylabels(`labels`out'')
}
restore 

* ---------------------------------------------------------------------------- *
* 					Reggio:	Adult-40						 				   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
preserve
keep if (Cohort == 5) 
drop if asilo == 1 

* Set necessary global variables
local	outcomes			votoMaturita /*BMI_obese*/
local	controls			${bic_adult_baseline_vars}

levelsof internr, local(list_interviewer)

foreach out in `outcomes' {
	foreach i in `list_interviewer' {
		di "for outcome: `outcome' and interviewer `i'"
		regress `out' maternaMuni `controls' if (internr != `i') & (Reggio == 1) & (maternaMuni == 1 | maternaOther == 1)
		estimates store `out'`i'
		local interview`out' `interview`out'' `out'`i' ||
		local labels`out' `labels`out'' `i'
	}
}

foreach out in `outcomes' {
	coefplot `interview`out'', keep(maternaMuni) vertical bycoefs bylabels(`labels`out'')
}
restore*/
