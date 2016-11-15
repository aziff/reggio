/*
Project:			Reggio Evaluation
Authors:			Anna Ziff
Original date:		11/8/16
This file:			Function for IPW weights
					Later: add some matching for sensitivity
*/

capture program drop ipwmlogitweight
capture program define ipwmlogitweight

version 13
syntax, yvar(string) xvars(varlist) cohort_num(integer) school_type(string)

	// multinomial logit across whole cohort
	mlogit `yvar' `xvars' if Cohort == `cohort_num', vce(robust)

	/*
	// predict propensity for those in all three cities
	capture drop pr_`yvar'_Cohort`cohort_num'
	qui predict pr_`yvar'_Cohort`cohort_num' if sample_`school_type'2 == 1 & Cohort == `cohort_num'
				
	// calculate weights exactuly
	capture drop weight_Cohort`cohort_num'
	qui gen weight_Cohort`cohort_num' = (1 / pr_`yvar'_Cohort`cohort_num') 			if `yvar' == 1 & Cohort == `cohort_num'
	qui replace weight_Cohort`cohort_num' = (1 / (1 - pr_`yvar'_Cohort`cohort_num')) 	if `yvar' == 0 & Cohort == `cohort_num'
	*/
end
