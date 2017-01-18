/* --------------------------------------------------------------------------- *
* Merging CSV's
* Authors: Jessica Yu Kyung Koh
* Created: 06/16/2016
* Edited:  12/15/2016
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
global cohort				adult30 adult40
global group				Yes /*Stat Reli*/

global reglistadult30			None30 BIC30 Full30 
global aipwlistadult30			AIPW30
global psmlistadult30			PSM30
global fulllistadult30			None BIC Full PSM AIPW   // order should be same as fulllistadultlp
global reglistadult30lp			none30 bic30 full30 
global aipwlistadult30lp		aipw30
global psmlistadult30lp			psm30 
local aipw30_n					bic30
global fulllistadult30lp		none30 bic30 full30 psm30 aipw30 


global reglistadult40			None40 BIC40 Full40 
global aipwlistadult40			AIPW40 
global psmlistadult40			PSM40
global fulllistadult40			None BIC Full PSM AIPW  // order should be same as fulllistadultlp
global reglistadult40lp			none40 bic40 full40
global aipwlistadult40lp		aipw40 
global psmlistadult40lp			psm40 
local aipw40_n					bic40
global fulllistadult40lp		none40 bic40 full40 psm40 aipw40


* ------------------------------------ *
* Merge and Create Tex for each cohort *
* ------------------------------------ *
foreach city in Parma Padova {
	foreach coh in $cohort {
		
		foreach gr in $group {
		
			import delimited using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/reg_`coh'_M_`gr'_`city'.csv", clear
			
			tempfile reg_`coh'_`gr'
			save "`reg_`coh'_`gr''"
			
			import delimited using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/aipw_`coh'_M_`gr'_`city'.csv", clear
			merge 1:1 rowname using `reg_`coh'_`gr''
			
			drop _merge
			
			tempfile reg_`coh'_`gr'
			save "`reg_`coh'_`gr''"
			
			import delimited using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/psm_`coh'_M_`gr'_`city'.csv", clear
			merge 1:1 rowname using `reg_`coh'_`gr''
			
			drop _merge
			
			* ------------------------- *
			* Determine the Tex Headers *
			* ------------------------- *
			* Tabular
			local count : word count ${reglist`coh'} ${aipwlist`coh'} ${psmlist`coh'}
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
			foreach outcome in $`coh'_outcome_M {
				di "for outcome `outcome'"
				* Regression-based
				foreach item in ${reglist`coh'lp} {
					
					* Get the values
					levelsof itt_`item' if rowname == "`outcome'", local(p`item'`outcome')
					levelsof itt_`item'_se if rowname == "`outcome'", local(se`item'`outcome')
					levelsof itt_`item'_p if rowname == "`outcome'", local(pv`item'`outcome')
					levelsof itt_`item'_n if rowname == "`outcome'", local(n`item'`outcome')
				
					* Format decimal points
					if !missing("`p`item'`outcome''") {
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
				
				* AIPW-based
				foreach item in ${aipwlist`coh'lp} {
					
					* Get the values
					levelsof aipw_`item' if rowname == "`outcome'", local(p`item'`outcome')
					levelsof aipw_`item'_se if rowname == "`outcome'", local(se`item'`outcome')
					levelsof aipw_`item'_p if rowname == "`outcome'", local(pv`item'`outcome')
					levelsof itt_``item'_n'_n if rowname == "`outcome'", local(n`item'`outcome')
					
					* Format decimal points
					if !missing("`p`item'`outcome''") {
						local p`item'`outcome' = string(`p`item'`outcome'', "%9.2f")
						local se`item'`outcome' = string(`se`item'`outcome'', "%9.2f")
						local pv`item'`outcome' = `pv`item'`outcome''
						
						* Boldify if p-value < 0.15
						if `pv`item'`outcome'' <= 0.10 {
							local p`item'`outcome' "\textbf{`p`item'`outcome''}"
						}
						
						* Number of observations in italic
						local n`item'`outcome' "\textit{ `n`item'`outcome'' }"
					}
				
				}
				di "aipw done `gr' `coh'"
			
				
				* PSM-based
				local num : list sizeof global(psmlist`coh')
				if `num' != 0 {
				foreach item in ${psmlist`coh'lp} {
					
					* Get the values
					
					levelsof psm_`item' if rowname == "`outcome'", local(p`item'`outcome')
					levelsof psm_`item'_se if rowname == "`outcome'", local(se`item'`outcome')
					levelsof psm_`item'_p if rowname == "`outcome'", local(pv`item'`outcome')
					levelsof psm_`item'_n if rowname == "`outcome'", local(n`item'`outcome')
					
					* Format decimal points
					if !missing("`p`item'`outcome''") {
						local p`item'`outcome' = string(`p`item'`outcome'', "%9.2f")
						local se`item'`outcome' = string(`se`item'`outcome'', "%9.2f")
						local pv`item'`outcome' = `pv`item'`outcome''
						
						* Boldify if p-value < 0.15
						if `pv`item'`outcome'' <= 0.10 {
							local p`item'`outcome' "\textbf{`p`item'`outcome''}"
						}
						
						* Number of observations in italic
						local n`item'`outcome' "\textit{ `n`item'`outcome'' }"
					}
				}
				di "psm done `gr' `coh'"
			
			
			
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
			file open tabfile`coh'`gr' using "${git_reggio}/output/multiple-methods/combinedanalysis/city`city'_`coh'_M_`gr'.tex", write replace
			file write tabfile`coh'`gr' "\begin{tabular}{`tabular'}" _n
			file write tabfile`coh'`gr' "\toprule" _n
			file write tabfile`coh'`gr' " `colname' \\" _n
			file write tabfile`coh'`gr' "\midrule" _n
		
			foreach outcome in $`coh'_outcome_M {
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
