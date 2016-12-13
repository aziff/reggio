/* ---------------------------------------------------------------------------- *
* Programming a function for the OLS for Reggio analysis (A more general version)
* Author: Anna Ziff, Jessica Yu Kyung Koh
* Edited: 12/12/2016

* Note: This function programs AIPW estimator using probit. 
* ---------------------------------------------------------------------------- */

capture program drop aipw
capture program define aipw

version 13
syntax, outcome(string) brep(integer) comparison(string)

***** Loop through bootstrap
forvalues b = 0/`brep' {

	***** 0 is point estimate with original sample
	if `b' != 0 { 
		bsample, strata(Male)
	}

	***** predict probabilities and generate weights
	probit D ${`group'_baseline_vars}, vce(robust) 

	***** only proceed if converged
	if e(converged) {	

		forvalues d = 0/1 {
			gen weight`d' = .

			predict Dhat``cohort'_num'`d', outcome(`d')
			replace weight`d' = (1 / Dhat``cohort'_num'`d') 

			qui reg `outcome' ${`cohort'_baseline_vars} CAPI if D = `d'
			
			predict Yhat`d'  // predicts for everyone!
		}

		***** calculate estimator
		gen tmp1 = Yhat1 + D1/weight * (`outcome' - Yhat1)
		gen tmp0 = Yhat0 + D0/weight * (`outcome' - Yhat0)
		
		gen dr`outcome'``cohort'_num' = tmp1 - tmp0
		
		di "results for `outcome'"
		sum dr`outcome'``cohort'_num'

		// store result
		collapse dr`outcome'``cohort'_num' 
	
		// save point estimate
		if `b' == 0 {
			sum dr`outcome'  
			local p`outcome'`cohort' = r(mean)	
		}

		mkmat dr`outcome'``cohort'_num', matrix(tmp)
	
		matrix `outcome'`cohort' = (`outcome'`cohort' \ tmp)
		matrix drop tmp
		matrix list `outcome'`cohort'
	}

	***** calculate mean/se over bootstraps for each outcome and cohort
	preserve
	clear
	svmat `outcome'`cohort'
	sum `outcome'`cohort'
	
	local m`outcome'`cohort' = r(mean)
	local s`outcome'`cohort' = r(sd)
	local m`outcome'`cohort' : di %9.2f `m`outcome'`cohort''
	local s`outcome'`cohort' : di %9.2f `s`outcome'`cohort''
	
	***** calculate pvalue 
	gen i = 0 if `outcome'`cohort' != .
	replace i = 1 if `outcome'`cohort' - `m`outcome'`cohort'' > `p`outcome'`cohort'' & `outcome'`cohort' != . 
	sum i
	if r(mean) <= 0.1 {
		local m`outcome'`cohort' "\textbf{`m`outcome'`cohort''}"
	}

	di r(mean)

	restore


end
