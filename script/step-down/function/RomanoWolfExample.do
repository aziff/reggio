/* RomanoWolfExample.do          damiancclarke             yyyy-mm-dd:2016-10-31
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

This code provides an example of Romano-Wolf's stepdown testing (patched togethe
r from their JASA (2005) paper, which is very technical, their Econometrica (200
5) paper, which gives a bit more details, and a useful online appendix from a pa
per by Savelyev and Tan which also discusses the algorithm.  The basic idea is
discussed in a pdf I am sending along with this code (though a quite draft form
at).

In the below, I am assuming that variables to be tested in multiple regressions
as independent variables are called:
var5, var6, var7, var10 and var12, and the treatment variable is called Reform.
Really though any type of test can be done by regression, just replacing the
regression on line 35 and 54 with the regression of interest.  The code is quite
generalisable.  The bottleneck is in the bootstrap step towards the top of the 
code (which could be sped up using Stata's built in bootstrap command with a bit
of effort).
*/



*------------------------------------------------------------------------------*
*---- Romano Wolf (full Sample)
*------------------------------------------------------------------------------*
local treat Reform
local covar covar1 covar2 covar3
local FE    i.state i.year
local se    cluster(state)

set seed 82130
local Nreps 150

**RUN REGRESSIONS AND BOOTSTRAP SAMPLE
foreach num of numlist 5 6 7 10 12 {
    dis "Estimation and bootstrapping with variable `num'"
    reg var`num' `covar' `FE' `treat', `se'
    local t`num' = abs(_b[`treat']/_se[`treat'])

    qui gen b_Reps`num' = .
    foreach bnum of numlist 1(1)`Nreps' {
        preserve
        bsample
        qui reg var`num' `covar' `FE' `treat', `se'
        restore
        qui replace b_Reps`num'=_b[`treat'] in `bnum'
    }
    qui sum b_Reps`num'
    local se`num' = r(sd)
    qui gen t_Reps`num'=abs((b_Reps`num'-r(mean))/`se`num'')
}

**CALCULATE STEPDOWN VALUE (ITERATE ON MAX-T)
local maxt = 0
local maxv = 0
local pval = 0
local cand 5 6 7 10 12
local rank

while `pval'<1&length("`cand'")!=0 {
    local donor_tvals
    *dis "Potential Candidates are now `cand'"
    
    foreach num of numlist `cand' {
        if `t`num''>`maxt' {
            local maxt = `t`num''
            local maxv = `num'
        }
        dis "Maximum t among candidates is `maxt' (option `maxv')"
        dis `maxt'
        local donor_tvals `donor_tvals' t_Reps`num'
    }
    *sum `donor_tvals'
    qui egen empiricalDist = rowmax(`donor_tvals')
    sort empiricalDist
        
    foreach cnum of numlist 1(1)`Nreps' {
        qui sum empiricalDist in `cnum'
        local cval = r(mean)
        *dis "comparing `maxt' to `cval'"
        if `maxt'>`cval' {
            local pval = 1-(`cnum'/`Nreps')
            *dis "Marginal p-value is `pval'"
        }
    }
    local p`maxv'   = string(ttail(`n`maxv'',`maxt')*2,"%5.3f")
    local prm`maxv' = string(`pval',"%5.3f")
    local ph`maxv'  = ttail(`n`maxv'',`maxt')*2*length("`cand'")
        
    dis "Original p-value is `p`maxv''" 
    dis "Romano Wolf p-value is `prm`maxv''"
    dis "Holm p-value is `ph`maxv''" 
        
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
