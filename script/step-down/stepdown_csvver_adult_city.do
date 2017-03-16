/* --------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - Within-Parma/Padova Analysis
* Authors: Jessica Yu Kyung Koh
* Created: 06/16/2016
* Edited:  03/16/2017
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
* 					Reggio Muni vs. None:	Adult 30							   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
preserve
keep if (Cohort == 4)
drop if asilo == 1 // dropping those who went to infant-toddler centers

local stype_switch = 1
foreach city in Parma Padova {
	foreach stype in Yes Muni {
		
		* Set necessary global variables
		global X					maternaMuni
		global reglist				None30 BIC30 Full30  // It => Italians, Mg => Migrants
		global aipwlist				AIPW30 
		global psmlist				PSM30
		global kernellist			KM30

		global XNone30				materna		
		global XBIC30				materna		
		global XFull30				materna	
		global XPSM30				materna	
		global XKM30				materna	


		global controlsNone30
		global controlsBIC30		${bic_adult_baseline_vars}
		global controlsFull30		${adult_baseline_vars}
		global controlsPSM30		${bic_adult_baseline_vars}
		global controlsKM30			${bic_adult_baseline_vars}

		global ifconditionNone30 	(`city' == 1) & (Cohort_Adult30 == 1) & (maternaNone == 1 | materna`stype' == 1)
		global ifconditionBIC30		${ifconditionNone30} 
		global ifconditionFull30	${ifconditionNone30}
		global ifconditionPSM30		${ifconditionNone30}
		global ifconditionKM30 		(`city' == 1) & (Cohort_Adult30 == 1) & (maternaNone == 1 | materna`stype' == 1)


		
		
		foreach type in  M {

			* ----------------------- *
			* For Regression Analysis *
			* ----------------------- *
			* Open necessary files
			cap file close regression_`type'_`stype'
			file open regression_`type'_`stype' using "${git_reggio}/output/multiple-methods/stepdown/csv/reg_adult30_`type'_`stype'_`city'_sd.csv", write replace

			* Run Multiple Analysis
			di "Estimating `type' for Adult: Regression Analysis"
			sdreganalysis, stype("`stype'") type("`type'") reglist("${reglist}") cohort("adult")
		
			* Close necessary files
			file close regression_`type'_`stype' 
		
			
			
			* ----------------------- *
			* For PSM Analysis 		  *
			* ----------------------- *
			* Open necessary files
			file open psm_`type'_`stype' using "${git_reggio}/output/multiple-methods/stepdown/csv/psm_adult30_`type'_`stype'_`city'_sd.csv", write replace

			* Run Multiple Analysis
			di "Estimating `type' for Adult: PSM Analysis"
			sdpsmanalysis, stype("`stype'") type("`type'") psmlist("${psmlist}") cohort("adult")
		
			* Close necessary files
			file close psm_`type'_`stype'
			
		
			* ----------------------- *
			* For Kernel Analysis 	  *
			* ----------------------- *
			* Open necessary files
			file open kern_`type'_`stype' using "${git_reggio}/output/multiple-methods/stepdown/csv/kern_adult30_`type'_`stype'_`city'_sd.csv", write replace

			* Run Multiple Analysis
			di "Estimating `type' for Children: PSM Analysis"
			sdkernelanalysis, stype("`stype'") type("`type'") kernellist("${kernellist}") cohort("adult")
		
			* Close necessary files
			file close kern_`type'_`stype'	
				
			
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
	foreach stype in Yes Muni {
		
		* Set necessary global variables
		global X					maternaMuni
		global reglist				None30 BIC30 Full30  // It => Italians, Mg => Migrants
		global aipwlist				AIPW30 
		global psmlist				PSM30
		global kernellist			KM30

		global XNone30				materna		
		global XBIC30				materna		
		global XFull30				materna	
		global XPSM30				materna	
		global XKM30				materna	


		global controlsNone30
		global controlsBIC30		${bic_adult_baseline_vars}
		global controlsFull30		${adult_baseline_vars}
		global controlsPSM30		${bic_adult_baseline_vars}
		global controlsKM30			${bic_adult_baseline_vars}

		global ifconditionNone30 	(`city' == 1) & (maternaNone == 1 | materna`stype' == 1)
		global ifconditionBIC30		${ifconditionNone30} 
		global ifconditionFull30	${ifconditionNone30}
		global ifconditionPSM30		${ifconditionNone30}
		global ifconditionKM30 		(`city' == 1) & (maternaNone == 1 | materna`stype' == 1)


		
		
		foreach type in  M {

			* ----------------------- *
			* For Regression Analysis *
			* ----------------------- *
			* Open necessary files
			cap file close regression_`type'_`stype'
			file open regression_`type'_`stype' using "${git_reggio}/output/multiple-methods/stepdown/csv/reg_adult30_`type'_`stype'_`city'_sd.csv", write replace

			* Run Multiple Analysis
			di "Estimating `type' for Adult: Regression Analysis"
			sdreganalysis, stype("`stype'") type("`type'") reglist("${reglist}") cohort("adult")
		
			* Close necessary files
			file close regression_`type'_`stype' 
		
			
			
			* ----------------------- *
			* For PSM Analysis 		  *
			* ----------------------- *
			* Open necessary files
			file open psm_`type'_`stype' using "${git_reggio}/output/multiple-methods/stepdown/csv/psm_adult30_`type'_`stype'_`city'_sd.csv", write replace

			* Run Multiple Analysis
			di "Estimating `type' for Adult: PSM Analysis"
			sdpsmanalysis, stype("`stype'") type("`type'") psmlist("${psmlist}") cohort("adult")
		
			* Close necessary files
			file close psm_`type'_`stype'
			
		
			* ----------------------- *
			* For Kernel Analysis 	  *
			* ----------------------- *
			* Open necessary files
			file open kern_`type'_`stype' using "${git_reggio}/output/multiple-methods/stepdown/csv/kern_adult30_`type'_`stype'_`city'_sd.csv", write replace

			* Run Multiple Analysis
			di "Estimating `type' for Children: PSM Analysis"
			sdkernelanalysis, stype("`stype'") type("`type'") kernellist("${kernellist}") cohort("adult")
		
			* Close necessary files
			file close kern_`type'_`stype'	
				
			
		}
		
		local stype_switch = 0
	}
}
restore
