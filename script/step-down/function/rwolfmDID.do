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
syntax varlist(min=1 fv ts numeric),
treatDummy_rw(varlist min=1 max=1 fv ts) 
controls_rw(varlist min=1 fv ts) 
matchmethod_rw(string)
compCity_rw(namelist min=1 max=2)
cohortCond_rw(string)
seed(numlist integer >0 max=1)
[reps(integer 5)]
;

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
	cap matchedDID `var', 	treatDummy(`treatDummy_rw') controls(`controls_rw') 
							matchmethod(`matchmethod_rw') compCity(`compCity_rw') 
							cohortCond(`cohortCond_rw');
	#delimit cr    
	if _rc!=0 {
        dis as error "nonBS matchedDID failed for outcome:`var', when comparing Reggio and `compCity'."
        ereturn scalar rw_`var' = .
		continue
		*exit _rc
    }
	
	local ++j
	local varlistreal `varlistreal' `var'
	
	* This is shifted below bootstrap because we need bs to estimate SE and pvalues *
	/*
    local t`j' = abs(r(att_`var')/r(seatt_`var'))
    local n`j' = e(N)-e(rank)
	di "local n`j' is: `n`j''"
    if `"`method'"'=="areg" local n`j' = e(df_r)
    local cand `cand' `j'
    */
	
    tempfile file`j'
	
	#delimit ;	
	bootstrap 	b`j'=e(mDID)	
				N_Reggio=e(N_Reggio)
				N_`compCity_rw'=e(N_`compCity_rw')
				rank_Reggio=e(rank_Reggio)
				rank_`compCity_rw'=e(rank_`compCity_rw'),
				saving(`file`j'')
				reps(`reps') strata(City Cohort):

	matchedDID `var',	treatDummy(`treatDummy_rw') controls(`controls_rw') 
						matchmethod(`matchmethod_rw') compCity(`compCity_rw') 
						cohortCond(`cohortCond_rw');
	#delimit cr
	
	*Computing relevant statistics
	mat beta = e(b)
	mat beta = beta[1,"b`j'"]
	local beta = beta[1,1]

	mat se = e(se)
	local se = se[1,1]

	mat N_Reggio = e(b)
	mat N_Reggio = N_Reggio[1,"N_Reggio"]
	local N_Reggio = N_Reggio[1,1]

	mat N_`compCity_rw' = e(b)
	mat N_`compCity_rw' = N_`compCity_rw'[1,"N_`compCity_rw'"]
	local N_`compCity_rw' = N_`compCity_rw'[1,1]

	mat rank_Reggio = e(b)
	mat rank_Reggio = rank_Reggio[1,"rank_Reggio"]
	local rank_Reggio = rank_Reggio[1,1]

	mat rank_`compCity_rw' = e(b)
	mat rank_`compCity_rw' = rank_`compCity_rw'[1,"rank_`compCity_rw'"]
	local rank_`compCity_rw' = rank_`compCity_rw'[1,1]
	
	
	* The N and rank defined immediately underneath will be used for rw procedure
	local N = `N_Reggio'+`N_`compCity_rw''		
	local rank = min(`rank_Reggio',`rank_`compCity_rw'')

	ereturn clear
	return clear
	
	
	local t`j' = abs(`beta'/`se')
	local n`j' = `N'-`rank'
	
	di "local n`j' is: `n`j''"
    *if `"`method'"'=="areg" local n`j' = e(df_r)
    local cand `cand' `j'
		
	preserve
    qui use `file`j'', clear
    qui gen n=_n
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
foreach var of varlist `varlistreal' {
    local ++j
    local ORIG "Original p-value is `p`j''"
    local RW "Romano Wolf p-value is `prm`j''"
    dis "For the variable `var': `ORIG'. `RW'."
    ereturn scalar rw_`var' = `prm`j's'
}   

end
