/* ---------------------------------------------------------------------------- *
* Creating program to compute kernel- or PSM nearest-neighbor-matched DID
* Author: Sidharth Moktan
* Edited: 03/10/2017

* Note: This do file includes both basic and bootstrapped versions of matchedDID
	estimators. The basic version only provides the DID point estimates without
	SEs. This basic version will be called in the rwolf do file. The bootstrapped
	version takes the above basic function and computes bootstrapped SEs and pvalues
	on the point estimates. This bs version will be called in the sd do file.
* ---------------------------------------------------------------------------- */
*==========================================================================*
* Basic matchedDID function to compute DID point estimate (no SE or pvalues)
*==========================================================================*
cap program drop matchedDID
program matchedDID, eclass

	vers 11.0
	#delimit ;
	syntax 	varlist(min=1 max=1 fv ts),
			mainCity(string) mainCohort(string) mainTreat(string) mainControl(string)
			compCity(string) compCohort(string) compTreat(string) compControl(string)
			controls(varlist min=1 fv ts) matchmethod(string);
	#delimit cr
	cap set seed `seed'
	*-------------------------------------------------------------------*
	*** Computing PSM-Nearest-Neighbor- or kernel-matched differences ***
	*-------------------------------------------------------------------*
	foreach grp in main comp{
		if ("`matchmethod'" == "kernel") local matchCond kernel k(epan)
		if ("`matchmethod'" == "psm") local matchCond neighbor(3)
		
		#delimit ;
		capture: psmatch2 	``grp'Treat' `controls' 
							if (``grp'City'==1 & Cohort_``grp'Cohort'==1 & (``grp'Treat'==1|``grp'Control'==1) ${pre_restrict}), 
							`matchCond' out(`varlist');		/*${pre_restrict} is only for asilo*/
		#delimit cr
		
		if _rc!=0 {
			dis as error "Failed when computing `matchmethod'-diff between `mainCity'(`mainCohort') & `compCity'(`compCohort')."
			ereturn scalar did = .
			continue
		}
		
		* Storing DID point estimate, N, and rank of cov-matrix
		local att`grp' = r(att_`varlist')
		local N_`grp' = e(N)
		local rank_`grp' = e(rank)
	}
	
	*-----------------------------------------------------------------*
	*** Computing diff-in-diff using matched-differences from above ***
	*-----------------------------------------------------------------*
	local mDID = `attmain' - `attcomp'

	* Deleting all unnecessary scalars and macros
	ereturn clear
	return clear

	* Storing relevant scalars for use in other programs
	ereturn scalar mDID = `mDID'
	ereturn scalar N_main = `N_main'
	ereturn scalar N_comp = `N_comp'
	ereturn scalar rank_main = `rank_main'
	ereturn scalar rank_comp = `rank_comp'

end


*=====================================================================================*
* Program to compute bootstrapped SEs and p-values using matchedDID program from above
*=====================================================================================*
cap program drop matchedDID_bs
program matchedDID_bs, eclass

	vers 11.0
	#delimit ;
	syntax 	varlist(min=1 max=1 fv ts),
			mainCity_bs(string) mainCohort_bs(string) mainTreat_bs(string) mainControl_bs(string)
			compCity_bs(string) compCohort_bs(string) compTreat_bs(string) compControl_bs(string)
			controls_bs(varlist min=1 fv ts)
			matchmethod_bs(string)
			[seed(numlist integer>0 max=1) reps(integer 5)];
	#delimit cr
	cap set seed `seed'
	preserve
	*----------------------------------------*
	*Running Bootstrap on matchedDID function*
	*----------------------------------------*
	#delimit ;	
	bootstrap 	DID=e(mDID)															/* Specifying BS options for reps, seed and estimate storage */
				N_main=e(N_main)
				N_comp=e(N_comp)
				rank_main=e(rank_main)
				rank_comp=e(rank_comp),
				reps(`reps') strata(City Cohort) saving(bsestimates, replace):		
				
	matchedDID `varlist',	mainCity(`mainCity_bs') mainCohort(`mainCohort_bs') mainTreat(`mainTreat_bs') mainControl(`mainControl_bs')
							compCity(`compCity_bs') compCohort(`compCohort_bs') compTreat(`compTreat_bs') compControl(`compControl_bs')
							controls(`controls_bs')	matchmethod(`matchmethod_bs');
	

	#delimit cr
	
	*---------------------------------------------------*
	*Computing relevant statistics from bootstrap output*
	*---------------------------------------------------*
	mat rawEst = e(b)		/* BS stores observed values for DID, N, and rank in e(b) (because of the way options were specified) */ 

	* Loop over the 5 different estimates in e(b) and store estimates in locals 
	foreach est in DID N_main N_comp rank_main rank_comp{	
		mat `est' = rawEst[1,"`est'"]	/* We define matrices twice(here and few lines above) because we can refer to cells by column name */
		local `est' = `est'[1,1]	
	}

	*se*
	mat se = e(se)
	local se = se[1,1]

	*p-value*
	use bsestimates, clear
	sum DID
	gen pindicator = (abs(`DID')<abs(DID-r(mean)))	
	sum pindicator
	local p = r(mean)

	restore

	*-----------------------------------------------------*
	* Storing relevant statistics from computations above *
	*-----------------------------------------------------*
	* Get rid of unnecessary estimates from storage
	ereturn clear
	return clear

	*Storing statistics in e(scalar) for later use in sdanalysis file*
	ereturn scalar beta = `DID'
	ereturn scalar se = `se'
	ereturn scalar p = `p'

	ereturn scalar N_main = `N_main'
	ereturn scalar N_comp = `N_comp'
	ereturn scalar N = `N_main'+`N_comp'		

	ereturn scalar rank_main = `rank_main'
	ereturn scalar rank_comp = `rank_comp'
	ereturn scalar rank = min(`rank_main',`rank_comp')
*/
end
*=========================================================================================*
/*
#delimit ;	

* Sample query for matchedDID_bs;
matchedDID_bs 	IQ_factor,
				mainCity_bs(Reggio) mainCohort_bs(Adult30) mainTreat_bs(maternaMuni) mainControl_bs(maternaNone)
				compCity_bs(Parma) compCohort_bs(Adult30) compTreat_bs(maternaMuni) compControl_bs(maternaNone)
				controls_bs(Male CAPI dadMaxEdu_Uni numSibling_2 numSibling_more)
				matchmethod_bs(kernel) seed(1) reps(5);
/*
matchedDID	 	votoMaturita,
				mainCity(Reggio) mainCohort(Adult30) mainTreat(maternaMuni) mainControl(maternaNone)
				compCity(Parma) compCohort(Adult30) compTreat(maternaMuni) compControl(maternaNone)
				controls(Male CAPI dadMaxEdu_Uni numSibling_2 numSibling_more)
				matchmethod(kernel);
*/
#delimit cr

