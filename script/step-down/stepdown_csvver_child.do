/* --------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - Step-Down for Children Cohort 
* Authors: Jessica Yu Kyung Koh
* Created: 06/16/2016
* Edited:  02/14/2017

* Note: This execution do file performs diff-in-diff estimates and generates tables
        by using "multipleanalysis" command that is programmed in 
		"reggio/script/ols/function/multipleanalysis.do"  
		To understand how the command is coded, please refer to the above do file.
* --------------------------------------------------------------------------- */

clear all

cap file 	close outcomes
cap log 	close

* Capture install commands 
cap which rwolf
if _rc ssc install rwolf
cap which psmatch2
if _rc ssc install psmatch2

global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio


global here : pwd

use "${data_reggio}/Reggio_reassigned"

* Include scripts and functions
include "${here}/../macros" 
include "${here}/function/sdreganalysis"
include "${here}/function/sdaipwanalysis"
include "${here}/function/sdpsmanalysis"
include "${here}/function/sdkernelanalysis"
include "${here}/function/writematrix"
include "${here}/function/rwolfpsm"
include "${here}/function/rwolfaipw"
include "${here}/function/rwolfkernel"
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
keep if (Cohort == 1)  //| (Cohort == 2)  check if I need to include migrant cohort

local stype_switch = 1
foreach stype in Other Stat Reli {
	
	* Set necessary global variables
	global X					maternaMuni
	global reglist				None BIC Full DidPm DidPv  // It => Italians, Mg => Migrants
	global psmlist				PSMR PSMPm PSMPv
	global kernellist			KMR KMPm KMPv
	global aipwlist				AIPW 
	global cohort				child

	global XNone				maternaMuni
	global XBIC					maternaMuni		
	global XFull				maternaMuni		
	global XDidPm				xmMuniReggio
	global XDidPv				xmMuniReggio 	
	global XPSMR				maternaMuni
	global XPSMPm				Reggio
	global XPSMPv				Reggio
	global XKMR					maternaMuni
	global XKMPm				Reggio
	global XKMPv				Reggio

	global keepNone				maternaMuni
	global keepBIC				maternaMuni
	global keepFull				maternaMuni

	global keepDidPm			xmMuniReggio
	global keepDidPv			xmMuniReggio
	global keepPSM				maternaMuni

	global controlsNone
	global controlsBIC			${bic_child_baseline_vars}
	global controlsFull			${child_baseline_vars}
	global controlsDidPm		maternaMuni Reggio ${bic_child_baseline_did_vars}
	global controlsDidPv		maternaMuni Reggio ${bic_child_baseline_did_vars}
	global controlsPSMR			${bic_child_baseline_vars}
	global controlsPSMPm		${bic_child_baseline_vars}
	global controlsPSMPv		${bic_child_baseline_vars}
	global controlsKMR			${bic_child_baseline_vars}
	global controlsKMPm			${bic_child_baseline_vars}
	global controlsKMPv			${bic_child_baseline_vars}
	global controlsAIPW			${bic_child_baseline_vars}
	
	local  Other_psm			materna
	local  Stat_psm				maternaStat
	local  Reli_psm				maternaReli

	global ifconditionNone 		(Reggio == 1) & (maternaMuni == 1 | materna`stype' == 1)
	global ifconditionBIC		${ifconditionNone}
	global ifconditionFull		${ifconditionNone}
	global ifconditionPSMR		${ifconditionNone}
	global ifconditionPSMPm		((Reggio == 1) & (maternaMuni == 1)) | ((Parma == 1) & (``stype'_psm' == 1))
	global ifconditionPSMPv		((Reggio == 1) & (maternaMuni == 1)) | ((Padova == 1) & (``stype'_psm' == 1))
	global ifconditionKMR		${ifconditionNone}
	global ifconditionKMPm		((Reggio == 1) & (maternaMuni == 1)) | ((Parma == 1) & (``stype'_psm' == 1))
	global ifconditionKMPv		((Reggio == 1) & (maternaMuni == 1)) | ((Padova == 1) & (``stype'_psm' == 1))
	global ifconditionDidPm		(Reggio == 1 | Parma == 1)    
	global ifconditionDidPv		(Reggio == 1 | Padova == 1)    & (maternaMuni == 1 | materna`stype' == 1)
	global ifconditionAIPW	 	(Reggio == 1)  & (maternaMuni == 1 | materna`stype' == 1)
	
	foreach type in  M CN S H B {

	/*	* ----------------------- *
		* For Regression Analysis *
		* ----------------------- *
		* Open necessary files
		file open regression_`type'_`stype' using "${git_reggio}/output/multiple-methods/stepdown/csv/reg_child_`type'_`stype'_sd.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Children: Regression Analysis"
		sdreganalysis, stype("`stype'") type("`type'") reglist("${reglist}") cohort("child")
	
		* Close necessary files
		file close regression_`type'_`stype' 
		
	
	
		* ----------------------- *
		* For PSM Analysis 		  *
		* ----------------------- *
		* Open necessary files
		file open psm_`type'_`stype' using "${git_reggio}/output/multiple-methods/stepdown/csv/psm_child_`type'_`stype'_sd.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Children: PSM Analysis"
		sdpsmanalysis, stype("`stype'") type("`type'") psmlist("${psmlist}") cohort("child")
	
		* Close necessary files
		file close psm_`type'_`stype' */
		
		
		
		* ----------------------- *
		* For Kernel Analysis 	  *
		* ----------------------- *
		* Open necessary files
		file open kern_`type'_`stype' using "${git_reggio}/output/multiple-methods/stepdown/csv/kern_child_`type'_`stype'.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Children: Kernel Analysis"
		sdkernelanalysis, stype("`stype'") type("`type'") kernellist("${kernellist}") cohort("child")
	
		* Close necessary files
		file close kern_`type'_`stype'
	
	
	}
	
	local stype_switch = 0
}

restore

