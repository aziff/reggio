/* --------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - OLS and Diff-in-Diff for Adult Cohorts
* Authors: Jessica Yu Kyung Koh
* Created: 06/16/2016
* Edited:  08/24/2016

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

global current : pwd

use "${data_reggio}/Reggio_prepared"
include "${current}/../macros" 
include "${current}/function/multipleanalysis"

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
global maternaMuni30_c			Muni_Age30
global maternaMuni40_c			Muni_Age40
global xmMuniAdult30did_c		DiD
global maternaMuniParma30_c		Parma30
global maternaMuniParma40_c		Parma40
global maternaMuniPadova30_c	Padova30
global maternaMuniPadova40_c	Padova40



* ---------------------------------------------------------------------------- *
* Regression: Reggio Muni vs. None
* ---------------------------------------------------------------------------- *
global X30					maternaMuni
global X40					maternaMuni
global Xdid					maternaMuni Cohort_Adult30 xmMuniAdult30
global keep30				maternaMuni
global keep40				maternaMuni
global keepdid				xmMuniAdult30
global comparisonlist		30 40 did
global controls				${adult_baseline_vars}
global usegroup				munivsnone
global ifcondition30 		(Reggio == 1) & (Cohort_Adult30 == 1) & (maternaMuni == 1 | maternaNone == 1)
global ifcondition40 		(Reggio == 1) & (Cohort_Adult40 == 1) & (maternaMuni == 1 | maternaNone == 1)
global ifconditiondid		(Reggio == 1) & (Cohort_Adult30 == 1 | Cohort_Adult40 == 1) & (maternaMuni == 1 | maternaNone == 1)

foreach type in E W L H N S R {

	multipleanalysis, type("`type'") comparisonlist("${comparisonlist}") usegroup("${usegroup}") 
}



* ---------------------------------------------------------------------------- *
* Regression: Reggio Muni vs. Parma/Padova None
* ---------------------------------------------------------------------------- *
global XPadova30			maternaMuni Padova
global XPadova40			maternaMuni Padova
global keepPadova30			maternaMuni 
global keepPadova40			maternaMuni 
global comparisonlist		Padova30 Padova40
global controls				${adult_baseline_vars}
global usegroup				munivsnone_pp
global ifconditionParma30 	((Reggio == 1 & maternaMuni == 1) | (Parma == 1 & maternaNone == 1)) & (Cohort_Adult30 == 1)
global ifconditionPadova30	((Reggio == 1 & maternaMuni == 1) | (Padova == 1 & maternaNone == 1)) & (Cohort_Adult30 == 1)
global ifconditionParma40 	((Reggio == 1 & maternaMuni == 1) | (Parma == 1 & maternaNone == 1)) & (Cohort_Adult40 == 1)
global ifconditionPadova40	((Reggio == 1 & maternaMuni == 1) | (Padova == 1 & maternaNone == 1)) & (Cohort_Adult40 == 1)

foreach type in E W L H N S R {

	multipleanalysis, type("`type'") comparisonlist("${comparisonlist}") usegroup("${usegroup}") 
}
