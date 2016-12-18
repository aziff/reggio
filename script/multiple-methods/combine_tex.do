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
global cohort				child adol adult
global group				Other None Stat Reli

global reglistchild				NoneIt BICIt FullIt DidPmIt DidPvIt   
global aipwlistchild			AIPWIt  
global fulllistchild			NoneIt BICIt FullIt DidPmIt DidPvIt AIPWIt
global reglistchildlp			noneit bicit fullit didpmit didpvit   
global aipwlistchildlp			aipwit 
local aipwit_n					bicit
global fulllistchildlp			noneit bicit fullit didpmit didpvit aipwit


global reglistadol				None BIC Full DidPm DidPv 
global aipwlistadol				AIPW
global fulllistadol				None Bic Full DidPm DidPv AIPW
global reglistadollp			none bic full didpm didpv   
global aipwlistadollp			aipw 
local aipw_n					bic
global fulllistadollp			none bic full didpm didpv aipw

global reglistadult				None30 BIC30 Full30 DidPm30 DidPv30 None40 BIC40 Full40 
global aipwlistadult			AIPW30 AIPW40
global fulllistadult			None30 BIC30 Full30 DidPm30 DidPv30 AIPW30 None40 BIC40 Full40 AIPW40
global reglistadultlp			none30 bic30 full30 didpm30 didpv30 none40 bic40 full40 
global aipwlistadultlp			aipw30 aipw40
local aipw30_n					bic30
local aipw40_n					bic40
global fulllistadultlp			none30 bic30 full30 didpm30 didpv30 aipw30 none40 bic40 full40 aipw40


* ------------------------------------ *
* Merge and Create Tex for each cohort *
* ------------------------------------ *
foreach coh in $cohort {
	
	foreach gr in $group {
	
		import delimited using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/reg_`coh'_M_`gr'.csv", clear
		
		tempfile reg_`coh'_`gr'
		save "`reg_`coh'_`gr''"
		
		import delimited using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/aipw_`coh'_M_`gr'.csv", clear
		merge 1:1 rowname using `reg_`coh'_`gr''
		
		drop _merge
		
		
		* ------------------------- *
		* Determine the Tex Headers *
		* ------------------------- *
		* Tabular
		local count : word count ${reglist`coh'} ${aipwlist`coh'}
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
				if `pv`item'`outcome'' <= 0.15 {			
					local p`item'`outcome' 	"\textbf{ `p`item'`outcome'' }"
				}
				
				* Number of observations in italic
				local n`item'`outcome' "\textit{ `n`item'`outcome'' }"
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
		file open tabfile`coh'`gr' using "${git_reggio}/output/multiple-methods/combinedanalysis/combined_`coh'_M_`gr'.tex", write replace
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
