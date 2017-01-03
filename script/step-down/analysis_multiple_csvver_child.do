/* --------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - Step-Down for Children Cohort (Main Outcomes)
* Authors: Jessica Yu Kyung Koh
* Created: 06/16/2016
* Edited:  01/03/2017

* Note: This execution do file performs diff-in-diff estimates and generates tables
        by using "multipleanalysis" command that is programmed in 
		"reggio/script/ols/function/multipleanalysis.do"  
		To understand how the command is coded, please refer to the above do file.
* --------------------------------------------------------------------------- */

clear all

cap file 	close outcomes
cap log 	close

* Capture install rwolf command (for Romano-Wolf stepdown procedure) exists
cap which rwolf
if _rc ssc install rwolf

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
include "${here}/function/sdreganalysis"
include "${here}/function/sdaipwanalysis"
include "${here}/function/sdpsmanalysis"
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
* 					Reggio Muni vs. None:	Children 						   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
preserve
keep if (Cohort == 1) | (Cohort == 2) 

local stype_switch = 1
foreach stype in Other {
	
	* Set necessary global variables
	global X					maternaMuni
	global reglist				None BIC Full DidPm DidPv  // It => Italians, Mg => Migrants
	global psmlist				PSMIt
	global aipwlist				AIPWIt 

	global XNone				maternaMuni
	global XBIC					maternaMuni		
	global XFull				maternaMuni		
	global XDidPm				xmMuniReggio
	global XDidPv				xmMuniReggio 	
	global XPSM					maternaMuni

	global keepNone				maternaMuni
	global keepBIC				maternaMuni
	global keepFull				maternaMuni

	global keepDidPm			xmMuniReggio
	global keepDidPv			xmMuniReggio
	global keepPSM				maternaMuni

	global controlsNone
	global controlsBIC			${bic_child_baseline_vars}
	global controlsFull			${child_baseline_vars}
	global controlsDidPm		maternaMuni Reggio ${bic_child_baseline_vars}
	global controlsDidPv		maternaMuni Reggio ${bic_child_baseline_vars}
	global controlsPSM			${bic_child_baseline_vars}

	global ifconditionNone 		(Reggio == 1) & (maternaMuni == 1 | materna`stype' == 1)
	global ifconditionBIC		${ifconditionNone}
	global ifconditionFull		${ifconditionNone}
	global ifconditionPSM		${ifconditionNone}
	global ifconditionDidPm		(Reggio == 1 | Parma == 1)    
	global ifconditionDidPv		(Reggio == 1 | Padova == 1)    & (maternaMuni == 1 | materna`stype' == 1)
	global ifconditionAIPW	 	(Reggio == 1)  & (maternaMuni == 1 | materna`stype' == 1)
	
	foreach type in  M CN S H B {

		* ----------------------- *
		* For Regression Analysis *
		* ----------------------- *
		* Open necessary files
		file open regression_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/reg_child_`type'_`stype'.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Children: Regression Analysis"
		sdreganalysis, stype("`stype'") type("`type'") reglist("${reglist}") cohort("child")
	
		* Close necessary files
		file close regression_`type'_`stype' 
		
		
	/*	
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
		file close aipw_`type'_`stype'	*/
	
	
	}
	
	local stype_switch = 0
}

restore

