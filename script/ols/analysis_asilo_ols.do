/* --------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - Asilo OLS for Adult Cohorts
* Authors: Jessica Yu Kyung Koh
* Created: 06/16/2016
* Edited:  09/08/2016

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

use "Z:\SURVEY_DATA_COLLECTION\data\Reggio_prepared"
include "${here}/../macros" 
include "${here}/function/olsestimate"

* ---------------------------------------------------------------------------- *
* 								Preparation 								   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
keep if (Cohort == 4) | (Cohort == 5) | (Cohort == 6)
keep if (City == 1)

** Gender condition
local p_con	
local m_con		& Male == 1
local f_con		& Male == 0

** Column names for final table
global asilo_Municipal_c


* ---------------------------------------------------------------------------- *
* Regression: Compare Reggio Age-30, Reggio Age-40, Parma Age-30 (0,1) group and (1,1) group 
* ---------------------------------------------------------------------------- *
/* Note: We compare people who did not attend any asilo and attended muni materna
		 with people who attended both municipal asilo and materna. */

preserve		 
		 
* Keeping only (0,1) group and (1,1) group
keep if ((asilo_Attend == 0) & (maternaType == 1)) | ((asilo_Municipal == 1) & (maternaType == 1))		 
		 
global X						asilo_Municipal	
global list 					None30 BIC30 Full30 None40 BIC40 Full40
global usegroup					asilocompare

global controlsNone30
global controlsNone40
global controlsBIC30		${bic_adult_baseline_vars}
global controlsBIC40		${bic_adult_baseline_vars}
global controlsFull30		${adult_baseline_vars}
global controlsFull40		${adult_baseline_vars}

global ifconditionNone30 	Cohort_Adult30 == 1
global ifconditionBIC30		${ifconditionNone30}
global ifconditionFull30	${ifconditionNone30}
global ifconditionNone40 	Cohort_Adult40 == 1
global ifconditionBIC40		${ifconditionNone40}
global ifconditionFull40	${ifconditionNone40}

foreach type in E W L H N S R {

	olsestimate, type("`type'") list("${list}") usegroup("${usegroup}") keep(${X}) cohort("adult")

}

restore







