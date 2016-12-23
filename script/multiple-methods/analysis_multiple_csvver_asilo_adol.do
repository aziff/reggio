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





* ---------------------------------------------------------------------------- *
* 					Reggio Muni vs. None:	Adolescent						   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
preserve
keep if (Cohort == 3)

local stype_switch = 1
foreach stype in  Other None {
	
	* Set necessary global variables
	global X					asiloMuni
	global reglist				None BIC Full // It => Italians, Mg => Migrants
	global aipwlist				AIPW
	global psmlist				PSM

	global XNone				asiloMuni		
	global XBIC					asiloMuni		
	global XFull				asiloMuni		
	global XPSM					asiloMuni


	global controlsNone
	global controlsBIC			${bic_adol_baseline_vars}
	global controlsFull			${adol_baseline_vars}
	global controlsPSM			${bic_adol_baseline_vars}
	global controlsDidPm		${bic_adol_baseline_vars}
	global controlsDidPv		${bic_adol_baseline_vars}

	global ifconditionNone 		(Reggio == 1) & (Cohort == 3)   & ((asilo`stype' == 1) & (maternaMuni == 1)) | ((asiloMuni == 1) & (maternaMuni == 1))
	global ifconditionBIC		${ifconditionNone}
	global ifconditionFull		${ifconditionNone}
	global ifconditionPSM		${ifconditionNone}
	global ifconditionDidPm		(Reggio == 1 | Parma == 1) & (Cohort == 3)   & ((asilo`stype' == 1) & (maternaMuni == 1)) | ((asiloMuni == 1) & (maternaMuni == 1))
	global ifconditionDidPv		(Reggio == 1 | Padova == 1) & (Cohort == 3)   & ((asilo`stype' == 1) & (maternaMuni == 1)) | ((asiloMuni == 1) & (maternaMuni == 1))
	global ifconditionAIPW 	    (Reggio == 1) & (Cohort == 3)   & ((asilo`stype' == 1) & (maternaMuni == 1)) | ((asiloMuni == 1) & (maternaMuni == 1))

	
	
	foreach type in  M  {

		* ----------------------- *
		* For Regression Analysis *
		* ----------------------- *
		* Open necessary files
		cap file close regression_`type'_`stype'
		file open regression_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/reg_adol_`type'_`stype'_asilo.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Children: Regression Analysis"
		reganalysis, stype("`stype'") type("`type'") reglist("${reglist}") cohort("adol")
	
		* Close necessary files
		file close regression_`type'_`stype' 
		
		
		* ----------------------- *
		* For PSM Analysis 		  *
		* ----------------------- *
		* Open necessary files
		file open psm_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/psm_adol_`type'_`stype'_asilo.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Adult: PSM Analysis"
		psmanalysis, stype("`stype'") type("`type'") psmlist("${psmlist}") cohort("adol")
	
		* Close necessary files
		file close psm_`type'_`stype'
		
		
		* ----------------- *
		* For AIPW Analysis *
		* ----------------- *
/*
		
			* Open necessary files
			cap file close aipw_`type'_`stype'
			file open aipw_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/aipw_adol_`type'_`stype'_asilo.csv", write replace

			* Run Multiple Analysis
			di "Estimating `type' for Children: AIPW Analysis"
			aipwanalysis, stype("`stype'") type("`type'") aipwlist("${aipwlist}") cohort("adol")
			
			* Close necessary files
			file close aipw_`type'_`stype'	
		*/
		
	}
	
	local stype_switch = 0
}

restore








