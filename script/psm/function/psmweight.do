/*
Project:			Reggio Evaluation
Authors:			Anna Ziff
Original date:		11/8/16
This file:			Function for PSM weights
					Later: add some matching for sensitivity
*/

capture program drop psmweight
capture program define psmweight

version 13
syntax, yvar(string) xvars(varlist) cohort_num(integer) school_type(string)

	// probit in Reggio only
	probit `yvar' `xvars' if Reggio == 1 & Cohort == `cohort_num'
					
	// predict propensity for those in all three cities
	qui predict pr_`yvar' if sample_`school_type'2 == 1 & Cohort == `cohort_num'
				
	// calculate weights exactuly
	qui gen weight = (1 / pr_`yvar') 			if `yvar' == 1 & Cohort == `cohort_num'
	qui replace weight = (1 / (1 - pr_`yvar')) 	if `yvar' == 0 & Cohort == `cohort_num'
	
end
