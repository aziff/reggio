* ---------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - Diff-in-Diff for Adult Cohorts
* Authors: Jessica Yu Kyung Koh
* Created: 06/16/2016
* Edited:  08/24/2016
* ---------------------------------------------------------------------------- *


clear all

cap file 	close outcomes
cap log 	close

global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio

global current : pwd

use "${data_reggio}/Reggio_prepared"
include "${current}/../macros" 
include "${current}/function/diffindiff"

* ---------------------------------------------------------------------------- *
* 								Preparation 								   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
keep if (Cohort == 4) | (Cohort == 5)

** Gender condition
local p_con	
local m_con		& Male == 1
local f_con		& Male == 0

* ---------------------------------------------------------------------------- *
* Regression: Padova Muni and Reli
* ---------------------------------------------------------------------------- *
global X					Cohort_Adult30 maternaReli xmReliAdult30	
global controls				${adult_baseline_vars}
local ifcondition 			Padova == 1 & (maternaMuni == 1 | maternaReli ==1)	

foreach type in E W L H N S R {

	diffindiff, type("`type'") ifcondition("`ifcondition'") comparison("padovamr") keep(Cohort_Adult30 maternaReli xmReliAdult30)

}

