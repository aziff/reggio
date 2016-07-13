* ---------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - OLS Regression
* Authors: Pietro Biroli, Chiara Pronzato
* Editors: Jessica Yu Kyung Koh, Anna Ziff
* Created: 02 March 2016
* Edited:  10 May 2016
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
include ${klmReggio}/Analysis/prepare-data.do

cd ${klmReggio}/Analysis/Output/


* Locals for Outcomes (Adult outcomes should be divided by age)
local outChild                        childSDQ_score childHealthPerc likeSchool likeMath likeLit difficultiesSit difficultiesInterest difficultiesObey difficultiesEat difficulties
local outAdol                         childSDQ_score SDQ_score Depression_score HealthPerc childHealthPerc MigrTaste_cat likeSchool likeMath likeLit difficultiesSit difficultiesInterest difficultiesObey difficultiesEat difficulties
local outAdult30                      Depression_score HealthPerc MigrTaste_cat
local outAdult40                      Depression_score HealthPerc MigrTaste_cat
local outAdult50                      Depression_score HealthPerc MigrTaste_cat

** Controls
*** Xright for Parma and its cohorts

foreach city in `cities' {
    local Xright_`city'     momMaxEdu_*_`city' dadMaxEdu_*_`city' CAPI_`city' momAgeBirth_`city' dadAgeBirth_`city' ///
                            momBornProvince_`city' dadBornProvince_`city' cgRelig_`city' houseOwn_`city' ///
                            cgReddito_*_`city' Age_`city' Age_sq_`city' /*Cohort_Adult40_`city' Cohort_Adult50_`city'*/                                    
}

* Locals for Controls (need to exclude Male because this analysis divide the sample by gender)
** Controls
local Xcontrol                       CAPI Age Age_sq momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni momAgeBirth dadAgeBirth ///missing cat: low edu
                                     dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni ///missing cat: low edu
                                     momBornProvince dadBornProvince cgRelig houseOwn cgReddito_2 cgReddito_3 cgReddito_4 cgReddito_5 cgReddito_6 cgReddito_7 /// missing cat: income below 5,000
                                     lowbirthweight birthpremature
local Xright                         `Xcontrol' Postal_* //Cohort_*
local xmaterna                       xm*
local xasilo                         xa*
/*
local main_name                      Control 1
local inter_name                     Control 2
local right_name                     Control 3
local all_name                       Control 4
*/

* Options to only include main_terms
local outregOptionChild	  bracket label dec(3) keep(ReggioAsilo ReggioMaterna xa* xm*) sortvar(ReggioAsilo ReggioMaterna xaReggioNone* xaReggioState* xaReggioReli* xaReggioSome* xaParmaMuni* xaPadovaMuni* xmReggioNone* xmReggioState* xmReggioReli* xmReggioSome* xmParmaMuni* xmPadovaMuni* Male) ctitle(" ") //drop(o.* *internr_* *Month_int_* Male* mom* dad* cgRelig* houseOwn* cgReddito*) 
local outregOptionAdol    `outregOptionChild'
local outregOptionAdult30   `outregOptionChild'
local outregOptionAdult40   `outregOptionChild'
local outregOptionAdult50   `outregOptionChild'

* Local for gender
local gender0	Female
local gender1	Male

/* definition of controls: check prepare-data.do */


* ---------------------------------------------------------------------------- *
** Generate cohort_new again to divide adult cohorts
drop Cohort_new

generate Cohort_new = 0
replace Cohort_new = 1 if Cohort == 1 // children
replace Cohort_new = 2 if Cohort == 3 // adolescents
replace Cohort_new = 3 if Cohort == 4 // adults age 30
replace Cohort_new = 4 if Cohort == 5 // adults age 40
replace Cohort_new = 5 if Cohort == 6 // adults age 50

* ---------------------------------------------------------------------------- *
** Run regressions and save the outputs
log using analysis_OLS_gender, replace 

sum `Xright'

/* keep track of what happens in the loops
set trace on
set tracedepth 1
*/
foreach group in short long { // run regressions for two different comparison groups: one with municipal-other-none (short), the other with all the school types (muni, reli, state, priv, none -- long)
	foreach age in `school_age_types' { // Asilo or Materna

		local cohort_val = 1
		** MAIN TREATMENT EFFECTS; CHANGE REFERENCE GROUP HERE
		if "`age'" == "Asilo" & "`group'" == "short" {
			local int xa 
			local reference_term    ReggioAsilo
			local other_terms       xaParmaMuni xaPadovaMuni /// Parma Padova ReggioAsilo 
						xaParmaSome xaPadovaSome xaReggioSome /// xaReggioSome 
						xaParmaNone xaPadovaNone xaReggioNone 
		}
		else if "`age'" == "Materna" & "`group'" == "short" {
			local int xm
			local reference_term    ReggioMaterna
			local other_terms       xmParmaMuni xmPadovaMuni /// Parma Padova ReggioMaterna 
						xmParmaSome xmPadovaSome xmReggioSome /// 
						xmParmaNone xmPadovaNone xmReggioNone 
		}						
		else if "`age'" == "Asilo" & "`group'" == "long" {
			local int xa 
			local reference_term    ReggioAsilo
			local other_terms	xaParmaMuni xaPadovaMuni /// Parma Padova ReggioAsilo 
						xaParmaReli xaPadovaReli xaReggioReli /// 
						xaParmaPriv xaPadovaPriv xaReggioPriv /// 
						xaParmaNone xaPadovaNone xaReggioNone 
		}
		else if "`age'" == "Materna" & "`group'" == "long" {
			local int xm
			local reference_term    ReggioMaterna
			local other_terms	xmParmaMuni xmPadovaMuni /// Parma Padova ReggioMaterna 
						xmParmaStat xmPadovaStat xmReggioStat ///
						xmParmaReli xmPadovaReli xmReggioReli /// 
						xmParmaPriv xmPadovaPriv xmReggioPriv ///
						xmParmaNone xmPadovaNone xmReggioNone 
		}
			
		
		foreach cohort in Child Adol Adult30 Adult40 Adult50 { 
			foreach gender in 0 1 {
			di "`cohort'"
				foreach outcome in `out`cohort'' {
					local large_sample_condition largeSample_`age'`cohort'``outcome'_short'`gender' == 1
					local outcomelabel : variable label `outcome'


					** Generate large sample (all missing are imputed to zero and converted into dummies)
					quietly reg `outcome' `other_terms' `Xright' `Xright_Parma' `Xright_Padova' if (Cohort_new == `cohort_val') & (Male == `gender'), robust  
					capture gen largeSample_`age'`cohort'``outcome'_short'`gender' = e(sample)	
					tab largeSample_`age'`cohort'``outcome'_short'`gender'

					** Run regressions and store results into latex
					di "Running the regressions for outcome `outcome' in cohort `cohort'"
					di "1. Only city/age terms"
					reg `outcome' `other_terms' if `large_sample_condition', robust  
					outreg2 using "${klmReggio}/Analysis/Output/OLS/ols_tex_`age'_`cohort'_`gender`gender''_``outcome'_short'_`group'.tex", ///
								  replace `outregOption`cohort'' tex(frag) addtext(Controls, None) ///
							  addnote("Dependent variable: `outcomelabel'.") //First column has no controls and shows the difference among averages. Second column includes interviewer fixed effects. Third column adds denmographic and family controls. Fourth column also controls for initial conditions (birthweight and prematurity, when present). Fifth column interacts all controls with city-dummies. Sixth column runs the regression only for the Reggio Emilia sample. Final column does not include interviewer fixed effects.")

					di "2. All controls"
					reg `outcome' `other_terms' `Xright' if `large_sample_condition', robust  
					outreg2 using "${klmReggio}/Analysis/Output/OLS/ols_tex_`age'_`cohort'_`gender`gender''_``outcome'_short'_`group'.tex", append `outregOption`cohort'' tex(frag) addtext(Controls, All)

					di "3. Controls interacted with City"
					reg `outcome' `other_terms' `Xright' `Xright_Parma' `Xright_Padova' if `large_sample_condition', robust 
					outreg2 using "${klmReggio}/Analysis/Output/OLS/ols_tex_`age'_`cohort'_`gender`gender''_``outcome'_short'_`group'.tex", append `outregOption`cohort'' tex(frag) addtext(Controls, Inter)

					/*di "4. Only Reggio"
					reg `outcome' `other_terms' `Xright' if `large_sample_condition' & Reggio==1, robust  
					outreg2 using "${klmReggio}/Analysis/Output/iv_tex`age'`cohort'``outcome'_short'_`group'.tex", append `outregOption`cohort'' tex(frag) addtext(Controls, Reggio)
					*/

				}
			}
			local cohort_val = `cohort_val' + 1
		}
	}
}


log close
