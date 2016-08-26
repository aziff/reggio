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
local Xright_City_Adol		`Xright_Parma' `Xright_Padova'
			
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

//foreach group in short long { // run regressions for two different comparison groups: one with municipal-other-none (short), the other with all the school types (muni, reli, state, priv, none -- long)
//	foreach age in xa xm { // Asilo or Materna
//			foreach cohort in ChildAdol Adol AdolAdult { // outcome groups
local group long
local age xa
local cohort ChildAdol
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
			
//				foreach outcome in `out`cohort'' {
local outcome childSDQ_score
					local large_sample_condition	largeSample_``age'_n'`cohort'``outcome'_short' == 1
					local outcomelabel : variable label `outcome'

					** Generate large sample (all missing are imputed to zero and converted into dummies)
					reg `outcome' `main_terms' `Xright' `Xright_`cohort'' `Xright_City_`cohort''  if (Cohort_`cohort' == 1), robust  
keep if e(sample)
					capture gen largeSample_``age'_n'`cohort'``outcome'_short' = e(sample)	
					tab largeSample_``age'_n'`cohort'``outcome'_short'
					

global xa_main_terms xaParmaMuniChild xaPadovaMuniChild xaReggioReliChild xaParmaReliChild xaPadovaReliChild xaReggioPrivChild xaParmaPrivChild xaPadovaPrivChild xaReggioNoneChild xaParmaNoneChild xaPadovaNoneChild ///
xaParmaMuniAdol xaPadovaMuniAdol xaReggioReliAdol xaParmaReliAdol xaPadovaReliAdol xaReggioPrivAdol xaParmaPrivAdol xaPadovaPrivAdol xaReggioNoneAdol xaParmaNoneAdol xaPadovaNoneAdol 

*(2) With controls
* Both
regress childSDQ_score $xa_main_terms Cohort_Adol Postal_5-Postal_9 Postal_13-Postal_15 Postal_29-Postal_33 Age Age_Adol Age_Parma Age_Padova Age_Parma_Adol Age_Padova_Adol /// 
                                                  Age_sq Age_sq_Adol Age_sq_Parma Age_sq_Padova Age_sq_Parma_Adol Age_sq_Padova_Adol /// 
                                                  Male Male_Adol Male_Parma Male_Padova Male_Parma_Adol Male_Padova_Adol /// 
                                                  CAPI CAPI_Adol CAPI_Parma CAPI_Padova CAPI_Parma_Adol CAPI_Padova_Adol /// 
                                                  momMaxEdu_middle momMaxEdu_middle_Adol momMaxEdu_middle_Parma momMaxEdu_middle_Padova momMaxEdu_middle_Parma_Adol momMaxEdu_middle_Padova_Adol /// 
                                                  momMaxEdu_HS momMaxEdu_HS_Adol momMaxEdu_HS_Parma momMaxEdu_HS_Padova momMaxEdu_HS_Parma_Adol momMaxEdu_HS_Padova_Adol /// 
                                                  momMaxEdu_Uni momMaxEdu_Uni_Adol momMaxEdu_Uni_Parma momMaxEdu_Uni_Padova momMaxEdu_Uni_Parma_Adol momMaxEdu_Uni_Padova_Adol /// 
                                                  momAgeBirth momAgeBirth_Adol momAgeBirth_Parma momAgeBirth_Padova momAgeBirth_Parma_Adol momAgeBirth_Padova_Adol /// 
                                                  dadAgeBirth dadAgeBirth_Adol dadAgeBirth_Parma dadAgeBirth_Padova dadAgeBirth_Parma_Adol dadAgeBirth_Padova_Adol /// 
                                                  dadMaxEdu_middle dadMaxEdu_middle_Adol dadMaxEdu_middle_Parma dadMaxEdu_middle_Padova dadMaxEdu_middle_Parma_Adol dadMaxEdu_middle_Padova_Adol /// 
                                                  dadMaxEdu_HS dadMaxEdu_HS_Adol dadMaxEdu_HS_Parma dadMaxEdu_HS_Padova dadMaxEdu_HS_Parma_Adol dadMaxEdu_HS_Padova_Adol /// 
                                                  dadMaxEdu_Uni dadMaxEdu_Uni_Adol dadMaxEdu_Uni_Parma dadMaxEdu_Uni_Padova dadMaxEdu_Uni_Parma_Adol dadMaxEdu_Uni_Padova_Adol /// 
                                                  momBornProvince momBornProvince_Adol momBornProvince_Parma momBornProvince_Padova momBornProvince_Parma_Adol momBornProvince_Padova_Adol /// 
                                                  dadBornProvince dadBornProvince_Adol dadBornProvince_Parma dadBornProvince_Padova dadBornProvince_Parma_Adol dadBornProvince_Padova_Adol /// 
        if Cohort == 1 | Cohort==3
outreg2 using tempfile, replace


* Adol only
regress childSDQ_score $xa_main_terms Cohort_Adol Postal_5-Postal_9 Postal_13-Postal_15 Postal_29-Postal_33 Age Age_Adol Age_Parma Age_Padova Age_Parma_Adol Age_Padova_Adol /// 
                                                  Age_sq Age_sq_Adol Age_sq_Parma Age_sq_Padova Age_sq_Parma_Adol Age_sq_Padova_Adol /// 
                                                  Male Male_Adol Male_Parma Male_Padova Male_Parma_Adol Male_Padova_Adol /// 
                                                  CAPI CAPI_Adol CAPI_Parma CAPI_Padova CAPI_Parma_Adol CAPI_Padova_Adol /// 
                                                  momMaxEdu_middle momMaxEdu_middle_Adol momMaxEdu_middle_Parma momMaxEdu_middle_Padova momMaxEdu_middle_Parma_Adol momMaxEdu_middle_Padova_Adol /// 
                                                  momMaxEdu_HS momMaxEdu_HS_Adol momMaxEdu_HS_Parma momMaxEdu_HS_Padova momMaxEdu_HS_Parma_Adol momMaxEdu_HS_Padova_Adol /// 
                                                  momMaxEdu_Uni momMaxEdu_Uni_Adol momMaxEdu_Uni_Parma momMaxEdu_Uni_Padova momMaxEdu_Uni_Parma_Adol momMaxEdu_Uni_Padova_Adol /// 
                                                  momAgeBirth momAgeBirth_Adol momAgeBirth_Parma momAgeBirth_Padova momAgeBirth_Parma_Adol momAgeBirth_Padova_Adol /// 
                                                  dadAgeBirth dadAgeBirth_Adol dadAgeBirth_Parma dadAgeBirth_Padova dadAgeBirth_Parma_Adol dadAgeBirth_Padova_Adol /// 
                                                  dadMaxEdu_middle dadMaxEdu_middle_Adol dadMaxEdu_middle_Parma dadMaxEdu_middle_Padova dadMaxEdu_middle_Parma_Adol dadMaxEdu_middle_Padova_Adol /// 
                                                  dadMaxEdu_HS dadMaxEdu_HS_Adol dadMaxEdu_HS_Parma dadMaxEdu_HS_Padova dadMaxEdu_HS_Parma_Adol dadMaxEdu_HS_Padova_Adol /// 
                                                  dadMaxEdu_Uni dadMaxEdu_Uni_Adol dadMaxEdu_Uni_Parma dadMaxEdu_Uni_Padova dadMaxEdu_Uni_Parma_Adol dadMaxEdu_Uni_Padova_Adol /// 
                                                  momBornProvince momBornProvince_Adol momBornProvince_Parma momBornProvince_Padova momBornProvince_Parma_Adol momBornProvince_Padova_Adol /// 
                                                  dadBornProvince dadBornProvince_Adol dadBornProvince_Parma dadBornProvince_Padova dadBornProvince_Parma_Adol dadBornProvince_Padova_Adol /// 
        if Cohort == 3
outreg2 using tempfile, append

* Child only
regress childSDQ_score $xa_main_terms Cohort_Adol Postal_5-Postal_9 Postal_13-Postal_15 Postal_29-Postal_33 Age Age_Adol Age_Parma Age_Padova Age_Parma_Adol Age_Padova_Adol /// 
                                                  Age_sq Age_sq_Adol Age_sq_Parma Age_sq_Padova Age_sq_Parma_Adol Age_sq_Padova_Adol /// 
                                                  Male Male_Adol Male_Parma Male_Padova Male_Parma_Adol Male_Padova_Adol /// 
                                                  CAPI CAPI_Adol CAPI_Parma CAPI_Padova CAPI_Parma_Adol CAPI_Padova_Adol /// 
                                                  momMaxEdu_middle momMaxEdu_middle_Adol momMaxEdu_middle_Parma momMaxEdu_middle_Padova momMaxEdu_middle_Parma_Adol momMaxEdu_middle_Padova_Adol /// 
                                                  momMaxEdu_HS momMaxEdu_HS_Adol momMaxEdu_HS_Parma momMaxEdu_HS_Padova momMaxEdu_HS_Parma_Adol momMaxEdu_HS_Padova_Adol /// 
                                                  momMaxEdu_Uni momMaxEdu_Uni_Adol momMaxEdu_Uni_Parma momMaxEdu_Uni_Padova momMaxEdu_Uni_Parma_Adol momMaxEdu_Uni_Padova_Adol /// 
                                                  momAgeBirth momAgeBirth_Adol momAgeBirth_Parma momAgeBirth_Padova momAgeBirth_Parma_Adol momAgeBirth_Padova_Adol /// 
                                                  dadAgeBirth dadAgeBirth_Adol dadAgeBirth_Parma dadAgeBirth_Padova dadAgeBirth_Parma_Adol dadAgeBirth_Padova_Adol /// 
                                                  dadMaxEdu_middle dadMaxEdu_middle_Adol dadMaxEdu_middle_Parma dadMaxEdu_middle_Padova dadMaxEdu_middle_Parma_Adol dadMaxEdu_middle_Padova_Adol /// 
                                                  dadMaxEdu_HS dadMaxEdu_HS_Adol dadMaxEdu_HS_Parma dadMaxEdu_HS_Padova dadMaxEdu_HS_Parma_Adol dadMaxEdu_HS_Padova_Adol /// 
                                                  dadMaxEdu_Uni dadMaxEdu_Uni_Adol dadMaxEdu_Uni_Parma dadMaxEdu_Uni_Padova dadMaxEdu_Uni_Parma_Adol dadMaxEdu_Uni_Padova_Adol /// 
                                                  momBornProvince momBornProvince_Adol momBornProvince_Parma momBornProvince_Padova momBornProvince_Parma_Adol momBornProvince_Padova_Adol /// 
                                                  dadBornProvince dadBornProvince_Adol dadBornProvince_Parma dadBornProvince_Padova dadBornProvince_Parma_Adol dadBornProvince_Padova_Adol /// 
        if Cohort == 1
outreg2 using tempfile, append

* Reggio only 
regress childSDQ_score $xa_main_terms Cohort_Adol Postal_5-Postal_9 Postal_13-Postal_15 Postal_29-Postal_33 Age Age_Adol Age_Parma Age_Padova Age_Parma_Adol Age_Padova_Adol /// 
                                                  Age_sq Age_sq_Adol Age_sq_Parma Age_sq_Padova Age_sq_Parma_Adol Age_sq_Padova_Adol /// 
                                                  Male Male_Adol Male_Parma Male_Padova Male_Parma_Adol Male_Padova_Adol /// 
                                                  CAPI CAPI_Adol CAPI_Parma CAPI_Padova CAPI_Parma_Adol CAPI_Padova_Adol /// 
                                                  momMaxEdu_middle momMaxEdu_middle_Adol momMaxEdu_middle_Parma momMaxEdu_middle_Padova momMaxEdu_middle_Parma_Adol momMaxEdu_middle_Padova_Adol /// 
                                                  momMaxEdu_HS momMaxEdu_HS_Adol momMaxEdu_HS_Parma momMaxEdu_HS_Padova momMaxEdu_HS_Parma_Adol momMaxEdu_HS_Padova_Adol /// 
                                                  momMaxEdu_Uni momMaxEdu_Uni_Adol momMaxEdu_Uni_Parma momMaxEdu_Uni_Padova momMaxEdu_Uni_Parma_Adol momMaxEdu_Uni_Padova_Adol /// 
                                                  momAgeBirth momAgeBirth_Adol momAgeBirth_Parma momAgeBirth_Padova momAgeBirth_Parma_Adol momAgeBirth_Padova_Adol /// 
                                                  dadAgeBirth dadAgeBirth_Adol dadAgeBirth_Parma dadAgeBirth_Padova dadAgeBirth_Parma_Adol dadAgeBirth_Padova_Adol /// 
                                                  dadMaxEdu_middle dadMaxEdu_middle_Adol dadMaxEdu_middle_Parma dadMaxEdu_middle_Padova dadMaxEdu_middle_Parma_Adol dadMaxEdu_middle_Padova_Adol /// 
                                                  dadMaxEdu_HS dadMaxEdu_HS_Adol dadMaxEdu_HS_Parma dadMaxEdu_HS_Padova dadMaxEdu_HS_Parma_Adol dadMaxEdu_HS_Padova_Adol /// 
                                                  dadMaxEdu_Uni dadMaxEdu_Uni_Adol dadMaxEdu_Uni_Parma dadMaxEdu_Uni_Padova dadMaxEdu_Uni_Parma_Adol dadMaxEdu_Uni_Padova_Adol /// 
                                                  momBornProvince momBornProvince_Adol momBornProvince_Parma momBornProvince_Padova momBornProvince_Parma_Adol momBornProvince_Padova_Adol /// 
                                                  dadBornProvince dadBornProvince_Adol dadBornProvince_Parma dadBornProvince_Padova dadBornProvince_Parma_Adol dadBornProvince_Padova_Adol /// 
        if (Cohort == 1 | Cohort==3) & Reggio==1
outreg2 using tempfile, append

/*
					di "4. Controls interacted with City"
					reg `outcome' `main_terms' `Xright' `Xright_`cohort'' `Xright_City_`cohort'' if `large_sample_condition', robust 
outreg2 using tempfile, append

					reg `outcome' `main_terms' `Xright' `Xright_`cohort'' `Xright_City_`cohort'' if `large_sample_condition' & Cohort==3, robust 
outreg2 using tempfile, append

					reg `outcome' `main_terms' `Xright' `Xright_`cohort'' `Xright_City_`cohort'' if `large_sample_condition' & Cohort==1, robust 
outreg2 using tempfile, append

					reg `outcome' `main_terms' `Xright' `Xright_`cohort'' `Xright_City_`cohort'' if `large_sample_condition' & Reggio==1, robust 
outreg2 using tempfile, append
