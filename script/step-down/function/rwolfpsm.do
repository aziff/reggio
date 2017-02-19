/* ---------------------------------------------------------------------------- *
* Modifying the Existing "rwolf" Command
* Author: Jessica Yu Kyung Koh
* Edited: 01/03/2016

* Note: The purpose of this do file is to modify the existing rwolf command to 
        accomodate more general commands other than reg/probit/logit.
* ---------------------------------------------------------------------------- */

cap program drop rwolfpsm
program rwolfpsm, eclass

vers 11.0
#delimit ;
syntax varlist(min=1 fv ts numeric) [if] [in] [pweight fweight aweight iweight],
indepvar(varlist max=1)
[
 method(string)
 controls(varlist fv ts)
 seed(numlist integer >0 max=1)
 reps(integer 100)
 ]
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
    
	dis "Estimating for `var'"
	/*cap qui*/ `method' (`var') (`indepvar' `controls') `if' `in' [`weight' `exp'], `options'
    if _rc!=0 {
        dis as error "Your original `method' does not work for `var'.  Please test the `method' and try again."
        ereturn scalar rw_`var' = .
		continue
		*exit _rc
    }

	local ++j
	local varlistreal `varlistreal' `var'
	
    local t`j' = abs(_b[ATE:r1vs0.`indepvar']/_se[ATE:r1vs0.`indepvar'])
    local n`j' = e(N)-e(rank)
	di "local n`j' is: `n`j''"
    if `"`method'"'=="areg" local n`j' = e(df_r)
    local cand `cand' `j'
    
    tempfile file`j'
    #delimit ;
    qui bootstrap b`j'=_b[ATE:r1vs0.`indepvar'], saving(`file`j'') reps(`reps'):
    `method' (`var') (`indepvar' `controls') `if' `in' [`weight' `exp'], `options';
    #delimit cr
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
