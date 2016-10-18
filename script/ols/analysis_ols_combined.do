/* --------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - OLS 
* Authors: Jessica Yu Kyung Koh
* Created: 06/16/2016
* Edited:  10/14/2016

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

global here : pwd

use "${data_reggio}/Reggio_prepared"
include "${here}/../macros" 
include "${here}/function/olsestimate"


** Gender condition
local p_con	
local m_con		& Male == 1
local f_con		& Male == 0

** Column names for final table
global maternaMuni_c		


* ---------------------------------------------------------------------------- *
* 					Reggio Muni vs. None:	Children 						   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
preserve
keep if (Cohort == 1) | (Cohort == 2) 

* Set necessary global variables
global X					maternaMuni
*global list				NoneIt BICIt FullIt NoneMg BICMg FullMg   // It => Italians, Mg => Migrants
global list					None BIC Full
global usegroup				munivsnone

global controlsNoneIt
global controlsNoneMg
global controlsNone
global controlsBICIt		${bic_child_baseline_vars}
global controlsBICMg		${bic_child_baseline_vars}
global controlsBIC			${bic_child_baseline_vars}
global controlsFullIt		${child_baseline_vars}
global controlsFullMg		${child_baseline_vars}
global controlsFull			${child_baseline_vars}

global ifconditionNoneIt 	(Reggio == 1) & (Cohort_Child == 1) & (maternaMuni == 1 | maternaNone == 1)
global ifconditionBICIt		${ifconditionNoneIt}
global ifconditionFullIt	${ifconditionNoneIt}
global ifconditionNoneMg 	(Reggio == 1) & (Cohort_Migrants == 1) & (maternaMuni == 1 | maternaNone == 1)
global ifconditionBICMg		${ifconditionNoneMg}
global ifconditionFullMg	${ifconditionNoneMg}
global ifconditionNone	 	(Reggio == 1) & (maternaMuni == 1 | maternaNone == 1)
global ifconditionBIC		${ifconditionNoneMg}
global ifconditionFull		${ifconditionNoneMg}

foreach type in CN S H B {

	olsestimate, type("`type'") list("${list}") usegroup("${usegroup}") keep(${X}) cohort("child")

}
restore


* ---------------------------------------------------------------------------- *
* 					Reggio Muni vs. None:	Adolescents 					   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
preserve
keep if (Cohort == 3)

* Set necessary global variables
global X					maternaMuni
global list					None BIC Full 
global usegroup				munivsnone

global controlsNone
global controlsBIC			${bic_adol_baseline_vars}
global controlsFull			${adol_baseline_vars}

global ifconditionNone  	(Reggio == 1) & (Cohort_Adol == 1) & (maternaMuni == 1 | maternaNone == 1)
global ifconditionBIC 		${ifconditionNone}
global ifconditionFull 		${ifconditionNone}

foreach type in CN S H B {

	olsestimate, type("`type'") list("${list}") usegroup("${usegroup}") keep(${X}) cohort("adol")

}
restore


* ---------------------------------------------------------------------------- *
* 					Reggio Muni vs. None:	Adults		 					   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
preserve
keep if (Cohort == 4) | (Cohort == 5) | (Cohort == 6)

* Set necessary global variables
global X					maternaMuni
global list					None30 BIC30 Full30 None40 BIC40 Full40
global usegroup				munivsnone

global controlsNone30
global controlsNone40
global controlsBIC30		${bic_adult_baseline_vars}
global controlsBIC40		${bic_adult_baseline_vars}
global controlsFull30		${adult_baseline_vars}
global controlsFull40		${adult_baseline_vars}

global ifconditionNone30 	(Reggio == 1) & (Cohort_Adult30 == 1) & (maternaMuni == 1 | maternaNone == 1)
global ifconditionBIC30		${ifconditionNone30}
global ifconditionFull30	${ifconditionNone30}
global ifconditionNone40 	(Reggio == 1) & (Cohort_Adult40 == 1) & (maternaMuni == 1 | maternaNone == 1)
global ifconditionBIC40		${ifconditionNone40}
global ifconditionFull40	${ifconditionNone40}

foreach type in E W L H N S R {

	olsestimate, type("`type'") list("${list}") usegroup("${usegroup}") keep(${X}) cohort("adult")

}
restore
