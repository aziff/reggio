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
local switch40 = 1				
/* PLEASE READ:
	- This switch is needed as some age-40 outputs use different methods, and there cannot be a clean loop that runs through everything.
	(1) Run the code with switch40 = 1 first
	(2) Then manually change the switch40 = 0 and then run the code again.

*/

global cohort					/*child adol adult30 adult40*/ adult30
global groupchild				Other Stat Reli
global groupadol				Other Stat Reli
global groupadult30		   		Stat Reli /*None Other Stat Reli*/
global groupadult40				None
global outcomechild				M CN S H B
global outcomeadol				M CN S H B
global outcomeadult30			/*M E W L H N S*/ M
global outcomeadult40			M E W L H N S
	

global reglistchild				None BIC Full DidPm DidPv    
global psmlistchild				PSMR 
global kernellistchild			KMR KMPm KMPv
global didpmlistchild			MDIDPM
global didpvlistchild			MDIDPV
global fulllistchild			None BIC Full PSMR KMR DidPm KMDidPm KMPm DidPv KMDidPv KMPv // order should be same as fulllistchildlp
global reglistchildlp			none bic full didpm didpv   
global psmlistchildlp			psmr 
global didpmlistchildlp			mdidpm
global didpvlistchildlp			mdidpv
global kernellistchildlp		kmr	kmpm kmpv
global fulllistchildlp			none bic full psmr kmr didpm mdidpm kmpm didpv mdidpv kmpv 
global firstlinechild			\multicolumn{5}{c}{Within Reggio} & \multicolumn{3}{c}{With Parma} & \multicolumn{3}{c}{With Padova}     
global clinechild				\cmidrule(lr){2-6} \cmidrule(lr){7-9} \cmidrule(lr){10-12}


global reglistadol				None BIC Full DidPm DidPv    
global psmlistadol				PSMR 
global kernellistadol			KMR KMPm KMPv
global didpmlistadol			MDIDPM
global didpvlistadol			MDIDPV
global fulllistadol				None BIC Full PSMR KMR DidPm KMDidPm KMPm DidPv KMDidPv KMPv // order should be same as fulllistchildlp
global reglistadollp			none bic full didpm didpv   
global psmlistadollp			psmr 
global didpmlistadollp			mdidpm
global didpvlistadollp			mdidpv
global kernellistadollp			kmr	kmpm kmpv
global fulllistadollp			none bic full psmr kmr didpm mdidpm kmpm didpv mdidpv kmpv 
global firstlineadol			\multicolumn{5}{c}{Within Reggio} & \multicolumn{3}{c}{With Parma} & \multicolumn{3}{c}{With Padova}     
global clineadol				\cmidrule(lr){2-6} \cmidrule(lr){7-9} \cmidrule(lr){10-12}


global reglistadult30			None30 BIC30 Full30 DidPm30 DidPv30 
global psmlistadult30			PSM30R  
global kernellistadult30		KM30R KM30Pm KM30Pv
global fulllistadult30			None BIC Full PSMR KMR DidPm KMDidPm KMPm DidPv KMDidPv KMPv  // order should be same as fulllistadultlp
global didpmlistadult30			MDIDPM
global didpvlistadult30			MDIDPV
global reglistadult30lp			none30 bic30 full30 didpm30 didpv30  
global psmlistadult30lp			psm30r
global kernellistadult30lp		km30r km30pm km30pv
global didpmlistadult30lp		mdidpm
global didpvlistadult30lp		mdidpv
global fulllistadult30lp		none30 bic30 full30 psm30r km30r didpm30 mdidpm km30pm didpv30 mdidpv km30pv
global firstlineadult30			\multicolumn{5}{c}{Within Reggio} & \multicolumn{3}{c}{With Parma} & \multicolumn{3}{c}{With Padova} 
global clineadult30				\cmidrule(lr){2-6} \cmidrule(lr){7-9} \cmidrule(lr){10-12}


global reglistadult40			None40 BIC40 Full40 DidPm40 DidPv40 
global psmlistadult40			PSM40R  
global kernellistadult40		KM40R KM40Pm KM40Pv
global fulllistadult40			None BIC Full PSMR KMR DidPm KMDidPm KMPm DidPv KMDidPv KMPv  // order should be same as fulllistadultlp
global didpmlistadult40			MDIDPM
global didpvlistadult40			MDIDPV
global reglistadult40lp			none40 bic40 full40 didpm40 didpv40  
global psmlistadult40lp			psm40r
global kernellistadult40lp		km40r km40pm km40pv
global didpmlistadult40lp		mdidpm
global didpvlistadult40lp		mdidpv

global fulllistadult40lp		none40 bic40 full40 psm40r km40r didpm40 mdidpm km40pm didpv40 mdidpv km40pv
global firstlineadult40			\multicolumn{5}{c}{Within Reggio} & \multicolumn{3}{c}{With Parma} & \multicolumn{3}{c}{With Padova} 
global clineadult40				\cmidrule(lr){2-6} \cmidrule(lr){7-9} \cmidrule(lr){10-12}



	
if `switch40' == 0 {
	global cohort					adult30 adult40
	global groupadult40				Other Reli		
	global reglistadult40			None40 BIC40 Full40 
	global psmlistadult40			PSM40R 
	global didpmlistadult40			
	global didpvlistadult40			
	global kernellistadult40		KM40R KM40Pm KM40Pv
	global fulllistadult40			None BIC Full PSMR KMR KMPm KMPv // order should be same as fulllistadultlp
	global reglistadult40lp			none40 bic40 full40
	global psmlistadult40lp			psm40r 
	global kernellistadult40lp		km40r km40pm km40pv
	global fulllistadult40lp		none40 bic40 full40 psm40r km40r km40pm km40pv
	global firstlineadult40			\multicolumn{5}{c}{Within Reggio} & With Parma & With Padova
	global clineadult40				\cmidrule(lr){2-6} \cmidrule(lr){7-7} \cmidrule(lr){8-8}
}


* ---------------------------------- *
* Capitalize cohort for matching did *
* ---------------------------------- *
local child_m		Child
local adol_m		Adol
local adult30_m		Adult30
local adult40_m 	Adult40


* ------------------------------------ *
* Merge and Create Tex for each cohort *
* ------------------------------------ *
foreach coh in $cohort {
	
	foreach gr in ${group`coh'} {
		foreach out in ${outcome`coh'} {
		
			di "Importing for `coh' `gr' `out'"
			import delimited using "${git_reggio}/output/multiple-methods/stepdown/csv/reg_`coh'_`out'_`gr'_sd.csv", clear
			
			tempfile reg_`coh'_`gr'
			save "`reg_`coh'_`gr''"
			
			import delimited using "${git_reggio}/output/multiple-methods/stepdown/csv/psm_`coh'_`out'_`gr'_sd.csv", clear
			merge 1:1 rowname using `reg_`coh'_`gr''
			
			drop _merge
			
			tempfile reg_`coh'_`gr'
			save "`reg_`coh'_`gr''"
			
			import delimited using "${git_reggio}/output/multiple-methods/stepdown/csv/kern_`coh'_`out'_`gr'.csv", clear
			merge 1:1 rowname using `reg_`coh'_`gr''
			
			drop _merge
			
			tempfile reg_`coh'_`gr'
			save "`reg_`coh'_`gr''"
			
			if `switch40' == 1 { // Only run for yes did Age-40
				di "Importing kernel Parma: `coh' `gr' `out'"
				import delimited using "${git_reggio}/output/multiple-methods/stepdown/csv/mDIDkernel_``coh'_m'_Parma_`out'_`gr'.csv", clear
				foreach spec in b se p sdp n {				// Rename columns to avoid conflicts in merge
					rename mdid_reggio_`spec' 	mdid_mdidpm_`spec'
				}
				merge 1:1 rowname using `reg_`coh'_`gr''
				
				drop _merge
				
				tempfile reg_`coh'_`gr'
				save "`reg_`coh'_`gr''"
				
				di "Importing kernel Padova: `coh' `gr' `out'"
				import delimited using "${git_reggio}/output/multiple-methods/stepdown/csv/mDIDkernel_``coh'_m'_Padova_`out'_`gr'.csv", clear
				foreach spec in b se p sdp n {				// Rename columns to avoid conflicts in merge
					rename mdid_reggio_`spec' 	mdid_mdidpv_`spec'
				}
				merge 1:1 rowname using `reg_`coh'_`gr''
				
				drop _merge
			}
			
			* ------------------------- *
			* Determine the Tex Headers *
			* ------------------------- *
			* Tabular
			local count : word count ${reglist`coh'} ${psmlist`coh'} ${kernellist`coh'} ${didpmlist`coh'} ${didpvlist`coh'}
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
					
					* If p-value is missing (the estimate failed), make sure point estimates and standard p-values are missing values. Sometimes they are shown as weird numbers.
					if missing("`pv`item'`outcome''") {
						local p`item'`outcome'
						local sd`item'`outcome'
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
						
						* If p-value is missing (the estimate failed), make sure point estimates and standard p-values are missing values. Sometimes they are shown as weird numbers.
						if missing("`pv`item'`outcome''") {
							local p`item'`outcome'
							local sd`item'`outcome'
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
						
						* If p-value is missing (the estimate failed), make sure point estimates and standard p-values are missing values. Sometimes they are shown as weird numbers.
						if missing("`pv`item'`outcome''") {
							local p`item'`outcome'
							local sd`item'`outcome'
						}
					}
				}
				di "psm done `gr' `coh'"
				
				* DID-matching-based
				if `switch40' != 0 {
					foreach item in ${didpmlist`coh'lp} ${didpvlist`coh'lp} {
						
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
						
						* If p-value is missing (the estimate failed), make sure point estimates and standard p-values are missing values. Sometimes they are shown as weird numbers.
						if missing("`pv`item'`outcome''") {
							local p`item'`outcome'
							local sd`item'`outcome'
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



