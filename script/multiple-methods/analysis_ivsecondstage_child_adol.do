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
local comparisonGroups 		iv kern psm
global ivlistchild 			ivit
global ivlistadol			iv
global psmlistchild 		psmr
global psmlistadol			psmr
global kernlistchild 		kmr
global kernlistadol			kmr
global kernH				kn
global ivH					iv
global psmH					psm



foreach cohort in child adol{	
	foreach stype in Other Reli Stat {											
		foreach type in  M CN S H B {	
		
			*-----------------------------------------*
			* Open latex file to write. We won't write 
			* into this file until the end of code.
			*-----------------------------------------*
			file open tabfile using "${git_reggio}/output/multiple-methods/stepdown/ivresults_`cohort'_`type'_`stype'.tex", write replace
			file write tabfile "\begin{tabular}{L{9cm} L{1cm} l L{1cm} l l l}" _n
			file write tabfile "\toprule" _n
			file write tabfile " & & 	 & & \multicolumn{3}{c}{\textbf{\ul{Tests of Equality}}} \\[10pt]" _n
			file write tabfile " & & IV & & PSM & & Kernel \\" _n
			file write tabfile "\midrule" _n
			
		
			
			*-----------------------------------------*
			* Merging data to conduct test of equality*
			*-----------------------------------------*
			foreach method in `comparisonGroups'{
				
				* Bring in csv containing estimated values
				local suffix
				if ("`method'" != "kern") local suffix _sd
				
				import delimited using "../../output/multiple-methods/stepdown/csv/`method'_`cohort'_`type'_`stype'`suffix'", clear
				if ("`method'" == "psm") drop psm_psmpm* psm_psmpv*
				if ("`method'" == "kern") drop kn_kmpm* kn_kmpv*
				
				tempfile `method'
				save "`method'", replace
			}
				
			use iv, clear
			merge 1:1 rowname using psm
			drop _merge
			merge 1:1 rowname using kern
			drop _merge
			
			
			
			*-----------------------------------------*
			* Testing for Equality *
			*-----------------------------------------*
			* Generate numerator and denominator for test
			gen numerator_iv_psm = iv_${ivlist`cohort'} - psm_psmr
			gen numerator_iv_kern = iv_${ivlist`cohort'} - kn_kmr
			gen denominator_iv_psm = ((iv_${ivlist`cohort'}_se)^2+(psm_psmr_se)^2)^(1/2)
			gen denominator_iv_kern = ((iv_${ivlist`cohort'}_se)^2+(kn_kmr_se)^2)^(1/2) 
		
			* Compute test statistic
			gen z_iv_psm =  numerator_iv_psm/denominator_iv_psm
			gen z_iv_kern = numerator_iv_kern/denominator_iv_kern
			
			*Calculate p-values
			gen pvalue_iv_psm = 2*(1-normal(abs(z_iv_psm)))
			gen pvalue_iv_kern = 2*(1-normal(abs(z_iv_kern)))
			
			
			
			* -------------------------------------------- *
			* Create macros entries for writing into latex
			* -------------------------------------------- *
			local totalvars = _N
			forvalues i = 1/`totalvars'{
				local varname = rowname[`i']
				local varname ${`varname'_lab}
			
				* Storing estimated coefficients and se
				*-------------------------------------*
				foreach method in `comparisonGroups'{ 			
					* Storing relevant estimates in macros
					local `method'_coef 	: di %3.2f `= ${`method'H}_${`method'list`cohort'}[`i']'
					local `method'_p		: di %3.2f `= ${`method'H}_${`method'list`cohort'}_p[`i']'
					local `method'_sdp		: di %3.2f `= ${`method'H}_${`method'list`cohort'}_sdp[`i']'
					
					* Assigning significance stars
					foreach t in p sdp{
						local sig_`method'_`t'
						if (``method'_`t''<0.1)		local sig_`method'_`t' "*" 
						if (``method'_`t''<0.05) 	local sig_`method'_`t' "**" 
						if (``method'_`t''<0.01)	local sig_`method'_`t' "***" 
					}
				}
				
				* Storing results from test of equality
				*-------------------------------------*

				* Storing relevant estimates in macros
				local z_psm 	: di %3.2f `= z_iv_psm[`i']'
				local z_kern	: di %3.2f `= z_iv_kern[`i']'
				
				local p_psm 	: di %3.2f `= pvalue_iv_psm[`i']'
				local p_kern	: di %3.2f `= pvalue_iv_kern[`i']'
				

				* Assigning significance stars
				foreach t in psm kern{
					local eq_sig_`t'
					if (`p_`t''<0.1)	local eq_sig_`t' "$\bm{\dagger$}" 	
					if (`p_`t''<0.05) 	local eq_sig_`t' "$\bm{\dagger \dagger$}" 	
					if (`p_`t''<0.01)	local eq_sig_`t' "$\bm{\dagger \dagger \dagger$}" 
				}
				
				
				local row_coef 	`varname' 							& & `iv_coef' 				& & `psm_coef' `eq_sig_psm' 	& & `kern_coef' `eq_sig_kern'
				local row_p		\quad \textit{Unadjusted P-Value}	& & (`iv_p') `sig_iv_p'		& & (`psm_p') `sig_psm_p'		& & (`kern_p') `sig_kern_p'
				local row_sdp	\quad \textit{Stepdown P-Value}		& & (`iv_sdp') `sig_iv_sdp'	& & (`psm_sdp') `sig_psm_sdp'	& & (`kern_sdp') `sig_kern_sdp'
				
				
				*----------------------*
				* Write to Tex
				*----------------------*
				file write tabfile "`row_coef' \\" _n
				file write tabfile "`row_p' \\" _n
				file write tabfile "`row_sdp' \\[3pt]" _n
							
			}
			
			file write tabfile "\bottomrule" _n
			file write tabfile "\end{tabular}" _n
			file close tabfile
			
		}
	}
				
}
