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
foreach city in Parma Padova {
	foreach stype in Yes {
		
		* Set necessary global variables
		global X					maternaMuni
		global reglist				NoneIt BICIt FullIt  // It => Italians, Mg => Migrants
		global aipwlist				AIPWIt 

		global XNoneIt				maternaYes	
		global XBICIt				maternaYes		
		global XFullIt				maternaYes		
		global XDidPmIt				maternaMuni	Reggio xmMuniReggio	
		global XDidPvIt				maternaMuni	Reggio xmMuniReggio	


		global keepNoneIt			maternaYes
		global keepBICIt			maternaYes
		global keepFullIt			maternaYes

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

		global ifconditionNoneIt 	(`city' == 1) 
		global ifconditionBICIt		${ifconditionNoneIt}
		global ifconditionFullIt	${ifconditionNoneIt}
		global ifconditionAIPWIt 	(`city' == 1) 
		
		foreach type in  M /*CN S H B*/ {

			* ----------------------- *
			* For Regression Analysis *
			* ----------------------- *
			* Open necessary files
			cap file close regression_`type'_`stype'
			file open regression_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/reg_child_`type'_`stype'_`city'.csv", write replace

			* Run Multiple Analysis
			di "Estimating `type' for Children: Regression Analysis"
			reganalysis, stype("`stype'") type("`type'") reglist("${reglist}") cohort("child")
		
			* Close necessary files
			file close regression_`type'_`stype' 
			
			
			* ----------------- *
			* For AIPW Analysis *
			* ----------------- *

			
			* Open necessary files
			cap file close aipw_`type'_`stype'
			file open aipw_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/aipw_child_`type'_`stype'_`city'.csv", write replace

			* Run Multiple Analysis
			di "Estimating `type' for Children: AIPW Analysis"
			aipwanalysis, stype("`stype'") type("`type'") aipwlist("${aipwlist}") cohort("child")
			
			* Close necessary files
			file close aipw_`type'_`stype'	
		
		
		}
		
		local stype_switch = 0
	}

}
restore

