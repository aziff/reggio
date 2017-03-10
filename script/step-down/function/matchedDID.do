/* ---------------------------------------------------------------------------- *
* Creating program to compute kernel- or PSM nearest-neighbor-matched DID
* Author: Sidharth Moktan
* Edited: 03/09/2017

* Note: This do file includes both basic and bootstrapped versions of matchedDID
	estimators. The basic version will be called in the rwolf do file. The 
	bootstrapped version will be called in the sd do file.
* ---------------------------------------------------------------------------- */

cap program drop matchedDID
program matchedDID, eclass

vers 11.0
#delimit ;
syntax 	varlist(min=1 max=1 fv ts),
		treatDummy(varlist min=1 max=1 fv ts)
		controls(varlist min=1 fv ts) 
		matchmethod(string)
		compCity(namelist min=1 max=2)
		cohortCond(string)
		[seed(numlist integer >0 max=1)
		reps(integer 100)]	;
#delimit cr

cap set seed `seed'

foreach city in Reggio `compCity'{
	local cityCond `city' == 1
	*------------------------------------------*
	*** Computing kernel-matched differences ***
	*------------------------------------------*
	if "`matchmethod'" == "kernel"{			
		di "Specification: capture psmatch2 `treatDummy' `controls' if (`cohortCond' & `cityCond') `in' `weight' `exp', kernel k(epan) out(`varlist')"		
		capture noisily: psmatch2 `treatDummy' `controls' if (`cohortCond' & `cityCond'), kernel k(epan) out(`varlist')

		if _rc!=0 {
			dis as error "Failed when computing `matchmethod'-diff between Reggio & `city' (`cohortCond')."
			ereturn scalar did = .
			continue
			*exit _rc
		}
		
		local att`city' = r(att_`varlist')
		local N_`city' = e(N)
		local rank_`city' = e(rank)
	}

	*--------------------------------------------------------*
	*** Computing PSM nearest-neighbor-matched differences ***
	*--------------------------------------------------------*
	if "`matchmethod'" == "psm"{	
		di "Specification: psmatch2 `treatDummy' `controls' if (`cohortCond' & `cityCond'), neighbor(3) out(`varlist')
		capture: psmatch2 `treatDummy' `controls' if (`cohortCond' & `cityCond'), neighbor(3) out(`varlist')
		
		*capture noisily: teffects psmatch (`varlist') (`treatDummy' `controls') if (`cohortCond' & `cityCond')
			/*	We choose psmatch2 over teffects because the latter doesn't store e(rank), which we need for rwolf step down.
				teffects is generally preferable because it computes the Abadie&Imbens SE estimators that account for estimated
				propensity scores. This is not an issue here as we don't use analytical SE. We bootstrap the SEs. */
		
		if _rc!=0 {
			dis as error "Failed when computing `matchmethod'-diff between Reggio & `city'(`cohortCond')."
			ereturn did = .
			continue
			*exit _rc
		}
		
		* The commented block below applies to teffects *
		
	/*	mat r = r(table)
		local att`city' = r[1,1]
		local rank_`city' = e(rank)	*/
				
		local att`city' = r(att_`varlist')
		local N_`city' = e(N)
		local rank_`city' = e(rank)
	}
}	
*--------------------------------------------------------------------------*
*** Computing diff-in-diff using matched-differences from above ***
*--------------------------------------------------------------------------*
local mDID = `attReggio' - `att`compCity''

* Deleting all unnecessary scalars and macros
ereturn clear
return clear

* Storing relevant scalars for use in other programs
ereturn scalar mDID = `mDID'
ereturn scalar N_Reggio = `N_Reggio'
ereturn scalar N_`compCity' = `N_`compCity''
ereturn scalar rank_Reggio = `rank_Reggio'
ereturn scalar rank_`compCity' = `rank_`compCity''

end


*=========================================================================================*
* Program to compute bootstrapped SEs and p-values usiing matchedDID program from above
*=========================================================================================*
cap program drop matchedDID_bs
program matchedDID_bs, eclass

vers 11.0
#delimit ;
syntax 	varlist(min=1 max=1 fv ts),
		treatDummy_bs(varlist min=1 max=1 fv ts) 
		controls_bs(varlist min=1 fv ts) 
		matchmethod_bs(string)
		compCity_bs(namelist min=1 max=2)
		cohortCond_bs(string)
		seed(numlist integer >0 max=1)
		[reps(integer 5)]
		;
#delimit cr

cap set seed `seed'

*------------------------------------------*
*Running Bootstrap on matching-DID function*
*------------------------------------------*
#delimit ;	
bootstrap 	DID=e(mDID)	
			N_Reggio=e(N_Reggio)
			N_`compCity_bs'=e(N_`compCity_bs')
			rank_Reggio=e(rank_Reggio)
			rank_`compCity_bs'=e(rank_`compCity_bs'),
			reps(`reps') strata(City Cohort):

matchedDID `varlist', 	treatDummy(`treatDummy_bs') controls(`controls_bs') 
						matchmethod(`matchmethod_bs') compCity(`compCity_bs') 
						cohortCond(`cohortCond_bs');
#delimit cr

*---------------------------------------------------*
*Computing relevant statistics from bootstrap output*
*---------------------------------------------------*
mat beta = e(b)
mat beta = beta[1,"DID"]
local beta = beta[1,1]

mat se = e(se)
local se = se[1,1]

local z = `beta'/`se'
local p=2*(1-normal(abs(`z')))

mat N_Reggio = e(b)
mat N_Reggio = N_Reggio[1,"N_Reggio"]
local N_Reggio = N_Reggio[1,1]

mat N_`compCity_bs' = e(b)
mat N_`compCity_bs' = N_`compCity_bs'[1,"N_`compCity_bs'"]
local N_`compCity_bs' = N_`compCity_bs'[1,1]

mat rank_Reggio = e(b)
mat rank_Reggio = rank_Reggio[1,"rank_Reggio"]
local rank_Reggio = rank_Reggio[1,1]

mat rank_`compCity_bs' = e(b)
mat rank_`compCity_bs' = rank_`compCity_bs'[1,"rank_`compCity_bs'"]
local rank_`compCity_bs' = rank_`compCity_bs'[1,1]

ereturn clear
return clear

*Storing relevant statistics in e(scalar) for later use in sdanalysis file*
ereturn scalar beta = `beta'
ereturn scalar se = `se'
ereturn scalar p = `p'

ereturn scalar N_Reggio = `N_Reggio'
ereturn scalar N_`compCity_bs' = `N_`compCity_bs''
ereturn scalar N = `N_Reggio'+`N_`compCity_bs''		

ereturn scalar rank_Reggio = `rank_Reggio'
ereturn scalar rank_`compCity_bs' = `rank_`compCity_bs''
ereturn scalar rank = min(`rank_Reggio',`rank_`compCity_bs'')

end
*=========================================================================================*
* Sample query for matchedDID_bs

#delimit ;	
matchedDID_bs IQ_factor,	treatDummy_bs(maternaMuni) controls_bs(Male CAPI dadMaxEdu_Uni numSibling_2 numSibling_more) 
							matchmethod_bs(kernel) compCity_bs(Parma) cohortCond_bs(Cohort_Adult30 == 1) seed(1) reps(2);
#delimit cr

* Sample query for matchedDID
/*
#delimit ;	
matchedDID IQ_factor,	treatDummy(maternaMuni) controls(Male CAPI dadMaxEdu_Uni numSibling_2 numSibling_more) 
							matchmethod(kernel) compCity(Parma) cohortCond(Cohort_Adult30 == 1) seed(1) reps(2);
#delimit cr
*/
