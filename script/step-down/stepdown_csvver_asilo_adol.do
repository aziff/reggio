/* --------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - Step-Down for Adolescent Cohort 
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
include "${here}/function/sd_mDID_analysis"
include "${here}/function/matchedDID"
include "${here}/function/rwolfmDID"
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

* Generate asilo interaction variable
generate xaReggioMuni = Reggio * asiloMuni

* ---------------------------------------------------------------------------- *
* 					Reggio Muni vs. None:	Adolescent						   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
preserve
keep if (Cohort == 3)  

local stype_switch = 1
foreach stype in Muni Other {
	
	* Set necessary global variables
	global X					asiloMuni
	global reglist				None BIC Full DidPm DidPv 
	global psmlist				PSMR PSMPm PSMPv
	global kernellist			KMR KMPm KMPv
	global cohort				adol

	global XNone				asiloMuni	
	global XBIC					asiloMuni		
	global XFull				asiloMuni	
	global XPSMR				asiloMuni
	global XPSMPm				asiloMuni
	global XPSMPv				asiloMuni
	global XKMR					asiloMuni
	global XKMPm				asiloMuni
	global XKMPv				asiloMuni
	global XDidPm				xaReggioMuni
	global XDidPv				xaReggioMuni

	global controlsNone
	global controlsBIC			${bic_asilo_adol_baseline_vars}
	global controlsFull			${adol_baseline_vars}
	global controlsPSMR			${bic_asilo_adol_baseline_vars}
	global controlsPSMPm		${bic_asilo_adol_baseline_vars}
	global controlsPSMPv		${bic_asilo_adol_baseline_vars}
	global controlsKMR			${bic_asilo_adol_baseline_vars}
	global controlsKMPm			${bic_asilo_adol_baseline_vars}
	global controlsKMPv			${bic_asilo_adol_baseline_vars}
	global controlsDidPm		Reggio asiloMuni ${bic_asilo_adol_baseline_vars}
	global controlsDidPv		Reggio asiloMuni ${bic_asilo_adol_baseline_vars}

	global ifconditionNone	 	(Reggio == 1) & (((asiloNone == 1) & (materna`stype' == 1)) | ((asiloMuni == 1) & (materna`stype' == 1)))
	global ifconditionBIC		${ifconditionNone}
	global ifconditionFull		${ifconditionNone}
	global ifconditionPSMR		${ifconditionNone}
	global ifconditionPSMPm		((Reggio == 1) & (asiloMuni == 1) & (materna`stype' == 1)) | ((Parma == 1) & (asiloNone == 1) & (materna`stype' == 1)) 
	global ifconditionPSMPv		((Reggio == 1) & (asiloMuni == 1) & (materna`stype' == 1)) | ((Padova == 1) & (asiloNone == 1) & (materna`stype' == 1)) 
	global ifconditionKMR		${ifconditionNone}
	global ifconditionKMPm		((Reggio == 1) & (asiloMuni == 1) & (materna`stype' == 1)) | ((Parma == 1) & (asiloNone == 1) & (materna`stype' == 1)) 
	global ifconditionKMPv		((Reggio == 1) & (asiloMuni == 1) & (materna`stype' == 1)) | ((Padova == 1) & (asiloNone == 1) & (materna`stype' == 1))
	global ifconditionDidPm		(Reggio == 1 | Parma == 1)    & (((asiloNone == 1) & (materna`stype' == 1)) | ((asiloMuni == 1) & (materna`stype' == 1)))
	global ifconditionDidPv		(Reggio == 1 | Padova == 1)    & (((asiloNone == 1) & (materna`stype' == 1)) | ((asiloMuni == 1) & (materna`stype' == 1))) 

	
	*--------------------*
	* matchedDID Globals
	*--------------------*
	global matchedDIDlist					mDIDasiloAdolPM mDIDasiloAdolPV
	
	*Analysis 1:
	global mainCity_mDIDasiloAdolPM			Reggio
	global mainCohort_mDIDasiloAdolPM		Adol
	global mainTreat_mDIDasiloAdolPM		asiloMuni
	global mainControl_mDIDasiloAdolPM		asiloNone
	global compCity_mDIDasiloAdolPM			Parma
	global compCohort_mDIDasiloAdolPM		Adol
	global compTreat_mDIDasiloAdolPM		asiloMuni
	global compControl_mDIDasiloAdolPM		asiloNone
	global controlsmDIDasiloAdolPM			${bic_asilo_adol_baseline_vars}
	global pre_restrict						& materna`stype' == 1
	
	*Analysis 2:
	global mainCity_mDIDasiloAdolPV			Reggio
	global mainCohort_mDIDasiloAdolPV		Adol
	global mainTreat_mDIDasiloAdolPV		asiloMuni
	global mainControl_mDIDasiloAdolPV		asiloNone
	global compCity_mDIDasiloAdolPV			Padova
	global compCohort_mDIDasiloAdolPV		Adol
	global compTreat_mDIDasiloAdolPV		asiloMuni
	global compControl_mDIDasiloAdolPV		asiloNone
	global controlsmDIDasiloAdolPV			${bic_asilo_adol_baseline_vars}
	
	foreach type in  M /*CN S H B*/ {
	/*
		* ----------------------- *
		* For Regression Analysis *
		* ----------------------- *
		* Open necessary files
		file open regression_`type'_`stype' using "${git_reggio}/output/multiple-methods/stepdown/csv/reg_adol_`type'_`stype'_asilo_sd.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Adolescent: Regression Analysis"
		sdreganalysis, stype("`stype'") type("`type'") reglist("${reglist}") cohort("adol")
	
		* Close necessary files
		file close regression_`type'_`stype' 
		
	
	
		* ----------------------- *
		* For PSM Analysis 		  *
		* ----------------------- *
		* Open necessary files
		file open psm_`type'_`stype' using "${git_reggio}/output/multiple-methods/stepdown/csv/psm_adol_`type'_`stype'_asilo_sd.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Adolescent: PSM Analysis"
		sdpsmanalysis, stype("`stype'") type("`type'") psmlist("${psmlist}") cohort("adol")
	
		* Close necessary files
		file close psm_`type'_`stype' 
		
	
		
		* ----------------------- *
		* For Kernel Analysis 	  *
		* ----------------------- *
		* Open necessary files
		file open kern_`type'_`stype' using "${git_reggio}/output/multiple-methods/stepdown/csv/kern_adol_`type'_`stype'_asilo_sd.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Adolescent: Kernel Analysis"
		sdkernelanalysis, stype("`stype'") type("`type'") kernellist("${kernellist}") cohort("adol")
	
		* Close necessary files
		file close kern_`type'_`stype' 
	
	*/
	
		foreach mm in kernel psm{
			foreach comp_in in ${matchedDIDlist}{
				* ------------------------ *
				* For Matched DID Analysis *
				* ------------------------ *
				* Open necessary files
				#delimit ;
				file open mDID_`type'_`stype' using 
				"${git_reggio}/output/multiple-methods/stepdown/csv/mDID`mm'_${mainCohort_`comp_in'}_${compCity_`comp_in'}_`type'_`stype'_asilo.csv", 
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

