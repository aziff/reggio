clear all
set more off
capture log close

*** directory
// global dir "D:\Research\ReggioChildren"
 global dir "C:\Users\Pronzato\Dropbox\ReggioChildren"
 global dir "C:\Users\pbiroli\Dropbox\ReggioChildren"
// global dir "/mnt/ide0/share/klmReggio"

global datadir "$dir/SURVEY_DATA_COLLECTION/data"
global outdir "$dir/Analysis/"
cd "$outdir"

log using selection, replace 
/*
Author: Pietro Biroli and Chiara Pronzato

Purpose of the do file: Analyze the Reggio Children Evaluation Survey to understand selection into different school types

This Draft: 11 Dec 2015

Input: 	Reggio.dta  --> see dataClean_all.do
		
Output:	Plots and tables
*/

use $datadir/Reggio.dta, clear

*--------------------------------------------------------*
* global variables for controls
global outcomes 	childSDQ_score SDQ_score Depression_score HealthPerc childHealthPerc MigrTaste_cat 
global outLabel 	childSDQ_score "SDQ score (mom report)" SDQ_score "SDQ Score" Depression_score "Depression Score" HealthPerc "Good health" childHealthPerc "Good health" MigrTaste_cat "Bothered by immigration into city"
des $outcomes 

global outChild 	childSDQ_score childHealthPerc 
global outAdo 		$outcomes 
global outAdult 	Depression_score HealthPerc MigrTaste_cat 

*--------------------------------------------------------*
* (item) Create some variables 
* make interview date fixed effects
gen Month_int = mofd(Date_int)
dummieslab Month_int
tab IncomeCat_manual , miss gen(Reddito_)
rename Reddito_8 Reddito_miss 
tab cgIncomeCat_manual , miss gen(cgReddito_)
gen cgReddito_miss = (cgIncomeCat_manual>=.)
drop cgReddito_8 cgReddito_9
gen cgSuperFaith = (cgFaith >=4) if cgFaith <.

*--------------------------------------------------------*
* global Controls
global Xright   	Male momMaxEdu_* dadMaxEdu_* internr_* CAPI momBornProvince dadBornProvince ///
					cgRelig houseOwn cgReddito_* Age Age_sq

global Xleft		lowbirthweight birthpremature grand_nbrhood cgSuperFaith cgAsilo cgMaterna //momHome06 
					
global xmaterna 	xm*
global xasilo 		xa*
		   

** Put some decent labels:
label var ReggioMaterna "RCH preschool"
label var ReggioAsilo "RCH infant-toddler"
label var treated "Reggio Approach"
gen ReggioBoth = ReggioMaterna * ReggioAsilo
label var ReggioBoth "RCH Both"

label var CAPI "CAPI"
label var Cohort_Adult30 "30 year olds"
label var Cohort_Adult40 "40 year olds"
label var Male "Male dummy"
label var asilo_Attend "Any infant-toddler center"
label var asilo_Municipal "Municipal infant-toddler center"
label var materna_Municipal "Municipal preschool"
label var materna_Religious "Religious preschool"
label var materna_State "State preschool"
label var materna_Private "Private preschool"

label var dadMaxEdu_Uni "Father College" 
label var momMaxEdu_Uni "Mother College" 
label var cgPA_HouseWife "Caregiver Housewife"
label var dadPA_Unempl "Father Unemployed" 
label var cgmStatus_div "Caregiver Divorced"
label var momHome06 "Mom Home at 6"
label var numSiblings "Num. Siblings"
label var childrenSibTot "Num. Siblings"
label var houseOwn "Own Home"
label var MaxEdu_Uni "College"

label var Depression_score "Depression"

// Create the double interactions of schooltype and city:
capture drop xm*
gen xmReggioNone = (maternaType ==0 & City == 1)  if maternaType<.
gen xmReggioMuni = (maternaType ==1 & City == 1)  if maternaType<.
gen xmReggioStat = (maternaType ==2 & City == 1)  if maternaType<.
gen xmReggioReli = (maternaType ==3 & City == 1)  if maternaType<.
gen xmReggioPriv = (maternaType ==4 & City == 1)  if maternaType<.
gen xmParmaNone  = (maternaType ==0 & City == 2)  if maternaType<.
gen xmParmaMuni  = (maternaType ==1 & City == 2)  if maternaType<.
gen xmParmaStat  = (maternaType ==2 & City == 2)  if maternaType<.
gen xmParmaReli  = (maternaType ==3 & City == 2)  if maternaType<.
gen xmParmaPriv  = (maternaType ==4 & City == 2)  if maternaType<.
gen xmPadovaNone = (maternaType ==0 & City == 3)  if maternaType<.
gen xmPadovaMuni = (maternaType ==1 & City == 3)  if maternaType<.
gen xmPadovaStat = (maternaType ==2 & City == 3)  if maternaType<.
gen xmPadovaReli = (maternaType ==3 & City == 3)  if maternaType<.
gen xmPadovaPriv = (maternaType ==4 & City == 3)  if maternaType<.
label var xmReggioNone "Reggio None pres."
label var xmReggioMuni "Reggio Muni pres."
label var xmReggioStat "Reggio State pres."
label var xmReggioReli "Reggio Reli pres."
label var xmReggioPriv "Reggio Priv pres."
label var xmParmaNone "Parma None pres."
label var xmParmaMuni "Parma Muni pres."
label var xmParmaStat "Parma State pres."
label var xmParmaReli "Parma Reli pres."
label var xmParmaPriv "Parma Priv pres."
label var xmPadovaNone "Padova None pres."
label var xmPadovaMuni "Padova Muni pres."
label var xmPadovaStat "Padova State pres."
label var xmPadovaReli "Padova Reli pres."
label var xmPadovaPriv "Padova Priv pres."

capture drop xa*
gen xaReggioNone = (asiloType ==0 & City == 1)  if asiloType<.
gen xaReggioMuni = (asiloType ==1 & City == 1)  if asiloType<.
gen xaReggioReli = (asiloType ==3 & City == 1)  if asiloType<.
gen xaReggioPriv = (asiloType ==4 & City == 1)  if asiloType<.
gen xaParmaNone = (asiloType ==0 & City == 2)  if asiloType<.
gen xaParmaMuni = (asiloType ==1 & City == 2)  if asiloType<.
gen xaParmaReli = (asiloType ==3 & City == 2)  if asiloType<.
gen xaParmaPriv = (asiloType ==4 & City == 2)  if asiloType<.
gen xaPadovaNone = (asiloType ==0 & City == 3)  if asiloType<.
gen xaPadovaMuni = (asiloType ==1 & City == 3)  if asiloType<.
gen xaPadovaReli = (asiloType ==3 & City == 3)  if asiloType<.
gen xaPadovaPriv = (asiloType ==4 & City == 3)  if asiloType<.
label var xaReggioNone "Reggio None ITC"
label var xaReggioMuni "Reggio Muni ITC"
label var xaReggioReli "Reggio Reli ITC"
label var xaReggioPriv "Reggio Priv ITC"
label var xaParmaNone "Parma None ITC"
label var xaParmaMuni "Parma Muni ITC"
label var xaParmaReli "Parma Reli ITC"
label var xaParmaPriv "Parma Priv ITC"
label var xaPadovaNone "Padova None ITC"
label var xaPadovaMuni "Padova Muni ITC"
label var xaPadovaReli "Padova Reli ITC"
label var xaPadovaPriv "Padova Priv ITC"

/*drop xmReggioMuni xaReggioMuni // RCH
drop xm*Reli //Omitted category: religious
drop xa*Reli //Omitted category: religious */

*--------- REGRESSIONS ------*
global outregOption bracket dec(3) sortvar(ReggioAsilo xa* $Xleft) drop(o.* *internr_* *Month_int_*) //label

reg childSDQ_score ReggioAsilo xaReggioReli xaReggioPriv $Xright if (City==1 & Cohort==1 & momMaxEdu_miss==0 & cgReddito_miss==0), robust  
gen smallSample = e(sample)

* Replace missing with zeros and put missing variable
foreach parent in mom dad{
foreach categ in MaxEdu mStatus PA{
foreach var of varlist `parent'`categ'_*{
	replace `var'=0 if `parent'`categ'_miss==1
} 
}
}

foreach var in momBornProvince dadBornProvince cgRelig houseOwn lowbirthweight {
	gen `var'_miss = (`var'>=.)
	replace `var'=0 if `var'_miss==1
}


reg childSDQ_score ReggioAsilo xaReggioReli xaReggioPriv $Xright if (City==1 & Cohort==1), robust  
gen largeSample = e(sample)

reg childSDQ_score ReggioAsilo xaReggioReli xaReggioPriv if largeSample==1, robust  
outreg2 using test.out, replace $outregOption addtext(Controls, None)

reg childSDQ_score ReggioAsilo xaReggioReli xaReggioPriv internr_* if largeSample==1, robust  
outreg2 using test.out, append $outregOption addtext(Controls, int FE)

reg childSDQ_score ReggioAsilo xaReggioReli xaReggioPriv internr_* Male momMaxEdu_* dadMaxEdu_* internr_* CAPI Age Age_sq if largeSample==1, robust  
outreg2 using test.out, append $outregOption addtext(Controls, demog)

reg childSDQ_score ReggioAsilo xaReggioReli xaReggioPriv internr_* Male momMaxEdu_* dadMaxEdu_* internr_* CAPI Age Age_sq Month_int_* if largeSample==1, robust  
outreg2 using test.out, append $outregOption addtext(Controls, demog+month)

reg childSDQ_score ReggioAsilo xaReggioReli xaReggioPriv $Xright if largeSample==1, robust  
outreg2 using test.out, append $outregOption addtext(Controls, Yes)

foreach var of varlist $Xleft{
	reg childSDQ_score ReggioAsilo xaReggioReli xaReggioPriv `var' $Xright if largeSample==1, robust  
	outreg2 using test.out, append $outregOption addtext(Controls, Yes)
}

reg childSDQ_score ReggioAsilo xaReggioReli xaReggioPriv $Xright $Xleft if largeSample==1, robust  
outreg2 using test.out, append $outregOption addtext(Controls, all)

foreach var of varlist $Xleft{
	reg `var' ReggioAsilo xaReggioReli xaReggioPriv $Xright if largeSample==1, robust
	outreg2 using test.out, append $outregOption addtext(Controls, Yes)
}

reg childSDQ_score ReggioAsilo xaReggioReli xaReggioPriv $Xright birthpremature grand_nbrhood if largeSample==1, robust  
outreg2 using test.out, append $outregOption addtext(Controls, chosen)

log close
