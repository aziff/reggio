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

/*
global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio
*/

global klmReggio  	"/mnt/ide0/share/klmReggio"
global data_reggio	"/mnt/ide0/share/klmReggio/data_survey/data"
global git_reggio	"/home/yukyungkoh/reggio"

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
foreach stype in Other None {
	
	* Set necessary global variables
	global X					asiloMuni
	global reglist				NoneIt BICIt FullIt // It => Italians, Mg => Migrants
	global psmlist				PSMIt
	global aipwlist				AIPWIt 

	global XNoneIt				asiloMuni	
	global XBICIt				asiloMuni		
	global XFullIt				asiloMuni	
	global XPSMIt				asiloMuni


	global controlsNoneIt
	global controlsNone
	global controlsBICIt		${bic_asilo_child_baseline_vars}
	global controlsBIC			${bic_asilo_child_baseline_vars}
	global controlsFullIt		${child_baseline_vars}
	global controlsFull			${child_baseline_vars}
	global controlsPSMIt		${bic_child_baseline_vars}
	global controlsDidPmIt		${bic_child_baseline_vars}
	global controlsDidPvIt		${bic_child_baseline_vars}

	global ifconditionNoneIt 	(Reggio == 1) & ((asilo`stype' == 1) & (maternaMuni == 1)) | ((asiloMuni == 1) & (maternaMuni == 1))
	global ifconditionBICIt		${ifconditionNoneIt}
	global ifconditionFullIt	${ifconditionNoneIt}
	global ifconditionPSMIt		${ifconditionNoneIt}
	global ifconditionDidPmIt	(Reggio == 1 | Parma == 1)    & ((asilo`stype' == 1) & (maternaMuni == 1)) | ((asiloMuni == 1) & (maternaMuni == 1))
	global ifconditionDidPvIt	(Reggio == 1 | Padova == 1)    & ((asilo`stype' == 1) & (maternaMuni == 1)) | ((asiloMuni == 1) & (maternaMuni == 1))
	global ifconditionAIPWIt 	(Reggio == 1)  & ((asilo`stype' == 1) & (maternaMuni == 1)) | ((asiloMuni == 1) & (maternaMuni == 1))
	
	foreach type in  M  {

		* ----------------------- *
		* For Regression Analysis *
		* ----------------------- *
		* Open necessary files
		file open regression_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/reg_child_`type'_`stype'_asilo.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Children: Regression Analysis"
		reganalysis, stype("`stype'") type("`type'") reglist("${reglist}") cohort("child")
	
		* Close necessary files
		file close regression_`type'_`stype' 
		
		
		
		* ----------------------- *
		* For PSM Analysis 		  *
		* ----------------------- *
		* Open necessary files
		file open psm_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/psm_child_`type'_`stype'_asilo.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Children: PSM Analysis"
		psmanalysis, stype("`stype'") type("`type'") psmlist("${psmlist}") cohort("child")
	
		* Close necessary files
		file close psm_`type'_`stype'
		
		
		* ----------------- *
		* For AIPW Analysis *
		* ----------------- *
/*
		
		* Open necessary files
		file open aipw_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/aipw_child_`type'_`stype'_asilo.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Children: AIPW Analysis"
		aipwanalysis, stype("`stype'") type("`type'") aipwlist("${aipwlist}") cohort("child")
		
		* Close necessary files
		file close aipw_`type'_`stype'	*/
	
	
	}
	
	local stype_switch = 0
}

restore

