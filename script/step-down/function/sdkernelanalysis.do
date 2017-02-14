/* ---------------------------------------------------------------------------- *
* Programming a function for the Kernel Matching for Reggio analysis (A more general version)
* Author: Jessica Yu Kyung Koh
* Edited: 02/14/2016

* Note: The purpose of this function is to generate csv file that contains
        point estimates, standard errors, p-values, and # of observations for
		different methodology. Since some methods we use are not regression 
		analysis, we cannot use commands like "estout" or "esttab". 
		
		The csv files created will be merged in other do files to produce
		presentable tables that combine methodologies. 
* ---------------------------------------------------------------------------- */


capture program drop sdkernelanalysis
capture program define sdkernelanalysis

version 13
syntax, stype(string) type(string) psmlist(string) cohort(string)

	
	* ------------- *
	* For Matching  *
	* ------------- *

	***** Determine if headers need to be written in output (first observation in each category)
	local header_switch header

	
	***** Step-down p-value calculation (No need to loop trhough each variable, but need to loop through methods)
	foreach comp in ${kernellist} {
		di "Running Romano-Wolf Stepdown Procedure for `comp'"

		rwolfkernel ${`cohort'_outcome_`type'} if ${ifcondition`comp'}, indepvar(${X`comp'}) controls(${controls`comp'}) method(psmatch2) reps(100) seed(1)
		
		di "Kernel Matching Stepdown done"
		foreach var in ${`cohort'_outcome_`type'} {
			local kn_sd_`var'_`comp' = e(rw_`var')
		}
		

	}
	
	
	
	
	***** Loop through the outcomes in a category and store OLS and diff-in-diff results for each age group
	foreach var in ${`cohort'_outcome_`type'} {
		
		local matitems	
		local matnames
	
		local switch = 1
		foreach comp in ${kernellist} {
			
			di "For comparison `comp'"
			di "psmatch2 ${X`comp'} ${controls`comp'} if ${ifcondition`comp'}, kernel k(epan) out(`var')"
			capture psmatch2 ${X`comp'} ${controls`comp'} if ${ifcondition`comp'}, kernel k(epan) out(`var')
			if !_rc {
			
				di "variable: `var'"
				* Perform matching
				psmatch2 ${X`comp'} ${controls`comp'} if ${ifcondition`comp'}, kernel k(epan) out(`var')
				
				di "Kernel matching specification: psmatch2 ${X`comp'} ${controls`comp'} if ${ifcondition`comp'}, kernel k(epan) out(`var')" 
				
				* Save key results to locals
				mat r = r(table)
				local kn_`comp' 	= 	r(att_`var')
				local kn_`comp'_se  = 	r(seatt_`var')
				local kn_`comp'_p	=	2*ttail(e(df_r), abs(r(att_`var')/r(seatt_`var')))
				local kn_`comp'_N	= 	e(N)
			}
			else {

					local kn_`comp' 	= 	.
					local kn_`comp'_se = 	.
					local kn_`comp'_p	=	.
					local kn_`comp'_N	= 	.
		
			}
			
			* Add to the matitems and matnames locals
			if `switch' == 1 {
				local matitems `matitems' `kn_`comp'', `kn_`comp'_se', `kn_`comp'_p', `kn_sd_`var'_`comp'', `kn_`comp'_N' 
			}
			if `switch' == 0 {
				local matitems `matitems', `kn_`comp'', `kn_`comp'_se', `kn_`comp'_p', `kn_sd_`var'_`comp'', `kn_`comp'_N'  
			}
			
			local matnames `matnames' kn_`comp' kn_`comp'_se kn_`comp'_p kn_`comp'_sdp kn_`comp'_N
			
			local switch = 0
		
			
		}	
		mat knresult = [`matitems']
		mat colname knresult = `matnames'
		
		writematrix, output(kern_`type'_`stype') rowname("`var'") matrix(knresult) `header_switch'
		local header_switch 
	}
	
end
