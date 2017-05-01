/* --------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - Sensitivity OLS
* Authors: Jessica Yu Kyung Koh
* Created: 06/16/2016
* Edited:  04/28/2016

* Note: This execution do file performs sensitivity analysis for questionnable interviewers
		identified by the interviewer-sensitivity coefplot. 
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
* 					Reggio Muni vs. Other:	Children 						   *
* ---------------------------------------------------------------------------- *
** Keep only the child cohort
preserve
keep if (Cohort == 1)

local stype_switch = 1
foreach stype in Other {
	
	* Set necessary global variables
	global X					maternaMuni
	global reglist				None Drop2526 Drop4018 DropAll

	global XNone				maternaMuni
	global XDrop2526			maternaMuni		
	global XDrop4018			maternaMuni
	global XDropAll				maternaMuni
	

	global controlsNone			${bic_child_baseline_vars}
	global controlsDrop2526		${bic_child_baseline_vars}
	global controlsDrop4018		${bic_child_baseline_vars}
	global controlsDropAll		${bic_child_baseline_vars}


	global ifconditionNone	 	(Reggio == 1) & (maternaMuni == 1 | materna`stype' == 1)
	global ifconditionDrop2526	(Reggio == 1) & (maternaMuni == 1 | materna`stype' == 1) & (internr != 2526)
	global ifconditionDrop4018	(Reggio == 1) & (maternaMuni == 1 | materna`stype' == 1) & (internr != 4018)
	global ifconditionDropAll	(Reggio == 1) & (maternaMuni == 1 | materna`stype' == 1) & (internr != 2526 & internr != 4018)


	foreach type in  M  {

		* ----------------------- *
		* For Regression Analysis *
		* ----------------------- *
		* Open necessary files
		file open regression_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/ols_sens_child_`type'_`stype'.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Children: Regression Analysis"
		reganalysis, stype("`stype'") type("`type'") reglist("${reglist}") cohort("child")
	
		* Close necessary files
		file close regression_`type'_`stype' 
		
					
	}
	
	local stype_switch = 0
}

restore



* ---------------------------------------------------------------------------- *
* 					Reggio Muni vs. Other:	Adolescents 					   *
* ---------------------------------------------------------------------------- *
** Keep only the adolescent cohort
preserve
keep if (Cohort == 3)

local stype_switch = 1
foreach stype in Other {
	
	* Set necessary global variables
	global X					maternaMuni
	global reglist				None Drop2526 Drop4018 DropAll

	global XNone				maternaMuni
	global XDrop2526			maternaMuni		
	global XDrop4018			maternaMuni
	global XDropAll				maternaMuni
	

	global controlsNone			${bic_adol_baseline_vars}
	global controlsDrop2526		${bic_adol_baseline_vars}
	global controlsDrop4018		${bic_adol_baseline_vars}
	global controlsDropAll		${bic_adol_baseline_vars}


	global ifconditionNone	 	(Reggio == 1) & (maternaMuni == 1 | materna`stype' == 1)
	global ifconditionDrop2526	(Reggio == 1) & (maternaMuni == 1 | materna`stype' == 1) & (internr != 2526)
	global ifconditionDrop4018	(Reggio == 1) & (maternaMuni == 1 | materna`stype' == 1) & (internr != 4018)
	global ifconditionDropAll	(Reggio == 1) & (maternaMuni == 1 | materna`stype' == 1) & (internr != 2526 & internr != 4018)


	foreach type in  M  {

		* ----------------------- *
		* For Regression Analysis *
		* ----------------------- *
		* Open necessary files
		file open regression_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/ols_sens_adol_`type'_`stype'.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Adolescents: Regression Analysis"
		reganalysis, stype("`stype'") type("`type'") reglist("${reglist}") cohort("adol")
	
		* Close necessary files
		file close regression_`type'_`stype' 
		
					
	}
	
	local stype_switch = 0
}





* ---------------------------------------------------------------------------- *
* 					Reggio Muni vs. Other:	Adult-30 						   *
* ---------------------------------------------------------------------------- *
** Keep only the adult-30 cohort
preserve
keep if (Cohort == 4) 
drop if asilo == 1

local stype_switch = 1
foreach stype in Other {
	
	* Set necessary global variables
	global X					maternaMuni
	global reglist				None Drop2526 Drop4018 DropAll

	global XNone				maternaMuni
	global XDrop2526			maternaMuni		
	global XDrop4018			maternaMuni
	global XDropAll				maternaMuni
	

	global controlsNone			${bic_adult_baseline_vars}
	global controlsDrop2526		${bic_adult_baseline_vars}
	global controlsDrop4018		${bic_adult_baseline_vars}
	global controlsDropAll		${bic_adult_baseline_vars}


	global ifconditionNone	 	(Reggio == 1) & (maternaMuni == 1 | materna`stype' == 1)
	global ifconditionDrop2526	(Reggio == 1) & (maternaMuni == 1 | materna`stype' == 1) & (internr != 2526)
	global ifconditionDrop4018	(Reggio == 1) & (maternaMuni == 1 | materna`stype' == 1) & (internr != 4018)
	global ifconditionDropAll	(Reggio == 1) & (maternaMuni == 1 | materna`stype' == 1) & (internr != 2526 & internr != 4018)


	foreach type in  M  {

		* ----------------------- *
		* For Regression Analysis *
		* ----------------------- *
		* Open necessary files
		file open regression_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/ols_sens_adult30_`type'_`stype'.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Adolescents: Regression Analysis"
		reganalysis, stype("`stype'") type("`type'") reglist("${reglist}") cohort("adult")
	
		* Close necessary files
		file close regression_`type'_`stype' 
		
					
	}
	
	local stype_switch = 0
}

restore





* ---------------------------------------------------------------------------- *
* 					Reggio Muni vs. Other:	Adult-40 						   *
* ---------------------------------------------------------------------------- *
* Keep only the adult-40 cohort
preserve
keep if (Cohort == 5) 
drop if asilo == 1

local stype_switch = 1
foreach stype in Other {
	
	* Set necessary global variables
	global X					maternaMuni
	global reglist				None Drop2526 Drop4018 DropAll

	global XNone				maternaMuni
	global XDrop2526			maternaMuni		
	global XDrop4018			maternaMuni
	global XDropAll				maternaMuni
	

	global controlsNone			${bic_adult_baseline_vars}
	global controlsDrop2526		${bic_adult_baseline_vars}
	global controlsDrop4018		${bic_adult_baseline_vars}
	global controlsDropAll		${bic_adult_baseline_vars}


	global ifconditionNone	 	(Reggio == 1) & (maternaMuni == 1 | materna`stype' == 1)
	global ifconditionDrop2526	(Reggio == 1) & (maternaMuni == 1 | materna`stype' == 1) & (internr != 2526)
	global ifconditionDrop4018	(Reggio == 1) & (maternaMuni == 1 | materna`stype' == 1) & (internr != 4018)
	global ifconditionDropAll	(Reggio == 1) & (maternaMuni == 1 | materna`stype' == 1) & (internr != 2526 & internr != 4018)


	foreach type in  M  {

		* ----------------------- *
		* For Regression Analysis *
		* ----------------------- *
		* Open necessary files
		file open regression_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/ols_sens_adult40_`type'_`stype'.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Adolescents: Regression Analysis"
		reganalysis, stype("`stype'") type("`type'") reglist("${reglist}") cohort("adult")
	
		* Close necessary files
		file close regression_`type'_`stype' 
		
					
	}
	
	local stype_switch = 0
}

restore

