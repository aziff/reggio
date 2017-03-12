/* --------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - Step-Down for Adult-50 Cohort
* Authors: Jessica Yu Kyung Koh
* Created: 06/16/2016
* Edited:  02/15/2017

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


global cohort			adult


* ---------------------------------------------------------------------------- *
* 					Comparison with Age-50 Cohort (DID)						   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
preserve
keep if (Cohort == 4) | (Cohort == 5) | (Cohort == 6) 

local stype_switch = 1
foreach stype in Other {
	
	* Interact age30 or age40 and materna
	generate int30Muni = Cohort_Adult30 * materna
	generate int40Muni = Cohort_Adult40 * materna
	
	* Set necessary global variables
	global reglist				RDiD40 RDiD30
	
	global XRDiD40				int40Muni
	global XRDiD30				int30Muni
	global XPmDiD40				xmMuniReggio
	global XPmDiD30				xmMuniReggio
	global XPvDiD40				xmMuniReggio
	global XPvDiD30				xmMuniReggio
	
	global controlsRDiD40		materna Cohort_Adult40 ${bic_adol_baseline_did_vars}
	global controlsRDiD30		materna Cohort_Adult30 ${bic_adol_baseline_did_vars}
	global controlsPmDiD40		materna Reggio ${bic_adol_baseline_did_vars}
	global controlsPmDiD30		materna Reggio ${bic_adol_baseline_did_vars}
	global controlsPvDiD40		materna Reggio ${bic_adol_baseline_did_vars}
	global controlsPvDiD30		materna Reggio ${bic_adol_baseline_did_vars}
	

	global ifconditionRDiD40	(Reggio == 1) & (((Cohort == 5) & (maternaMuni == 1 | maternaNone == 1)) | ((Cohort == 6) & (maternaOther == 1 | maternaNone == 1)))
	global ifconditionRDiD30	(Reggio == 1) & (((Cohort == 4) & (maternaMuni == 1 | maternaNone == 1)) | ((Cohort == 6) & (maternaOther == 1 | maternaNone == 1)))
	global ifconditionPmDiD40	((Reggio == 1) & (Cohort == 5) & (maternaMuni == 1 | maternaNone == 1)) | ((Parma == 1) & (Cohort == 6))
	global ifconditionPmDiD30	((Reggio == 1) & (Cohort == 4) & (maternaMuni == 1 | maternaNone == 1)) | ((Parma == 1) & (Cohort == 6))
	global ifconditionPvDiD40	((Reggio == 1) & (Cohort == 5) & (maternaMuni == 1 | maternaNone == 1)) | ((Padova == 1) & (Cohort == 6))
	global ifconditionPvDiD30	((Reggio == 1) & (Cohort == 4) & (maternaMuni == 1 | maternaNone == 1)) | ((Padova == 1) & (Cohort == 6))
	
	*--------------------*
	* matchedDID Globals
	*--------------------*
	global matchedDIDlist			mDID_30RE_50RE /*mDID_40RE_50RE mDID_30RE_50PM mDID_40RE_50PM mDID_30RE_50PV mDID_40RE_50PV*/
	
	*Analysis 1:
	global mainCity_mDID_30RE_50RE			Reggio
	global mainCohort_mDID_30RE_50RE		Adult30
	global mainTreat_mDID_30RE_50RE			maternaMuni
	global mainControl_mDID_30RE_50RE		maternaNone
	global compCity_mDID_30RE_50RE			Reggio
	global compCohort_mDID_30RE_50RE		Adult50
	global compTreat_mDID_30RE_50RE			maternaOther
	global compControl_mDID_30RE_50RE		maternaNone
	global controlsmDID_30RE_50RE			${bic_adult_baseline_vars}	
	global pre_restrict						/* Only include for asilo*/
	
	*Analysis 2:
	global mainCity_mDID_40RE_50RE			Reggio
	global mainCohort_mDID_40RE_50RE		Adult40
	global mainTreat_mDID_40RE_50RE			maternaMuni
	global mainControl_mDID_40RE_50RE		maternaNone
	global compCity_mDID_40RE_50RE			Reggio
	global compCohort_mDID_40RE_50RE		Adult50
	global compTreat_mDID_40RE_50RE			maternaOther
	global compControl_mDID_40RE_50RE		maternaNone
	global controlsmDID_40RE_50RE			${bic_adult_baseline_vars}		
	
	*Analysis 3:
	global mainCity_mDID_30RE_50PM			Reggio
	global mainCohort_mDID_30RE_50PM		Adult30
	global mainTreat_mDID_30RE_50PM			maternaMuni
	global mainControl_mDID_30RE_50PM		maternaNone
	global compCity_mDID_30RE_50PM			Parma
	global compCohort_mDID_30RE_50PM		Adult50
	global compTreat_mDID_30RE_50PM			maternaOther
	global compControl_mDID_30RE_50PM		maternaNone
	global controlsmDID_30RE_50PM			${bic_adult_baseline_vars}	
	
	*Analysis 4:
	global mainCity_mDID_40RE_50PM			Reggio
	global mainCohort_mDID_40RE_50PM		Adult40
	global mainTreat_mDID_40RE_50PM			maternaMuni
	global mainControl_mDID_40RE_50PM		maternaNone
	global compCity_mDID_40RE_50PM			Padova
	global compCohort_mDID_40RE_50PM		Adult50
	global compTreat_mDID_40RE_50PM			maternaOther
	global compControl_mDID_40RE_50PM		maternaNone
	global controlsmDID_40RE_50PM			${bic_adult_baseline_vars}		
	
	*Analysis 5:
	global mainCity_mDID_30RE_50PV			Reggio
	global mainCohort_mDID_30RE_50PV		Adult30
	global mainTreat_mDID_30RE_50PV			maternaMuni
	global mainControl_mDID_30RE_50PV		maternaNone
	global compCity_mDID_30RE_50PV			Padova
	global compCohort_mDID_30RE_50PV		Adult50
	global compTreat_mDID_30RE_50PV			maternaOther
	global compControl_mDID_30RE_50PV		maternaNone
	global controlsmDID_30RE_50PV			${bic_adult_baseline_vars}	
	
	*Analysis 6:
	global mainCity_mDID_40RE_50PV			Reggio
	global mainCohort_mDID_40RE_50PV		Adult40
	global mainTreat_mDID_40RE_50PV			maternaMuni
	global mainControl_mDID_40RE_50PV		maternaNone
	global compCity_mDID_40RE_50PV			Padova
	global compCohort_mDID_40RE_50PV		Adult50
	global compTreat_mDID_40RE_50PV			maternaOther
	global compControl_mDID_40RE_50PV		maternaNone
	global controlsmDID_40RE_50PV			${bic_adult_baseline_vars}		
	
	foreach type in   M E W L H N S {

		* ----------------------- *
		* For Regression Analysis *
		* ----------------------- *
		* Open necessary files
		cap file close regression_`type'_`stype'
		file open regression_`type'_`stype' using "${git_reggio}/output/multiple-methods/stepdown/csv/did_adult50_`type'_`stype'_sd.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Adult-50: Regression Analysis"
		sdreganalysis, stype("`stype'") type("`type'") reglist("${reglist}") cohort("adult")
	
		* Close necessary files
		file close regression_`type'_`stype' 
	
	/*
		foreach mm in kernel psm{
			foreach comp_in in ${matchedDIDlist}{
				* ------------------------ *
				* For Matched DID Analysis *
				* ------------------------ *
				* Open necessary files
				#delimit ;
				file open mDID_`type'_`stype' using 
				"${git_reggio}/output/multiple-methods/stepdown/csv/mDID`mm'_${compCohort_`comp_in'}_${mainCohort_`comp_in'}_${compCity_`comp_in'}_`type'_`stype'.csv", 
				write replace;
				#delimit cr
				
				* Run Multiple Analysis
				di "Estimating `type' for ${mainCohort_`comp_in'}: Matched DID Analysis"
				sd_mDID_analysis, stype("`stype'") type("`type'") cohort("adult") comp("`comp_in'") matchingmethod("`mm'") 
			
				* Close necessary files
				file close mDID_`type'_`stype' 
			}
		}		*/
		
	}
	
	local stype_switch = 0
}

restore

/*
* ---------------------------------------------------------------------------- *
* 					Comparison with Age-50 Cohort (NO DID)					   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
preserve
keep if (Cohort == 4) | (Cohort == 5) | (Cohort == 6) 

local stype_switch = 1
foreach stype in None Other Reli {
	
	* Set necessary global variables
	global reglist				OLS40 OLS30
	global psmlist				NNPSM40 NNPSM30
	global kernellist			KM40 KM30

	global XOLS40				maternaMuni
	global XOLS30				maternaMuni	
	global XNNPSM40				maternaMuni
	global XNNPSM30				maternaMuni
	global XKM40				maternaMuni
	global XKM30				maternaMuni
	
	global controlsOLS40		${bic_adult_baseline_vars}
	global controlsOLS30		${bic_adult_baseline_vars}
	global controlsNNPSM40		${bic_adult_baseline_vars}
	global controlsNNPSM30		${bic_adult_baseline_vars}
	global controlsKM40			${bic_adult_baseline_vars}
	global controlsKM30			${bic_adult_baseline_vars}

	global ifconditionOLS40		(Reggio == 1) & (((Cohort == 5) & (maternaMuni == 1)) | ((Cohort == 6) & (materna`stype' == 1)))
	global ifconditionOLS30		(Reggio == 1) & (((Cohort == 4) & (maternaMuni == 1)) | ((Cohort == 6) & (materna`stype' == 1)))
	global ifconditionNNPSM40	(Reggio == 1) & (((Cohort == 5) & (maternaMuni == 1)) | ((Cohort == 6) & (materna`stype' == 1)))
	global ifconditionNNPSM30	(Reggio == 1) & (((Cohort == 4) & (maternaMuni == 1)) | ((Cohort == 6) & (materna`stype' == 1)))
	global ifconditionKM40		(Reggio == 1) & (((Cohort == 5) & (maternaMuni == 1)) | ((Cohort == 6) & (materna`stype' == 1)))
	global ifconditionKM30		(Reggio == 1) & (((Cohort == 4) & (maternaMuni == 1)) | ((Cohort == 6) & (materna`stype' == 1)))
	

	foreach type in  M E W L H N S {

		* ----------------------- *
		* For Regression Analysis *
		* ----------------------- *
		* Open necessary files
		cap file close regression_`type'_`stype'
		file open regression_`type'_`stype' using "${git_reggio}/output/multiple-methods/stepdown/csv/reg_adult50_`type'_`stype'_sd.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Adult-50: Regression Analysis"
		sdreganalysis, stype("`stype'") type("`type'") reglist("${reglist}") cohort("adult")
	
		* Close necessary files
		file close regression_`type'_`stype' 
		
		
		* ----------------------- *
		* For PSM Analysis 		  *
		* ----------------------- *
		* Open necessary files
		file open psm_`type'_`stype' using "${git_reggio}/output/multiple-methods/stepdown/csv/psm_adult50_`type'_`stype'_sd.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Adult-50: PSM Analysis"
		sdpsmanalysis, stype("`stype'") type("`type'") psmlist("${psmlist}") cohort("adult")
	
		* Close necessary files
		file close psm_`type'_`stype'
		
		
		* ----------------------- *
		* For Kernel Analysis 	  *
		* ----------------------- *
		* Open necessary files
		file open kern_`type'_`stype' using "${git_reggio}/output/multiple-methods/stepdown/csv/kern_adult50_`type'_`stype'.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Adult-50: PSM Analysis"
		sdkernelanalysis, stype("`stype'") type("`type'") kernellist("${kernellist}") cohort("adult")
	
		* Close necessary files
		file close kern_`type'_`stype'
		
		
	
	}
	
	local stype_switch = 0
}

restore






	




