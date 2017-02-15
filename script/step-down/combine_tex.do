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
global cohort					child adol adult30 adult40
global groupchild				Other 
global groupadol				Other
global groupadult30		   		None Other /*Stat Reli*/
global groupadult40				Other /*Stat Reli*/
global outcomechild				M CN S H B
global outcomeadol				M CN S H B
global outcomeadult30			M E W L H N S
global outcomeadult40			M E W L H N S
	

global reglistchild				None BIC Full DidPm DidPv   
global aipwlistchild			AIPWIt  
global psmlistchild				PSM /*PSMR PSMPm PSMPv*/
global fulllistchild			None BIC Full PSM DidPm DidPv /*DidPm PSMPm DidPv PSMPv*/ // order should be same as fulllistchildlp
global reglistchildlp			none bic full didpm didpv   
global aipwlistchildlp			aipw 
global psmlistchildlp			psm /*psmr psmpm psmpv*/
local aipwit_n					bic
global fulllistchildlp			none bic full psm didpm didpv /*psmr didpm psmpm didpv psmpv */



global reglistadol				None BIC Full DidPm DidPv 
global aipwlistadol				AIPW
global psmlistadol				PSM /*PSMR PSMPm PSMPv*/
global fulllistadol				None BIC Full PSM DidPm DidPv /*DidPm PSMPm DidPv PSMPv*/  // order should be same as fulllistadollp
global reglistadollp			none bic full didpm didpv   
global aipwlistadollp			aipw 
global psmlistadollp			psm /*psmr psmpm psmpv*/ 
local aipw_n					bic
global fulllistadollp			none bic full psm didpm didpv /*psmr didpm psmpm didpv psmpv */


global reglistadult30			None30 BIC30 Full30 DidPm30 DidPv30 
global aipwlistadult30			AIPW30
global psmlistadult30			PSM30 /*PSM30R PSM30Pm PSM30Pv */
global fulllistadult30			None BIC Full PSM DidPm DidPv /*DidPm PSMPm DidPv PSMPv*/    // order should be same as fulllistadultlp
global reglistadult30lp			none30 bic30 full30 didpm30 didpv30  
global aipwlistadult30lp		aipw30
global psmlistadult30lp			psm30 /*psm30r psm30pm psm30pv*/
local aipw30_n					bic30
global fulllistadult30lp		none30 bic30 full30 psm30 didpm30 didpv30 /*psm30r didpm30 psm30pm didpv30 psm30pv*/


global reglistadult40			None40 BIC40 Full40 
global aipwlistadult40			AIPW40 
global psmlistadult40			PSM40 /*PSM40R PSM40Pm PSM40Pv*/
global fulllistadult40			None BIC Full PSM /*PSMPm PSMPv*/ // order should be same as fulllistadultlp
global reglistadult40lp			none40 bic40 full40
global aipwlistadult40lp		aipw40 
global psmlistadult40lp			psm40 /*psm40r psm40pm psm40pv*/
local aipw40_n					bic40
global fulllistadult40lp		none40 bic40 full40 psm40 /*psm40r psm40pm psm40pv*/

/*
global cohort					adult40
global groupadult40				None			

global reglistadult40			None40 BIC40 Full40 DidPm40 DidPv40
global aipwlistadult40			AIPW40 
global psmlistadult40			PSM40 /*PSM40R PSM40Pm PSM40Pv*/
global fulllistadult40			None BIC Full PSM DidPm DidPv /*DidPm PSMPm DidPv PSMPv*/ // order should be same as fulllistadultlp
global reglistadult40lp			none40 bic40 full40 didpm40 didpv40
global aipwlistadult40lp		aipw40
global psmlistadult40lp			psm40 /*psm40r psm40pm psm40pv*/
local aipw40_n					bic40
global fulllistadult40lp		none40 bic40 full40 psm40 didpm40 didpv40 /*didpm40 psm40pm didpv40 psm40pv */ */

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
			
			/*import delimited using "${git_reggio}/output/multiple-methods/stepdown/csv/aipw_`coh'_`out'_`gr'_sd.csv", clear
			merge 1:1 rowname using `reg_`coh'_`gr''
			
			drop _merge
			
			tempfile reg_`coh'_`gr'
			save "`reg_`coh'_`gr''"*/
			
			import delimited using "${git_reggio}/output/multiple-methods/stepdown/csv/psm_`coh'_`out'_`gr'_sd.csv", clear
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
					if !missing("`p`item'`outcome''") & !missing("`pv`item'`outcome''") {
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
					local `outcome'tex_pv	``outcome'tex_pv' & (`pv`item'`outcome'')
				}
			
				* Tex file Stepdown P-Value 
				local `outcome'tex_sd	\quad \textit{Stepdown P-Value}
				foreach item in ${fulllist`coh'lp}  {
					local `outcome'tex_sd	``outcome'tex_sd' & (`sd`item'`outcome'')
				}
			
			}
			

			* ------------------- *
			* Now Create Tex file *
			* ------------------- *
				
			file open tabfile`coh'`gr' using "${git_reggio}/output/multiple-methods/stepdown/combined_`coh'_`out'_`gr'_sd.tex", write replace
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



