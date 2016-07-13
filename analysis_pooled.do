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
include ${klmReggio}/Analysis/prepare-data.do

//cd ${klmReggio}/Analysis/Output/
cd /home/UZH/pbirol/Downloads/

* Options to only include main_terms
local outregOptionChild	  bracket label dec(3) keep(ReggioAsilo ReggioMaterna xa* xm* adt_x?Reggio* Male) sortvar(ReggioAsilo ReggioMaterna xa* xm* adt_x?Reggio* Male) ctitle(" ") //drop(o.* *internr_* *Month_int_* Male* mom* dad* cgRelig* houseOwn* cgReddito*) 
local outregOptionAdol    `outregOptionChild'
local outregOptionAdult   `outregOptionChild'

* Locals for controls: look at prepare.do

* ---------------------------------------------------------------------------- *
* Generate variables that interact all controls with city dummies
** Controls
foreach var in `Xcontrol' `Xleft' {
	di "`var'"
	capture generate `var'_Parma = `var'*Parma
	capture generate `var'_Padova = `var'*Padova
}

* ---------------------------------------------------------------------------- *
* Locals for the pooled variables
** Controls
local Xright_Parma 			Male_Parma momMaxEdu_*_Parma dadMaxEdu_*_Parma CAPI_Parma momAgeBirth_Parma dadAgeBirth_Parma ///
							momBornProvince_Parma dadBornProvince_Parma cgRelig_Parma houseOwn_Parma ///
							cgReddito_*_Parma Age_Parma Age_sq_Parma Cohort_Adult40_Parma Cohort_Adult50_Parma
local Xright_Padova 		Male_Padova momMaxEdu_*_Padova dadMaxEdu_*_Padova CAPI_Padova momAgeBirth_Padova dadAgeBirth_Padova ///
							momBornProvince_Padova dadBornProvince_Padova cgRelig_Padova houseOwn_Padova ///
							cgReddito_*_Padova Age_Padova Age_sq_Padova	Cohort_Adult40_Padova Cohort_Adult50_Padova
							// notice that Xright does not include internr_* (interviewer number)
local Xleft_Parma		lowbirthweight_Parma birthpremature_Parma
local Xleft_Padova		lowbirthweight_Padova birthpremature_Padova 	

* ---------------------------------------------------------------------------- *
** Run regressions and save the outputs
log using analysis_pooled, replace 

foreach group in short long { // run regressions for two different comparison groups: one with municipal-other-none (short), the other with all the school types (muni, reli, state, priv, none -- long)
	foreach age in `school_age_types' { // Asilo or Materna
		local cohort_val = 1
		** MAIN TREATMENT EFFECTS; CHANGE REFERENCE GROUP HERE
		if "`age'" == "Asilo" & "`group'" == "short" {
			local int xa 
			local main_terms	ReggioAsilo xaParmaMuni xaPadovaMuni /// Parma Padova 
								///xaReggioSome xaParmaSome xaPadovaSome /// omitted category: any other type
								xaReggioNone xaParmaNone xaPadovaNone
		}
		else if "`age'" == "Materna" & "`group'" == "short" {
			local int xm
			local main_terms	ReggioMaterna xmParmaMuni xmPadovaMuni /// Parma Padova 
								///xmReggioSome xmParmaSome xmPadovaSome /// omitted category: any other type
								xmReggioNone xmParmaNone xmPadovaNone
		}						
		else if "`age'" == "Asilo" & "`group'" == "long" {
			local int xa 
			local main_terms	xaParmaMuni xaPadovaMuni /// omitted category: Municipal Parma Padova ///ReggioAsilo 
								xaReggioReli xaParmaReli xaPadovaReli /// 
								xaReggioPriv xaParmaPriv xaPadovaPriv ///
								xaReggioNone xaParmaNone xaPadovaNone
		}
		else if "`age'" == "Materna" & "`group'" == "long" {
			local int xm
			local main_terms	xmParmaMuni xmPadovaMuni /// omitted category: Municipal Parma Padova ///ReggioMaterna 
								xmReggioStat xmParmaStat xmPadovaStat ///
								xmReggioReli xmParmaReli xmPadovaReli /// 
								xmReggioPriv xmParmaPriv xmPadovaPriv ///
								xmReggioNone xmParmaNone xmPadovaNone
		}
			
		foreach cohort in `cohorts' { // Child, Adol, or Adult 
			foreach outcome in `out`cohort'' {
				local large_sample_condition	largeSample_`age'`cohort'``outcome'_short' == 1
				local outcomelabel : variable label `outcome'


				** Generate large sample (all missing are imputed to zero and converted into dummies)
				reg `outcome' `main_terms' `Xright' `Xadultint' `Xleft' `Xright_Parma' `Xright_Padova' `Xleft_Parma' `Xleft_Padova' if (Cohort_new == `cohort_val'), robust  
				capture gen largeSample_`age'`cohort'``outcome'_short' = e(sample)	
				tab largeSample_`age'`cohort'``outcome'_short'

				** Run regressions and store results into latex
				di "Running the regressions for outcome `outcome' in cohort `cohort'"
				di "1. Only city/age terms"
				reg `outcome' `main_terms' if `large_sample_condition', robust  
				outreg2 using "${klmReggio}/Analysis/Output/pool_tex`age'`cohort'``outcome'_short'_`group'.tex", ///
							  replace `outregOption`cohort'' tex(frag) addtext(Controls, None) ///
						  addnote("Dependent variable: `outcomelabel'.") //First column has no controls and shows the difference among averages. Second column includes interviewer fixed effects. Third column adds denmographic and family controls. Fourth column also controls for initial conditions (birthweight and prematurity, when present). Fifth column interacts all controls with city-dummies. Sixth column runs the regression only for the Reggio Emilia sample. Final column does not include interviewer fixed effects.")

				di "2. Adding postal code fixed effects"
				reg `outcome' `main_terms' CAPI Postal_* if `large_sample_condition', robust  
				outreg2 using "${klmReggio}/Analysis/Output/pool_tex`age'`cohort'``outcome'_short'_`group'.tex", append `outregOption`cohort'' tex(frag) addtext(Controls, F.E.)

				di "3. Interviewer and demographic/family/interview characteristics"
				reg `outcome' `main_terms' `Xright' `Xadultint' if `large_sample_condition', robust  
				outreg2 using "${klmReggio}/Analysis/Output/pool_tex`age'`cohort'``outcome'_short'_`group'.tex", append `outregOption`cohort'' tex(frag) addtext(Controls, Family)

				di "4. All controls"
				reg `outcome' `main_terms' `Xright' `Xadultint' `Xleft' if `large_sample_condition', robust  
				outreg2 using "${klmReggio}/Analysis/Output/pool_tex`age'`cohort'``outcome'_short'_`group'.tex", append `outregOption`cohort'' tex(frag) addtext(Controls, All)

				di "5. Controls interacted with City"
				reg `outcome' `main_terms' `Xright' `Xadultint' `Xleft' `Xright_Parma' `Xright_Padova' `Xleft_Parma' `Xleft_Padova' if `large_sample_condition', robust 
				matrix define aux = r(table)
				matrix define  beta`age'`cohort'``outcome'_short' = aux[1,1...] //store all the betas
				matrix define  pval`age'`cohort'``outcome'_short' = aux[4,1...] //store all the p-values
				outreg2 using "${klmReggio}/Analysis/Output/pool_tex`age'`cohort'``outcome'_short'_`group'.tex", append `outregOption`cohort'' tex(frag) addtext(Controls, Inter)

				di "6. Only Reggio"
				reg `outcome' `main_terms' `Xright' `Xadultint' `Xleft' if `large_sample_condition' & Reggio==1, robust  
				outreg2 using "${klmReggio}/Analysis/Output/pool_tex`age'`cohort'``outcome'_short'_`group'.tex", append `outregOption`cohort'' tex(frag) addtext(Controls, Reggio)

				di "7. No Fixed Effects"
				reg `outcome' `main_terms' `Xcontrol' `Xadultint' `Xleft' if `large_sample_condition', robust  
				outreg2 using "${klmReggio}/Analysis/Output/pool_tex`age'`cohort'``outcome'_short'_`group'.tex", append `outregOption`cohort'' tex(frag) addtext(Controls, no FE)

			}
			local cohort_val = `cohort_val' + 1
		}
	}
}



/* TO DO: Jessica, can you find a way of reporting only the pvalues of the interactions with the City (e.g. Male_Parma, momMaxEdu_*_Parma) 
in order to check if and which ones are significantly different from zero? */

foreach age in `school_age_types' { // Asilo or Materna
	foreach cohort in `cohorts' { // Child, Adol, or Adult  
		foreach outcome in `out`cohort'' {
		matrix list pval`age'`cohort'``outcome'_short' 
		}
	}
}

log close
