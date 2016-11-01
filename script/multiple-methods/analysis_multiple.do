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

use "${data_reggio}/Reggio_prepared"
include "${here}/../macros" 
include "${here}/function/multipleanalysis"

* ---------------------------------------------------------------------------- *
* 								Preparation 								   *
* ---------------------------------------------------------------------------- *
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
* 					Reggio Muni vs. None:	Adults		 					   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
preserve
keep if (Cohort == 4) | (Cohort == 5) | (Cohort == 6)

* Set necessary global variables
global comparisonlist		None30 BIC30 Full30 DidPm30 DidPv30 None40 BIC40 Full40 DidPm40 DidPv40

global XNone30				maternaMuni		
global XBIC30				maternaMuni		
global XFull30				maternaMuni		
global XDidPm30				maternaMuni	Reggio xmMuniReggio	
global XDidPv30				maternaMuni	Reggio xmMuniReggio	

global XNone40				maternaMuni		
global XBIC40				maternaMuni		
global XFull40				maternaMuni		
global XDidPm40				maternaMuni	Reggio xmMuniReggio	
global XDidPv40				maternaMuni	Reggio xmMuniReggio	

global keepNone30			maternaMuni
global keepBIC30			maternaMuni
global keepFull30			maternaMuni
global keepNone40			maternaMuni
global keepBIC40			maternaMuni
global keepFull40			maternaMuni

global keepDidPm30			xmMuniReggio
global keepDidPv30			xmMuniReggio
global keepDidPm40			xmMuniReggio
global keepDidPv40			xmMuniReggio
	
global usegroup				munivsnone

global controlsNone30
global controlsNone40
global controlsBIC30		${bic_adult_baseline_vars}
global controlsBIC40		${bic_adult_baseline_vars}
global controlsFull30		${adult_baseline_vars}
global controlsFull40		${adult_baseline_vars}
global controlsDidPm30		${bic_adult_baseline_vars}
global controlsDidPm40		${bic_adult_baseline_vars}
global controlsDidPv30		${bic_adult_baseline_vars}
global controlsDidPv40		${bic_adult_baseline_vars}

global ifconditionNone30 	(Reggio == 1) & (Cohort_Adult30 == 1) & (maternaMuni == 1 | maternaNone == 1)
global ifconditionBIC30		${ifconditionNone30}
global ifconditionFull30	${ifconditionNone30}
global ifconditionDidPm30	(Reggio == 1 | Parma == 1) & (Cohort_Adult30 == 1) & (maternaMuni == 1 | maternaNone == 1)
global ifconditionDidPv30	(Reggio == 1 | Padova == 1) & (Cohort_Adult30 == 1) & (maternaMuni == 1 | maternaNone == 1)

global ifconditionNone40 	(Reggio == 1) & (Cohort_Adult40 == 1) & (maternaMuni == 1 | maternaNone == 1)
global ifconditionBIC40		${ifconditionNone40}
global ifconditionFull40	${ifconditionNone40}
global ifconditionDidPm40	(Reggio == 1 | Parma == 1) & (Cohort_Adult40 == 1) & (maternaMuni == 1 | maternaNone == 1)
global ifconditionDidPv40	(Reggio == 1 | Padova == 1) & (Cohort_Adult40 == 1) & (maternaMuni == 1 | maternaNone == 1)

foreach type in E W L H N S R {

	multipleanalysis, type("`type'") comparisonlist("${comparisonlist}") usegroup("${usegroup}") 
}
restore






/*
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
*/

