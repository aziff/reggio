* ---------------------------------------------------------------------------- *
* Checking the consistency between coefficients and baseline characteristics
* Authors: Jessica Yu Kyung Koh
* Created: 03/09/2016
* ---------------------------------------------------------------------------- *

capture log close
clear all
set more off
set maxvar 32000

* ---------------------------------------------------------------------------- *
* Set directory
global klmReggio	: 	env klmReggio		
global data_reggio	: 	env data_reggio

* Prepare the data for the analysis, creating variables and locals
include ${klmReggio}/Analysis/prepare-data.do

cd ${klmReggio}/Analysis/Output/

* Options to only include main_terms
local outregOptionChild	  bracket label dec(3) keep(ReggioAsilo ReggioMaterna xa* xm* Male) sortvar(ReggioAsilo ReggioMaterna xa* xm* Male) ctitle(" ") //drop(o.* *internr_* *Month_int_* Male* mom* dad* cgRelig* houseOwn* cgReddito*) 
local outregOptionAdol    `outregOptionChild'
local outregOptionAdult   `outregOptionChild'

* Locals for controls: look at prepare.do

* ---------------------------------------------------------------------------- *
* Generate variables that interact all controls with city dummies
** Controls
foreach var in `Xcontrol' `Xleft' {
	capture generate `var'_Parma = `var'*Parma
	capture generate `var'_Padova = `var'*Padova
}

* ---------------------------------------------------------------------------- *
* Locals for the pooled variables
** Controls
local Xright_Parma 			Male_Parma momMaxEdu_*_Parma dadMaxEdu_*_Parma CAPI_Parma ///
							momBornProvince_Parma dadBornProvince_Parma cgRelig_Parma houseOwn_Parma ///
							cgReddito_*_Parma Age_Parma Age_sq_Parma 
local Xright_Padova 		Male_Padova momMaxEdu_*_Padova dadMaxEdu_*_Padova CAPI_Padova ///
							momBornProvince_Padova dadBornProvince_Padova cgRelig_Padova houseOwn_Padova ///
							cgReddito_*_Padova Age_Padova Age_sq_Padova	
							// notice that Xright does not include internr_* (interviewer number)
local Xleft_Parma			lowbirthweight_Parma birthpremature_Parma
local Xleft_Padova			lowbirthweight_Padova birthpremature_Padova 	

* ---------------------------------------------------------------------------- *
** Run regressions and save the outputs
log using analysis_dummycheck, replace 

local xa_main_terms		xaParmaMuni xaPadovaMuni ///
						xaReggioReli xaParmaReli xaPadovaReli /// 
						xaReggioPriv xaParmaPriv xaPadovaPriv ///
						xaReggioNone xaParmaNone xaPadovaNone

local xm_main_terms		xmParmaMuni xmPadovaMuni ///
						xmReggioStat xmParmaStat xmPadovaStat ///
						xmReggioReli xmParmaReli xmPadovaReli /// 
						xmReggioPriv xmParmaPriv xmPadovaPriv ///
						xmReggioNone xmParmaNone xmPadovaNone

local outregOption	  	bracket label dec(3) ctitle(" ") 

* Checking Asilo 
summarize childSDQ_score if xaReggioMuni == 1 & Cohort_new == 1
scalar reference_xa = r(mean)

foreach type in Muni Reli Priv None {
	foreach city in Parma Padova {
		summarize childSDQ_score if xa`city'`type' == 1 & Cohort_new == 1
		scalar mean`city'`type'_xa = r(mean) - reference_xa
		di mean`city'`type'_xa
	}
}

regress childSDQ_score `xa_main_terms' if (Cohort_new == 1)
outreg2 using "${klmReggio}/Analysis/Output/dummycheck_xa.tex", replace `outregOption' tex(frag) addtext(Controls, None) 	


* Checking Materna
summarize childSDQ_score if xmReggioMuni == 1 & Cohort_new == 1
scalar reference_xm = r(mean)

foreach type in Muni Stat Reli Priv None {
	foreach city in Parma Padova {
		summarize childSDQ_score if xm`city'`type' == 1 & Cohort_new == 1
		scalar mean`city'`type'_xm = r(mean) - reference_xm
		di mean`city'`type'_xm
	}
}

regress childSDQ_score `xm_main_terms' if (Cohort_new == 1)
outreg2 using "${klmReggio}/Analysis/Output/dummycheck_xm.tex", replace `outregOption' tex(frag) addtext(Controls, None) 		
						
log close

/* Jessica: I think you tend to start doing very complicated things very quickly.
The simple check that I was talking about was just the following lines:
*/
capture drop tempvar
global xa_main_terms xaParmaMuni xaPadovaMuni xaReggioReli xaParmaReli xaPadovaReli xaReggioPriv xaParmaPriv xaPadovaPriv xaReggioNone xaParmaNone xaPadovaNone

summarize childSDQ_score if xaReggioMuni == 1 & Cohort == 1
scalar reference_xa = r(mean)
gen tempvar = childSDQ_score - reference_xa
tabstat tempvar if Cohort==1, by(cityXasilo) stat(mean count)
regress childSDQ_score ///
        xaParmaMuni xaPadovaMuni xaReggioReli xaParmaReli xaPadovaReli xaReggioPriv xaParmaPriv xaPadovaPriv xaReggioNone xaParmaNone xaPadovaNone /// 
        if Cohort == 1
outreg2 using tempfile, replace
regress childSDQ_score Parma Padova ///
                                 xaReggioReli xaParmaReli xaPadovaReli xaReggioPriv xaParmaPriv xaPadovaPriv xaReggioNone xaParmaNone xaPadovaNone /// 
        if Cohort == 1
outreg2 using tempfile, append
drop tempvar 

** With some controls
global controls CAPI Male Age Age_sq momMaxEdu_middle momMaxEdu_HS 
reg childSDQ_score  $controls  if Cohort==1, robust
predict tempvar, residual
summarize tempvar if xaReggioMuni == 1 & Cohort == 1
scalar reference_xa = r(mean)
replace tempvar = tempvar - reference_xa
tabstat tempvar if Cohort==1, by(cityXasilo) stat(mean count)
regress childSDQ_score $controls ///
        xaParmaMuni xaPadovaMuni xaReggioReli xaParmaReli xaPadovaReli xaReggioPriv xaParmaPriv xaPadovaPriv xaReggioNone xaParmaNone xaPadovaNone /// 
        if Cohort == 1
outreg2 using tempfile, append
regress childSDQ_score $controls Parma Padova ///
                                 xaReggioReli xaParmaReli xaPadovaReli xaReggioPriv xaParmaPriv xaPadovaPriv xaReggioNone xaParmaNone xaPadovaNone /// 
        if Cohort == 1
outreg2 using tempfile, append

/* note for future self: 
this is not exactly the same as the tabstat summary statistics, probabl due to corr(dummies,controls)
but it's the same as adding a different set of dummies, for example with city

As expected
the value of the Parma dummy is the same as xaParmaMuni 
the value of all the other dummies within Parma changes.
*/
