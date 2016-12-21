/* --------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - PSM for Adult Cohorts
* Authors: Jessica Yu Kyung Koh
* Created: 06/16/2016
* Edited:  12/19/2016

* Note: This execution do file performs psm estimates and generates tables
        by using "multipleanalysis" 
* --------------------------------------------------------------------------- */

clear all

cap file 	close outcomes
cap log 	close


global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio


/*
global klmReggio  	"/mnt/ide0/share/klmReggio"
global data_reggio	"/mnt/ide0/share/klmReggio/data_survey/data"
global git_reggio	"/home/yukyungkoh/reggio"
*/
global here : pwd

use "${data_reggio}/Reggio_reassigned"

* Include scripts and functions
include "${here}/../macros" 


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
drop if (ReggioAsilo == . | ReggioMaterna == .)




* ---------------------------------------------------------------------------- *
* 					Reggio Muni vs. None:	Adult	30						   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts

keep if (Cohort == 4) 
drop if asilo == 1 // dropping those who went to infant-toddler centers


global XBIC30				maternaMuni		

global controlsBIC30		${bic_adult_baseline_vars}

global ifconditionNone30 	(Reggio == 1) & (Cohort_Adult30 == 1)  & (maternaMuni == 1 | maternaOther == 1)
global ifconditionBIC30		${ifconditionNone30} 
global ifconditionFull30	${ifconditionNone30}


foreach outcome in $adult_outcome_M {

	di "displaying PSM equation: teffects psmatch (`outcome') (${XBIC30} ${controlsBIC30}) if ${ifconditionBIC30}"
	teffects psmatch (`outcome') (${XBIC30} ${controlsBIC30}) if ${ifconditionBIC30}
	

}


