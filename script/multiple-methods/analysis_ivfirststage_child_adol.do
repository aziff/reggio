/* --------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - OLS and Diff-in-Diff for Adult Cohorts
* Authors: Jessica Yu Kyung Koh
* Created: 06/16/2016
* Edited:  12/12/2016

* Note: This execution do file performs diff-in-diff estimates and generates tables
        by using "multipleanalysis" command that is programmed in 
		"reggio/script/ols/function/multipleanalysis.do"  
		To understand how the command is coded, please refer to the above do file.
* --------------------------------------------------------------------------- */

clear all

cap file 	close outcomes
cap log 	close

global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio

global here : pwd
*--------------------------------------------------------------------------- */
* Include scripts and functions
include "${here}/../macros" 
include "${here}/function/writematrix"
* --------------------------------------------------------------------------- */


foreach stype in Other /*Reli Stat*/ {											

	*-----------------------------------------*
	* Open latex file to write. We won't write 
	* into this file until the end of code.
	*-----------------------------------------*
	file open tabfile using "${git_reggio}/output/multiple-methods/stepdown/ivfirststage_`stype'.tex", write replace
	file write tabfile "\begin{tabular}{l L{1cm} l L{1cm} l}" _n
	file write tabfile "\toprule" _n
	file write tabfile " & & Child & & Adol \\" _n
	file write tabfile "\midrule" _n
	
	*-----------------------------------------*
	* Import estimates*
	*-----------------------------------------*
	foreach cohort in child adol{	
		import delimited using "../../output/multiple-methods/stepdown/csv/ivfirststage_`cohort'_`stype'", clear
		foreach x of varlist _all {
			rename `x' `x'_`cohort'
		}
		rename rowname_`cohort' rowname
		
		tempfile `cohort'
		save "`cohort'", replace
	}
	
	use child, clear
	merge 1:1 rowname using adol
	
	* -------------------------------------------- *
	* Create macros entries for writing into latex
	* -------------------------------------------- *
	local totalvars = _N		
	foreach cohort in child adol{	
		local N				= n_`cohort'[1]
		local r	: di %3.2f `= r_`cohort'[1]'

		forvalues i = 1/`totalvars'{
			
			local varname = rowname[`i']
					
			* Storing relevant estimates in macros
			local coef 	: di %3.2f `= coef_`cohort'[`i']'
			local p		: di %3.2f `= p_`cohort'[`i']'
			local se	: di %3.2f `= se_`cohort'[`i']'
			
			* Assigning significance stars
			local sig
			if (`p'<0.1)	local sig "*" 
			if (`p'<0.05) 	local sig "**" 
			if (`p'<0.01)	local sig "***" 
			

			* Storing values in row macros		
			if "`cohort'" == "child"{
				local row_coef_`i' `varname' 	& & `coef' 	`sig'	
				local row_se_`i'				& & (`se')
			}
			if "`cohort'" == "adol"{
				local row_coef_`i' 	`row_coef_`i'' 	& & `coef' 	`sig'	
				local row_se_`i'	`row_se_`i''	& & (`se')
			}
		}
		if "`cohort'" == "child"{
			local row_N			N			& & `N'
			local row_R			R$^2$ 		& & `r'	
		}
		if "`cohort'" == "adol"{
			local row_N			`row_N'		& & `N'
			local row_R			`row_R'		& & `r'		
		}
	}
	
	forvalues i = 1/`totalvars'{
		file write tabfile "`row_coef_`i'' \\" _n
		file write tabfile "`row_se_`i'' \\[5pt]" _n
	}
	
	file write tabfile "\midrule" _n	
	file write tabfile "`row_R' \\" _n
	file write tabfile "`row_N' \\" _n	
	
	file write tabfile "\bottomrule" _n
	file write tabfile "\end{tabular}" _n
	file close tabfile
}
			

