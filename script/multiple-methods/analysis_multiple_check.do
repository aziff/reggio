/* --------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - OLS and Diff-in-Diff for Adult Cohorts
* Authors: Jessica Yu Kyung Koh
* Created: 06/16/2016
* Edited:  11/08/2016

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

* Include scripts and functions
include "${here}/../macros" 
include "${here}/function/reganalysis"
include "${here}/function/writematrix"


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


** Preparation for IPW
drop if(ReggioAsilo == . | ReggioMaterna == .)

gen sample1 		= (Reggio == 1)
gen sample_nido2 	= ((Reggio == 1 & ReggioAsilo == 1) 	| (Parma == 1) | (Padova == 1))
gen sample_materna2 	= ((Reggio == 1 & ReggioMaterna == 1) 	| (Parma == 1) | (Padova == 1))
gen sample3 		= (Reggio == 1 	| Parma == 1)
gen sample4 		= (Reggio == 1 	| Padova == 1)

				
* ANALYSIS

local child_cohorts		Child Migrant
local adol_cohorts		Adolescent
local adult_cohorts		Adult30 Adult40 Adult50

local nido_var			ReggioAsilo
local materna_var		ReggioMaterna

local Child_num 		= 1
local Migrant_num 		= 2
local Adolescent_num 	= 3
local Adult30_num 		= 4
local Adult40_num 		= 5
local Adult50_num 		= 6





* ---------------------------------------------------------------------------- *
* 					Reggio Muni vs. None:	Children 						   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
preserve
keep if (Cohort == 1) | (Cohort == 2) 

foreach stype in None Stat Reli Other {
	* Set necessary global variables
	global X					maternaMuni
	global reglist				NoneIt BICIt FullIt DidPmIt DidPvIt /*IPWIt*/ NoneMg BICMg FullMg DidPmMg DidPvMg /*IPWMg*/ // It => Italians, Mg => Migrants
	global usegroup				munivs`type'_child

	global XNoneIt				maternaMuni		
	global XBICIt				maternaMuni		
	global XFullIt				maternaMuni		
	global XDidPmIt				maternaMuni	Reggio xmMuniReggio	
	global XDidPvIt				maternaMuni	Reggio xmMuniReggio	

	global XNoneMg				maternaMuni		
	global XBICMg				maternaMuni		
	global XFullMg				maternaMuni		
	global XDidPmMg				maternaMuni	Reggio xmMuniReggio	
	global XDidPvMg				maternaMuni	Reggio xmMuniReggio	

	global keepNoneIt			maternaMuni
	global keepBICIt			maternaMuni
	global keepFullIt			maternaMuni
	global keepIPWIt			ReggioMaterna
	global keepNoneMg			maternaMuni
	global keepBICMg			maternaMuni
	global keepFullMg			maternaMuni

	global keepDidPmIt			xmMuniReggio
	global keepDidPvIt			xmMuniReggio
	global keepDidPmMg			xmMuniReggio
	global keepDidPvMg			xmMuniReggio

	global controlsNoneIt
	global controlsNoneMg
	global controlsNone
	global controlsBICIt		${bic_child_baseline_vars}
	global controlsBICMg		${bic_child_baseline_vars}
	global controlsBIC			${bic_child_baseline_vars}
	global controlsFullIt		${child_baseline_vars}
	global controlsFullMg		${child_baseline_vars}
	global controlsFull			${child_baseline_vars}
	global controlsDidPmIt		${bic_child_baseline_vars}
	global controlsDidPmMg		${bic_child_baseline_vars}
	global controlsDidPvIt		${bic_child_baseline_vars}
	global controlsDidPvMg		${bic_child_baseline_vars}

	global ifconditionNoneIt 	(Reggio == 1) & (Cohort_Child == 1)   & (maternaMuni == 1 | materna`type' == 1)
	global ifconditionBICIt		${ifconditionNoneIt}
	global ifconditionFullIt	${ifconditionNoneIt}
	global ifconditionNoneMg 	(Reggio == 1) & (Cohort_Migrants == 1)   & (maternaMuni == 1 | materna`type' == 1)
	global ifconditionBICMg		${ifconditionNoneMg}
	global ifconditionFullMg	${ifconditionNoneMg}
	global ifconditionNone	 	(Reggio == 1)   & (maternaMuni == 1 | materna`type' == 1)
	global ifconditionBIC		${ifconditionNoneMg}
	global ifconditionFull		${ifconditionNoneMg}
	global ifconditionDidPmIt	(Reggio == 1 | Parma == 1) & (Cohort == 1)   & (maternaMuni == 1 | materna`type' == 1)
	global ifconditionDidPvIt	(Reggio == 1 | Padova == 1) & (Cohort == 1)   & (maternaMuni == 1 | materna`type' == 1)
	global ifconditionDidPmMg	(Reggio == 1 | Parma == 1) & (Cohort == 2)   & (maternaMuni == 1 | materna`type' == 1)
	global ifconditionDidPvMg	(Reggio == 1 | Padova == 1) & (Cohort == 2)   & (maternaMuni == 1 | materna`type' == 1)


	foreach type in CN /*S*/ H B {

		* Open necessary files
		file open regression_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/reg_child_`type'_`stype'.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Children: Multiple Analysis"
		reganalysis, stype("`stype'") type("`type'") reglist("${comparisonlist}") usegroup("${usegroup}") cohort("child")
		
		* Close necessary files
		file close regression_`type'_`stype'
	}
}

restore


