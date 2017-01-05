/* ---------------------------------------------------------------------------- *
* Programming a function for the OLS for Reggio analysis (A more general version)
* Author: Anna Ziff, Jessica Yu Kyung Koh
* Edited: 01/04/2017

* Note: This function programs AIPW estimator using probit. 
* ---------------------------------------------------------------------------- */

capture program drop aipw
program aipw, eclass

version 13
syntax, outcome(string) brep(integer) cohort(string) comparison(string)

***** Loop through bootstrap
matrix `outcome'`cohort' = J(1,1,.)

forvalues b = 0/`brep' {
	di "for Bootstrap = `b'"
	
	preserve
	***** 0 is point estimate with original sample
	if `b' != 0 { 
		bsample, strata(Male)
	}
	di "summarizing for bootstrap `b'"
	summ intnr if D == 1
	local obsN1 = r(N)
	summ intnr if D == 0
	local obsN0 = r(N)
	
	***** only proceed if there are sufficient observation
	if (`obsN1' >= 5) & (`obsN0' >= 5) {
	
	***** predict probabilities and generate weights
	probit D ${bic_`cohort'_baseline_vars}, vce(robust) iterate(30)

		***** only proceed if converged
		if e(converged) {	
		
			di "Predicting for outcome == 1"
			predict Dhat1
			summ Dhat1
			
			gen weight1 = .
			replace weight1 = (1 / Dhat1) 
			
			generate Dhat0 = 1 - Dhat1
			
			generate weight0 = .
			replace weight0 = (1 / Dhat0) 

			di "Regressing for `outcome' for treated"
			capture reg `outcome' ${bic_`cohort'_baseline_vars} if D == 1
			if _rc {
				continue
			}
			predict Yhat1  // predicts for everyone!
		
			di "Regressing for `outcome' for control"
			capture reg `outcome' ${bic_`cohort'_baseline_vars} if D == 0
			if _rc {
				continue
			}
			predict Yhat0  // predicts for everyone!
		
			***** calculate estimator
			gen tmp1 = Yhat1 + D1/weight1 * (`outcome' - Yhat1)
			gen tmp0 = Yhat0 + D0/weight0 * (`outcome' - Yhat0)

			
			gen dr`outcome' = tmp1 - tmp0
			
			di "results for `outcome'"
			sum dr`outcome'

			// store result
			collapse dr`outcome'
		
			// save point estimate
			if `b' == 0 {
				sum dr`outcome'  
				global p`outcome' = r(mean)	
			}

			mkmat dr`outcome', matrix(tmp)
		
			di "filling out the matrix"
			matrix `outcome'`cohort' = (`outcome'`cohort' \ tmp)
			
			matrix drop tmp
			
			di "Listing outcome cohort matrix"
			matrix list `outcome'`cohort'
					
			}
		}
		restore
		
	}
		
	***** calculate mean/se over bootstraps for each outcome and cohort
	preserve
	clear
	svmat `outcome'`cohort'
	sum `outcome'`cohort'
	
	if r(N) != 0 {
		global m`outcome' = r(mean)
		global s`outcome' = r(sd)
	
		***** calculate pvalue 
		gen i = 0 if `outcome' != .
		replace i = 1 if ((`outcome' - ${m`outcome'}) > ${p`outcome'}) & (`outcome' != .) 
		sum i
		global pval`outcome' = r(mean)
		
		* Store the estimation results to the ereturn e()
		tempname b V 	// this notifies Stata that I am going to store something in `b' and `V'
	
		matrix `b' = J(1,1,.)
		matrix `b' = (${p`outcome'})
		matrix rownames `b' = `outcome'
		matrix colnames `b' = D
		mat list `b'
		
		matrix `V' = J(1,1,.)
		matrix `V' = ( ${s`outcome'}^2 )
		matrix rownames `V' = D
		matrix colnames `V' = D
		mat list `V'
	
	} 
	else {
		global p`outcome' = 0
		global s`outcome' = 0
		global pval`outcome' = 9999999
	
		* Store the estimation results to the ereturn e()
		tempname b V 	// this notifies Stata that I am going to store something in `b' and `V'
	
		matrix `b' = J(1,1,.)
		matrix `b' = (0)
		matrix rownames `b' = `outcome'
		matrix colnames `b' = D
		display "displaying b matrix: `b'"
		
		matrix `V' = J(1,1,.)
		matrix `V' = (0)
		matrix rownames `V' = D
		matrix colnames `V' = D
		display "displaying V matrix: `V'"
		
	}
	 
	restore
	
	ereturn post `b' `V'
	
	* Display the results
	di "p`outcome' ${p`outcome'}"
	di "s`outcome' ${s`outcome'}"
	di "pval`outcome' ${pval`outcome'}"
	di "AIPW function successful!"

end





