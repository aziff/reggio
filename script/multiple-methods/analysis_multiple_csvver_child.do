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

* ANALYSIS
local child_cohorts		Child Migrant
local adol_cohorts		Adolescent
local adult_cohorts		Adult30 Adult40 Adult50

local nido_var			ReggioAsilo
local materna_var		ReggioMaterna




* ---------------------------------------------------------------------------- *
* 					Reggio Muni vs. None:	Children 						   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
preserve
keep if (Cohort == 1) | (Cohort == 2) 

local stype_switch = 1
foreach stype in Other Stat Reli {
	
	* Set necessary global variables
	global X					maternaMuni
	global reglist				NoneIt BICIt FullIt DidPmIt DidPvIt  // It => Italians, Mg => Migrants
	global psmlist				PSMReggio PSMParma PSMPadova
	global aipwlist				AIPWIt 

	global XNoneIt				maternaMuni
	global XBICIt				maternaMuni		
	global XFullIt				maternaMuni		
	global XDidPmIt				xmMuniReggio maternaMuni Reggio 
	global XDidPvIt				xmMuniReggio maternaMuni Reggio 	
	global XPSMReggio			maternaMuni
	global XPSMParma			Reggio
	global XPSMPadova			Reggio

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
	global controlsPSMReggio	${bic_child_baseline_vars}
	global controlsPSMParma		${bic_child_baseline_vars}
	global controlsPSMPadova	${bic_child_baseline_vars}
	global controlsAIPWIt		${bic_child_baseline_vars}

	global ifconditionNoneIt 	(Reggio == 1) & (maternaMuni == 1 | materna`stype' == 1)
	global ifconditionBICIt		${ifconditionNoneIt}
	global ifconditionFullIt	${ifconditionNoneIt}
	global ifconditionPSMReggio	${ifconditionNoneIt}
	global ifconditionPSMParma 	((Reggio == 1) & (maternaMuni == 1)) | ((Parma == 1) & (materna`stype') == 1))
	global ifconditionPSMPadova	((Reggio == 1) & (maternaMuni == 1)) | ((Padova == 1) & (materna`stype') == 1))
	global ifconditionDidPmIt	(Reggio == 1 | Parma == 1)    
	global ifconditionDidPvIt	(Reggio == 1 | Padova == 1)    & (maternaMuni == 1 | materna`stype' == 1)
	global ifconditionAIPWIt 	(Reggio == 1)  & (maternaMuni == 1 | materna`stype' == 1)
	
	foreach type in  M CN S H B {

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
		
		
		
		* ----------------------- *
		* For PSM Analysis 		  *
		* ----------------------- *
		* Open necessary files
		file open psm_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/psm_child_`type'_`stype'.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Children: PSM Analysis"
		psmanalysis, stype("`stype'") type("`type'") psmlist("${psmlist}") cohort("child")
	
		* Close necessary files
		file close psm_`type'_`stype'
		
		
		
		
		
		* ----------------- *
		* For AIPW Analysis *
		* ----------------- *

		
		* Open necessary files
		file open aipw_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/aipw_child_`type'_`stype'.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Children: AIPW Analysis"
		aipwanalysis, stype("`stype'") type("`type'") aipwlist("${aipwlist}") cohort("child")
		
		* Close necessary files
		file close aipw_`type'_`stype'	
	
	
	}
	
	local stype_switch = 0
}

restore

