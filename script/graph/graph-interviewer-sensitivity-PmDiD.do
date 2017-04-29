/* --------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - OLS and Diff-in-Diff for Adult Cohorts
* Authors: Jessica Yu Kyung Koh
* Created: 06/16/2016
* Edited:  04/27/2017

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

	
	global XDidPm				xmMuniReggio
	global XDidPv				xmMuniReggio 	


	global controlsFull			${child_baseline_vars}
	global controlsDidPm		maternaMuni Reggio ${bic_child_baseline_did_vars}

/*
* ---------------------------------------------------------------------------- *
* 					Reggio Parma DiD:	Children			 				   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
preserve
keep if (Cohort == 1) | (Cohort == 2) 

* Set necessary global variables
local	outcomes			pos_childSDQ_score BMI_obese
local	controls			maternaMuni Reggio ${bic_child_baseline_did_vars}

levelsof internr, local(list_interviewer)

foreach out in `outcomes' {
	foreach i in `list_interviewer' {
		di "for outcome: `outcome' and interviewer `i'"
		regress `out' xmMuniReggio `controls' if (internr != `i') & (Reggio == 1 | Parma == 1) & (maternaMuni == 1 | maternaOther == 1)
		estimates store `out'`i'
		local interview`out' `interview`out'' `out'`i' ||
		local labels`out' `labels`out'' `i'
	}
}

foreach out in `outcomes' {
	coefplot `interview`out'', keep(xmMuniReggio) vertical bycoefs bylabels(`labels`out'')
}
restore


* ---------------------------------------------------------------------------- *
* 					Reggio Parma DiD:	Adolescent			 				   *
* ---------------------------------------------------------------------------- *

preserve
keep if (Cohort == 3) 

* Set necessary global variables
local	outcomes			pos_childSDQ_score BMI_obese	
local	controls			maternaMuni Reggio ${bic_adol_baseline_did_vars}

levelsof internr, local(list_interviewer)

foreach out in `outcomes' {
	foreach i in `list_interviewer' {
		di "for outcome: `outcome' and interviewer `i'"
		regress `out' xmMuniReggio `controls' if (internr != `i') & (Reggio == 1 | Parma == 1) & (maternaMuni == 1 | maternaOther == 1)
		estimates store `out'`i'
		local interview`out' `interview`out'' `out'`i' ||
		local labels`out' `labels`out'' `i'
	}
}

foreach out in `outcomes' {
	coefplot `interview`out'', keep(xmMuniReggio) vertical bycoefs bylabels(`labels`out'')
}
restore



* ---------------------------------------------------------------------------- *
* 					Reggio:	Adult-30						 				   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
preserve
keep if (Cohort == 4) 

* Set necessary global variables
local	outcomes			votoMaturita /*BMI_obese*/	
local	controls			maternaMuni Reggio ${bic_addult_baseline_did_vars}

levelsof internr, local(list_interviewer)

foreach out in `outcomes' {
	foreach i in `list_interviewer' {
		di "for outcome: `outcome' and interviewer `i'"
		regress `out' xmMuniReggio `controls' if (internr != `i') & (Reggio == 1 | Parma == 1) & (maternaMuni == 1 | maternaOther == 1)
		estimates store `out'`i'
		local interview`out' `interview`out'' `out'`i' ||
		local labels`out' `labels`out'' `i'
	}
}

foreach out in `outcomes' {
	coefplot `interview`out'', keep(xmMuniReggio) vertical bycoefs bylabels(`labels`out'')
}
restore

*/


* ---------------------------------------------------------------------------- *
* 					Reggio:	Adult-40						 				   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
preserve
keep if (Cohort == 5) 

* Set necessary global variables
local	outcomes			/*votoMaturita*/ BMI_obese	
local	controls			maternaMuni Reggio ${bic_addult_baseline_did_vars}

levelsof internr, local(list_interviewer)

foreach out in `outcomes' {
	foreach i in `list_interviewer' {
		di "for outcome: `outcome' and interviewer `i'"
		regress `out' xmMuniReggio `controls' if (internr != `i') & (Reggio == 1 | Parma == 1) & (maternaMuni == 1 | maternaOther == 1)
		estimates store `out'`i'
		local interview`out' `interview`out'' `out'`i' ||
		local labels`out' `labels`out'' `i'
	}
}

foreach out in `outcomes' {
	coefplot `interview`out'', keep(xmMuniReggio) vertical bycoefs bylabels(`labels`out'')
}
restore
