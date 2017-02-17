/* --------------------------------------------------------------------------- *
* Merging CSV's
* Authors: Jessica Yu Kyung Koh
* Created: 06/16/2016
* Edited:  01/17/2016
* --------------------------------------------------------------------------- */

clear all

cap file 	close outcomes
cap log 	close

global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio

global here : pwd

* Include scripts and functions
include "${here}/../macros" 


* ---------- *
* Set Macros *
* ---------- *
global cohort					child adol 
global groupchild				Other Stat Reli
global groupadol				Stat  Reli Other

global outcomechild				M /*CN S H B*/
global outcomeadol				M /*CN S H B*/

global ivlistchild				ivit
global fulllistchild			IV
global ivlistchildlp			ivit
global fulllistchildlp			ivit

global ivlistadol				iv
global fulllistadol				IV
global ivlistadollp				iv
global fulllistadollp			iv

* ------------------------------------ *
* Merge and Create Tex for each cohort *
* ------------------------------------ *
foreach coh in $cohort {
	
	foreach gr in ${group`coh'} {
		foreach out in ${outcome`coh'} {
		
			import delimited using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/iv_`coh'_`out'_`gr'.csv", clear
			
			tempfile iv_`coh'_`gr'
			save "`iv_`coh'_`gr''"
			
			* ------------------------- *
			* Determine the Tex Headers *
			* ------------------------- *
			* Tabular
			local count : word count ${ivlist`coh'}
			local tabular 	l
			
			foreach num of numlist 1/`count' {
				local tabular `tabular' c
			}
			di "tabular: `tabular'"
			
			* Column Names
			local colname
			di "reglist: ${reglist`coh'} 	aipwlist: ${aipwlist`coh'}"
			
			foreach item in ${fulllist`coh'} {
				local colname `colname' & `item'
			}
			
			di "colname: `colname'"
			
			* Estimate
			foreach outcome in ${`coh'_outcome_`out'} {
				
			
				di "for outcome `outcome'"
				* Regression-based
				foreach item in ${ivlist`coh'lp} {
					
					* Get the values
					levelsof iv_`item' if rowname == "`outcome'", local(p`item'`outcome')
					levelsof iv_`item'_sdp if rowname == "`outcome'", local(sd`item'`outcome')
					levelsof iv_`item'_p if rowname == "`outcome'", local(pv`item'`outcome')
					levelsof iv_`item'_n if rowname == "`outcome'", local(n`item'`outcome')
				
					* Format decimal points
					if !missing("`p`item'`outcome''")  & !missing("`pv`item'`outcome''") {
						local p`item'`outcome' = string(`p`item'`outcome'', "%9.2f")
						local pvn`item'`outcome' = `sd`item'`outcome''
						local sd`item'`outcome' = string(`sd`item'`outcome'', "%9.2f")
						
						local pv`item'`outcome' = string(`pv`item'`outcome'', "%9.2f")
								
						
						*Boldify if p-value < 0.15
						if `pvn`item'`outcome'' <= 0.15 {			
							local p`item'`outcome' 	"\textbf{ `p`item'`outcome'' }"
						}
						
					}
				}
				di "regression done"
				
				
				* Tex file Point Estimate
				local `outcome'tex_p 	${`outcome'_lab}
				foreach item in ${fulllist`coh'lp} {
					local `outcome'tex_p	``outcome'tex_p' & `p`item'`outcome''
				}
	
				* Tex file Standard Error
				local `outcome'tex_se	
				foreach item in ${fulllist`coh'lp}  {
					local `outcome'tex_se	``outcome'tex_se' & (`se`item'`outcome'')
				}
			
				* Tex file Number of observation
				local `outcome'tex_N	
				foreach item in ${fulllist`coh'lp}  {
					local `outcome'tex_N	``outcome'tex_N' & `n`item'`outcome'' 
				}
			
			
			}
			

			* ------------------- *
			* Now Create Tex file *
			* ------------------- *
				
			file open tabfile`coh'`gr' using "${git_reggio}/output/multiple-methods/stepdown/combined_`coh'_`out'_`gr'_iv.tex", write replace
			file write tabfile`coh'`gr' "\begin{tabular}{`tabular'}" _n
			file write tabfile`coh'`gr' "\toprule" _n
			file write tabfile`coh'`gr' " `colname' \\" _n
			file write tabfile`coh'`gr' "\midrule" _n

			foreach outcome in ${`coh'_outcome_`out'} {
				* Point Estimate
				file write tabfile`coh'`gr' "``outcome'tex_p' \\" _n
				
				* Standard Error
				file write tabfile`coh'`gr' "``outcome'tex_se' \\" _n
				
				* Number of obs
				file write tabfile`coh'`gr' "``outcome'tex_N' \\" _n
			}
		
				file write tabfile`coh'`gr' "\bottomrule" _n
				file write tabfile`coh'`gr' "\end{tabular}" _n
				file close tabfile`coh'`gr'
		
	
		}
	}
}



