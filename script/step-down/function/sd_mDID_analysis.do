/* ---------------------------------------------------------------------------- *
* Programming a function for matchedDID (both psm and kernel)
* Author: Sidharth Moktan & Yu Kyung Koh
* Edited: 03/09/2017

* Note: The purpose of this function is to generate csv file that contains
        point estimates, standard errors, p-values, and # of observations for
		different methodology. Since some methods we use are not regression 
		analysis, we cannot use commands like "estout" or "esttab". 
		
		The csv files created will be merged in other do files to produce
		presentable tables that combine methodologies. 
* ---------------------------------------------------------------------------- */
capture program drop sd_mDID_analysis
capture program define sd_mDID_analysis, eclass

version 13
syntax, stype(string) type(string) cohort(string) comparisonCity(string) matchingmethod(string)

	* ---------------- *
	* For Matched DID  *
	* ---------------- *

	***** Determine if headers need to be written in output (first observation in each category)
	local header_switch header

	***** Step-down p-value calculation (No need to loop trhough each variable, but need to loop through methods)
	foreach comp in ${matchedDIDlist} {
		foreach city in `comparisonCity'{
			di "Running Romano-Wolf Stepdown Procedure for `comp'_`city'"
			#delimit ;
			rwolfmDID ${`cohort'_outcome_`type'}, 	treatDummy_rw(maternaMuni) controls_rw(${controls`comp'}) matchmethod_rw(`matchingmethod')
													compCity_rw(`city') cohortCond_rw(${cohortcond_`comp'}) seed(1) reps(20);
			#delimit cr
			
			di "Kernel Matching Stepdown done"
			foreach var in ${`cohort'_outcome_`type'} {
				local mDID_sd_`var' = e(rw_`var')
			}
		}
	}
		
	
	***** Loop through the outcomes in a category and store matched diff-in-diff results
	foreach comp in ${matchedDIDlist}{
		foreach city in `comparisonCity'{
			foreach var in ${`cohort'_outcome_`type'} {		
				local matitems	
				local matnames
				local switch = 1
			
				#delimit ;		
				cap matchedDID_bs `var',	treatDummy_bs(maternaMuni) controls_bs(${controls`comp'}) matchmethod_bs(`matchingmethod')
											compCity_bs(`city')	cohortCond_bs(${cohortcond_`comp'}) seed(1) reps(20);
				#delimit cr
				
				* Save key results to locals
				di "`var'"
				if !_rc{
					local mDID_b 	= 	e(beta)
					local mDID_se	= 	e(se)
					local mDID_p	=	e(p)
					local mDID_N	= 	e(N)		
				}
				else{
					local mDID_b 	= 	.
					local mDID_se	= 	.
					local mDID_p	=	.
					local mDID_N	= 	.			
				}
				
					
				* Add to the matitems and matnames locals
				if `switch' == 1 {
					local matitems `matitems' `mDID_b', `mDID_se', `mDID_p', `mDID_sd_`var'', `mDID_N' 
				}
				if `switch' == 0 {
					local matitems `matitems', `mDID_b', `mDID_se', `mDID_p', `mDID_sd_`var'', `mDID_N'  
				}
				
				local matnames `matnames' mDID_`city'_b mDID_`city'_se mDID_`city'_p mDID_`city'_sdp mDID_`city'_N
				
				local switch = 0
				
					

				mat mDIDresult = [`matitems']
				mat colname mDIDresult = `matnames'
				
				writematrix, output(mDID_`type'_`stype') rowname("`var'") matrix(mDIDresult) `header_switch'
				local header_switch 

				
			}
		}
	}
	
end
