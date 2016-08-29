/* --------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - OLS for Adult Cohorts
* Authors: Jessica Yu Kyung Koh
* Created: 06/16/2016
* Edited:  08/24/2016

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

* ---------------------------------------------------------------------------- *
* Regression: Reggio Age 30 Group
* ---------------------------------------------------------------------------- *
global X					maternaNone maternaReli maternaPriv maternaStat	
global controls				${adult_baseline_vars}
global usegroup				reggio30
global reggio30_note		age-30 cohort in Reggio
global ifcondition 			Reggio == 1 & Cohort_Adult30 == 1

foreach type in E W L H N S R {

	olsestimate, type("`type'") ifcondition("${ifcondition}") usegroup("${usegroup}") keep(${X})

}

