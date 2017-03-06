/* ---------------------------------------------------------------------------- *
* Programming an IV function for Reggio analysis (A more general version)
* Author: Sidharth Moktan
* Edited: 2/14/2017

* Note: The purpose of this function is to generate csv file that contains
        point estimates, standard errors, p-values, and # of observations for
		different methodology. Since some methods we use are not regression 
		analysis, we cannot use commands like "estout" or "esttab". 
		
		The csv files created will be merged in other do files to produce
		presentable tables that combine methodologies. 
* ---------------------------------------------------------------------------- */

*==============================================================================*
* Defining Function
*==============================================================================*
	capture program drop ivanalysis
	capture program define ivanalysis

	version 13
	syntax, stype(string) type(string) ivlist(string) cohort(string)

		
		* ------------------------------------- *
		* For IV 								*
		* ------------------------------------- *

		***** Determine if headers need to be written in output (first observation in each category)
		local header_switch header

		***** Loop through the outcomes in a category and store OLS and diff-in-diff results for each age group
		foreach var in ${`cohort'_outcome_`type'} {
			
			local matitems	
			local matnames
		
			local switch = 1
			foreach comp in ${ivlist} {
				sum `var' if ${ifcondition`comp'}
				if r(N) > 0 {
				
					di "variable: `var'"
					* Regress
					ivregress `var' ${controls`comp'} ($endog = $IVmaterna) if ${ifcondition`comp'}, robust
					di "IV specification: ivregress `var' ${controls`comp'} (${endog} = $IVmaterna) if ${ifcondition`comp'}, robust" 
					
					* Save key results to locals
					mat r = r(table)
					local itt_`comp' 	= 	r[1,1]
					local itt_`comp'_se = 	r[2,1]
					local itt_`comp'_p	=	r[4,1]
					local itt_`comp'_N	= 	e(N)
					
					* Add to the matitems and matnames locals
					if `switch' == 1 {
						local matitems `matitems' `itt_`comp'', `itt_`comp'_se', `itt_`comp'_p', `itt_`comp'_N' 
					}
					if `switch' == 0 {
						local matitems `matitems', `itt_`comp'', `itt_`comp'_se', `itt_`comp'_p', `itt_`comp'_N'  
					}
					
					local matnames `matnames' itt_`comp' itt_`comp'_se itt_`comp'_p itt_`comp'_N
					
					local switch = 0
				}
			}	
		
			mat iv = [`matitems']
			mat colname iv = `matnames'
			
			*writematrix, output(iv_`type'_`stype') rowname("`var'") matrix(iv) `header_switch'
			local header_switch 
		}
		
	end

*==============================================================================*
* Calling Function
*==============================================================================*
	foreach cohort in child adol{
		clear all
		
		global klmReggio   : env klmReggio
		global data_reggio : env data_reggio
		global git_reggio  : env git_reggio

		global here : pwd

		use "${data_reggio}/Reggio_reassigned"

		if ("`cohort'"=="child") keep if Cohort<3
		if ("`cohort'"=="adol") keep if Cohort==3
		drop if asilo == 1
		
		local stype_switch = 1
		foreach stype in Other None /*Stat Reli*/ {

			global ivlist					IV`cohort'
			global ifconditionIVchild		(`city' == 1) & (Cohort < 3) 
			global ifconditionIVadol		(`city' == 1) & (Cohort == 3) 
			
			global controlsNone
			global controlsIV				${bic_`cohort'_baseline_vars}
			global controlsFull				${`cohort'_baseline_vars}
			
			global endog					maternaMuni
			global IVmaterna				score50 distMaternaMunicipal1 distMaternaPrivate1 distMaternaReligious1 distState1
			
			gen score25 = (score <= r(p25))
			gen score50 = (score > r(p25) & score <= r(p50))
			gen score75 = (score > r(p50) & score <= r(p75))
			label var score25 "25th pct of RA admission score"
			label var score50 "50th pct of RA admission score"
			label var score75 "75th pct of RA admission score"
			
			foreach type in  M E W L H N S {

				* ----------------------- *
				* For IV Analysis *
				* ----------------------- *
				* Open necessary files
				*cap file close regression_`type'_`stype'
				*file open regression_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/reg_adult30_`type'_`stype'.csv", write replace

				* Run Multiple Analysis
				di "Estimating `type' for Adult: IV Analysis"
				ivanalysis, stype("`stype'") type("`type'") ivlist("${ivlist}") cohort("`cohort'")
			
				* Close necessary files
				*file close regression_`type'_`stype' 
				
			}
			
			local stype_switch = 0
		}
	}
