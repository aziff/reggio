/* --------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - Step-Down for Adolescent Cohort 
* Authors: Jessica Yu Kyung Koh
* Created: 06/16/2016
* Edited:  01/08/2017

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
include "${here}/function/sd_mDID_analysis"
include "${here}/function/matchedDID"
include "${here}/function/rwolfmDID"
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


global cohort			adol


* ---------------------------------------------------------------------------- *
* 					Reggio Muni vs. None:	Adolescent						   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
preserve
keep if (Cohort == 3)

local stype_switch = 1
foreach stype in Other Stat Reli {
	
	* Set necessary global variables
	global X					maternaMuni
	global reglist				None BIC Full DidPm DidPv // It => Italians, Mg => Migrants
	global aipwlist				AIPW
	global psmlist				PSMR PSMPm PSMPv
	global kernellist			KMR KMPm KMPv

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

	global controlsNone
	global controlsBIC			${bic_adol_baseline_vars}
	global controlsFull			${adol_baseline_vars}
	global controlsDidPm		maternaMuni Reggio ${bic_adol_baseline_vars}
	global controlsDidPv		maternaMuni Reggio ${bic_adol_baseline_vars}
	global controlsAIPW			${bic_adol_baseline_vars}
	global controlsPSMR			${bic_adol_baseline_vars}
	global controlsPSMPm		${bic_adol_baseline_vars}
	global controlsPSMPv		${bic_adol_baseline_vars}
	global controlsKMR			${bic_adol_baseline_vars}
	global controlsKMPm			${bic_adol_baseline_vars}
	global controlsKMPv			${bic_adol_baseline_vars}
	global controlsAIPW			${bic_adol_baseline_vars}
	
	local  Other_psm			materna
	local  Stat_psm				maternaStat
	local  Reli_psm				maternaReli

	global ifconditionNone 		(Reggio == 1)   & (maternaMuni == 1 | materna`stype' == 1)
	global ifconditionBIC		${ifconditionNone}
	global ifconditionFull		${ifconditionNone}
	global ifconditionPSMR		${ifconditionNone}
	global ifconditionPSMPm 	((Reggio == 1) & (maternaMuni == 1)) | ((Parma == 1) & (``stype'_psm' == 1))
	global ifconditionPSMPv		((Reggio == 1) & (maternaMuni == 1)) | ((Padova == 1) & (``stype'_psm' == 1))
	global ifconditionKMR		${ifconditionNone}
	global ifconditionKMPm 		((Reggio == 1) & (maternaMuni == 1)) | ((Parma == 1) & (``stype'_psm' == 1))
	global ifconditionKMPv		((Reggio == 1) & (maternaMuni == 1)) | ((Padova == 1) & (``stype'_psm' == 1))
	global ifconditionDidPm		(Reggio == 1 | Parma == 1) & (maternaMuni == 1 | materna`stype' == 1)
	global ifconditionDidPv		(Reggio == 1 | Padova == 1) & (maternaMuni == 1 | materna`stype' == 1)
	global ifconditionAIPW 	    (Reggio == 1) & (maternaMuni == 1 | materna`stype' == 1)
	
	*--------------------*
	* matchedDID Globals
	*--------------------*
	global matchedDIDlist				mDIDAdolPM mDIDAdolPV
	
	*Analysis 1:
	global mainCity_mDIDAdolPM			Reggio
	global mainCohort_mDIDAdolPM		Adol
	global mainTreat_mDIDAdolPM			maternaMuni
	global mainControl_mDIDAdolPM		materna`stype'
	global compCity_mDIDAdolPM			Parma
	global compCohort_mDIDAdolPM		Adol
	global compTreat_mDIDAdolPM			maternaMuni
	global compControl_mDIDAdolPM		maternaOther
	global controlsmDIDAdolPM			${bic_adol_baseline_vars}
	global pre_restrict					/* Only include for asilo*/
	
	*Analysis 2:
	global mainCity_mDIDAdolPV			Reggio
	global mainCohort_mDIDAdolPV		Adol
	global mainTreat_mDIDAdolPV			maternaMuni
	global mainControl_mDIDAdolPV		materna`stype'
	global compCity_mDIDAdolPV			Padova
	global compCohort_mDIDAdolPV		Adol
	global compTreat_mDIDAdolPV			maternaMuni
	global compControl_mDIDAdolPV		maternaOther
	global controlsmDIDAdolPV			${bic_adol_baseline_vars}
		
	foreach type in  M CN S H B {
	/*

		* ----------------------- *
		* For Regression Analysis *
		* ----------------------- *
		* Open necessary files
		cap file close regression_`type'_`stype'
		file open regression_`type'_`stype' using "${git_reggio}/output/multiple-methods/stepdown/csv/reg_adol_`type'_`stype'_sd.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Children: Regression Analysis"
		sdreganalysis, stype("`stype'") type("`type'") reglist("${reglist}") cohort("adol")
	
		* Close necessary files
		file close regression_`type'_`stype' 
		
		
		
		
		* ----------------------- *
		* For PSM Analysis 		  *
		* ----------------------- *
		* Open necessary files
		file open psm_`type'_`stype' using "${git_reggio}/output/multiple-methods/stepdown/csv/psm_adol_`type'_`stype'_sd.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Adult: PSM Analysis"
		sdpsmanalysis, stype("`stype'") type("`type'") psmlist("${psmlist}") cohort("adol")
	
		* Close necessary files
		file close psm_`type'_`stype'
		
		
		* ----------------------- *
		* For Kernel Analysis 	  *
		* ----------------------- *
		* Open necessary files
		file open kern_`type'_`stype' using "${git_reggio}/output/multiple-methods/stepdown/csv/kern_adol_`type'_`stype'.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Children: PSM Analysis"
		sdkernelanalysis, stype("`stype'") type("`type'") kernellist("${kernellist}") cohort("adol")
	
		* Close necessary files
		file close kern_`type'_`stype'
*/	

		* ------------------------ *
		* For Matched DID Analysis *
		* ------------------------ *
		foreach mm in kernel psm{
			foreach comp_in in ${matchedDIDlist}{
				
				* Open necessary files
				#delimit ;
				file open mDID_`type'_`stype' using 
				"${git_reggio}/output/multiple-methods/stepdown/csv/mDID`mm'_${mainCohort_`comp_in'}_${compCity_`comp_in'}_`type'_`stype'.csv", 
				write replace;
				#delimit cr
				
				* Run Multiple Analysis
				di "Estimating `type' for ${mainCohort_`comp_in'}: Matched DID Analysis"
				sd_mDID_analysis, stype("`stype'") type("`type'") cohort("adol") comp("`comp_in'") matchingmethod("`mm'") 
			
				* Close necessary files
				file close mDID_`type'_`stype'
			}
		}	
		
	
	}
	
	local stype_switch = 0
}

restore








