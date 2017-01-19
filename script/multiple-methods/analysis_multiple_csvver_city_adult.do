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



* ---------------------------------------------------------------------------- *
* 					Reggio Muni vs. None:	Adult 30							   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
preserve
keep if (Cohort == 4)
drop if asilo == 1 // dropping those who went to infant-toddler centers

local stype_switch = 1
foreach city in Parma Padova {
	foreach stype in Yes {
		
		* Set necessary global variables
		global X					maternaMuni
		global reglist				None30 BIC30 Full30  // It => Italians, Mg => Migrants
		global aipwlist				AIPW30 
		global psmlist				PSM30

		global XNone30				maternaYes		
		global XBIC30				maternaYes		
		global XFull30				maternaYes	
		global XPSM30				maternaYes	
		global XAIPW30				maternaYes	


		global controlsNone30
		global controlsBIC30		${bic_adult_baseline_vars}
		global controlsFull30		${adult_baseline_vars}
		global controlsPSM30		${bic_adult_baseline_vars}
		global controlsAIPW30		${bic_adult_baseline_vars}

		global ifconditionNone30 	(`city' == 1) & (Cohort_Adult30 == 1) 
		global ifconditionBIC30		${ifconditionNone30} 
		global ifconditionFull30	${ifconditionNone30}
		global ifconditionPSM30		${ifconditionNone30}
		global ifconditionAIPW30 	(`city' == 1) & (Cohort_Adult30 == 1)


		
		
		foreach type in  M {

			* ----------------------- *
			* For Regression Analysis *
			* ----------------------- *
			* Open necessary files
			cap file close regression_`type'_`stype'
			file open regression_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/reg_adult30_`type'_`stype'_`city'.csv", write replace

			* Run Multiple Analysis
			di "Estimating `type' for Children: Regression Analysis"
			reganalysis, stype("`stype'") type("`type'") reglist("${reglist}") cohort("adult")
		
			* Close necessary files
			file close regression_`type'_`stype' 
			
			
			
			* ----------------------- *
			* For PSM Analysis 		  *
			* ----------------------- *
			* Open necessary files
			cap file close psm_`type'_`stype'
			file open psm_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/psm_adult30_`type'_`stype'_`city'.csv", write replace

			* Run Multiple Analysis
			di "Estimating `type' for Adult: PSM Analysis"
			psmanalysis, stype("`stype'") type("`type'") psmlist("${psmlist}") cohort("adult")
		
			* Close necessary files
			file close psm_`type'_`stype'
				
				
				
			* ----------------- *
			* For AIPW Analysis *
			* ----------------- *
			* Open necessary files
			cap file close aipw_`type'_`stype'
			file open aipw_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/aipw_adult30_`type'_`stype'_`city'.csv", write replace

			* Run Multiple Analysis
			di "Estimating `type' for Children: AIPW Analysis"
			aipwanalysis, stype("`stype'") type("`type'") aipwlist("${aipwlist}") cohort("adult")
			
			* Close necessary files
			file close aipw_`type'_`stype'	
			
			
		}
		
		local stype_switch = 0
	}
}
restore










* ---------------------------------------------------------------------------- *
* 					Reggio Muni vs. None:	Adult 40							   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
preserve
keep if (Cohort == 5)
drop if asilo == 1 // dropping those who went to infant-toddler centers

local stype_switch = 1
foreach city in Parma Padova {
	foreach stype in Yes {
		
		* Set necessary global variables
		global X					maternaMuni
		global reglist				None40 BIC40 Full40  // It => Italians, Mg => Migrants
		global aipwlist				AIPW40 
		global psmlist				PSM40

		global XNone40				maternaYes		
		global XBIC40				maternaYes		
		global XFull40				maternaYes	
		global XPSM40				maternaYes	
		global XAIPW40				maternaYes	


		global controlsNone40
		global controlsBIC430		${bic_adult_baseline_vars}
		global controlsFull40		${adult_baseline_vars}
		global controlsPSM40		${bic_adult_baseline_vars}
		global controlsAIPW40		${bic_adult_baseline_vars}

		global ifconditionNone40 	(`city' == 1) & (Cohort_Adult40 == 1) 
		global ifconditionBIC40		${ifconditionNone40} 
		global ifconditionFull40	${ifconditionNone40}
		global ifconditionPSM40		${ifconditionNone40}
		global ifconditionAIPW40 	(`city' == 1) & (Cohort_Adult40 == 1)


		
		
		foreach type in  M {

			* ----------------------- *
			* For Regression Analysis *
			* ----------------------- *
			* Open necessary files
			cap file close regression_`type'_`stype'
			file open regression_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/reg_adult40_`type'_`stype'_`city'.csv", write replace

			* Run Multiple Analysis
			di "Estimating `type' for Children: Regression Analysis"
			reganalysis, stype("`stype'") type("`type'") reglist("${reglist}") cohort("adult")
		
			* Close necessary files
			file close regression_`type'_`stype' 
			
			
			
			* ----------------------- *
			* For PSM Analysis 		  *
			* ----------------------- *
			* Open necessary files
			cap file close psm_`type'_`stype'
			file open psm_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/psm_adult40_`type'_`stype'_`city'.csv", write replace

			* Run Multiple Analysis
			di "Estimating `type' for Adult: PSM Analysis"
			psmanalysis, stype("`stype'") type("`type'") psmlist("${psmlist}") cohort("adult")
		
			* Close necessary files
			file close psm_`type'_`stype'
				
				
				
			* ----------------- *
			* For AIPW Analysis *
			* ----------------- *
			* Open necessary files
			cap file close aipw_`type'_`stype'
			file open aipw_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/aipw_adult40_`type'_`stype'_`city'.csv", write replace

			* Run Multiple Analysis
			di "Estimating `type' for Children: AIPW Analysis"
			aipwanalysis, stype("`stype'") type("`type'") aipwlist("${aipwlist}") cohort("adult")
			
			* Close necessary files
			file close aipw_`type'_`stype'	
			
			
		}
		
		local stype_switch = 0
	}
}
restore
