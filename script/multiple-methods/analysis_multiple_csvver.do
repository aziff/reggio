/* --------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - OLS and Diff-in-Diff for Adult Cohorts
* Authors: Jessica Yu Kyung Koh
* Created: 06/16/2016
* Edited:  12/12/2016

* Note: This execution do file performs diff-in-diff estimates and generates tables
        by using "multipleanalysis" command that is programmed in 
		"reggio/script/ols/function/multipleanalysis.do"  
		To understand how the command is coded, please refer to the above do file.
* --------------------------------------------------------------------------- */

clear all

cap file 	close outcomes
cap log 	close

global klmReggio   : env klmReggio
global YuKyung		"C:/Users/YuKyung/Desktop"
global data_reggio : env data_reggio
global git_reggio  : env git_reggio

global here : pwd

*use "${data_reggio}/Reggio_prepared"
use "${YuKyung}/Reggio_prepared"

* Include scripts and functions
include "${here}/../macros" 
include "${here}/function/reganalysis"
include "${here}/function/aipwanalysis"
include "${here}/function/writematrix"
include "${here}/../ipw/function/aipw"


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

generate D = 0
replace  D = 1 			if (ReggioMaterna == 1)

generate D0 = (D == 0)
generate D1 = (D == 1)
generate D2 = (D == 2)

global bootstrap = 50
set seed 1234

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

local stype_switch = 1
foreach stype in /*None Stat Reli*/ Other {
	
	* Set necessary global variables
	global X					maternaMuni
	global reglist				NoneIt BICIt FullIt DidPmIt DidPvIt  // It => Italians, Mg => Migrants
	global aipwlist				WnoneIt WpresIt 

	global XNoneIt				maternaMuni		
	global XBICIt				maternaMuni		
	global XFullIt				maternaMuni		
	global XDidPmIt				maternaMuni	Reggio xmMuniReggio	
	global XDidPvIt				maternaMuni	Reggio xmMuniReggio	


	global keepNoneIt			maternaMuni
	global keepBICIt			maternaMuni
	global keepFullIt			maternaMuni

	global keepDidPmIt			xmMuniReggio
	global keepDidPvIt			xmMuniReggio

	global controlsNoneIt
	global controlsNone
	global controlsBICIt		${bic_child_baseline_vars}
	global controlsBIC			${bic_child_baseline_vars}
	global controlsFullIt		${child_baseline_vars}
	global controlsFull			${child_baseline_vars}
	global controlsDidPmIt		${bic_child_baseline_vars}
	global controlsDidPvIt		${bic_child_baseline_vars}

	global ifconditionNoneIt 	(Reggio == 1) & (maternaMuni == 1 | materna`type' == 1)
	global ifconditionBICIt		${ifconditionNoneIt}
	global ifconditionFullIt	${ifconditionNoneIt}
	global ifconditionDidPmIt	(Reggio == 1 | Parma == 1)    & (maternaMuni == 1 | materna`type' == 1)
	global ifconditionDidPvIt	(Reggio == 1 | Padova == 1)    & (maternaMuni == 1 | materna`type' == 1)
	global ifconditionWnoneIt   (Reggio == 1)   & (maternaMuni == 1 | maternaNone == 1)
	global ifconditionWpresIt 	(Reggio == 1)  & (maternaMuni == 1 | maternaOther == 1)
	
	foreach type in  M /*CN S H B*/ {

		* ----------------------- *
		* For Regression Analysis *
		* ----------------------- *
		* Open necessary files
		file open regression_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/reg_child_`type'_`stype'.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Children: Regression Analysis"
		reganalysis, stype("`stype'") type("`type'") reglist("${reglist}") cohort("child")
	
		* Close necessary files
		file close regression_`type'_`stype' 
		
		
		* ----------------- *
		* For AIPW Analysis *
		* ----------------- *
		if `stype_switch' == 1 { // Does not depend on `stype', so we only need to run once!
		
			* Open necessary files
			file open aipw_`type' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/aipw_child_`type'.csv", write replace

			* Run Multiple Analysis
			di "Estimating `type' for Children: AIPW Analysis"
			aipwanalysis, type("`type'") aipwlist("${aipwlist}") cohort("child")
			
			* Close necessary files
			file close aipw_`type'	
		}
		
	}
	
	local stype_switch = 0
}

restore












* ---------------------------------------------------------------------------- *
* 					Reggio Muni vs. None:	Adolescent						   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
preserve
keep if (Cohort == 3)

local stype_switch = 1
foreach stype in /*None Stat Reli*/ Other {
	
	* Set necessary global variables
	global X					maternaMuni
	global reglist				None BIC Full DidPm DidPv // It => Italians, Mg => Migrants
	global aipwlist				Wnone Wpres

	global XNone				maternaMuni		
	global XBIC					maternaMuni		
	global XFull				maternaMuni		
	global XDidPm				maternaMuni	Reggio xmMuniReggio	
	global XDidPv				maternaMuni	Reggio xmMuniReggio	

	global keepNone				maternaMuni
	global keepBIC				maternaMuni
	global keepFull				maternaMuni
	global keepDidPm			xmMuniReggio
	global keepDidPv			xmMuniReggio

	global controlsNone
	global controlsBIC			${bic_adol_baseline_vars}
	global controlsFull			${adol_baseline_vars}
	global controlsDidPm		${bic_adol_baseline_vars}
	global controlsDidPv		${bic_adol_baseline_vars}

	global ifconditionNone 		(Reggio == 1) & (Cohort == 3)   & (maternaMuni == 1 | materna`type' == 1)
	global ifconditionBIC		${ifconditionNone}
	global ifconditionFull		${ifconditionNone}
	global ifconditionDidPm		(Reggio == 1 | Parma == 1) & (Cohort == 3)   & (maternaMuni == 1 | materna`type' == 1)
	global ifconditionDidPv		(Reggio == 1 | Padova == 1) & (Cohort == 3)   & (maternaMuni == 1 | materna`type' == 1)
	global ifconditionWnone     (Reggio == 1) & (Cohort == 3)   & (maternaMuni == 1 | maternaNone == 1)
	global ifconditionWpres 	(Reggio == 1) & (Cohort == 3)   & (maternaMuni == 1 | maternaOther == 1)

	
	
	foreach type in  M /*CN S H B*/ {

		* ----------------------- *
		* For Regression Analysis *
		* ----------------------- *
		* Open necessary files
		cap file close regression_`type'_`stype'
		file open regression_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/reg_adol_`type'_`stype'.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Children: Regression Analysis"
		reganalysis, stype("`stype'") type("`type'") reglist("${reglist}") cohort("adol")
	
		* Close necessary files
		file close regression_`type'_`stype' 
		
		
		* ----------------- *
		* For AIPW Analysis *
		* ----------------- *
		if `stype_switch' == 1 { // Does not depend on `stype', so we only need to run once!
		
			* Open necessary files
			cap file close aipw_`type'_`stype'
			file open aipw_`type' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/aipw_adol_`type'.csv", write replace

			* Run Multiple Analysis
			di "Estimating `type' for Children: AIPW Analysis"
			aipwanalysis, type("`type'") aipwlist("${aipwlist}") cohort("adol")
			
			* Close necessary files
			file close aipw_`type'	
		}
		
	}
	
	local stype_switch = 0
}

restore














* ---------------------------------------------------------------------------- *
* 					Reggio Muni vs. None:	Children 						   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
preserve
keep if (Cohort == 4) | (Cohort == 5) | (Cohort == 6)
drop if asilo == 1 // dropping those who went to infant-toddler centers

local stype_switch = 1
foreach stype in /*None Stat Reli*/ Other {
	
	* Set necessary global variables
	global X					maternaMuni
	global reglist				None30 BIC30 Full30 DidPm30 DidPv30 None40 BIC40 Full40 // It => Italians, Mg => Migrants
	global aipwlist				Wnone30 Wpres30 Wnone40 Wpres40

	global XNone30				maternaMuni		
	global XBIC30				maternaMuni		
	global XFull30				maternaMuni		
	global XDidPm30				maternaMuni	Reggio xmMuniReggio	
	global XDidPv30				maternaMuni	Reggio xmMuniReggio	

	global XNone40				maternaMuni		
	global XBIC40				maternaMuni		
	global XFull40				maternaMuni		

	global keepNone30			maternaMuni
	global keepBIC30			maternaMuni
	global keepFull30			maternaMuni
	global keepIPW30			ReggioMaterna
	global keepNone40			maternaMuni
	global keepBIC40			maternaMuni
	global keepFull40			maternaMuni

	global keepDidPm30			xmMuniReggio
	global keepDidPv30			xmMuniReggio

	global controlsNone30
	global controlsNone40
	global controlsBIC30		${bic_adult_baseline_vars}
	global controlsBIC40		${bic_adult_baseline_vars}
	global controlsFull30		${adult_baseline_vars}
	global controlsFull40		${adult_baseline_vars}
	global controlsDidPm30		${bic_adult_baseline_vars}
	global controlsDidPv30		${bic_adult_baseline_vars}


	global ifconditionNone30 	(Reggio == 1) & (Cohort_Adult30 == 1)  & (maternaMuni == 1 | materna`type' == 1)
	global ifconditionBIC30		${ifconditionNone30} 
	global ifconditionFull30	${ifconditionNone30}
	global ifconditionDidPm30	(Reggio == 1 | Parma == 1) & (Cohort_Adult30 == 1)  & (maternaMuni == 1 | materna`type' == 1)
	global ifconditionDidPv30	(Reggio == 1 | Padova == 1) & (Cohort_Adult30 == 1)  & (maternaMuni == 1 | materna`type' == 1)

	global ifconditionNone40 	(Reggio == 1) & (Cohort_Adult40 == 1)  & (maternaMuni == 1 | materna`type' == 1)
	global ifconditionBIC40		${ifconditionNone40}
	global ifconditionFull40	${ifconditionNone40}
	global ifconditionDidPm40	(Reggio == 1 | Parma == 1) & (Cohort_Adult40 == 1)  & (maternaMuni == 1 | materna`type' == 1)
	global ifconditionDidPv40	(Reggio == 1 | Padova == 1) & (Cohort_Adult40 == 1)  & (maternaMuni == 1 | materna`type' == 1)
	global ifconditionWnone30   (Reggio == 1) & (Cohort_Adult30 == 1)   & (maternaMuni == 1 | maternaNone == 1)
	global ifconditionWpres30 	(Reggio == 1) & (Cohort_Adult30 == 1)   & (maternaMuni == 1 | maternaOther == 1)
	global ifconditionWnone40 	(Reggio == 1) & (Cohort_Adult40 == 1)   & (maternaMuni == 1 | maternaNone == 1)
	global ifconditionWpres40	(Reggio == 1) & (Cohort_Adult40 == 1)   & (maternaMuni == 1 | maternaOther == 1)
	
	
	
	
	foreach type in  M {

		* ----------------------- *
		* For Regression Analysis *
		* ----------------------- *
		* Open necessary files
		cap file close regression_`type'_`stype'
		file open regression_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/reg_adult_`type'_`stype'.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Children: Regression Analysis"
		reganalysis, stype("`stype'") type("`type'") reglist("${reglist}") cohort("adult")
	
		* Close necessary files
		file close regression_`type'_`stype' 
		
		
		* ----------------- *
		* For AIPW Analysis *
		* ----------------- *
		if `stype_switch' == 1 { // Does not depend on `stype', so we only need to run once!
		
			* Open necessary files
			cap file close aipw_`type'_`stype'
			file open aipw_`type' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/aipw_adult_`type'.csv", write replace

			* Run Multiple Analysis
			di "Estimating `type' for Children: AIPW Analysis"
			aipwanalysis, type("`type'") aipwlist("${aipwlist}") cohort("adult")
			
			* Close necessary files
			file close aipw_`type'	
		}
		
	}
	
	local stype_switch = 0
}

restore
