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
include "${here}/function/ivanalysis"


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

**Manipulating instruments to prepare for ivregress**
*Reggio Score Instrument*
gen score25 = (score <= r(p25))
gen score50 = (score > r(p25) & score <= r(p50))
gen score75 = (score > r(p50) & score <= r(p75))

label var score25 "25th pct of RA admission score"
label var score50 "50th pct of RA admission score"
label var score75 "75th pct of RA admission score"

*Creating distance squared*
foreach st in Municipal Private Religious State{
	gen distMaterna`st'1_sq = distMaterna`st'1^2
}

/*
*Cost Instrument* -- Decided not to use because we get very little 
 variation in cost. Cost is designed to vary by parent's income, but
 we don't have a complete income variable (missing data). Further, our 
 cost data doesn't capture variation in cost by school, only by school-type

local maternaCost
foreach t in Muni /*Reli Stat*/{
	rename Fees_med_full_materna`t'_3 effective_medianFee_materna`t'
	local maternaCost `maternaCost' effective_medianFee_materna`t'
} 			/*_3, _2 and _1 correspond to ages 3, 2 and 1 respectively */

local asiloCost
foreach  t in Muni Reli{
	rename Fees_med_full_asilo`t'_1 effective_medianFee_asilo`t'
	local asiloCost `asiloCost' effective_medianFee_asilo`t'
} 			/*_3, _2 and _1 correspond to ages 3, 2 and 1 respectively */
*/


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
	global psmlist				PSMR PSMPm PSMPv
	global aipwlist				AIPWIt
	global ivlist				IVIt

	global XNoneIt				maternaMuni
	global XBICIt				maternaMuni		
	global XFullIt				maternaMuni		
	global XDidPmIt				xmMuniReggio maternaMuni Reggio 
	global XDidPvIt				xmMuniReggio maternaMuni Reggio 	
	global XPSMR				maternaMuni
	global XPSMPm				Reggio
	global XPSMPv				Reggio
	global endog				maternaMuni
	
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
	global controlsDidPmIt		${bic_child_baseline_did_vars}
	global controlsDidPvIt		${bic_child_baseline_did_vars}
	global controlsPSMR			${bic_child_baseline_vars}
	global controlsPSMPm		${bic_child_baseline_vars}
	global controlsPSMPv		${bic_child_baseline_vars}
	global controlsAIPWIt		${bic_child_baseline_vars}
	global controlsIVIt			${bic_child_baseline_vars}
	
	local  Other_psm			materna
	local  Stat_psm				maternaStat
	local  Reli_psm				maternaReli

	global ifconditionNoneIt 	(Reggio == 1) & (maternaMuni == 1 | materna`stype' == 1)
	global ifconditionBICIt		${ifconditionNoneIt}
	global ifconditionFullIt	${ifconditionNoneIt}
	global ifconditionPSMR		${ifconditionNoneIt}
	global ifconditionPSMPm		((Reggio == 1) & (maternaMuni == 1)) | ((Parma == 1) & (``stype'_psm' == 1))
	global ifconditionPSMPv		((Reggio == 1) & (maternaMuni == 1)) | ((Padova == 1) & (``stype'_psm' == 1))
	global ifconditionDidPmIt	(Reggio == 1 | Parma == 1)    
	global ifconditionDidPvIt	(Reggio == 1 | Padova == 1)    & (maternaMuni == 1 | materna`stype' == 1)
	global ifconditionAIPWIt 	(Reggio == 1)  & (maternaMuni == 1 | materna`stype' == 1)
	global ifconditionIVIt	 	(Reggio == 1)  & (maternaMuni == 1 | materna`stype' == 1)
	
	global IVinstruments		score ///
								distMaternaMunicipal1 distMaternaPrivate1 distMaternaReligious1 distMaternaState1 ///
								distMaternaMunicipal1_sq distMaternaPrivate1_sq distMaternaReligious1_sq distMaternaState1_sq
	
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
		
		
		* ----------------------- *
		* For IV Analysis *
		* ----------------------- *
		* Open necessary files
		cap file close iv_`type'_`stype'
		file open iv_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/iv_child_`type'_`stype'.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Adult: IV Analysis"
		ivanalysis, stype("`stype'") type("`type'") ivlist("${ivlist}") cohort("child")
	
		* Close necessary files
		file close iv_`type'_`stype' 
					
	}
	
	local stype_switch = 0
}

restore

