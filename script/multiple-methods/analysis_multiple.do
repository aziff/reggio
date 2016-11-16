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
include "${here}/function/multipleanalysis"
*include "${here}/../psm/function/psmweight"

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

foreach type in None Stat Reli Other {
	* Set necessary global variables
	global X					maternaMuni
	global comparisonlist		NoneIt BICIt FullIt DidPmIt DidPvIt /*IPWIt*/ NoneMg BICMg FullMg DidPmMg DidPvMg /*IPWMg*/ // It => Italians, Mg => Migrants
	global usegroup				munivs`type'_child

	global XNoneIt				maternaMuni		
	global XBICIt				maternaMuni		
	global XFullIt				maternaMuni		
	global XDidPmIt				maternaMuni	Reggio xmMuniReggio	
	global XDidPvIt				maternaMuni	Reggio xmMuniReggio	
	global XIPWIt				ReggioMaterna materna

	global XNoneMg				maternaMuni		
	global XBICMg				maternaMuni		
	global XFullMg				maternaMuni		
	global XDidPmMg				maternaMuni	Reggio xmMuniReggio	
	global XDidPvMg				maternaMuni	Reggio xmMuniReggio	
	global XIPWMg				ReggioMaterna materna

	global keepNoneIt			maternaMuni
	global keepBICIt			maternaMuni
	global keepFullIt			maternaMuni
	global keepIPWIt			ReggioMaterna
	global keepNoneMg			maternaMuni
	global keepBICMg			maternaMuni
	global keepFullMg			maternaMuni
	global keepIPWMg			ReggioMaterna

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
	global controlsIPWIt		${bic_child_baseline_vars} [pweight = weight_Cohort1]
	global controlsIPWMg		${bic_child_baseline_vars} [pweight = weight_Cohort2]

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
	global ifconditionIPWIt		(sample_materna2 == 1 & Cohort == 1)
	global ifconditionDidPmMg	(Reggio == 1 | Parma == 1) & (Cohort == 2)   & (maternaMuni == 1 | materna`type' == 1)
	global ifconditionDidPvMg	(Reggio == 1 | Padova == 1) & (Cohort == 2)   & (maternaMuni == 1 | materna`type' == 1)
	global ifconditionIPWMg		(sample_materna2 == 1 & Cohort == 2)


	foreach type in CN S H B {

		/* Compute IPW Weight
		di "Estimating `type' for Children: psmweight"
		psmweight, yvar("ReggioMaterna") xvars(${child_baseline_vars}) cohort_num(1) school_type("materna")
		psmweight, yvar("ReggioMaterna") xvars(${child_baseline_vars}) cohort_num(2) school_type("materna") */

		* Run Multiple Analysis
		di "Estimating `type' for Children: Multiple Analysis"
		multipleanalysis, type("`type'") comparisonlist("${comparisonlist}") usegroup("${usegroup}") cohort("child")

	}
}
restore




* ---------------------------------------------------------------------------- *
* 					Reggio Muni vs. None:	Adolescents 					   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
preserve
keep if (Cohort == 3)

foreach type in None Stat Reli Other {
	* Set necessary global variables
	global X					maternaMuni
	global comparisonlist		None BIC Full DidPm DidPv /*IPW*/ 
	global usegroup				munivs`type'_adol

	global XNone				maternaMuni		
	global XBIC					maternaMuni		
	global XFull				maternaMuni		
	global XDidPm				maternaMuni	Reggio xmMuniReggio	
	global XDidPv				maternaMuni	Reggio xmMuniReggio	
	global XIPW					ReggioMaterna materna

	global keepNone				maternaMuni
	global keepBIC				maternaMuni
	global keepFull				maternaMuni
	global keepIPW				ReggioMaterna
	global keepDidPm			xmMuniReggio
	global keepDidPv			xmMuniReggio

	global controlsNone
	global controlsBIC			${bic_adol_baseline_vars}
	global controlsFull			${adol_baseline_vars}
	global controlsDidPm		${bic_adol_baseline_vars}
	global controlsDidPv		${bic_adol_baseline_vars}
	global controlsIPW			${bic_adol_baseline_vars} [pweight = weight_Cohort3]

	global ifconditionNone 		(Reggio == 1) & (Cohort == 3)   & (maternaMuni == 1 | materna`type' == 1)
	global ifconditionBIC		${ifconditionNone}
	global ifconditionFull		${ifconditionNone}
	global ifconditionDidPm		(Reggio == 1 | Parma == 1) & (Cohort == 3)   & (maternaMuni == 1 | materna`type' == 1)
	global ifconditionDidPv		(Reggio == 1 | Padova == 1) & (Cohort == 3)   & (maternaMuni == 1 | materna`type' == 1)
	global ifconditionIPW		(sample_materna2 == 1 & Cohort == 3)   & (maternaMuni == 1 | materna`type' == 1)


	foreach type in CN S H B {
		
		/* Compute IPW Weight
		psmweight, yvar("ReggioMaterna") xvars(${child_baseline_vars}) cohort_num(3) school_type("materna") */

		* Run Multiple Analysis
		multipleanalysis, type("`type'") comparisonlist("${comparisonlist}") usegroup("${usegroup}") cohort("adol")

	}
}
restore



	

* ---------------------------------------------------------------------------- *
* 					Reggio Muni vs. All:	Adults		 					   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
preserve
keep if (Cohort == 4) | (Cohort == 5) | (Cohort == 6)
drop if asilo == 1 // dropping those who went to infant-toddler centers

foreach type in None Stat Reli Other {
	* Set necessary global variables
	global comparisonlist		None30 BIC30 Full30 DidPm30 DidPv30 /*IPW30*/ None40 BIC40 Full40 DidPm40 DidPv40 /*IPW40*/

	global XNone30				maternaMuni		
	global XBIC30				maternaMuni		
	global XFull30				maternaMuni		
	global XDidPm30				maternaMuni	Reggio xmMuniReggio	
	global XDidPv30				maternaMuni	Reggio xmMuniReggio	
	global XIPW30				ReggioMaterna materna

	global XNone40				maternaMuni		
	global XBIC40				maternaMuni		
	global XFull40				maternaMuni		
	global XDidPm40				maternaMuni	Reggio xmMuniReggio	
	global XDidPv40				maternaMuni	Reggio xmMuniReggio	
	global XIPW40				ReggioMaterna materna

	global keepNone30			maternaMuni
	global keepBIC30			maternaMuni
	global keepFull30			maternaMuni
	global keepIPW30			ReggioMaterna
	global keepNone40			maternaMuni
	global keepBIC40			maternaMuni
	global keepFull40			maternaMuni
	global keepIPW40			ReggioMaterna

	global keepDidPm30			xmMuniReggio
	global keepDidPv30			xmMuniReggio
	global keepDidPm40			xmMuniReggio
	global keepDidPv40			xmMuniReggio
		
	global usegroup				munivs`type'_adult

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
	global controlsIPW30		${bic_adult_baseline_vars} [pweight = weight_Cohort4]
	global controlsIPW40		${bic_adult_baseline_vars} [pweight = weight_Cohort5]

	global ifconditionNone30 	(Reggio == 1) & (Cohort_Adult30 == 1)  & (maternaMuni == 1 | materna`type' == 1)
	global ifconditionBIC30		${ifconditionNone30} 
	global ifconditionFull30	${ifconditionNone30}
	global ifconditionDidPm30	(Reggio == 1 | Parma == 1) & (Cohort_Adult30 == 1)  & (maternaMuni == 1 | materna`type' == 1)
	global ifconditionDidPv30	(Reggio == 1 | Padova == 1) & (Cohort_Adult30 == 1)  & (maternaMuni == 1 | materna`type' == 1)
	global ifconditionIPW30		(sample_materna2 == 1 & Cohort == 4)

	global ifconditionNone40 	(Reggio == 1) & (Cohort_Adult40 == 1)  & (maternaMuni == 1 | materna`type' == 1)
	global ifconditionBIC40		${ifconditionNone40}
	global ifconditionFull40	${ifconditionNone40}
	global ifconditionDidPm40	(Reggio == 1 | Parma == 1) & (Cohort_Adult40 == 1)  & (maternaMuni == 1 | materna`type' == 1)
	global ifconditionDidPv40	(Reggio == 1 | Padova == 1) & (Cohort_Adult40 == 1)  & (maternaMuni == 1 | materna`type' == 1)
	global ifconditionIPW40		(sample_materna2 == 1 & Cohort == 5)

	foreach type in E W L H N S R {
		
		/* Compute IPW Weight
		psmweight, yvar("ReggioMaterna") xvars(${adult_baseline_vars}) cohort_num(4) school_type("materna") // For age-30 cohort
		psmweight, yvar("ReggioMaterna") xvars(${adult_baseline_vars}) cohort_num(5) school_type("materna") // For age-40 cohort */

		* Run Multiple Analysis
		multipleanalysis, type("`type'") comparisonlist("${comparisonlist}") usegroup("${usegroup}") cohort("adult")
	}
}

restore

