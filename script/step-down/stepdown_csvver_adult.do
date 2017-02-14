/* --------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - Step-Down for Adult Cohort 
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
* 					Reggio Muni vs. None:	Adult	30						   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
preserve
keep if (Cohort == 4) 
drop if asilo == 1 // dropping those who went to infant-toddler centers

local stype_switch = 1
foreach stype in Other None /*Stat Reli*/ {
	
	* Set necessary global variables
	global X					maternaMuni
	global reglist				None30 BIC30 Full30 DidPm30 DidPv30 
	global aipwlist				AIPW30 
	global psmlist				PSM30R PSM30Pm PSM30Pv
	global kernellist			KM30R KM30Pm KM30Pv

	global XNone30				maternaMuni		
	global XBIC30				maternaMuni		
	global XFull30				maternaMuni		
	global XPSM30R				maternaMuni
	global XPSM30Pm				Reggio
	global XPSM30Pv				Reggio
	global XKM30R				maternaMuni
	global XKM30Pm				Reggio
	global XKM30Pv				Reggio
	global XDidPm30				xmMuniReggio 	
	global XDidPv30				xmMuniReggio  	

	global controlsNone30
	global controlsBIC30		${bic_adult_baseline_vars}
	global controlsFull30		${adult_baseline_vars}
	global controlsPSM30R		${bic_adult_baseline_vars}
	global controlsPSM30Pm		${bic_adult_baseline_vars}
	global controlsPSM30Pv		${bic_adult_baseline_vars}	
	global controlsKM30R		${bic_adult_baseline_vars}
	global controlsKM30Pm		${bic_adult_baseline_vars}
	global controlsKM30Pv		${bic_adult_baseline_vars}	
	global controlsDidPm30		maternaMuni Reggio ${bic_adult_baseline_vars}
	global controlsDidPv30		maternaMuni Reggio ${bic_adult_baseline_vars}
	global controlsAIPW30		${bic_adult_baseline_vars}	

	local  Other_psm			materna
	local  None_psm				maternaNone
	local  Stat_psm				maternaStat
	local  Reli_psm				maternaReli
	
	global ifconditionNone30 	(Reggio == 1) & (Cohort_Adult30 == 1)  & (maternaMuni == 1 | materna`stype' == 1)
	global ifconditionBIC30		${ifconditionNone30} 
	global ifconditionFull30	${ifconditionNone30}
	global ifconditionPSM30R	${ifconditionNone30}
	global ifconditionPSM30Pm	((Reggio == 1) & (maternaMuni == 1)) | ((Parma == 1) & (``stype'_psm' == 1))
	global ifconditionPSM30Pv	((Reggio == 1) & (maternaMuni == 1)) | ((Padova == 1) & (``stype'_psm' == 1))
	global ifconditionKM30R		${ifconditionNone30}
	global ifconditionKM30Pm	((Reggio == 1) & (maternaMuni == 1)) | ((Parma == 1) & (``stype'_psm' == 1))
	global ifconditionKM30Pv	((Reggio == 1) & (maternaMuni == 1)) | ((Padova == 1) & (``stype'_psm' == 1))
	global ifconditionDidPm30	(Reggio == 1 | Parma == 1) & (Cohort_Adult30 == 1)  & (maternaMuni == 1 | materna`stype' == 1)
	global ifconditionDidPv30	(Reggio == 1 | Padova == 1) & (Cohort_Adult30 == 1)  & (maternaMuni == 1 | materna`stype' == 1)
	global ifconditionAIPW30 	(Reggio == 1) & (Cohort_Adult30 == 1)   & (maternaMuni == 1 | materna`stype' == 1)

		
	foreach type in  M E W L H N S {

		* ----------------------- *
		* For Regression Analysis *
		* ----------------------- *
		* Open necessary files
		cap file close regression_`type'_`stype'
		file open regression_`type'_`stype' using "${git_reggio}/output/multiple-methods/stepdown/csv/reg_adult30_`type'_`stype'_sd.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Adult: Regression Analysis"
		sdreganalysis, stype("`stype'") type("`type'") reglist("${reglist}") cohort("adult")
	
		* Close necessary files
		file close regression_`type'_`stype' 
		
		
		
		* ----------------------- *
		* For PSM Analysis 		  *
		* ----------------------- *
		* Open necessary files
		file open psm_`type'_`stype' using "${git_reggio}/output/multiple-methods/stepdown/csv/psm_adult30_`type'_`stype'_sd.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Adult: PSM Analysis"
		sdpsmanalysis, stype("`stype'") type("`type'") psmlist("${psmlist}") cohort("adult")
	
		* Close necessary files
		file close psm_`type'_`stype'
		
		
		* ----------------------- *
		* For Kernel Analysis 	  *
		* ----------------------- *
		* Open necessary files
		file open kern_`type'_`stype' using "${git_reggio}/output/multiple-methods/stepdown/csv/kern_adult30_`type'_`stype'.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Children: PSM Analysis"
		sdkernelanalysis, stype("`stype'") type("`type'") kernellist("${kernellist}") cohort("adult")
	
		* Close necessary files
		file close kern_`type'_`stype'
		
	}
	
	local stype_switch = 0
}

restore








* ---------------------------------------------------------------------------- *
* 					Reggio Muni vs. None:	Adult40		NO DID				   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
preserve
keep if (Cohort == 5) 
drop if asilo == 1 // dropping those who went to infant-toddler centers

local stype_switch = 1
foreach stype in Other /*Stat Reli*/ {
	
	* Set necessary global variables
	global X					maternaMuni
	global reglist				None40 BIC40 Full40
	global aipwlist				AIPW40 
	global psmlist				PSM40R PSM40Pm PSM40Pv
	global kernellist			KM40R KM40Pm KM40Pv

	global XNone40				maternaMuni		
	global XBIC40				maternaMuni		
	global XFull40				maternaMuni		
	global XPSM40R				maternaMuni
	global XPSM40Pm				Reggio
	global XPSM40Pv				Reggio
	global XKM40R				maternaMuni
	global XKM40Pm				Reggio
	global XKM40Pv				Reggio
	*global XDidPm40			maternaMuni	Reggio xmMuniReggio	
	*global XDidPv40			maternaMuni	Reggio xmMuniReggio		

	global controlsNone40
	global controlsBIC40		${bic_adult_baseline_vars}
	global controlsFull40		${adult_baseline_vars}
	global controlsPSM40R		${bic_adult_baseline_vars}
	global controlsPSM40Pm		${bic_adult_baseline_vars}
	global controlsPSM40Pv		${bic_adult_baseline_vars}
	global controlsKM40R		${bic_adult_baseline_vars}
	global controlsKM40Pm		${bic_adult_baseline_vars}
	global controlsKM40Pv		${bic_adult_baseline_vars}
	global controlsDidPm40		${bic_adult_baseline_vars}
	global controlsDidPv40		${bic_adult_baseline_vars}
	global controlsAIPW40		${bic_adult_baseline_vars}


	global ifconditionNone40 	(Reggio == 1) & (Cohort_Adult40 == 1)  & (maternaMuni == 1 | materna`stype' == 1)
	global ifconditionBIC40		${ifconditionNone40} 
	global ifconditionFull40	${ifconditionNone40}
	global ifconditionPSM40R	${ifconditionNone40}
	global ifconditionPSM40Pm	((Reggio == 1) & (maternaMuni == 1)) | ((Parma == 1) & (``stype'_psm' == 1))
	global ifconditionPSM40Pv	((Reggio == 1) & (maternaMuni == 1)) | ((Padova == 1) & (``stype'_psm' == 1))
	global ifconditionKM40R		${ifconditionNone40}
	global ifconditionKM40Pm	((Reggio == 1) & (maternaMuni == 1)) | ((Parma == 1) & (``stype'_psm' == 1))
	global ifconditionKM40Pv	((Reggio == 1) & (maternaMuni == 1)) | ((Padova == 1) & (``stype'_psm' == 1))
	global ifconditionAIPW40 	(Reggio == 1) & (Cohort_Adult40 == 1)   & (maternaMuni == 1 | materna`stype' == 1)

		
	foreach type in  M E W L H N S {

		* ----------------------- *
		* For Regression Analysis *
		* ----------------------- *
		* Open necessary files
		cap file close regression_`type'_`stype'
		file open regression_`type'_`stype' using "${git_reggio}/output/multiple-methods/stepdown/csv/reg_adult40_`type'_`stype'_sd.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Children: Regression Analysis"
		sdreganalysis, stype("`stype'") type("`type'") reglist("${reglist}") cohort("adult")
	
		* Close necessary files
		file close regression_`type'_`stype' 
		
		* ----------------------- *
		* For PSM Analysis 		  *
		* ----------------------- *
		* Open necessary files
		file open psm_`type'_`stype' using "${git_reggio}/output/multiple-methods/stepdown/csv/psm_adult40_`type'_`stype'_sd.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Adult: PSM Analysis"
		sdpsmanalysis, stype("`stype'") type("`type'") psmlist("${psmlist}") cohort("adult")
	
		* Close necessary files
		file close psm_`type'_`stype'
		
		
		
		* ----------------------- *
		* For Kernel Analysis 	  *
		* ----------------------- *
		* Open necessary files
		file open kern_`type'_`stype' using "${git_reggio}/output/multiple-methods/stepdown/csv/kern_adult40_`type'_`stype'.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Children: PSM Analysis"
		sdkernelanalysis, stype("`stype'") type("`type'") kernellist("${kernellist}") cohort("adult")
	
		* Close necessary files
		file close kern_`type'_`stype'
		
		/* ----------------- *
		* For AIPW Analysis *
		* ----------------- *
			* Open necessary files
			cap file close aipw_`type'_`stype'
			file open aipw_`type'_`stype' using "${git_reggio}/output/multiple-methods/stepdown/csv/aipw_adult40_`type'_`stype'_sd.csv", write replace

			* Run Multiple Analysis
			di "Estimating `type' for Children: AIPW Analysis"
			sdaipwanalysis, stype("`stype'") type("`type'") aipwlist("${aipwlist}") cohort("adult")
			
			* Close necessary files
			file close aipw_`type'_`stype'	*/
		
		
	}
	
	local stype_switch = 0
}

restore







* ---------------------------------------------------------------------------- *
* 					Reggio Muni vs. None:	Adult40		YES DID				   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
preserve
keep if (Cohort == 5) 
drop if asilo == 1 // dropping those who went to infant-toddler centers

local stype_switch = 1
foreach stype in None {
	
	* Set necessary global variables
	global X					materna
	global reglist				None40 BIC40 Full40 DidPm40 DidPv40
	global aipwlist				AIPW40 
	global psmlist				PSM40R PSM40Pm PSM40Pv
	global kernellist			KM40R KM40Pm KM40Pv

	global XNone40				maternaMuni		
	global XBIC40				maternaMuni		
	global XFull40				maternaMuni		
	global XPSM40R				maternaMuni
	global XPSM40Pm				Reggio
	global XPSM40Pv				Reggio
	global XKM40R				maternaMuni
	global XKM40Pm				Reggio
	global XKM40Pv				Reggio
	global XDidPm40			    xmMuniReggio 	
	global XDidPv40			    xmMuniReggio 		


	global controlsNone40
	global controlsBIC40		${bic_adult_baseline_vars}
	global controlsFull40		${adult_baseline_vars}
	global controlsPSM40R		${bic_adult_baseline_vars}
	global controlsPSM40Pm		${bic_adult_baseline_vars}
	global controlsPSM40Pv		${bic_adult_baseline_vars}
	global controlsKM40R		${bic_adult_baseline_vars}
	global controlsKM40Pm		${bic_adult_baseline_vars}
	global controlsKM40Pv		${bic_adult_baseline_vars}	
	global controlsDidPm40		materna Reggio ${bic_adult_baseline_vars}
	global controlsDidPv40		materna Reggio ${bic_adult_baseline_vars}
	global controlsAIPW40		${bic_adult_baseline_vars}


	global ifconditionNone40 	(Reggio == 1) & (Cohort_Adult40 == 1)  & (maternaMuni == 1 | materna`stype' == 1)
	global ifconditionBIC40		${ifconditionNone40} 
	global ifconditionFull40	${ifconditionNone40}
	global ifconditionPSM40R	${ifconditionNone40}
	global ifconditionPSM40Pm	((Reggio == 1) & (maternaMuni == 1)) | ((Parma == 1) & (materna`stype' == 1))
	global ifconditionPSM40Pv	((Reggio == 1) & (maternaMuni == 1)) | ((Padova == 1) & (materna`stype' == 1))
	global ifconditionKM40R		${ifconditionNone40}
	global ifconditionKM40Pm	((Reggio == 1) & (maternaMuni == 1)) | ((Parma == 1) & (materna`stype' == 1))
	global ifconditionKM40Pv	((Reggio == 1) & (maternaMuni == 1)) | ((Padova == 1) & (materna`stype' == 1))
	global ifconditionDidPm40	((Reggio == 1 & (maternaMuni == 1 | maternaNone == 1)) | (Parma == 1 & (maternaOther == 1 | maternaNone == 1))) & (Cohort_Adult40 == 1) 
	global ifconditionDidPv40	((Reggio == 1 & (maternaMuni == 1 | maternaNone == 1)) | (Padova == 1 & (maternaOther == 1 | maternaNone == 1))) & (Cohort_Adult40 == 1) 
	global ifconditionAIPW40 	(Reggio == 1) & (Cohort_Adult40 == 1)   & (maternaMuni == 1 | materna`stype' == 1)

		
	foreach type in  M E W L H N S {

		* ----------------------- *
		* For Regression Analysis *
		* ----------------------- *
		* Open necessary files
		cap file close regression_`type'_`stype'
		file open regression_`type'_`stype' using "${git_reggio}/output/multiple-methods/stepdown/csv/reg_adult40_`type'_`stype'_sd.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Children: Regression Analysis"
		sdreganalysis, stype("`stype'") type("`type'") reglist("${reglist}") cohort("adult")
	
		* Close necessary files
		file close regression_`type'_`stype' 
		
		
		
		* ----------------------- *
		* For PSM Analysis 		  *
		* ----------------------- *
		* Open necessary files
		file open psm_`type'_`stype' using "${git_reggio}/output/multiple-methods/stepdown/csv/psm_adult40_`type'_`stype'_sd.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Adult: PSM Analysis"
		sdpsmanalysis, stype("`stype'") type("`type'") psmlist("${psmlist}") cohort("adult")
	
		* Close necessary files
		file close psm_`type'_`stype'
		
		
		
		* ----------------------- *
		* For Kernel Analysis 	  *
		* ----------------------- *
		* Open necessary files
		file open kern_`type'_`stype' using "${git_reggio}/output/multiple-methods/stepdown/csv/kern_adult40_`type'_`stype'.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Children: PSM Analysis"
		sdkernelanalysis, stype("`stype'") type("`type'") kernellist("${kernellist}") cohort("adult")
	
		* Close necessary files
		file close kern_`type'_`stype'
		
		
	/*	* ----------------- *
		* For AIPW Analysis *
		* ----------------- *
			* Open necessary files
			cap file close aipw_`type'_`stype'
			file open aipw_`type'_`stype' using "${git_reggio}/output/multiple-methods/stepdown/csv/aipw_adult40_`type'_`stype'_sd.csv", write replace

			* Run Multiple Analysis
			di "Estimating `type' for Children: AIPW Analysis"
			sdaipwanalysis, stype("`stype'") type("`type'") aipwlist("${aipwlist}") cohort("adult")
			
			* Close necessary files
			file close aipw_`type'_`stype'	*/
		
		
	}
	
	local stype_switch = 0
}

restore





