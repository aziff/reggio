/* ---------------------------------------------------------------------------- *
* Programming a function for the OLS for Reggio analysis (A more general version)
* Author: Jessica Yu Kyung Koh
* Edited: 12/12/2016

* Note: The purpose of this function is to generate csv file that contains
        point estimates, standard errors, p-values, and # of observations for
		different methodology. Since some methods we use are not regression 
		analysis, we cannot use commands like "estout" or "esttab". 
		
		The csv files created will be merged in other do files to produce
		presentable tables that combine methodologies. 
* ---------------------------------------------------------------------------- */


capture program drop reganalysis
capture program define reganalysis

version 13
syntax, stype(string) type(string) reglist(string) cohort(string)

	
	* ------------------------------------- *
	* For Regression (OLS and Diff-in-Diff) *
	* ------------------------------------- *

	***** Determine if headers need to be written in output (first observation in each category)
	local header_switch header

	***** Loop through the outcomes in a category and store OLS and diff-in-diff results for each age group
	foreach var in ${`cohort'_outcome_`type'} {
		
		local matitems	
		local matnames
	
		local switch = 1
		foreach comp in ${reglist} {
			sum `var' if ${ifcondition`comp'}
			if r(N) > 0 {
			
				di "variable: `var'"
				* Regress
				reg `var' ${X`comp'} ${controls`comp'} if ${ifcondition`comp'}, robust
				di "Regression specification: reg `var' ${X`comp'} ${controls`comp'} if ${ifcondition`comp'}, robust" 
				
				* Save key results to locals
				mat r = r(table)
				local itt_`comp' 	= 	r[1,1]
				local itt_`comp'_se = 	r[2,1]
				local itt_`comp'_p	=	r[4,1]
				local itt_`comp'_N	= 	e(N)
				
				* Add to the matitems and matnames locals
				if `switch' == 1 {
					local matitems `matitems' `itt_`comp'', `itt_`comp'_se', `itt_`comp'_p', `itt_`comp'_N' 
				}
				if `switch' == 0 {
					local matitems `matitems', `itt_`comp'', `itt_`comp'_se', `itt_`comp'_p', `itt_`comp'_N'  
				}
				
				local matnames `matnames' itt_`comp' itt_`comp'_se itt_`comp'_p itt_`comp'_N
				
				local switch = 0
			}
		}	
	
		mat regression = [`matitems']
		mat colname regression = `matnames'
		
		writematrix, output(regression_`type'_`stype') rowname("`var'") matrix(regression) `header_switch'
		local header_switch 
	}
	
end
