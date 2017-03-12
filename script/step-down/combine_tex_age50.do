/* --------------------------------------------------------------------------- *
* Merging CSV's
* Authors: Jessica Yu Kyung Koh
* Created: 11/16/2016
* Edited:  02/19/2017
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
global cohort					adult50
global groupadult50				Other
global outcomeadult50			M E W L H N S
	
global didlistadult50			DiD40 DiD30 
global reglistadult50			OLS40 OLS30
global did30listadult50			KMDID30
global did40listadult50			KMDID40

global didlistadult50lp			rdid40 rdid30 
global reglistadult50lp			ols40 ols30
global did30listadult50lp		mdid30
global did40listadult50lp		mdid40

global fulllistadult50			OLS30 DiD30 KMDiD30 OLS40 DiD40 KMDiD40
global fulllistadult50lp		ols30 rdid30 mdid30 ols40 rdid40 mdid40
global firstlineadult50			\multicolumn{3}{c}{Within Age-30} & \multicolumn{3}{c}{With Age-40}     
global clineadult50				\cmidrule(lr){2-4} \cmidrule(lr){5-7} 



* ------------------------------------ *
* Merge and Create Tex for each cohort *
* ------------------------------------ *
foreach coh in $cohort {
	foreach gr in ${group`coh'} {
		foreach out in ${outcome`coh'} {
		
			di "Importing for `coh' `gr' `out' - DID"
			import delimited using "${git_reggio}/output/multiple-methods/stepdown/csv/did_`coh'_`out'_Other_sd.csv", clear
			
			tempfile reg_`coh'_`gr'
			save "`reg_`coh'_`gr''"
			
			di "Importing for `coh' `gr' `out' - REG"
			import delimited using "${git_reggio}/output/multiple-methods/stepdown/csv/reg_`coh'_`out'_None_sd.csv", clear
			merge 1:1 rowname using `reg_`coh'_`gr''
			
			drop _merge
			
			tempfile reg_`coh'_`gr'
			save "`reg_`coh'_`gr''"

			import delimited using "${git_reggio}/output/multiple-methods/stepdown/csv/mDIDkernel_Adult50_Adult40_Reggio_`out'_`gr'_alt.csv", clear
			foreach spec in b se p sdp n {				// Rename columns to avoid conflicts in merge
				rename mdid_reggio_`spec' 	mdid_mdid40_`spec'
			}
			merge 1:1 rowname using `reg_`coh'_`gr''
			
			drop _merge
			
			tempfile reg_`coh'_`gr'
			save "`reg_`coh'_`gr''"
			
			import delimited using "${git_reggio}/output/multiple-methods/stepdown/csv/mDIDkernel_Adult50_Adult30_Reggio_`out'_`gr'.csv", clear
			foreach spec in b se p sdp n {				// Rename columns to avoid conflicts in merge
				rename mdid_reggio_`spec' 	mdid_mdid30_`spec'
			}
			merge 1:1 rowname using `reg_`coh'_`gr''
			
			drop _merge
			
			
			* ------------------------- *
			* Determine the Tex Headers *
			* ------------------------- *
			* Tabular
			local count : word count ${didlist`coh'} ${reglist`coh'} ${did30list`coh'} ${did40list`coh'}
			local tabular 	l
			
			foreach num of numlist 1/`count' {
				local tabular `tabular' c
			}
			di "tabular: `tabular'"
			
			* Column Names
			local colname
			
			foreach item in ${fulllist`coh'} {
				local colname `colname' & `item'
			}
			
			di "colname: `colname'"
			
			* Estimate
			foreach outcome in ${adult_outcome_`out'} {
				
			
				di "for outcome `outcome'"
				* Regression-based
				foreach item in ${didlist`coh'lp} ${reglist`coh'lp} {
					
					* Get the values
					levelsof itt_`item' if rowname == "`outcome'", local(p`item'`outcome')
					levelsof itt_`item'_sdp if rowname == "`outcome'", local(sd`item'`outcome')
					levelsof itt_`item'_p if rowname == "`outcome'", local(pv`item'`outcome')
					levelsof itt_`item'_n if rowname == "`outcome'", local(n`item'`outcome')
				
					* Format decimal points
					if !missing("`p`item'`outcome''")  & !missing("`pv`item'`outcome''") {
						* Store p-values into another macro
						local pvn`item'`outcome' = `pv`item'`outcome''
						local sdn`item'`outcome' = `sd`item'`outcome''
					
						* Stringify the numbers to limit the decimal points
						local p`item'`outcome' = string(`p`item'`outcome'', "%9.2f")
						local sd`item'`outcome' = string(`sd`item'`outcome'', "%9.2f")
						local pv`item'`outcome' = string(`pv`item'`outcome'', "%9.2f")
								
						* Wrap parentheses around p-values
						local pv`item'`outcome' 	(`pv`item'`outcome'')
						local sd`item'`outcome'		(`sd`item'`outcome'')
						
						*Put stars according to the significance level 
						if `pvn`item'`outcome'' <= 0.05 {			
							local pv`item'`outcome' 	"`pv`item'`outcome''***"
						}
						if `pvn`item'`outcome'' <= 0.10 & `pvn`item'`outcome'' > 0.05 {			
							local pv`item'`outcome' 	"`pv`item'`outcome''**"
						}
						if `pvn`item'`outcome'' <= 0.15 & `pvn`item'`outcome'' > 0.10 {			
							local pv`item'`outcome' 	"`pv`item'`outcome''*"
						}
						if `sdn`item'`outcome'' <= 0.05 {			
							local sd`item'`outcome' 	"`sd`item'`outcome''***"
						}
						if `sdn`item'`outcome'' <= 0.10 & `sdn`item'`outcome'' > 0.05 {			
							local sd`item'`outcome' 	"`sd`item'`outcome''**"
						}
						if `sdn`item'`outcome'' <= 0.05 & `sdn`item'`outcome'' > 0.10 {			
							local sd`item'`outcome' 	"`sd`item'`outcome''*"
						}					
					}
				}
				di "regression done"
				
				
				* DID-matching-based
			
				foreach item in ${did30list`coh'lp} ${did40list`coh'lp} {
					
					* Get the values
					levelsof mdid_`item'_b if rowname == "`outcome'", local(p`item'`outcome')
					levelsof mdid_`item'_sdp if rowname == "`outcome'", local(sd`item'`outcome')
					levelsof mdid_`item'_p if rowname == "`outcome'", local(pv`item'`outcome')
					levelsof mdid_`item'_n if rowname == "`outcome'", local(n`item'`outcome')
					
					
				
					* Format decimal points
					if !missing("`p`item'`outcome''")  & !missing("`pv`item'`outcome''") {
						* Store p-values into another macro
						local pvn`item'`outcome' = `pv`item'`outcome''
						local sdn`item'`outcome' = `sd`item'`outcome''
					
						* Stringify the numbers to limit the decimal points
						local p`item'`outcome' = string(`p`item'`outcome'', "%9.2f")
						local sd`item'`outcome' = string(`sd`item'`outcome'', "%9.2f")
						local pv`item'`outcome' = string(`pv`item'`outcome'', "%9.2f")
								
						* Wrap parentheses around p-values
						local pv`item'`outcome' 	(`pv`item'`outcome'')
						local sd`item'`outcome'		(`sd`item'`outcome'')
						
						*Put stars according to the significance level 
						if `pvn`item'`outcome'' <= 0.05 {			
							local pv`item'`outcome' 	"`pv`item'`outcome''***"
						}
						if `pvn`item'`outcome'' <= 0.10 & `pvn`item'`outcome'' > 0.05 {			
							local pv`item'`outcome' 	"`pv`item'`outcome''**"
						}
						if `pvn`item'`outcome'' <= 0.15 & `pvn`item'`outcome'' > 0.10 {			
							local pv`item'`outcome' 	"`pv`item'`outcome''*"
						}
						if `sdn`item'`outcome'' <= 0.05 {			
							local sd`item'`outcome' 	"`sd`item'`outcome''***"
						}
						if `sdn`item'`outcome'' <= 0.10 & `sdn`item'`outcome'' > 0.05 {			
							local sd`item'`outcome' 	"`sd`item'`outcome''**"
						}
						if `sdn`item'`outcome'' <= 0.05 & `sdn`item'`outcome'' > 0.10 {			
							local sd`item'`outcome' 	"`sd`item'`outcome''*"
						}					
					}
				}
			
				di "did matching done `gr' `coh'"
				
				* Tex file Point Estimate
				local `outcome'tex_p 	${`outcome'_lab}
				foreach item in ${fulllist`coh'lp} {
					local `outcome'tex_p	``outcome'tex_p' & `p`item'`outcome''
				}
	
				* Tex file P-Value
				local `outcome'tex_pv	\quad \textit{Unadjusted P-Value}
				foreach item in ${fulllist`coh'lp}  {
					local `outcome'tex_pv	``outcome'tex_pv' & `pv`item'`outcome''
				}
			
				* Tex file Stepdown P-Value 
				local `outcome'tex_sd	\quad \textit{Stepdown P-Value}
				foreach item in ${fulllist`coh'lp}  {
					local `outcome'tex_sd	``outcome'tex_sd' & `sd`item'`outcome''
				}
			
			}
			

			* ------------------- *
			* Now Create Tex file *
			* ------------------- *
				
			file open tabfile`coh'`gr' using "${git_reggio}/output/multiple-methods/stepdown/combined_`coh'_`out'_`gr'_sd.tex", write replace
			file write tabfile`coh'`gr' "\begin{tabular}{`tabular'}" _n
			file write tabfile`coh'`gr' "\toprule" _n
			file write tabfile`coh'`gr' "& ${firstline`coh'} \\"
			file write tabfile`coh'`gr' "${cline`coh'}" _n 
			file write tabfile`coh'`gr' " `colname' \\" _n
			file write tabfile`coh'`gr' "\midrule" _n

			foreach outcome in ${adult_outcome_`out'} {
				* Point Estimate
				file write tabfile`coh'`gr' "``outcome'tex_p' \\" _n
				
				* Standard Error
				file write tabfile`coh'`gr' "``outcome'tex_pv' \\" _n
				
				* Number of obs
				file write tabfile`coh'`gr' "``outcome'tex_sd' \\" _n
			}
		
				file write tabfile`coh'`gr' "\bottomrule" _n
				file write tabfile`coh'`gr' "\end{tabular}" _n
				file close tabfile`coh'`gr'
		
	
		}
	}
}



