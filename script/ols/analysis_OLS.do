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

** Column names for final table
global maternaMuni_c		Muni
global maternaNone_c		None
global maternaReli_c		Reli
global maternaPriv_c		Priv
global maternaStat_c		Stat
global maternaYes_c			Materna
global Reggio_c				Reggio


* ---------------------------------------------------------------------------- *
* Regression: Compare Reggio with All The Other Cities (All Age Groups)
* ---------------------------------------------------------------------------- *
global X					Reggio	
global agelist 				30 40 50
global controls				${adult_baseline_vars}
global usegroup				reggiovsall
global reggiovsall_note		Reggio vs. other cities for each adult cohort \\ specified by each column. Estimation for each column is restricted to the corresponding cohort
global ifcondition30 		Cohort_Adult30 == 1
global ifcondition40 		Cohort_Adult40 == 1
global ifcondition50 		Cohort_Adult50 == 1

foreach type in E W L H N S R {
	olsestimate, type("`type'") agelist("${agelist}") usegroup("${usegroup}") keep(${X})	
}


* ---------------------------------------------------------------------------- *
* Regression: Reggio Age 30 Group
* ---------------------------------------------------------------------------- *
global X					maternaNone maternaReli maternaPriv maternaStat	
global agelist				30
global controls				${adult_baseline_vars}
global usegroup				reggio30
global reggio30_note		age-30 cohort in Reggio
global ifcondition30 		Reggio == 1 & Cohort_Adult30 == 1

foreach type in E W L H N S R {

	olsestimate, type("`type'") agelist("${agelist}") usegroup("${usegroup}") keep(${X})

}

* ---------------------------------------------------------------------------- *
* Regression: Parma Age 30 Group
* ---------------------------------------------------------------------------- *
global X					maternaNone maternaReli maternaPriv maternaStat	
global agelist				30
global controls				${adult_baseline_vars}
global usegroup				parma30
global parma30_note			age-30 cohort in Parma
global ifcondition30 		Parma == 1 & Cohort_Adult30 == 1

foreach type in E W L H N S R {

	olsestimate, type("`type'") agelist("${agelist}") usegroup("${usegroup}") keep(${X})

}

* ---------------------------------------------------------------------------- *
* Regression: Padova Age 30 Group
* ---------------------------------------------------------------------------- *
global X					maternaNone maternaReli maternaPriv maternaStat	
global agelist				30
global controls				${adult_baseline_vars}
global usegroup				padova30
global padova30_note		age-30 cohort in Padova
global ifcondition30 		Padova == 1 & Cohort_Adult30 == 1

foreach type in E W L H N S R {

	olsestimate, type("`type'") agelist("${agelist}") usegroup("${usegroup}") keep(${X})

}



* ---------------------------------------------------------------------------- *
* Regression: Reggio Age 40 Group
* ---------------------------------------------------------------------------- *
global X					maternaNone maternaReli maternaPriv maternaStat	
global agelist				40
global controls				${adult_baseline_vars}
global usegroup				reggio40
global reggio40_note		age-40 cohort in Reggio
global ifcondition40 		Reggio == 1 & Cohort_Adult40 == 1

foreach type in E W L H N S R {

	olsestimate, type("`type'") agelist("${agelist}") usegroup("${usegroup}") keep(${X})

}

* ---------------------------------------------------------------------------- *
* Regression: Parma Age 40 Group
* ---------------------------------------------------------------------------- *
global X					maternaNone maternaReli maternaPriv maternaStat	
global agelist				40
global controls				${adult_baseline_vars}
global usegroup				parma40
global parma40_note			age-40 cohort in Parma
global ifcondition40 		Parma == 1 & Cohort_Adult40 == 1

foreach type in E W L H N S R {

	olsestimate, type("`type'") agelist("${agelist}") usegroup("${usegroup}") keep(${X})

}

* ---------------------------------------------------------------------------- *
* Regression: Padova Age 40 Group
* ---------------------------------------------------------------------------- *
global X					maternaNone maternaReli maternaPriv maternaStat	
global agelist				40
global controls				${adult_baseline_vars}
global usegroup				padova40
global padova40_note		age-40 cohort in Padova
global ifcondition40 		Padova == 1 & Cohort_Adult40 == 1

foreach type in E W L H N S R {

	olsestimate, type("`type'") agelist("${agelist}") usegroup("${usegroup}") keep(${X})

}



* ---------------------------------------------------------------------------- *
* Regression: Yes Preschool vs. No Preschool for Age 50 Group
* ---------------------------------------------------------------------------- *
global X					maternaYes
global agelist				Reggio Parma Padova
global controls				${adult_baseline_vars}
global usegroup				yesvsno50
global yesvsno50_note		Preschool vs. No Preschool for age-50 cohort for each city \\ specified by each column. Estimation for each column is restricted to the corresponding city
global ifconditionReggio 	Reggio == 1 & Cohort_Adult50 == 1
global ifconditionParma 	Parma == 1 & Cohort_Adult50 == 1
global ifconditionPadova 	Padova == 1 & Cohort_Adult50 == 1

foreach type in E W L H N S R {

	olsestimate, type("`type'") agelist("${agelist}") usegroup("${usegroup}") keep(${X})

}


* ---------------------------------------------------------------------------- *
* Regression: Reggio Muni vs. None
* ---------------------------------------------------------------------------- *
global X					maternaMuni
global agelist				30 40
global controls				${adult_baseline_vars}
global usegroup				munivsnone
global munivsnone_note		people in Reggio who attended municipal preschools or none
global ifcondition30 		(Reggio == 1) & (Cohort_Adult30 == 1) & (maternaMuni == 1 | maternaNone == 1)
global ifcondition40 		(Reggio == 1) & (Cohort_Adult40 == 1) & (maternaMuni == 1 | maternaNone == 1)

foreach type in E W L H N S R {

	olsestimate, type("`type'") agelist("${agelist}") usegroup("${usegroup}") keep(${X})

}


