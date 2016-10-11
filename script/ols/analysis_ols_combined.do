/* --------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - OLS 
* Authors: Jessica Yu Kyung Koh
* Created: 06/16/2016
* Edited:  10/11/2016

* Note: This execution do file performs diff-in-diff estimates and generates tables
        by using "olsestimate" command that is programmed in 
		"reggio/script/ols/function/olsestimate.do"  
		To understand how the command is coded, please refer to the above do file.
* --------------------------------------------------------------------------- */

clear all

cap file 	close outcomes
cap log 	close

global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio

global current : pwd

use "${data_reggio}/Reggio_prepared"
include "${current}/../macros" 
include "${current}/function/olsestimate"

* ---------------------------------------------------------------------------- *
* 								Preparation 								   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
keep if (Cohort == 4) | (Cohort == 5) | (Cohort == 6)

** Gender condition
local p_con	
local m_con		& Male == 1
local f_con		& Male == 0

** Column names for final table
global maternaMuni_c		


* ---------------------------------------------------------------------------- *
* Regression: Reggio Muni vs. None
* ---------------------------------------------------------------------------- *
global X					maternaMuni
global list					None30 BIC30 Full30 None40 BIC40 Full40
global usegroup				munivsnone

global controlsNone30
global controlsNone40
global controlsBIC30		${bic_adults_baseline_vars}
global controlsBIC40		${bic_adults_baseline_vars}
global controlsFull30		${adult_baseline_vars}
global controlsFull40		${adult_baseline_vars}

global ifconditionNone30 	(Reggio == 1) & (Cohort_Adult30 == 1) & (maternaMuni == 1 | maternaNone == 1)
global ifconditionBIC30		${ifcondition30none}
global ifconditionFull30	${ifcondition30none}
global ifconditionNone40 	(Reggio == 1) & (Cohort_Adult40 == 1) & (maternaMuni == 1 | maternaNone == 1)
global ifconditionBIC40		${ifcondition40none}
global ifconditionFull40	${ifcondition40none}

foreach type in E W L H N S R {

	olsestimate, type("`type'") list("${list}") usegroup("${usegroup}") keep(${X})

}


