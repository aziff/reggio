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
global maternaMuni_c		Muni
global maternaNone_c		None
global maternaReli_c		Reli
global maternaPriv_c		Priv
global maternaStat_c		Stat
global maternaYes_c			Materna
global Reggio_c				Reggio


* ---------------------------------------------------------------------------- *
* Regression: Compare Reggio Age-30, Reggio Age-40, Parma Age-30 (0,1) group and (1,1) group 
* ---------------------------------------------------------------------------- *
/* Note: We compare people who did not attend any asilo and attended muni materna
		 with people who attended both municipal asilo and materna. */

preserve		 
		 
* Keeping only (0,1) group and (1,1) group
keep if ((asilo_Attend == 0) & (maternaType == 1)) | ((asilo_Municipal == 1) & (maternaType == 1))		 
		 
global X						asilo_Municipal	
global agelist 					Reggio30 Reggio40 Parma30
global controls					${adult_baseline_vars}
global usegroup					asilocompare
global asilocompare_note		the effects of attending the municipal asilo \\ for the group specified by each column. Estimation for each column \\ is restricted to the corresponding cohort
global ifconditionReggio30 		Reggio == 1 & Cohort_Adult30 == 1
global ifconditionReggio40 		Reggio == 1 & Cohort_Adult40 == 1
global ifconditionParma30 		Parma == 1 & Cohort_Adult30 == 1

foreach type in E W L H N S R {
	olsestimate, type("`type'") agelist("${agelist}") usegroup("${usegroup}") keep(${X})	
}

restore


