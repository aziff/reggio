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
** Keep only the adult cohorts
preserve
keep if (Cohort == 1)

local stype_switch = 1
foreach stype in Other {
	
	* Set necessary global variables
	global X					xmMuniReggio
	global reglist				None Drop2526 Drop4018 DropAll

	global XNone				xmMuniReggio
	global XDrop2526			xmMuniReggio		
	global XDrop4018			xmMuniReggio
	global XDropAll				xmMuniReggio
	

	global controlsNone			maternaMuni Reggio ${bic_child_baseline_vars}
	global controlsDrop2526		maternaMuni Reggio ${bic_child_baseline_vars}
	global controlsDrop4018		maternaMuni Reggio ${bic_child_baseline_vars}
	global controlsDropAll		maternaMuni Reggio ${bic_child_baseline_vars}


	global ifconditionNone	 	(Reggio == 1 | Parma == 1)  & (maternaMuni == 1 | materna`stype' == 1)
	global ifconditionDrop2526	(Reggio == 1 | Parma == 1)  & (maternaMuni == 1 | materna`stype' == 1) & (internr != 2526)
	global ifconditionDrop4018	(Reggio == 1 | Parma == 1)  & (maternaMuni == 1 | materna`stype' == 1) & (internr != 4018)
	global ifconditionDropAll	(Reggio == 1 | Parma == 1)  & (maternaMuni == 1 | materna`stype' == 1) & (internr != 2526 & internr != 4018)


	foreach type in  M  {

		* ----------------------- *
		* For Regression Analysis *
		* ----------------------- *
		* Open necessary files
		file open regression_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/didpm_sens_child_`type'_`stype'.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Children: Regression Analysis"
		reganalysis, stype("`stype'") type("`type'") reglist("${reglist}") cohort("child")
	
		* Close necessary files
		file close regression_`type'_`stype' 
		
					
	}
	
	local stype_switch = 0
}

restore

