/* --------------------------------------------------------------------------- *
* Merging CSV's
* Authors: Jessica Yu Kyung Koh
* Created: 06/16/2016
* Edited:  04/29/2017
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
global cohort					child adol adult30 adult40
	

global reglistchild				None Drop2526 Drop4018 DropAll   
global fulllistchild			None Drop2526 Drop4018 DropAll // order should be same as fulllistchildlp
global reglistchildlp			none drop2526 drop4018 dropall 
global fulllistchildlp			none drop2526 drop4018 dropall 

global reglistadol				None Drop2526 Drop4018 DropAll   
global fulllistadol				None Drop2526 Drop4018 DropAll // order should be same as fulllistchildlp
global reglistadollp			none drop2526 drop4018 dropall 
global fulllistadollp			none drop2526 drop4018 dropall 

global reglistadult30			None Drop2526 Drop4018 DropAll   
global fulllistadult30			None Drop2526 Drop4018 DropAll // order should be same as fulllistchildlp
global reglistadult30lp			none drop2526 drop4018 dropall 
global fulllistadult30lp		none drop2526 drop4018 dropall 

global reglistadult40			None Drop2526 Drop4018 DropAll   
global fulllistadult40			None Drop2526 Drop4018 DropAll // order should be same as fulllistchildlp
global reglistadult40lp			none drop2526 drop4018 dropall 
global fulllistadult40lp		none drop2526 drop4018 dropall 

* ------------------------------------ *
* Merge and Create Tex for each cohort *
* ------------------------------------ *
foreach coh in $cohort {
	
	foreach out in ${`coh'_outcome_M} {
	
		import delimited using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/ols_sens_`coh'_M_Other.csv", clear
		
		* ------------------------- *
		* Determine the Tex Headers *
		* ------------------------- *
		* Tabular
		local count : word count ${reglist`coh'} 
		local tabular 	l
		
		foreach num of numlist 1/`count' {
			local tabular `tabular' c
		}
		di "tabular: `tabular'"
		
		* Column Names
		local colname
		di "reglist: ${reglist`coh'} "
		
		foreach item in ${fulllist`coh'} {
			local colname `colname' & `item'
		}
		
		di "colname: `colname'"
		
		* Estimate
		foreach outcome in ${`coh'_outcome_M} {
			
		
			di "for outcome `outcome'"
			* Regression-based
			foreach item in ${reglist`coh'lp} {
				
				* Get the values
				levelsof itt_`item' if rowname == "`outcome'", local(p`item'`outcome')
				levelsof itt_`item'_se if rowname == "`outcome'", local(se`item'`outcome')
				levelsof itt_`item'_p if rowname == "`outcome'", local(pv`item'`outcome')
				levelsof itt_`item'_n if rowname == "`outcome'", local(n`item'`outcome')
			
				* Format decimal points
				if !missing("`p`item'`outcome''") & !missing("`se`item'`outcome''") {
					local p`item'`outcome' = string(`p`item'`outcome'', "%9.2f")
					local se`item'`outcome' = string(`se`item'`outcome'', "%9.2f")
								
					local pv`item'`outcome' = `pv`item'`outcome''
					
					* Boldify if p-value < 0.15
					if `pv`item'`outcome'' <= 0.15 {			
						local p`item'`outcome' 	"\textbf{ `p`item'`outcome'' }"
					}
					
					* Number of observations in italic
					local n`item'`outcome' "\textit{ `n`item'`outcome'' }"
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
			
		file open tabfile`coh' using "${git_reggio}/output/multiple-methods/combinedanalysis/ols_sens_`coh'_M_Other.tex", write replace
		file write tabfile`coh' "\begin{tabular}{`tabular'}" _n
		file write tabfile`coh' "\toprule" _n
		file write tabfile`coh' " `colname' \\" _n
		file write tabfile`coh' "\midrule" _n

		foreach outcome in ${`coh'_outcome_M} {
			* Point Estimate
			file write tabfile`coh' "``outcome'tex_p' \\" _n
			
			* Standard Error
			file write tabfile`coh' "``outcome'tex_se' \\" _n
			
			* Number of obs
			file write tabfile`coh' "``outcome'tex_N' \\" _n
		}
	
			file write tabfile`coh' "\bottomrule" _n
			file write tabfile`coh' "\end{tabular}" _n
			file close tabfile`coh'
	

	}
	
}



