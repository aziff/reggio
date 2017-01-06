/* ---------------------------------------------------------------------------- *
* Programming a function for the OLS for Reggio analysis (A more general version)
* Author: Anna Ziff, Jessica Yu Kyung Koh
* Edited: 12/12/2016

* Note: The purpose of this function is to generate csv file that contains
        point estimates, standard errors, p-values, and # of observations for
		AIPW. Since some methods we use are not regression 
		analysis, we cannot use commands like "estout" or "esttab". 
		
		The csv files created will be merged in other do files to produce
		presentable tables that combine different methodologies. 
* ---------------------------------------------------------------------------- */


capture program drop aipwanalysis
capture program define aipwanalysis

version 13
syntax, stype(string) type(string) aipwlist(string) cohort(string)

	
	* ------------------------------------- *
	* For Regression (OLS and Diff-in-Diff) *
	* ------------------------------------- *

	***** Determine if headers need to be written in output (first observation in each category)
	local header_switch header
	
	***** Step-down p-value calculation (No need to loop trhough each variable, but need to loop through methods)
	foreach comp in ${aipwlist} {
		di "Running Romano-Wolf Stepdown Procedure for `comp'"
		rwolfaipw ${`cohort'_outcome_`type'} if ${ifcondition`comp'}, indepvar(D) controls(${controls`comp'}) method(aipw) reps(250) seed(1)
		
		di "PSM Stepdown done"
		foreach var in ${`cohort'_outcome_`type'} {
			local aipw_sd_`var'_`comp' = e(rw_`var')
		}
	}
	

	***** Loop through the outcomes in a category and store OLS and diff-in-diff results for each age group
	foreach var in ${`cohort'_outcome_`type'} {
		
		local matitems	
		local matnames
	
		local switch = 1
		foreach comp in ${aipwlist} {
		
			sum `var' if ${ifcondition`comp'}
			if r(N) > 0 {
			
				di "variable: `var'"
				* Estimate AIPW
				preserve
				
				keep if ${ifcondition`comp'}
				aipw, outcome("`var'") brep(${bootstrap}) cohort(`cohort') comparison("`comp'")
				
				restore
				
				* Save key results to locals
				local aipw_`comp' 	= 	${p`var'}
				local aipw_`comp'_se = 	${s`var'}
				local aipw_`comp'_p	=	${pval`var'}
				
				* Add to the matitems and matnames locals
				if `switch' == 1 {
					local matitems `matitems' `aipw_`comp'', `aipw_`comp'_se', `aipw_`comp'_p', `aipw_sd_`var'_`comp''
				}
				if `switch' == 0 {
					local matitems `matitems', `aipw_`comp'', `aipw_`comp'_se', `aipw_`comp'_p',  `aipw_sd_`var'_`comp'' 
				}
				local matnames `matnames' aipw_`comp' aipw_`comp'_se aipw_`comp'_p aipw_`comp'_sdp
				local switch = 0
			}
		}	
		
		mat aipw = [`matitems']
		
		mat colname aipw = `matnames'
		
		writematrix, output(aipw_`type'_`stype') rowname("`var'") matrix(aipw) `header_switch'
		di "writematrix done!"
		local header_switch 
	}
	
end
