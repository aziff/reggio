/* ---------------------------------------------------------------------------- *
* Programming an IV function for Reggio analysis (Step-down)
* Author: Sidharth Moktan, Jessica Yu Kyung Koh
* Edited: 2/16/2017

* Note: The purpose of this function is to generate csv file that contains
        point estimates, standard errors, p-values, and # of observations for
		different methodology. Since some methods we use are not regression 
		analysis, we cannot use commands like "estout" or "esttab". 
		
		The csv files created will be merged in other do files to produce
		presentable tables that combine methodologies. 
* ---------------------------------------------------------------------------- */

capture program drop sdivanalysis
capture program define sdivanalysis

version 13
syntax, stype(string) type(string) ivlist(string) cohort(string)

	* ------------------------------------- *
	* For IV 								*
	* ------------------------------------- *

	***** Determine if headers need to be written in output (first observation in each category)
	local header_switch header
	
	***** Step-down p-value calculation (No need to loop trhough each variable, but need to loop through methods)
	foreach comp in ${ivlist} {
		di "Running Romano-Wolf Stepdown Procedure for `comp'"
		rwolfiv ${`cohort'_outcome_`type'} if ${ifcondition`comp'}, indepvar(${endog}) controls(${controls`comp'}) method(ivregress 2sls) reps(250) seed(1)
		
		foreach var in ${`cohort'_outcome_`type'} {
			local iv_sd_`var'_`comp' = e(rw_`var')
		}
	}
	

	***** Loop through the outcomes in a category and store OLS and diff-in-diff results for each age group
	foreach var in ${`cohort'_outcome_`type'} {
		
		local matitems	
		local matnames
		
		local firstStageItems
		local firstStageNames
	
		local switch = 1
		foreach comp in ${ivlist} {
			sum `var' if ${ifcondition`comp'}
			if r(N) > 0 {				
				
				*-------------*
				*Second Stage:
				*-------------*
				di "variable: `var'"
				* Regress
				ivregress 2sls `var' ${controls`comp'} ($endog = $IVinstruments) if ${ifcondition`comp'}, robust first
				di "IV specification: ivregress 2sls `var' ${controls`comp'} (${endog} = $IVinstruments) if ${ifcondition`comp'}, robust" 
				
				* Save key results to locals
				mat r = r(table)
				local iv_`comp' 	= 	r[1,1]
				local iv_`comp'_se = 	r[2,1]
				local iv_`comp'_p	=	r[4,1]
				local iv_`comp'_N	= 	e(N)
				
				* Add to the matitems and matnames locals
				if `switch' == 1 {
					local matitems `matitems' `iv_`comp'', `iv_`comp'_se', `iv_`comp'_p', `iv_sd_`var'_`comp'', `iv_`comp'_N' 
				}
				if `switch' == 0 {
					local matitems `matitems', `iv_`comp'', `iv_`comp'_se', `iv_`comp'_p', `iv_sd_`var'_`comp'', `iv_`comp'_N'  
				}
				
				local matnames `matnames' iv_`comp' iv_`comp'_se iv_`comp'_p iv_`comp'_sdp iv_`comp'_N
				
				local switch = 0
			}
		}	
	
		mat iv = [`matitems']
		mat colname iv = `matnames'
		
		writematrix, output(iv_`type'_`stype') rowname("`var'") matrix(iv) `header_switch'
		local header_switch 
	}
	
end
