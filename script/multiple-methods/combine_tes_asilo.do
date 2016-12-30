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
global cohort					child adol adult30 adult40
global group					Other None 

global reglistchild				NoneIt BICIt FullIt   	 
global fulllistchild			NoneIt BICIt FullIt  
global reglistchildlp			noneit bicit fullit  
global aipwlistchildlp			psmit 
local aipwit_n					bicit
global fulllistchildlp			noneit bicit fullit 


global reglistadol				None BIC Full 
global fulllistadol				None Bic Full  
global reglistadollp			none bic full   
global fulllistadollp			none bic full 

global reglistadult30				None30 BIC30 Full30
global fulllistadult30				None30 BIC30 Full30 
global reglistadult30lp				none30 bic30 full30 
global fulllistadult30lp			none30 bic30 full30


global reglistadult40				None40 BIC40 Full40
global fulllistadult40				None40 BIC40 Full40 
global reglistadult40lp				none40 bic40 full40 
global fulllistadult40lp			none40 bic40 full40

* ------------------------------------ *
* Merge and Create Tex for each cohort *
* ------------------------------------ *
foreach coh in $cohort {
	
	foreach gr in $group {
	
		import delimited using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/reg_`coh'_M_`gr'_asilo.csv", clear
		
		
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
		di "reglist: ${reglist`coh'} 	aipwlist: ${aipwlist`coh'}"
		
		foreach item in ${fulllist`coh'} {
			local colname `colname' & `item'
		}
		
		di "colname: `colname'"
		
		* Estimate
		foreach outcome in $`coh'_outcome_M {
			* Regression-based
			foreach item in ${reglist`coh'lp} {
				
				* Get the values
				levelsof itt_`item' if rowname == "`outcome'", local(p`item'`outcome')
				levelsof itt_`item'_se if rowname == "`outcome'", local(se`item'`outcome')
				levelsof itt_`item'_p if rowname == "`outcome'", local(pv`item'`outcome')
				levelsof itt_`item'_n if rowname == "`outcome'", local(n`item'`outcome')
				
				* Format decimal points
				local p`item'`outcome' : di %9.2f `p`item'`outcome''
				local se`item'`outcome' : di %9.2f `se`item'`outcome''
				local pv`item'`outcome' = `pv`item'`outcome''
				
				* Boldify if p-value < 0.15
				if `pv`item'`outcome'' <= 0.10 {			
					local p`item'`outcome' 	"\textbf{ `p`item'`outcome'' }"
				}
				
				* Number of observations in italic
				local n`item'`outcome' "\textit{ `n`item'`outcome'' }"
			}
			di "regression done"
			
			/* AIPW-based
			foreach item in ${aipwlist`coh'lp} {
				
				* Get the values
				levelsof aipw_`item' if rowname == "`outcome'", local(p`item'`outcome')
				levelsof aipw_`item'_se if rowname == "`outcome'", local(se`item'`outcome')
				levelsof aipw_`item'_p if rowname == "`outcome'", local(pv`item'`outcome')
				levelsof itt_``item'_n'_n if rowname == "`outcome'", local(n`item'`outcome')
				
				* Format decimal points
				local p`item'`outcome' : di %9.2f `p`item'`outcome''
				local se`item'`outcome' : di %9.2f `se`item'`outcome''
				local pv`item'`outcome' = `pv`item'`outcome''
				
				* Boldify if p-value < 0.15
				if `pv`item'`outcome'' <= 0.10 {
					local p`item'`outcome' "\textbf{`p`item'`outcome''}"
				}
				
				* Number of observations in italic
				local n`item'`outcome' "\textit{ `n`item'`outcome'' }"
			
			}
			di "aipw done `gr' `coh'"
		*/
		
		
			* Tex file Point Estimate
			local `outcome'tex_p 	${`outcome'_lab}
			foreach item in ${fulllist`coh'lp} {
				local `outcome'tex_p	``outcome'tex_p' & `p`item'`outcome''
			}
			
			* Tex file Standard Error
			local `outcome'tex_se	
			foreach item in ${fulllist`coh'lp}  {
				local `outcome'tex_se	``outcome'tex_se' & (`se`item'`outcome'' )
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
		file open tabfile`coh'`gr' using "${git_reggio}/output/multiple-methods/combinedanalysis/asilo_`coh'_M_`gr'.tex", write replace
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
