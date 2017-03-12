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
syntax, stype(string) type(string) cohort(string) comp(string) matchingmethod(string)

* ---------------- *
* For Matched DID  *
* ---------------- *

***** Determine if headers need to be written in output (first observation in each category)
local header_switch header

***** Step-down p-value calculation (No need to loop through each variable, but need to loop through methods)

di "Running Romano-Wolf Stepdown Procedure for `comp'_`city'"
#delimit ;
rwolfmDID	 ${`cohort'_outcome_`type'},
			mainCity_rw(${mainCity_`comp'}) mainCohort_rw(${mainCohort_`comp'}) mainTreat_rw(${mainTreat_`comp'}) mainControl_rw(${mainControl_`comp'})
			compCity_rw(${compCity_`comp'}) compCohort_rw(${compCohort_`comp'}) compTreat_rw(${compTreat_`comp'}) compControl_rw(${compControl_`comp'})
			controls_rw(${controls`comp'}) matchmethod_rw(`matchingmethod')
			seed(1) reps(250);
#delimit cr			

di "Kernel Matching Stepdown done"
foreach var in ${`cohort'_outcome_`type'} {
	local mDID_sd_`var' = e(rw_`var')
}


***** Loop through the outcomes in a category and store matched diff-in-diff results

foreach var in ${`cohort'_outcome_`type'} {		
	local matitems	
	local matnames
	local switch = 1
	
	#delimit ;
	capture: matchedDID_bs 	`var',
							mainCity_bs(${mainCity_`comp'}) mainCohort_bs(${mainCohort_`comp'}) mainTreat_bs(${mainTreat_`comp'}) mainControl_bs(${mainControl_`comp'})
							compCity_bs(${compCity_`comp'}) compCohort_bs(${compCohort_`comp'}) compTreat_bs(${compTreat_`comp'}) compControl_bs(${compControl_`comp'})
							controls_bs(${controls`comp'}) matchmethod_bs(`matchingmethod')
							seed(1) reps(100);
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
	
	local matnames `matnames' mDID_${mainCity_`comp'}_b mDID_${mainCity_`comp'}_se mDID_${mainCity_`comp'}_p mDID_${mainCity_`comp'}_sdp mDID_${mainCity_`comp'}_N
	
	local switch = 0
	
		

	mat mDIDresult = [`matitems']
	mat colname mDIDresult = `matnames'
	
	writematrix, output(mDID_`type'_`stype') rowname("`var'") matrix(mDIDresult) `header_switch'
	local header_switch 

			

}

end
