* ---------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - OLS pooled across cities
* Authors: Pietro Biroli, Chiara Pronzato
* Editors: Jessica Yu Kyung Koh, Anna Ziff
* Created: 12/11/2015
* Edited: 01/14/2016
* ---------------------------------------------------------------------------- *

capture log close
clear all
set more off
set maxvar 32000
* ---------------------------------------------------------------------------- *
* Set directory
/* 
Note: In order to make this do file runable on other computers, 
		create an environment variable that points to the directory for Reggio.dta.
		Those who want to use this code on their computers should set up 
		environment variables named "klmReggio" for klmReggio 
		and "data_reggio" for klmReggio/SURVEY_DATA_COLLECTION/data
		on their computers. 
Note: Install the following commands: dummieslab, outreg2
*/

global klmReggio	: 	env klmReggio		
global data_reggio	: 	env data_reggio

* Prepare the data for the analysis, creating variables and locals
include ${klmReggio}/Analysis/prepare-data_new.do

cd ${klmReggio}/Analysis/Output/

* Options to only include main_terms
local outregOptionChildAdol	  bracket label dec(3) keep(x?Reggio* x?ParmaMuni* x?PadovaMuni* Male) sortvar(x?Reggio* x?ParmaMuni* x?PadovaMuni* Male) ctitle(" ") //drop(o.* *internr_* *Month_int_* Male* mom* dad* cgRelig* houseOwn* cgReddito*) 
local outregOptionAdol    	  `outregOptionChildAdol'
local outregOptionAdolAdult   `outregOptionChildAdol'

* Locals for controls: look at prepare.do

* ---------------------------------------------------------------------------- *
** Locals for regressions
local ChildAdol_n	Child
local Adol_n		Adol
local xa_n			Asilo
local xm_n			Materna

** Locals for the set of interaction terms that should be included for each group 
** (Can somebody check these?)
local Xright_Adol			`Xright_Parma' `Xright_Padova'
			
local Xright_ChildAdol		Cohort_Adol `Xright_Adol'
local Xright_City_ChildAdol	`Xright_Parma' `Xright_Parma_Adol' /// `Xright_Parma_Child' 
							`Xright_Padova' `Xright_Padova_Adol' // `Xright_Padova_Child' 

local Xright_AdolAdult      Cohort_Adult?? `Xright_Adult'
local Xright_City_AdolAdult `Xright_Parma' `Xright_Parma_Adult' ///
                            `Xright_Padova' `Xright_Padova_Adult'

local Xright_Adultall      Cohort_Adult?? `Xright_Adult30' `Xright_Adult40' `Xright_Adult50'
local Xright_City_Adultall `Xright_Parma' `Xright_Parma_Adult30' `Xright_Parma_Adult40' `Xright_Parma_Adult50' ///
                           `Xright_Padova' `Xright_Padova_Adult30' `Xright_Padova_Adult40' `Xright_Padova_Adult50' 

* ---------------------------------------------------------------------------- *
** Run regressions and save the outputs
log using analysis_pooled, replace 

foreach group in short long { // run regressions for two different comparison groups: one with municipal-other-none (short), the other with all the school types (muni, reli, state, priv, none -- long)
	foreach age in xa xm { // Asilo or Materna
			foreach cohort in ChildAdol Adol AdolAdult { // outcome groups
				** MAIN TREATMENT EFFECTS; CHANGE REFERENCE GROUP HERE
				if "`group'" == "short" & ("`cohort'" == "ChildAdol" | "`cohort'" == "Adol") {
					local main_terms	                     `age'ParmaMuniChild `age'PadovaMuniChild /// `age'ReggioMuniChild
                                        `age'ReggioSomeChild `age'ParmaSomeChild `age'PadovaSomeChild /// 
                                        `age'ReggioNoneChild `age'ParmaNoneChild `age'PadovaNoneChild ///
                                                            `age'ParmaMuniAdol `age'PadovaMuniAdol ///  `age'ReggioMuniAdol
                                        `age'ReggioSomeAdol `age'ParmaSomeAdol `age'PadovaSomeAdol ///
                                        `age'ReggioNoneAdol `age'ParmaNoneAdol `age'PadovaNoneAdol 
				}
				else if "`group'" == "short" & ("`cohort'" == "AdolAdult") {
					local main_terms	                     `age'ParmaMuniAdult `age'PadovaMuniAdult /// `age'ReggioMuniAdult
                                        `age'ReggioSomeAdult `age'ParmaSomeAdult `age'PadovaSomeAdult /// 
                                        `age'ReggioNoneAdult `age'ParmaNoneAdult `age'PadovaNoneAdult ///
                                                            `age'ParmaMuniAdol `age'PadovaMuniAdol ///  `age'ReggioMuniAdol
                                        `age'ReggioSomeAdol `age'ParmaSomeAdol `age'PadovaSomeAdol ///
                                        `age'ReggioNoneAdol `age'ParmaNoneAdol `age'PadovaNoneAdol 
				}
				else if "`group'" == "long" & ("`cohort'" == "ChildAdol" | "`cohort'" == "Adol") {
					local main_terms	                     `age'ParmaMuniChild `age'PadovaMuniChild /// `age'ReggioMuniChild
                                        `age'ReggioReliChild `age'ParmaReliChild `age'PadovaReliChild /// 
                                        `age'ReggioStatChild `age'ParmaStatChild `age'PadovaStatChild /// 
                                        `age'ReggioPrivChild `age'ParmaPrivChild `age'PadovaPrivChild ///
                                        `age'ReggioNoneChild `age'ParmaNoneChild `age'PadovaNoneChild ///
                                                         `age'ParmaMuniAdol `age'PadovaMuniAdol ///  `age'ReggioMuniAdol
                                        `age'ReggioReliAdol `age'ParmaReliAdol `age'PadovaReliAdol ///
                                        `age'ReggioStatAdol `age'ParmaStatAdol `age'PadovaStatAdol ///
                                        `age'ReggioPrivAdol `age'ParmaPrivAdol `age'PadovaPrivAdol ///
                                        `age'ReggioNoneAdol `age'ParmaNoneAdol `age'PadovaNoneAdol 

					}
				else if "`group'" == "long" & ("`cohort'" == "AdolAdult") {
					local main_terms	                     `age'ParmaMuniAdult `age'PadovaMuniAdult /// `age'ReggioMuniAdult
                                        `age'ReggioReliAdult `age'ParmaReliAdult `age'PadovaReliAdult /// 
                                        `age'ReggioStatAdult `age'ParmaStatAdult `age'PadovaStatAdult /// 
                                        `age'ReggioPrivAdult `age'ParmaPrivAdult `age'PadovaPrivAdult ///
                                        `age'ReggioNoneAdult `age'ParmaNoneAdult `age'PadovaNoneAdult ///
                                                         `age'ParmaMuniAdol `age'PadovaMuniAdol ///  `age'ReggioMuniAdol
                                        `age'ReggioReliAdol `age'ParmaReliAdol `age'PadovaReliAdol ///
                                        `age'ReggioStatAdol `age'ParmaStatAdol `age'PadovaStatAdol ///
                                        `age'ReggioPrivAdol `age'ParmaPrivAdol `age'PadovaPrivAdol ///
                                        `age'ReggioNoneAdol `age'ParmaNoneAdol `age'PadovaNoneAdol 
				}
			
				foreach outcome in `out`cohort'' {
					local large_sample_condition	largeSample_``age'_n'`cohort'``outcome'_short' == 1
					local outcomelabel : variable label `outcome'

					** Generate large sample (all missing are imputed to zero and converted into dummies)
					reg `outcome' `main_terms' `Xright' `Xright_`cohort'' `Xright_City_`cohort''  if (Cohort_`cohort' == 1), robust  
					capture gen largeSample_``age'_n'`cohort'``outcome'_short' = e(sample)	
					tab largeSample_``age'_n'`cohort'``outcome'_short'

					** Run regressions and store results into latex
					di "Running the regressions for outcome `outcome' in cohort `cohort'"
					di "1. Only city/age terms"
					reg `outcome' `main_terms' Cohort_* if `large_sample_condition', robust  
					outreg2 using "${klmReggio}/Analysis/Output/new_pool_tex``age'_n'`cohort'``outcome'_short'_`group'.tex", ///
								  replace `outregOption`cohort'' tex(frag) addtext(Controls, None) ///
							  addnote("Dependent variable: `outcomelabel'.") //First column has no controls and shows the difference among averages. Second column includes interviewer fixed effects. Third column adds denmographic and family controls. Fourth column also controls for initial conditions (birthweight and prematurity, when present). Fifth column interacts all controls with city-dummies. Sixth column runs the regression only for the Reggio Emilia sample. Final column does not include interviewer fixed effects.")

					
					di "2. Adding postal code fixed effects"
					reg `outcome' `main_terms' Cohort_* CAPI Postal_* if `large_sample_condition', robust  
					outreg2 using "${klmReggio}/Analysis/Output/new_pool_tex``age'_n'`cohort'``outcome'_short'_`group'.tex", append `outregOption`cohort'' tex(frag) addtext(Controls, F.E.)
					
					di "3. All controls"
					reg `outcome' `main_terms' `Xright' `Xright_`cohort'' if `large_sample_condition', robust  
					outreg2 using "${klmReggio}/Analysis/Output/new_pool_tex``age'_n'`cohort'``outcome'_short'_`group'.tex", append `outregOption`cohort'' tex(frag) addtext(Controls, All)
					
					di "4. Controls interacted with City"
					reg `outcome' `main_terms' `Xright' `Xright_`cohort'' `Xright_City_`cohort'' if `large_sample_condition', robust 
					outreg2 using "${klmReggio}/Analysis/Output/new_pool_tex``age'_n'`cohort'``outcome'_short'_`group'.tex", append `outregOption`cohort'' tex(frag) addtext(Controls, Inter)
					
					di "5. Only Reggio"
					reg `outcome' `main_terms' `Xright' `Xright_`cohort'' `Xright_City_`cohort'' if `large_sample_condition' & Reggio==1, robust  
					outreg2 using "${klmReggio}/Analysis/Output/new_pool_tex``age'_n'`cohort'``outcome'_short'_`group'.tex", append `outregOption`cohort'' tex(frag) addtext(Controls, Reggio)

					di "6. Only Adolescets"
					reg `outcome' `main_terms' `Xright' `Xright_`cohort'' `Xright_City_`cohort'' if `large_sample_condition' & Cohort==3, robust  
					outreg2 using "${klmReggio}/Analysis/Output/new_pool_tex``age'_n'`cohort'``outcome'_short'_`group'.tex", append `outregOption`cohort'' tex(frag) addtext(Controls, Adol)

					di "7. No Fixed Effects"
					reg `outcome' `main_terms' `Xcontrol' `Xright_`cohort'' `Xright_City_`cohort'' if `large_sample_condition', robust  
					outreg2 using "${klmReggio}/Analysis/Output/new_pool_tex``age'_n'`cohort'``outcome'_short'_`group'.tex", append `outregOption`cohort'' tex(frag) addtext(Controls, no FE)
					
			}
		}
	}
}

/*
* DUMMY CHECK

global xa_main_terms xaParmaMuniChild xaPadovaMuniChild xaReggioReliChild xaParmaReliChild xaPadovaReliChild xaReggioPrivChild xaParmaPrivChild xaPadovaPrivChild xaReggioNoneChild xaParmaNoneChild xaPadovaNoneChild ///
                     xaParmaMuniAdol xaPadovaMuniAdol xaReggioReliAdol xaParmaReliAdol xaPadovaReliAdol xaReggioPrivAdol xaParmaPrivAdol xaPadovaPrivAdol xaReggioNoneAdol xaParmaNoneAdol xaPadovaNoneAdol 

*(1) No controls
* Both
regress childSDQ_score $xa_main_terms Cohort_Adol /// 
        if Cohort == 1 | Cohort==3
outreg2 using tempfile, replace

* Child only
capture drop tempvar
summarize childSDQ_score if xaReggioMuniChild == 1 & Cohort == 1
scalar reference_xa = r(mean)
gen tempvar = childSDQ_score - reference_xa
tabstat tempvar if Cohort==1, by(cityXasilo) stat(mean count)

regress childSDQ_score $xa_main_terms /// 
        if Cohort == 1
outreg2 using tempfile, append
drop tempvar 

* Adol only
capture drop tempvar
summarize childSDQ_score if xaReggioMuniAdol == 1 & Cohort == 3
scalar reference_xa = r(mean)
gen tempvar = childSDQ_score - reference_xa
tabstat tempvar if Cohort==3, by(cityXasilo) stat(mean count)

regress childSDQ_score $xa_main_terms /// 
        if Cohort == 3
outreg2 using tempfile, append
drop tempvar 

* Reggio only 
regress childSDQ_score $xa_main_terms Cohort_Adol /// 
        if (Cohort == 1 | Cohort==3) & Reggio==1
outreg2 using tempfile, append

*(2) With controls
* Both
regress childSDQ_score $xa_main_terms Cohort_Adol Age Age_Adol Age_Parma Age_Padova Age_Parma_Adol Age_Padova_Adol /// 
        if Cohort == 1 | Cohort==3
outreg2 using tempfile, append

* Adol only
regress childSDQ_score $xa_main_terms Cohort_Adol Age Age_Adol Age_Parma Age_Padova Age_Parma_Adol Age_Padova_Adol /// 
        if Cohort == 3
outreg2 using tempfile, append

* Child only
regress childSDQ_score $xa_main_terms Cohort_Adol Age Age_Adol Age_Parma Age_Padova Age_Parma_Adol Age_Padova_Adol /// 
        if Cohort == 1
outreg2 using tempfile, append

* Reggio only 
regress childSDQ_score $xa_main_terms Cohort_Adol Age Age_Adol Age_Parma Age_Padova Age_Parma_Adol Age_Padova_Adol /// 
        if (Cohort == 1 | Cohort==3) & Reggio==1
outreg2 using tempfile, append

*/

log close

/* store the p-values of the interactions
matrix define aux = r(table)
matrix define  beta`age'`cohort'``outcome'_short' = aux[1,1...] //store all the betas
matrix define  pval`age'`cohort'``outcome'_short' = aux[4,1...] //store all the p-values
*/
