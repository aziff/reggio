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
include "${here}/function/writematrix"


foreach stype in Other /*Reli Stat*/ {
															
	foreach type in  M CN S H B {
		foreach var in ${adol_outcome_`type'} {		
		
	* ======================================== *
	* Begin estimations *
	* ======================================== *	

			* ----------------------- *
			* For IV Analysis *
			* ----------------------- *
			foreach comp in ${ivlist} {
				sum `var' if ${ifcondition`comp'}
				if r(N) > 0 {
					* Regress				
					ivregress 2sls `var' ${controls`comp'} ($endog = $IVinstruments) if ${ifcondition`comp'}, robust
					
				}
			}
		
		
			* ----------------------- *
			* For PSM Analysis 		  *
			* ----------------------- *		
			foreach comp in ${psmlist} {
				capture teffects psmatch (`var') (${X`comp'} ${controls`comp'}) if ${ifcondition`comp'}
				if !_rc {			
					di "variable: `var'"
					* Regress
					teffects psmatch (`var') (${X`comp'} ${controls`comp'}) if ${ifcondition`comp'}
					
				}
			}


	* ======================================== *
	* Begin tests for equality *
	* ======================================== *	

			test iv_IQ_factor[maternaMuni] = psm_IQ_factor[maternaMuni]
		
		}
	}
}

restore
