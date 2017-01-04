/* ---------------------------------------------------------------------------- *
* Programming a function for the PSM for Reggio analysis (A more general version)
* Author: Jessica Yu Kyung Koh
* Edited: 12/22/2016

* Note: The purpose of this function is to generate csv file that contains
        point estimates, standard errors, p-values, and # of observations for
		different methodology. Since some methods we use are not regression 
		analysis, we cannot use commands like "estout" or "esttab". 
		
		The csv files created will be merged in other do files to produce
		presentable tables that combine methodologies. 
* ---------------------------------------------------------------------------- */


capture program drop sdpsmanalysis
capture program define sdpsmanalysis

version 13
syntax, stype(string) type(string) psmlist(string) cohort(string)

	
	* ------------------------------------- *
	* For Regression (OLS and Diff-in-Diff) *
	* ------------------------------------- *

	***** Determine if headers need to be written in output (first observation in each category)
	local header_switch header
	
	***** Step-down p-value calculation (No need to loop trhough each variable, but need to loop through methods)
	foreach comp in ${psmlist} {
		di "Running Romano-Wolf Stepdown Procedure for `comp'"
		rwolfpsm ${`cohort'_outcome_`type'} if ${ifcondition`comp'}, indepvar(${X`comp'}) controls(${controls`comp'}) method(teffects psmatch) reps(100) seed(1)
		
		di "PSM Stepdown done"
		foreach var in ${`cohort'_outcome_`type'} {
			local psm_sd_`var'_`comp' = e(rw_`var')
		}
	}


	***** Loop through the outcomes in a category and store OLS and diff-in-diff results for each age group
	foreach var in ${`cohort'_outcome_`type'} {
		
		local matitems	
		local matnames
	
		local switch = 1
		foreach comp in ${psmlist} {
			
			capture teffects psmatch (`var') (${X`comp'} ${controls`comp'}) if ${ifcondition`comp'}
			if !_rc {
			
				di "variable: `var'"
				* Regress
				teffects psmatch (`var') (${X`comp'} ${controls`comp'}) if ${ifcondition`comp'}
				
				di "Regression specification: teffects psmatch `var' ${X`comp'} ${controls`comp'} if ${ifcondition`comp'}" 
				
				* Save key results to locals
				mat r = r(table)
				local psm_`comp' 	= 	r[1,1]
				local psm_`comp'_se = 	r[2,1]
				local psm_`comp'_p	=	r[4,1]
				local psm_`comp'_N	= 	e(N)
			}
			else {

					local psm_`comp' 	= 	.
					local psm_`comp'_se = 	.
					local psm_`comp'_p	=	.
					local psm_`comp'_N	= 	.
		
			}
			
			* Add to the matitems and matnames locals
			if `switch' == 1 {
				local matitems `matitems' `psm_`comp'', `psm_`comp'_se', `psm_`comp'_p', `psm_sd_`var'_`comp'', `psm_`comp'_N' 
			}
			if `switch' == 0 {
				local matitems `matitems', `psm_`comp'', `psm_`comp'_se', `psm_`comp'_p', `psm_sd_`var'_`comp'', `psm_`comp'_N'  
			}
			
			local matnames `matnames' psm_`comp' psm_`comp'_se psm_`comp'_p psm_`comp'_sdp psm_`comp'_N
			
			local switch = 0
		
			
		}	
		mat psmresult = [`matitems']
		mat colname psmresult = `matnames'
		
		writematrix, output(psm_`type'_`stype') rowname("`var'") matrix(psmresult) `header_switch'
		local header_switch 
	}
	
end
