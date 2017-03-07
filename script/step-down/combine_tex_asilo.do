/* --------------------------------------------------------------------------- *
* Merging CSV's
* Authors: Jessica Yu Kyung Koh
* Created: 11/16/2016
* Edited:  02/16/2017
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
global groupchild				Muni
global groupadol				Muni
global groupadult30		   		Muni
global groupadult40				None
global outcomechild				M /*CN S H B*/
global outcomeadol				M /*CN S H B*/
global outcomeadult30			M /*E W L H N S*/
global outcomeadult40			M /*E W L H N S*/
	

global reglistchild				None BIC Full DidPm DidPv  
global psmlistchild				PSMR PSMPm PSMPv
global kernellistchild			KMR KMPm KMPv
global fulllistchild			None BIC Full PSM KM DidPm PSMPm KMPm DidPv  // order should be same as fulllistchildlp
global reglistchildlp			none bic full didpm didpv
global psmlistchildlp			psm
global kernellistchildlp		km
global fulllistchildlp			none bic full psm km didpm didpv
global firstlinechild			\multicolumn{5}{c}{Within Reggio} & \multicolumn{3}{c}{With Parma} & \multicolumn{3}{c}{With Padova}     
global clinechild				\cmidrule(lr){2-6} \cmidrule(lr){7-9} \cmidrule(lr){10-12}

global reglistadol				None BIC Full DidPm DidPv  
global psmlistadol				PSM
global kernellistadol			KM
global fulllistadol				None BIC Full PSM KM DidPm DidPv // order should be same as fulllistchildlp
global reglistadollp			none bic full didpm didpv
global psmlistadollp			psm
global kernellistadollp			km
global fulllistadollp			none bic full psm km didpm didpv

global reglistadult30			None BIC Full DidPm DidPv
global psmlistadult30			PSM
global kernellistault30			KM
global fulllistadult30			None BIC Full PSM KM DidPm DidPv // order should be same as fulllistchildlp
global reglistadult30lp			none bic full didpm didpv
global psmlistadult30lp			psm
global kernellistadult30lp		km
global fulllistadult30lp		none bic full psm km didpm didpv

/*
global reglistadult40			None BIC Full   
global psmlistadult40			PSM
global kernellistault40			KM
global fulllistadult40			None BIC Full PSM KM // order should be same as fulllistchildlp
global reglistadult40lp			none bic full 
global psmlistadult40lp			psm
global kernellistadult40lp		km
global fulllistadult40lp		none bic full psm km */

* ------------------------------------ *
* Merge and Create Tex for each cohort *
* ------------------------------------ *
foreach coh in $cohort {
	
	foreach gr in ${group`coh'} {
		foreach out in ${outcome`coh'} {
		
			di "Importing for `coh' `gr' `out'"
			import delimited using "${git_reggio}/output/multiple-methods/stepdown/csv/reg_`coh'_`out'_`gr'_asilo_sd.csv", clear
			
			tempfile reg_`coh'_`gr'
			save "`reg_`coh'_`gr''"
			
			import delimited using "${git_reggio}/output/multiple-methods/stepdown/csv/psm_`coh'_`out'_`gr'_asilo_sd.csv", clear
			merge 1:1 rowname using `reg_`coh'_`gr''
			
			drop _merge
			
			tempfile reg_`coh'_`gr'
			save "`reg_`coh'_`gr''"
			
			import delimited using "${git_reggio}/output/multiple-methods/stepdown/csv/kern_`coh'_`out'_`gr'_asilo_sd.csv", clear
			merge 1:1 rowname using `reg_`coh'_`gr''
			
			drop _merge
			
			
			
			* ------------------------- *
			* Determine the Tex Headers *
			* ------------------------- *
			* Tabular
			local count : word count ${reglist`coh'} ${psmlist`coh'} ${kernellist`coh'}
			local tabular 	l
			
			foreach num of numlist 1/`count' {
				local tabular `tabular' c
			}
			di "tabular: `tabular'"
			
			* Column Names
			local colname
			di "reglist: ${reglist`coh'} 	psmlist: ${aipwlist`coh'}   kernellist: ${kernellist`coh'}"
			
			foreach item in ${fulllist`coh'} {
				local colname `colname' & `item'
			}
			
			di "colname: `colname'"
			
			* Estimate
			foreach outcome in ${`coh'_outcome_`out'} {
				
			
				di "for outcome `outcome'"
				* Regression-based
				foreach item in ${reglist`coh'lp} {
					
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
				
			
				
				* PSM-based
				local num : list sizeof global(psmlist`coh')
				if `num' != 0 {
					foreach item in ${psmlist`coh'lp} {
						
						* Get the values
						levelsof psm_`item' if rowname == "`outcome'", local(p`item'`outcome')
						levelsof psm_`item'_sdp if rowname == "`outcome'", local(sd`item'`outcome')
						levelsof psm_`item'_p if rowname == "`outcome'", local(pv`item'`outcome')
						levelsof psm_`item'_n if rowname == "`outcome'", local(n`item'`outcome')
						
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
				}
				di "psm done `gr' `coh'"
				
				
				
				* Kernel-based
				local num : list sizeof global(kernellist`coh')
				if `num' != 0 {
					foreach item in ${kernellist`coh'lp} {
						
						* Get the values
						levelsof kn_`item' if rowname == "`outcome'", local(p`item'`outcome')
						levelsof kn_`item'_sdp if rowname == "`outcome'", local(sd`item'`outcome')
						levelsof kn_`item'_p if rowname == "`outcome'", local(pv`item'`outcome')
						levelsof kn_`item'_n if rowname == "`outcome'", local(n`item'`outcome')
						
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
				}
				di "psm done `gr' `coh'"
				
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
				
			file open tabfile`coh'`gr' using "${git_reggio}/output/multiple-methods/stepdown/combined_`coh'_`out'_`gr'_asilo_sd.tex", write replace
			file write tabfile`coh'`gr' "\begin{tabular}{`tabular'}" _n
			file write tabfile`coh'`gr' "\toprule" _n
			file write tabfile`coh'`gr' " `colname' \\" _n
			file write tabfile`coh'`gr' "\midrule" _n

			foreach outcome in ${`coh'_outcome_`out'} {
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



