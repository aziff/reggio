/* ---------------------------------------------------------------------------- *
* Modifying the Existing "rwolf" Command for matched-DID estimation
* Author: Jessica Yu Kyung Koh & Sidharth Moktan
* Edited: 02/14/2016

* Note: The purpose of this do file is to modify the existing rwolf command to 
        accomodate more general commands other than reg/probit/logit.
* ---------------------------------------------------------------------------- */
cap program drop rwolfmDID
program rwolfmDID, eclass

vers 11.0
#delimit ;
syntax 	varlist(min=1 fv ts),
		mainCity_rw(string) mainCohort_rw(string) mainTreat_rw(string) mainControl_rw(string)
		compCity_rw(string) compCohort_rw(string) compTreat_rw(string) compControl_rw(string)
		controls_rw(varlist min=1 fv ts) matchmethod_rw(string)
		[seed(numlist integer>0 max=1) reps(integer 5)];
#delimit cr
cap set seed `seed'
if `"`method'"'=="" local method regress
*-------------------------------------------------------------------------------
*--- Run bootstrap reps to create null Studentized distribution
*-------------------------------------------------------------------------------
local j=0
local cand
local varlistreal
dis "Running `reps' bootstrap replications for each variable.  This may take some time"
foreach var of varlist `varlist' {
    
	#delimit ;	
	cap matchedDID `var',	mainCity(`mainCity_rw') mainCohort(`mainCohort_rw') mainTreat(`mainTreat_rw') mainControl(`mainControl_rw')
							compCity(`compCity_rw') compCohort(`compCohort_rw') compTreat(`compTreat_rw') compControl(`compControl_rw')
							controls(`controls_rw')	matchmethod(`matchmethod_rw');
	#delimit cr    
	if _rc!=0 {
        dis as error "nonBS matchedDID failed for outcome:`var', when comparing `mainCity' and `compCity'."
        ereturn scalar rw_`var' = .
		continue
    }
	
	local ++j
	local varlistreal `varlistreal' `var'
	 tempfile file`j'
	 
	 
	#delimit ;	
	capture: bootstrap 		DID=e(mDID)															
							N_main=e(N_main)
							N_comp=e(N_comp)
							rank_main=e(rank_main)
							rank_comp=e(rank_comp),
							reps(`reps') strata(City Cohort) saving(`file`j''):		
							
	matchedDID `var',		mainCity(`mainCity_rw') mainCohort(`mainCohort_rw') mainTreat(`mainTreat_rw') mainControl(`mainControl_rw')
							compCity(`compCity_rw') compCohort(`compCohort_rw') compTreat(`compTreat_rw') compControl(`compControl_rw')
							controls(`controls_rw')	matchmethod(`matchmethod_rw');
	#delimit cr

	if _rc!=0 {
		dis as error "Failed when bootstrapping `matchmethod_rw'-diff between `mainCity_rw'(`mainCohort_rw') & `compCity_rw'(`compCohort_rw')."
		local se = .
		local N = .
		local rank = .
		local t`j' = .
		local n`j' = .
		local cand `cand'
		
		preserve
		qui use `file`j'', clear
		qui gen n=_n
		gen b`j' = .
		qui save `file`j'', replace
		restore
	
		continue
	}
	
	
		*Computing relevant statistics
		mat rawEst = e(b)		/* BS stores observed values for DID, N, and rank in e(b) (because of the way options were specified) */ 

		* Loop over the 5 different estimates in e(b) and store estimates in locals 
		foreach est in DID N_main N_comp rank_main rank_comp{	
			mat `est' = rawEst[1,"`est'"]	/* We define matrices twice(here and few lines above) because we can refer to cells by column name */
			local `est' = `est'[1,1]
		}


		*se*
		mat se = e(se)
		local se = se[1,1]
		
		* The N and rank defined immediately underneath will be used for rw procedure
		local N = `N_main'+`N_comp'		
		local rank = min(`rank_main',`rank_comp')
		
		local t`j' = abs(`DID'/`se')
		local n`j' = `N'-`rank'
		
		di "local n`j' is: `n`j''"
		*if `"`method'"'=="areg" local n`j' = e(df_r)
		local cand `cand' `j'
			
		preserve
		qui use `file`j'', clear
		qui gen n=_n
		gen b`j' = DID
		qui save `file`j'', replace
		restore
	

}

preserve
qui use `file1', clear
if `j'>1 {
    foreach jj of numlist 2(1)`j' {
        qui merge 1:1 n using `file`jj''
        qui drop _merge
    }
}

*-------------------------------------------------------------------------------
*--- Create null t-distribution
*-------------------------------------------------------------------------------
foreach num of numlist 1(1)`j' {
    qui sum b`num'
    qui replace b`num'=abs((b`num'-r(mean))/r(sd)) 
}

*-------------------------------------------------------------------------------
*--- Create stepdown value in descending order based on t-stats
*-------------------------------------------------------------------------------
local maxt = 0
local pval = 0
local rank

while length("`cand'")!=0 {
    local donor_tvals

    foreach var of local cand {
        if `t`var''>`maxt' {
            local maxt = `t`var''
            local maxv `var'
        }
        qui dis "Maximum t among remaining candidates is `maxt' (variable `maxv')"
        local donor_tvals `donor_tvals' b`var'
    }
    qui egen empiricalDist = rowmax(`donor_tvals')
    sort empiricalDist
    forvalues cnum = 1(1)`reps' {
        qui sum empiricalDist in `cnum'
        local cval = r(mean)
        if `maxt'>`cval' {
            local pval = 1-((`cnum'+1)/(`reps'+1))
        }
    }
    local prm`maxv's= `pval'
    if length(`"`prmsm1'"') != 0 local prm`maxv's = max(`prm`maxv's',`prmsm1')
    local p`maxv'   = string(ttail(`n`maxv'',`maxt')*2,"%6.4f")
    local prm`maxv' = string(`prm`maxv's',"%6.4f")
    local prmsm1 = `prm`maxv's'
    
    drop empiricalDist
    local rank `rank' `maxv'
    local candnew
    foreach c of local cand {
        local match = 0
        foreach r of local rank {
            if `r'==`c' local match = 1
        }
        if `match'==0 local candnew `candnew' `c'
    }
    local cand `candnew'
    local maxt = 0
    local maxv = 0
}
restore

*-------------------------------------------------------------------------------
*--- Report y export p-values
*-------------------------------------------------------------------------------
local j=0
dis _newline

ereturn clear
return clear

foreach var of varlist `varlistreal' {
    local ++j
    local ORIG "Original p-value is `p`j''"
    local RW "Romano Wolf p-value is `prm`j''"
    dis "For the variable `var': `ORIG'. `RW'."
    ereturn scalar rw_`var' = `prm`j's'
}   

end


/* Example of syntax when caling function
preserve

keep if (Cohort == 4) 
drop if asilo == 1 // dropping those who went to infant-toddler centers
drop if (ReggioAsilo == . | ReggioMaterna == .)

#delimit ;
rwolfmDID	 	IQ_factor IQ_score votoMaturita	highschoolGrad MaxEdu_Uni MaxEdu_Grad,
				mainCity_rw(Reggio) mainCohort_rw(Adult30) mainTreat_rw(maternaMuni) mainControl_rw(maternaOther)
				compCity_rw(Padova) compCohort_rw(Adult30) compTreat_rw(maternaMuni) compControl_rw(maternaOther)
				controls_rw(Male CAPI dadMaxEdu_Uni numSibling_2 numSibling_more)
				matchmethod_rw(psm) seed(1) reps(25);
#delimit cr
*/
