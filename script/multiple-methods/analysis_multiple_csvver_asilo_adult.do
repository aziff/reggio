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
global data_reggio : env data_reggio
global git_reggio  : env git_reggio

global here : pwd

use "${data_reggio}/Reggio_reassigned"

* Include scripts and functions
include "${here}/../macros" 
include "${here}/function/reganalysis"
include "${here}/function/aipwanalysis"
include "${here}/function/psmanalysis"
include "${here}/function/writematrix"
include "${here}/../ipw/function/aipw"


* ---------------------------------------------------------------------------- *
* 								Preparation 								   *
* ---------------------------------------------------------------------------- *
** Preparation for IPW
drop if (ReggioAsilo == . | ReggioMaterna == .)

generate D = 0
replace  D = 1 			if (ReggioMaterna == 1)

generate D0 = (D == 0)
generate D1 = (D == 1)
generate D2 = (D == 2)

global bootstrap = 70
set seed 1234



* ---------------------------------------------------------------------------- *
* 					Reggio Muni vs. None:	Adult-30						   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
preserve
keep if (Cohort == 4) | (Cohort == 5)

local stype_switch = 1
foreach stype in Other None {
	
	* Set necessary global variables
	global X					asiloMuni
	global reglist				None30 BIC30 Full30  // It => Italians, Mg => Migrants
	global aipwlist				AIPW30
	global psmlist				PSM30

	global XNone30				asiloMuni	
	global XBIC30				asiloMuni		
	global XFull30				asiloMuni	
	global XPSM30				asiloMuni

	global XNone40				asiloMuni		
	global XBIC40				asiloMuni	
	global XFull40				asiloMuni		

	global controlsNone30
	global controlsNone40
	global controlsBIC30		${bic_adult_baseline_vars}
	global controlsBIC40		${bic_adult_baseline_vars}
	global controslPSM30		${bic_adult_baseline_vars}
	global controlsFull30		${adult_baseline_vars}
	global controlsFull40		${adult_baseline_vars}
	global controlsDidPm30		${bic_adult_baseline_vars}
	global controlsDidPv30		${bic_adult_baseline_vars}


	global ifconditionNone30 	(Reggio == 1) & (Cohort_Adult30 == 1)  & ((asilo`stype' == 1) & (maternaMuni == 1)) | ((asiloMuni == 1) & (maternaMuni == 1))
	global ifconditionBIC30		${ifconditionNone30} 
	global ifconditionFull30	${ifconditionNone30}
	global ifconditionPSM30		${ifconditionNone30} 

	global ifconditionNone40 	(Reggio == 1) & (Cohort_Adult40 == 1)  & ((asilo`stype' == 1) & (maternaMuni == 1)) | ((asiloMuni == 1) & (maternaMuni == 1))
	global ifconditionBIC40		${ifconditionNone40}
	global ifconditionFull40	${ifconditionNone40}
	
	
	
	
	foreach type in  M /*E W L H N S*/ {

		* ----------------------- *
		* For Regression Analysis *
		* ----------------------- *
		* Open necessary files
		cap file close regression_`type'_`stype'
		file open regression_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/reg_adult30`type'_`stype'_asilo.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Children: Regression Analysis"
		reganalysis, stype("`stype'") type("`type'") reglist("${reglist}") cohort("adult30")
	
		* Close necessary files
		file close regression_`type'_`stype' 
		
	/*	
		* ----------------------- *
		* For PSM Analysis 		  *
		* ----------------------- *
		* Open necessary files
		file open psm_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/psm_adult30_`type'_`stype'_asilo.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Adult: PSM Analysis"
		psmanalysis, stype("`stype'") type("`type'") psmlist("${psmlist}") cohort("adult")
	
		* Close necessary files
		file close psm_`type'_`stype'*/
		
		
		
		
		* ----------------- *
		* For AIPW Analysis *
		* ----------------- *

		/*
			* Open necessary files
			cap file close aipw_`type'_`stype'
			file open aipw_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/aipw_adult_`type'_`stype'_asilo.csv", write replace

			* Run Multiple Analysis
			di "Estimating `type' for Children: AIPW Analysis"
			aipwanalysis, stype("`stype'") type("`type'") aipwlist("${aipwlist}") cohort("adult")
			
			* Close necessary files
			file close aipw_`type'_`stype'	
		*/
		
	}
	
	local stype_switch = 0
}

restore




















* ---------------------------------------------------------------------------- *
* 					Reggio Muni vs. None:	Adult-40						   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
preserve
keep if (Cohort == 4) | (Cohort == 5)

local stype_switch = 1
foreach stype in Other None {
	
	* Set necessary global variables
	global X					asiloMuni
	global reglist				None40 BIC40 Full40  // It => Italians, Mg => Migrants
	global aipwlist				AIPW40
	global psmlist				PSM40

	global XNone40				asiloMuni	
	global XBIC40				asiloMuni		
	global XFull40				asiloMuni	
	global XPSM40				asiloMuni	

	global controlsNone40
	global controlsBIC40		${bic_adult_baseline_vars}
	global controslPSM40		${bic_adult_baseline_vars}
	global controlsFull40		${adult_baseline_vars}

	global ifconditionNone40 	(Reggio == 1) & (Cohort_Adult40 == 1)  & ((asilo`stype' == 1) & (maternaMuni == 1)) | ((asiloMuni == 1) & (maternaMuni == 1))
	global ifconditionBIC40		${ifconditionNone40}
	global ifconditionFull40	${ifconditionNone40}
	global ifconditionPSM40		${ifconditionNone40}
	
	
	
	
	foreach type in  M /*E W L H N S*/ {

		* ----------------------- *
		* For Regression Analysis *
		* ----------------------- *
		* Open necessary files
		cap file close regression_`type'_`stype'
		file open regression_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/reg_adult40`type'_`stype'_asilo.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Children: Regression Analysis"
		reganalysis, stype("`stype'") type("`type'") reglist("${reglist}") cohort("adult40")
	
		* Close necessary files
		file close regression_`type'_`stype' 
		
		
		/* ----------------------- *
		* For PSM Analysis 		  *
		* ----------------------- *
		* Open necessary files
		file open psm_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/psm_adult40_`type'_`stype'_asilo.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Adult: PSM Analysis"
		psmanalysis, stype("`stype'") type("`type'") psmlist("${psmlist}") cohort("adult")
	
		* Close necessary files
		file close psm_`type'_`stype'
		*/
		
		
		
		* ----------------- *
		* For AIPW Analysis *
		* ----------------- *

		/*
			* Open necessary files
			cap file close aipw_`type'_`stype'
			file open aipw_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/aipw_adult_`type'_`stype'_asilo.csv", write replace

			* Run Multiple Analysis
			di "Estimating `type' for Children: AIPW Analysis"
			aipwanalysis, stype("`stype'") type("`type'") aipwlist("${aipwlist}") cohort("adult")
			
			* Close necessary files
			file close aipw_`type'_`stype'	
		*/
		
	}
	
	local stype_switch = 0
}

restore

