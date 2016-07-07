clear all
set more off
capture log close

/*
Author: Pietro Biroli (pietro.biroli@econ.uzh.ch)

Purpose of the do file: Analyze the Reggio Children Evaluation Survey to understand impact on SDQ, Health, and immigration assimiltion (First round)

This Draft: 10 Dec 2015

Input: 	Reggio.dta  --> see dataClean_all.do
		
Output:	Plots and tables
*/

*** directory
// global dir "D:\Research\ReggioChildren"
 global dir "C:\Users\pbiroli\Dropbox\ReggioChildren"
// global dir "/mnt/ide0/share/klmReggio"

global datadir "$dir/SURVEY_DATA_COLLECTION/data"
global outdir "$dir/Analysis/pietro/Tables"
cd "$outdir"

use $datadir/Reggio.dta, clear

*--------------------------------------------------------*
* (item) global variables for controls
global outcomes 	childSDQ_score SDQ_score Depression_score HealthPerc childHealthPerc MigrTaste_cat 
global outLabel 	childSDQ_score "SDQ score (mom report)" SDQ_score "SDQ Score" Depression_score "Depression Score" HealthPerc "Good health" childHealthPerc "Good health" MigrTaste_cat "Bothered by immigration into city"
des $outcomes 

global outChild 	childSDQ_score childHealthPerc 
global outAdo 		$outcomes 
global outAdult 	Depression_score HealthPerc MigrTaste_cat 

global Controls CAPI Age Age_sq Male momHome06 famSize_4 famSize_5plus houseOwn /// famSize_2 famSize_3=reference category Cohort_* 
				dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni /// noDad -> omitted for collinearity
				momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni ///
				grand_nbrhood grand_city grand_far ///
				Month_int_*
				// Parma Padova //--> include every time when needed

global xmaterna 	xm*
global xasilo 		xa*
			   
// only for children and ado
global cgPA 		cgPA_Unempl cgPA_OLF cgPA_HouseWife dadPA_Unempl dadPA_OLF cgSES_teacher cgSES_professional cgSES_self hhSES_teacher hhSES_professional hhSES_self 
global cgmStatus 	cgmStatus_married cgmStatus_div cgmStatus_cohab lone_parent childrenSibTot  // noDad nonMom

// only for adults
global MaxEdu 		MaxEdu_middle MaxEdu_HS MaxEdu_Uni
global PA 			PA_Unempl PA_OLF PA_HouseWife SES_teacher SES_professional SES_self
global mStatus 		mStatus_married mStatus_div mStatus_cohab numSiblings 

// NOTE: omitted category -- PAPI, Reggio, Female, Famsize=3,


*-* OutReg Options:
// List different options for outreg -- global Options se tex fragment blankrows starlevels(10 5 1) sigsymb(*,**,***) starloc(1) summstat(N) // keep($Display)
// List of option for esttab
global Options 		compress nomtitles nodepvars wrap booktabs nonotes label  se(%4.3f) b(3) eqlabels(none) star(* 0.10 ** 0.05 *** 0.01) 
global outregOption bracket sortvar(ReggioMaterna ReggioAsilo treated)

*--------------------------------------------------------*
* (item) Create some variables 
* make interview date fixed effects
gen Month_int = mofd(Date_int)
dummieslab Month_int

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
label var xmReggioNone"Reggio None pres."
label var xmReggioMuni"Reggio Muni pres."
label var xmReggioStat"Reggio State pres."
label var xmReggioReli"Reggio Reli pres."
label var xmReggioPriv"Reggio Priv pres."
label var xmParmaNone"Parma None pres."
label var xmParmaMuni"Parma Muni pres."
label var xmParmaStat"Parma State pres."
label var xmParmaReli"Parma Reli pres."
label var xmParmaPriv"Parma Priv pres."
label var xmPadovaNone"Padova None pres."
label var xmPadovaMuni"Padova Muni pres."
label var xmPadovaStat"Padova State pres."
label var xmPadovaReli"Padova Reli pres."
label var xmPadovaPriv"Padova Priv pres."

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
label var xaReggioNone"Reggio None ITC"
label var xaReggioMuni"Reggio Muni ITC"
label var xaReggioReli"Reggio Reli ITC"
label var xaReggioPriv"Reggio Priv ITC"
label var xaParmaNone"Parma None ITC"
label var xaParmaMuni"Parma Muni ITC"
label var xaParmaReli"Parma Reli ITC"
label var xaParmaPriv"Parma Priv ITC"
label var xaPadovaNone"Padova None ITC"
label var xaPadovaMuni"Padova Muni ITC"
label var xaPadovaReli"Padova Reli ITC"
label var xaPadovaPriv"Padova Priv ITC"

drop xmReggioMuni xaReggioMuni // RCH
drop xm*Reli //Omitted category: religious
drop xa*Reli //Omitted category: religious

*--------- Instruments ------*
egen distMaternaMin = rowmin(distMaterna*1)
gen distMaternaAdd = distMaternaMunicipal1 - distMaternaMin
pwcorr distMaternaAdd distMaternaMunicipal1
label var distMaternaAdd "Additional distance from municipal preschool to closest one"

egen distAsiloMin = rowmin(distAsilo*1)
gen distAsiloAdd = distAsiloMunicipal1 - distAsiloMin
pwcorr distAsiloAdd distAsiloMunicipal1
label var distAsiloAdd "Additional distance from municipal infant-toddler center to closest one"

gen IV_distMat = distMaternaMunicipal1*Reggio
gen IV_distAdd =  distMaternaAdd*Reggio
gen IV_distAsi = distAsiloMunicipal1*Reggio
gen IV_score = score*Reggio
gen mofb = month(Birthday) //month of birth
tab mofb, gen(IV_m)
drop IV_m12 //reference month: december
forvalues i=1/11{
	replace IV_m`i' = IV_m`i'*Reggio
}


if 1==0{ // Tables and graphs of summary statistics for outcomes
*--------------------------------------------------------*
* (item) Some Summary Statistics

global options  main(mean %5.2f) aux(sd %5.2f) unstack /// nostar 
nonote nomtitle nonumber replace tex nogaps

estpost tabstat $outcomes ///
, by(Cohort) statistics(mean sd) columns(statistics)
esttab using outcomes.tex, $options coef($outLabel)

*--------------------------------------------------------*
* (item) Make the Graphs 
global graphOptions over(maternaType, label(angle(45))) over(City) asyvars  ytitle("Mean") 
global graphExport replace width(800) height(600)

*--------------------------------- Children ------------------------------------
foreach var of varlist $outChild{
		//local var childSDQ_score
		des `var'
		
		local lab: variable label `var' // save variable label in local `lab'
		local graph_title = "Children - " + "`lab'" //create the graph's title through concatenation
		
		preserve
		keep if(Cohort == 1)
		collapse (mean) mean_`var'= `var' (sd) sd_`var' = `var' (count) n=`var', by(maternaType City)
		replace sd_`var' = 0 if(sd_`var' == . )
		drop if (maternaType == 4 | maternaType >=.) // drop private or missing
		replace mean_`var' = . if n <=5 // replace to missing if too few obs
		replace n = . if n <=5 // replace to missing if too few obs
		
		generate hi = mean_`var' //mean_`var' + invttail(n,0.025)*(sd_`var' / sqrt(n))
		generate lo = mean_`var' - invttail(n,0.025)*(sd_`var' / sqrt(n))
		generate zero = 0 //for putting the numbers on the x-axis

		generate se = sd_`var' / sqrt(n)

		generate maternaCity = maternaType      if City == 1
		replace  maternaCity = maternaType + 6  if City == 2
		replace  maternaCity = maternaType + 12 if City == 3
		
		twoway (bar mean_`var' maternaCity if maternaType==0) ///
     	 	 (bar mean_`var' maternaCity if maternaType==1)   ///
      		 (bar mean_`var' maternaCity if maternaType==2)   ///
      	 	 (bar mean_`var' maternaCity if maternaType==3)   ///
       	 	 (bar mean_`var' maternaCity if maternaType==4)   ///
       	 	 (scatter zero maternaCity, ms(i) mlab(n) mlabpos(6) mlabcolor(black)) /// mean_`var' 
       	 	 (rcap hi lo maternaCity, lcolor(red)), ///
        	 legend(order(1 "Not Attended" 2 "Municipal" 3 "State" 4 "Religious")) /// 5 "Private"
         	 xlabel(2.05 "Reggio" 7.975 "Parma" 14.0 "Padova", noticks) ///
         	 xtitle("City and Materna Type") ytitle("Mean") title("`graph_title'")  ///
			 /// MAYBE HERE PUT THE SCALE ONLY IF mean_`var'<=1 & mean_`var'>=0
			 note("Source: RCH survey. Plot of means and thier standard errors. Number of obs. in each category at the bottom") ///
			 yscale(range(-0.2 1))  ylabel(#8) ///

		restore, preserve
	
		graph export `var'_Child.png, $graphExport //export the graph
		
		restore, not
}

*--------------------------------- Migrants ------------------------------------
foreach var of varlist $outChild{
		des `var'
		
		local lab: variable label `var' // save variable label in local `lab'
		local graph_title = "Migrant Children - " + "`lab'" //create the graph's title through concatenation
		
		preserve
		keep if(Cohort == 2)
		collapse (mean) mean_`var'= `var' (sd) sd_`var' = `var' (count) n=`var', by(maternaType City)
		replace sd_`var' = 0 if(sd_`var' == . )
		drop if (maternaType == 4 | maternaType >=.) // drop private or missing
		replace mean_`var' = . if n <=5 // replace to missing if too few obs
		replace n = . if n <=5 // replace to missing if too few obs
		
		generate hi = mean_`var' //mean_`var' + invttail(n,0.025)*(sd_`var' / sqrt(n))
		generate lo = mean_`var' - invttail(n,0.025)*(sd_`var' / sqrt(n))
		generate zero = 0 //for putting the numbers on the x-axis

		generate se = sd_`var' / sqrt(n)

		generate maternaCity = maternaType      if City == 1
		replace  maternaCity = maternaType + 6  if City == 2
		replace  maternaCity = maternaType + 12 if City == 3
		
		twoway (bar mean_`var' maternaCity if maternaType==0) ///
     	 	 (bar mean_`var' maternaCity if maternaType==1)   ///
      		 (bar mean_`var' maternaCity if maternaType==2)   ///
      	 	 (bar mean_`var' maternaCity if maternaType==3)   ///
       	 	 (bar mean_`var' maternaCity if maternaType==4)   ///
       	 	 (scatter zero maternaCity, ms(i) mlab(n) mlabpos(6) mlabcolor(black)) /// mean_`var' 
       	 	 (rcap hi lo maternaCity, lcolor(red)), ///
        	 legend(order(1 "Not Attended" 2 "Municipal" 3 "State" 4 "Religious")) /// 5 "Private"
         	 xlabel(2.05 "Reggio" 7.975 "Parma" 14.0 "Padova", noticks) ///
         	 xtitle("City and Materna Type") ytitle("Mean") title("`graph_title'")  ///
			 /// MAYBE HERE PUT THE SCALE ONLY IF mean_`var'<=1 & mean_`var'>=0
			 note("Source: RCH survey. Plot of means and thier standard errors. Number of obs. in each category at the bottom") ///
			 yscale(range(-0.2 1))  ylabel(#8)

		restore, preserve
	
		graph export `var'_Migrant.png, $graphExport //export the graph
		
		restore, not
}

*------------------------------- Adolescents -----------------------------------
foreach var of varlist $outcomes{
		des `var'
		local lab: variable label `var' // save variable label in local `lab'
		local graph_title = "Adolescents - " + "`lab'" //create the graph's title through concatenation
	
		preserve
		keep if(Cohort == 3)
		collapse (mean) mean_`var'= `var' (sd) sd_`var' = `var' (count) n=`var', by(maternaType City)
		replace sd_`var' = 0 if(sd_`var' == . )
		drop if (maternaType == 4 | maternaType >=.) // drop private or missing
		replace mean_`var' = . if n <=5 // replace to missing if too few obs
		replace n = . if n <=5 // replace to missing if too few obs
		
		generate hi = mean_`var' //mean_`var' + invttail(n,0.025)*(sd_`var' / sqrt(n))
		generate lo = mean_`var' - invttail(n,0.025)*(sd_`var' / sqrt(n))
		generate zero = 0 //for putting the numbers on the x-axis

		generate se = sd_`var' / sqrt(n)

		generate maternaCity = maternaType      if City == 1
		replace  maternaCity = maternaType + 6  if City == 2
		replace  maternaCity = maternaType + 12 if City == 3
		
		twoway (bar mean_`var' maternaCity if maternaType==0) ///
     	 	 (bar mean_`var' maternaCity if maternaType==1)   ///
      		 (bar mean_`var' maternaCity if maternaType==2)   ///
      	 	 (bar mean_`var' maternaCity if maternaType==3)   ///
       	 	 (bar mean_`var' maternaCity if maternaType==4)   ///
       	 	 (scatter zero maternaCity, ms(i) mlab(n) mlabpos(6) mlabcolor(black)) /// mean_`var' 
       	 	 (rcap hi lo maternaCity, lcolor(red)), ///
        	 legend(order(1 "Not Attended" 2 "Municipal" 3 "State" 4 "Religious")) /// 5 "Private"
         	 xlabel(2.05 "Reggio" 7.975 "Parma" 14.0 "Padova", noticks) ///
         	 xtitle("City and Materna Type") ytitle("Mean") title("`graph_title'")  ///
			 /// MAYBE HERE PUT THE SCALE ONLY IF mean_`var'<=1 & mean_`var'>=0
			 note("Source: RCH survey. Plot of means and thier standard errors. Number of obs. in each category at the bottom") ///
			 yscale(range(-0.2 1))  ylabel(#8)
         	 
		restore, preserve
	
		graph export `var'_Ado.png, $graphExport //export the graph
		
		restore, not
}

*--------------------------------- Adult 30 ------------------------------------
foreach var of varlist $outAdult{
		des `var'
		
		local lab: variable label `var' // save variable label in local `lab'
		local graph_title = "Adult 30 - " + "`lab'" //create the graph's title through concatenation
	
		preserve
		keep if(Cohort == 4)
		collapse (mean) mean_`var'= `var' (sd) sd_`var' = `var' (count) n=`var', by(maternaType City)
		replace sd_`var' = 0 if(sd_`var' == . )
		drop if (maternaType == 4 | maternaType >=.) // drop private or missing
		replace mean_`var' = . if n <=5 // replace to missing if too few obs
		replace n = . if n <=5 // replace to missing if too few obs
		
		generate hi = mean_`var' //mean_`var' + invttail(n,0.025)*(sd_`var' / sqrt(n))
		generate lo = mean_`var' - invttail(n,0.025)*(sd_`var' / sqrt(n))
		generate zero = 0 //for putting the numbers on the x-axis

		generate se = sd_`var' / sqrt(n)

		generate maternaCity = maternaType      if City == 1
		replace  maternaCity = maternaType + 6  if City == 2
		replace  maternaCity = maternaType + 12 if City == 3
		
		twoway (bar mean_`var' maternaCity if maternaType==0) ///
     	 	 (bar mean_`var' maternaCity if maternaType==1)   ///
      		 (bar mean_`var' maternaCity if maternaType==2)   ///
      	 	 (bar mean_`var' maternaCity if maternaType==3)   ///
       	 	 (bar mean_`var' maternaCity if maternaType==4)   ///
       	 	 (scatter zero maternaCity, ms(i) mlab(n) mlabpos(6) mlabcolor(black)) /// mean_`var' 
       	 	 (rcap hi lo maternaCity, lcolor(red)), ///
        	 legend(order(1 "Not Attended" 2 "Municipal" 3 "State" 4 "Religious")) /// 5 "Private"
         	 xlabel(2.05 "Reggio" 7.975 "Parma" 14.0 "Padova", noticks) ///
         	 xtitle("City and Materna Type") ytitle("Mean") title("`graph_title'")  ///
			 /// MAYBE HERE PUT THE SCALE ONLY IF mean_`var'<=1 & mean_`var'>=0
			 note("Source: RCH survey. Plot of means and thier standard errors. Number of obs. in each category at the bottom") ///
			 yscale(range(-0.2 1))  ylabel(#8)
		
		restore, preserve
	
		graph export `var'_Adult30.png, $graphExport //export the graph
		
		restore, not
}

*--------------------------------- Adult 40 ------------------------------------
foreach var of varlist $outAdult{
		des `var'

		local lab: variable label `var' // save variable label in local `lab'
		local graph_title = "Adult 40 - " + "`lab'" //create the graph's title through concatenation
	
		preserve
		keep if(Cohort == 5)
		collapse (mean) mean_`var'= `var' (sd) sd_`var' = `var' (count) n=`var', by(maternaType City)
		replace sd_`var' = 0 if(sd_`var' == . )
		drop if (maternaType == 4 | maternaType >=.) // drop private or missing
		replace mean_`var' = . if n <=5 // replace to missing if too few obs
		replace n = . if n <=5 // replace to missing if too few obs
		
		generate hi = mean_`var' //mean_`var' + invttail(n,0.025)*(sd_`var' / sqrt(n))
		generate lo = mean_`var' - invttail(n,0.025)*(sd_`var' / sqrt(n))
		generate zero = 0 //for putting the numbers on the x-axis

		generate se = sd_`var' / sqrt(n)

		generate maternaCity = maternaType      if City == 1
		replace  maternaCity = maternaType + 6  if City == 2
		replace  maternaCity = maternaType + 12 if City == 3
		
		twoway (bar mean_`var' maternaCity if maternaType==0) ///
     	 	 (bar mean_`var' maternaCity if maternaType==1)   ///
      		 (bar mean_`var' maternaCity if maternaType==2)   ///
      	 	 (bar mean_`var' maternaCity if maternaType==3)   ///
       	 	 (bar mean_`var' maternaCity if maternaType==4)   ///
       	 	 (scatter zero maternaCity, ms(i) mlab(n) mlabpos(6) mlabcolor(black)) /// mean_`var' 
       	 	 (rcap hi lo maternaCity, lcolor(red)), ///
        	 legend(order(1 "Not Attended" 2 "Municipal" 3 "State" 4 "Religious")) /// 5 "Private"
         	 xlabel(2.05 "Reggio" 7.975 "Parma" 14.0 "Padova", noticks) ///
         	 xtitle("City and Materna Type") ytitle("Mean") title("`graph_title'")  ///
			 /// MAYBE HERE PUT THE SCALE ONLY IF mean_`var'<=1 & mean_`var'>=0
			 note("Source: RCH survey. Plot of means and thier standard errors. Number of obs. in each category at the bottom") ///
			 yscale(range(-0.2 1))  ylabel(#8)
		restore, preserve
	
		graph export `var'_Adult40.png, $graphExport //export the graph
		
		restore, not
}

*--------------------------------- Adult 50 ------------------------------------
foreach var of varlist $outAdult{
		des `var'

		local lab: variable label `var' // save variable label in local `lab'
		local graph_title = "Adult 50 - " + "`lab'" //create the graph's title through concatenation
	
		preserve
		keep if(Cohort == 6)
		collapse (mean) mean_`var'= `var' (sd) sd_`var' = `var' (count) n=`var', by(maternaType City)
		replace sd_`var' = 0 if(sd_`var' == . )
		drop if (maternaType == 4 | maternaType >=.) // drop private or missing
		replace mean_`var' = . if n <=5 // replace to missing if too few obs
		replace n = . if n <=5 // replace to missing if too few obs
		
		generate hi = mean_`var' //mean_`var' + invttail(n,0.025)*(sd_`var' / sqrt(n))
		generate lo = mean_`var' - invttail(n,0.025)*(sd_`var' / sqrt(n))
		generate zero = 0 //for putting the numbers on the x-axis

		generate se = sd_`var' / sqrt(n)

		generate maternaCity = maternaType      if City == 1
		replace  maternaCity = maternaType + 6  if City == 2
		replace  maternaCity = maternaType + 12 if City == 3
		
		twoway (bar mean_`var' maternaCity if maternaType==0) ///
     	 	 (bar mean_`var' maternaCity if maternaType==1)   ///
      		 (bar mean_`var' maternaCity if maternaType==2)   ///
      	 	 (bar mean_`var' maternaCity if maternaType==3)   ///
       	 	 (bar mean_`var' maternaCity if maternaType==4)   ///
       	 	 (scatter zero maternaCity, ms(i) mlab(n) mlabpos(6) mlabcolor(black)) /// mean_`var' 
       	 	 (rcap hi lo maternaCity, lcolor(red)), ///
        	 legend(order(1 "Not Attended" 2 "Municipal" 3 "State" 4 "Religious")) /// 5 "Private"
         	 xlabel(2.05 "Reggio" 7.975 "Parma" 14.0 "Padova", noticks) ///
         	 xtitle("City and Materna Type") ytitle("Mean") title("`graph_title'")  ///
			 /// MAYBE HERE PUT THE SCALE ONLY IF mean_`var'<=1 & mean_`var'>=0
			 note("Source: RCH survey. Plot of means and thier standard errors. Number of obs. in each category at the bottom") ///
			 yscale(range(-0.2 1))  ylabel(#8)

		restore, preserve
	
		graph export `var'_Adult50.png, $graphExport //export the graph
		
		restore, not
}

*-------------------------------- All Adults -----------------------------------
foreach var of varlist $outAdult{
		des `var'
		local lab: variable label `var' // save variable label in local `lab'
		local graph_title = "All Adults - " + "`lab'" //create the graph's title through concatenation
	
		preserve
		keep if(Cohort > 3)
		collapse (mean) mean_`var'= `var' (sd) sd_`var' = `var' (count) n=`var', by(maternaType City)
		replace sd_`var' = 0 if(sd_`var' == . )
		drop if (maternaType == 4 | maternaType >=.) // drop private or missing
		replace mean_`var' = . if n <=5 // replace to missing if too few obs
		replace n = . if n <=5 // replace to missing if too few obs
		
		generate hi = mean_`var' //mean_`var' + invttail(n,0.025)*(sd_`var' / sqrt(n))
		generate lo = mean_`var' - invttail(n,0.025)*(sd_`var' / sqrt(n))
		generate zero = 0 //for putting the numbers on the x-axis

		generate se = sd_`var' / sqrt(n)

		generate maternaCity = maternaType      if City == 1
		replace  maternaCity = maternaType + 6  if City == 2
		replace  maternaCity = maternaType + 12 if City == 3
		
		twoway (bar mean_`var' maternaCity if maternaType==0) ///
     	 	 (bar mean_`var' maternaCity if maternaType==1)   ///
      		 (bar mean_`var' maternaCity if maternaType==2)   ///
      	 	 (bar mean_`var' maternaCity if maternaType==3)   ///
       	 	 (bar mean_`var' maternaCity if maternaType==4)   ///
       	 	 (scatter zero maternaCity, ms(i) mlab(n) mlabpos(6) mlabcolor(black)) /// mean_`var' 
       	 	 (rcap hi lo maternaCity, lcolor(red)), ///
        	 legend(order(1 "Not Attended" 2 "Municipal" 3 "State" 4 "Religious")) /// 5 "Private"
         	 xlabel(2.05 "Reggio" 7.975 "Parma" 14.0 "Padova", noticks) ///
         	 xtitle("City and Materna Type") ytitle("Mean") title("`graph_title'")  ///
			 /// MAYBE HERE PUT THE SCALE ONLY IF mean_`var'<=1 & mean_`var'>=0
			 note("Source: RCH survey. Plot of means and thier standard errors. Number of obs. in each category at the bottom") ///
			 yscale(range(-0.2 1))  ylabel(#8)

		
		restore, preserve
	
		graph export `var'_AllAdults.png, $graphExport //export the graph
		
		restore, not
}

}
*--------------------------------------------------------*
if 1==1{ //  (item) Selection and controls
/* Run some analysis to understand what is the selection mechanisms into the different types of school
and to see which one are the appropriate variables to control for (see also Pischke Schwandt 2015)
*/
*-* (item) Summary statistics
//do $dir/Analysis/descrittivePietro/sumStat.do
global childX1   	Male momAgeBirth momBornProvince dadAgeBirth dadBornProvince CAPI //noMom noDad 
global childGrand	grandAlive grand_nbrhood /// daily_grandCare 
global childInterg	famSize olderSibling cgAsilo cgMaterna /// youngSibling 
					/// momHome06 
					
					childRelig cgRelig cgFaith ///
					birthweight lowbirthweight birthpremature /// cgYrMarry cgIQ_score 

global childSES		momMaxEdu_* dadMaxEdu_* /// momPA_Empl momPA_OLF momPA_HouseWife dadPA_Empl dadPA_Unempl 
					mommStatus_married dadmStatus_married ///
					houseOwn cgIncome25000 ///
					cgSES_worker cgSES_teacher cgSES_professional cgSES_self ///
					hhSES_worker hhSES_teacher hhSES_professional hhSES_self ///

global childPRE $childX1 childGrand childSES

global adultPRE		Male momBornProvince momMaxEdu_* momRelig ///
					dadBornProvince dadMaxEdu_* dadRelig ///
					numSiblings grandAlive grand_nbrhood daily_grandCare CAPI


label var noMom "No mom"
label var momAgeBirth "Mom age at birth"
label var momBornProvince "Mom born in province"
label var mommStatus_married "Mom married"
label var momMaxEdu_Uni "Mom university"
label var momPA_Unempl "Mom unempl"
label var momPA_HouseWife "Mom housewife"
label var noDad "No dad"
label var dadAgeBirth "Dad age at birth"
label var dadBornProvince "Dad born in province"
label var dadmStatus_married "Dad married"
label var dadMaxEdu_Uni "Dad university"
label var dadPA_Unempl "Dad unempl"
label var famSize "Family size"
label var speakItal "Speak italian"
label var cgAsilo "Caregiver attended asilo"
label var cgMaterna "Caregiver attended preschool"
label var cgYrMarry "Year wedding"
label var grandAlive "Grandp alive"
label var grand_nbrhood "Grandp in neighbourhood"
label var daily_grandCare "Daily grandp care"
label var cgIQ_score "IQ caregiver"
label var birthweight "Birthweight"
label var birthpremature "Premature birth"
label var CAPI "CAPI"
label var houseOwn "Own house"

label var dadRelig "Dad is religious"
label var momRelig "Mom is religious"
label var numSiblings "N. siblings"

/*label var childRelig 
label var cgRelig 
label var cgFaith 
*/

replace momBornProvince=0 if Cohort==2 //not relevant for immigrants, otherwise it won't run
replace dadBornProvince=0 if Cohort==2 //not relevant for immigrants, otherwise it won't run


}
*--------------------------------------------------------*
if 1==1{ //  (item) Some Regression
cd $outdir

*-* Run some regressions just to find out what sample to keep:
capture drop sample*
reg ReggioMaterna Parma Padova $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus $xmaterna if Cohort>3, robust 
gen sampleAdult = e(sample)
reg ReggioMaterna Parma Padova $Controls $cgPA $cgmStatus $xmaterna if Cohort==3, robust
gen sampleAdo = e(sample)
reg ReggioMaterna Parma Padova $Controls $cgPA $cgmStatus $xmaterna if Cohort==1, robust 
gen sampleChild = e(sample)
reg ReggioMaterna Parma Padova $Controls $cgPA $cgmStatus $xmaterna if Cohort==2, robust 
gen sampleMigr = e(sample)

//==================================================================================================================================
*---* Adults, simple OLS
local i=0
foreach var of varlist $outAdult{
//local var Depression_score
//local var MigrTaste_cat
local i=`i'+1
local eq "eqAdult_`var'"
local lablvar: variable label `var'
di "`lablvar'"

eststo `eq'0: reg `var' ReggioMaterna ReggioAsilo treated Parma Padova Cohort_Adult* CAPI if sampleAdult==1 & Cohort>3, robust // [=] at some point should use logit/probit
outreg2 using ItaAdult_`i'.out, replace ctitle("DROP") title("`lablvar'") $outregOption 

eststo `eq'1a: reg `var' ReggioMaterna Parma Padova Cohort_Adult* CAPI if sampleAdult==1 & Cohort>3, robust // [=] at some point should use logit/probit
outreg2 using ItaAdult_`i'.out, append ctitle("`var' Baseline") title("`lablvar'")  $outregOption 

eststo `eq'1b: reg `var' ReggioAsilo Parma Padova Cohort_Adult* CAPI if sampleAdult==1 & Cohort>3, robust // [=] at some point should use logit/probit
outreg2 using ItaAdult_`i'.out, append ctitle("`var' Baseline") title("`lablvar'") $outregOption 

eststo `eq'1c: reg `var' treated Parma Padova Cohort_Adult* CAPI if sampleAdult==1 & Cohort>3, robust // [=] at some point should use logit/probit
outreg2 using ItaAdult_`i'.out, append ctitle("`var' Baseline") title("`lablvar'") $outregOption 

eststo `eq'3a: reg `var' ReggioMaterna Parma Padova Cohort_Adult* $Controls  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
outreg2 using ItaAdult_`i'.out, append ctitle("with Controls") $outregOption 

eststo `eq'3b: reg `var' ReggioAsilo Parma Padova Cohort_Adult* $Controls  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
outreg2 using ItaAdult_`i'.out, append ctitle("with Controls") $outregOption 

eststo `eq'3c: reg `var' treated Parma Padova Cohort_Adult* $Controls  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
outreg2 using ItaAdult_`i'.out, append ctitle("with Controls") $outregOption 

eststo `eq'4a: reg `var' ReggioMaterna  Parma Padova Cohort_Adult* $Controls $MaxEdu $PA $mStatus i.IncomeCat_manual  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
outreg2 using ItaAdult_`i'.out, append ctitle("with income") $outregOption 

eststo `eq'4b: reg `var' ReggioAsilo Parma Padova Cohort_Adult* $Controls $MaxEdu $PA $mStatus i.IncomeCat_manual  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
outreg2 using ItaAdult_`i'.out, append ctitle("with income") $outregOption 

eststo `eq'4c: reg `var' treated Parma Padova Cohort_Adult* $Controls $MaxEdu $PA $mStatus i.IncomeCat_manual  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
outreg2 using ItaAdult_`i'.out, append ctitle("with income") $outregOption 

eststo `eq'5a: reg `var' ReggioMaterna Parma Padova Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus $xmaterna  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using ItaAdult_`i'.out, append ctitle("with school") $outregOption 

eststo `eq'5b: reg `var' ReggioAsilo Parma Padova Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus $xasilo  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using ItaAdult_`i'.out, append ctitle("with school") $outregOption 

eststo `eq'5c: reg `var' treated Parma Padova Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus $xmaterna $xasilo  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using ItaAdult_`i'.out, append ctitle("with school") $outregOption 

eststo `eq'6a: reg `var' ReggioMaterna       Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus if sampleAdult==1 & Cohort>3 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using ItaAdult_`i'.out, append ctitle("Reggio Only") $outregOption 

eststo `eq'6b: reg `var' ReggioAsilo         Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus if sampleAdult==1 & Cohort>3 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using ItaAdult_`i'.out, append ctitle("Reggio Only") $outregOption 

eststo `eq'6c: reg `var' treated               Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus if sampleAdult==1 & Cohort>3 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using ItaAdult_`i'.out, append ctitle("Reggio Only") $outregOption 

eststo `eq'7a: reg `var' ReggioMaterna  Parma Padova Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus if sampleAdult==1 & Cohort>3 & materna_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using ItaAdult_`i'.out, append ctitle("Mun. only") $outregOption 

eststo `eq'7b: reg `var' ReggioAsilo Parma Padova Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus if sampleAdult==1 & Cohort>3 & asilo_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using ItaAdult_`i'.out, append ctitle("Mun. only") $outregOption 

eststo `eq'7c: reg `var' treated Parma Padova Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus if sampleAdult==1 & Cohort>3 & (materna_Municipal==1 | asilo_Municipal==1), robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using ItaAdult_`i'.out, append ctitle("Mun. only") $outregOption 

//LATEX OUTPUT: keep only the following
esttab `eq'4a `eq'4b `eq'5a `eq'5b `eq'6a `eq'6b using ItaAdult-`i'.tex, replace $Options ///  eq2 eq7a eq7b 
stats(controls income school reggio muni N r2 , fmt(0 0 0 0 0 0 0 3) ///
labels(`"Controls"' `"SES"' `"School types"' `"Reggio Only"' `"Mun. Only"' `"Observations"' `"\(R^{2}\)"' ) ) ///
keep($aduDisp) ///
mgroups("`lablvar'"	, pattern(1 0 0 0 0 0 0)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
}

*---* Adults: Instrumented regression
local i=0
foreach var of varlist $outAdult{
//local var MigrTaste_cat
local i=`i'+1
local eq "IVAdult_`var'"
local lablvar: variable label `var'
di "`lablvar'"

eststo `eq'0: ivregress 2sls `var' (ReggioMaterna ReggioAsilo treated =  IV_distMat IV_distAsi IV_score IV_m*) distCenter Parma Padova Cohort_Adult* CAPI if sampleAdult==1 & Cohort>3, robust // [=] at some point should use logit/probit
outreg2 using IVAdult_`i'.out, replace ctitle("DROP") title("`lablvar'")  $outregOption 

eststo `eq'1a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova Cohort_Adult* CAPI if sampleAdult==1 & Cohort>3, robust // [=] at some point should use logit/probit
outreg2 using IVAdult_`i'.out, append ctitle("`var' Baseline") title("`lablvar'")  $outregOption 

eststo `eq'1b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova Cohort_Adult* CAPI if sampleAdult==1 & Cohort>3, robust // [=] at some point should use logit/probit
outreg2 using IVAdult_`i'.out, append ctitle("`var' Baseline") title("`lablvar'") $outregOption 

eststo `eq'1c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova Cohort_Adult* CAPI if sampleAdult==1 & Cohort>3, robust // [=] at some point should use logit/probit
outreg2 using IVAdult_`i'.out, append ctitle("`var' Baseline") title("`lablvar'") $outregOption 

eststo `eq'3a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova Cohort_Adult* $Controls  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle("with Controls") $outregOption 

eststo `eq'3b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova Cohort_Adult* $Controls  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle("with Controls") $outregOption 

eststo `eq'3c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova Cohort_Adult* $Controls  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle("with Controls") $outregOption 


eststo `eq'4a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter  Parma Padova Cohort_Adult* $Controls $MaxEdu $PA $mStatus i.IncomeCat_manual  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle("with income") $outregOption

eststo `eq'4b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova Cohort_Adult* $Controls $MaxEdu $PA $mStatus i.IncomeCat_manual  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle("with income") $outregOption

eststo `eq'4c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova Cohort_Adult* $Controls $MaxEdu $PA $mStatus i.IncomeCat_manual  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle("with income") $outregOption

eststo `eq'5a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus $xmaterna  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle("with school") $outregOption

eststo `eq'5b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus $xasilo  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle("with school") $outregOption

eststo `eq'5c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus $xmaterna $xasilo  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle("with school") $outregOption

eststo `eq'6a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter       Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus if sampleAdult==1 & Cohort>3 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle("Reggio Only") $outregOption

eststo `eq'6b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter         Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus if sampleAdult==1 & Cohort>3 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle("Reggio Only") $outregOption

eststo `eq'6c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter               Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus if sampleAdult==1 & Cohort>3 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle("Reggio Only") $outregOption

eststo `eq'7a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter  Parma Padova Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus if sampleAdult==1 & Cohort>3 & materna_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle("Mun. only") $outregOption

eststo `eq'7b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus if sampleAdult==1 & Cohort>3 & asilo_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle("Mun. only") $outregOption

eststo `eq'7c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus if sampleAdult==1 & Cohort>3 & (materna_Municipal==1 | asilo_Municipal==1), robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle("Mun. only") $outregOption

esttab `eq'4a `eq'4b `eq'5a `eq'5b `eq'6a `eq'6b using IVAdult-`i'.tex, replace $Options ///  eq2 
stats(controls income school reggio muni N r2 , fmt(0 0 0 0 0 0 0 3) ///
labels(`"Controls"' `"SES"' `"School types"' `"Reggio Only"' `"Mun. Only"' `"Observations"' `"\(R^{2}\)"' ) ) ///
keep($aduDisp) ///
mgroups("`lablvar'"	, pattern(1 0 0 0 0 0 0)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
}



*---* Adults: Instrumented regression, FIRST STAGE
local i=0
foreach var of varlist $outAdult{
//local var MigrTaste_cat
local i=`i'+1
local eq "IVAdult_`var'"
local lablvar: variable label `var'
di "`lablvar'"

eststo `eq'4a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter  Parma Padova Cohort_Adult* $Controls $MaxEdu $PA $mStatus i.IncomeCat_manual  if sampleAdult==1 & Cohort>3, robust first
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle("with income") $outregOption

eststo `eq'4b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova Cohort_Adult* $Controls $MaxEdu $PA $mStatus i.IncomeCat_manual  if sampleAdult==1 & Cohort>3, robust first
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle("with income") $outregOption

eststo `eq'5a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus $xmaterna  if sampleAdult==1 & Cohort>3, robust first
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle("with school") $outregOption

eststo `eq'5b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus $xasilo  if sampleAdult==1 & Cohort>3, robust first
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle("with school") $outregOption

eststo `eq'6a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter       Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus if sampleAdult==1 & Cohort>3 & Reggio==1, robust first
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle("Reggio Only") $outregOption

eststo `eq'6b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter         Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus if sampleAdult==1 & Cohort>3 & Reggio==1, robust first
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle("Reggio Only") $outregOption

esttab `eq'4a `eq'4b `eq'5a `eq'5b `eq'6a `eq'6b using IVAdult-`i'_First.tex, replace $Options ///  eq2 
stats(controls income school reggio muni N r2 , fmt(0 0 0 0 0 0 0 3) ///
labels(`"Controls"' `"SES"' `"School types"' `"Reggio Only"' `"Mun. Only"' `"Observations"' `"\(R^{2}\)"' ) ) ///
keep($aduDisp) ///
mgroups("`lablvar'"	, pattern(1 0 0 0 0 0 0)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
}


//==================================================================================================================================

eststo clear
*---* Adolescents, simple OLS
local i=0
foreach var of varlist $outAdo{
//local var MigrTaste_cat
local i=`i'+1
local eq "eqAdo_`var'"
local lablvar: variable label `var'
di "`lablvar'"

eststo `eq'0: reg `var' ReggioMaterna ReggioAsilo treated Parma Padova CAPI if sampleAdo==1 & Cohort==3, robust // [=] at some point should use logit/probit
outreg2 using ItaAdo_`i'.out, replace ctitle("DROP") title("`lablvar'") $outregOption

eststo `eq'1a: reg `var' ReggioMaterna Parma Padova CAPI if sampleAdo==1 & Cohort==3, robust // [=] at some point should use logit/probit
outreg2 using ItaAdo_`i'.out, append ctitle("`var' Baseline") $outregOption

eststo `eq'1b: reg `var' ReggioAsilo Parma Padova CAPI if sampleAdo==1 & Cohort==3, robust // [=] at some point should use logit/probit
outreg2 using ItaAdo_`i'.out, append ctitle("`var' Baseline") $outregOption

eststo `eq'1c: reg `var' treated Parma Padova CAPI if sampleAdo==1 & Cohort==3, robust // [=] at some point should use logit/probit
outreg2 using ItaAdo_`i'.out, append ctitle("`var' Baseline") $outregOption

eststo `eq'3a: reg `var' ReggioMaterna Parma Padova $Controls $cgPA $cgmStatus $cgPA $cgmStatus  if sampleAdo==1 & Cohort==3, robust 
	estadd local controls "Yes", replace
outreg2 using ItaAdo_`i'.out, append ctitle("with Controls") $outregOption

eststo `eq'3b: reg `var' ReggioAsilo Parma Padova $Controls $cgPA $cgmStatus  if sampleAdo==1 & Cohort==3, robust 
	estadd local controls "Yes", replace
outreg2 using ItaAdo_`i'.out, append ctitle("with Controls") $outregOption

eststo `eq'3c: reg `var' treated Parma Padova $Controls $cgPA $cgmStatus  if sampleAdo==1 & Cohort==3, robust 
	estadd local controls "Yes", replace
outreg2 using ItaAdo_`i'.out, append ctitle("with Controls") $outregOption


eststo `eq'4a: reg `var' ReggioMaterna  Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using ItaAdo_`i'.out, append ctitle("with mom") $outregOption

eststo `eq'4b: reg `var' ReggioAsilo Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using ItaAdo_`i'.out, append ctitle("with mom") $outregOption

eststo `eq'4c: reg `var' treated Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using ItaAdo_`i'.out, append ctitle("with mom") $outregOption

eststo `eq'5a: reg `var' ReggioMaterna Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xmaterna  if sampleAdo==1 & Cohort==3, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using ItaAdo_`i'.out, append ctitle("with school") $outregOption

eststo `eq'5b: reg `var' ReggioAsilo Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xasilo  if sampleAdo==1 & Cohort==3, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using ItaAdo_`i'.out, append ctitle("with school") $outregOption

eststo `eq'5c: reg `var' treated Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xmaterna $xasilo  if sampleAdo==1 & Cohort==3, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using ItaAdo_`i'.out, append ctitle("with school") $outregOption

eststo `eq'6a: reg `var' ReggioMaterna  $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using ItaAdo_`i'.out, append ctitle("Reggio Only") $outregOption

eststo `eq'6b: reg `var' ReggioAsilo    $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using ItaAdo_`i'.out, append ctitle("Reggio Only") $outregOption

eststo `eq'6c: reg `var' treated     $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using ItaAdo_`i'.out, append ctitle("Reggio Only") $outregOption

eststo `eq'7a: reg `var' ReggioMaterna  Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3 & materna_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using ItaAdo_`i'.out, append ctitle("Mun. only") $outregOption

eststo `eq'7b: reg `var' ReggioAsilo Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3 & asilo_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using ItaAdo_`i'.out, append ctitle("Mun. only") $outregOption

eststo `eq'7c: reg `var' treated Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3 & (materna_Municipal==1 | asilo_Municipal==1), robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using ItaAdo_`i'.out, append ctitle("Mun. only") $outregOption

esttab `eq'4a `eq'4b `eq'5a `eq'5b `eq'6a `eq'6b using ItaAdo-`i'.tex, replace $Options ///  `eq'2 
stats(controls mom school reggio muni N r2 , fmt(0 0 0 0 0 0 0 3) ///
labels(`"Controls"' `"Mom beliefs"' `"School types"' `"Reggio Only"' `"Mun. Only"' `"Observations"' `"\(R^{2}\)"' ) ) ///
keep($Disp) ///
mgroups("`lablvar'"	, pattern(1 0 0 0 0 0 0)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
}

*---* Adolescents: Instrumented regression
local i=0
foreach var of varlist $outAdo{
//local var MigrTaste_cat
local i=`i'+1
local eq "IVAdo_`var'"
local lablvar: variable label `var'
di "`lablvar'"

eststo `eq'0: ivregress 2sls `var' (ReggioMaterna ReggioAsilo treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter distCenter Parma Padova CAPI if sampleAdo==1 & Cohort==3, robust // [=] at some point should use logit/probit
outreg2 using IVAdo_`i'.out, replace ctitle("DROP") $outregOption

eststo `eq'1a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova CAPI if sampleAdo==1 & Cohort==3, robust // [=] at some point should use logit/probit
outreg2 using IVAdo_`i'.out, replace ctitle("`var' Baseline") $outregOption

eststo `eq'1b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova CAPI if sampleAdo==1 & Cohort==3, robust // [=] at some point should use logit/probit
outreg2 using IVAdo_`i'.out, append ctitle("`var' Baseline") $outregOption

eststo `eq'1c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova CAPI if sampleAdo==1 & Cohort==3, robust // [=] at some point should use logit/probit
outreg2 using IVAdo_`i'.out, append ctitle("`var' Baseline") $outregOption

eststo `eq'3a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus  if sampleAdo==1 & Cohort==3, robust 
	estadd local controls "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle("with Controls") $outregOption

eststo `eq'3b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus  if sampleAdo==1 & Cohort==3, robust 
	estadd local controls "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle("with Controls") $outregOption

eststo `eq'3c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus  if sampleAdo==1 & Cohort==3, robust 
	estadd local controls "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle("with Controls") $outregOption

eststo `eq'4a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter  Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle("with mom") $outregOption

eststo `eq'4b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle("with mom") $outregOption

eststo `eq'4c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle("with mom") $outregOption

eststo `eq'5a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xmaterna  if sampleAdo==1 & Cohort==3, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle("with school") $outregOption

eststo `eq'5b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xasilo  if sampleAdo==1 & Cohort==3, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle("with school") $outregOption

eststo `eq'5c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xmaterna $xasilo  if sampleAdo==1 & Cohort==3, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle("with school") $outregOption

eststo `eq'6a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle("Reggio Only") $outregOption

eststo `eq'6b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle("Reggio Only") $outregOption

eststo `eq'6c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter  $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle("Reggio Only") $outregOption

eststo `eq'7a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter  Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3 & materna_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle("Mun. only") $outregOption

eststo `eq'7b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3 & asilo_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle("Mun. only") $outregOption

eststo `eq'7c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3 & (materna_Municipal==1 | asilo_Municipal==1), robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle("Mun. only") $outregOption

esttab `eq'4a `eq'4b `eq'5a `eq'5b `eq'6a `eq'6b using IVAdo-`i'.tex, replace $Options ///  `eq'2 
stats(controls mom school reggio muni N r2 , fmt(0 0 0 0 0 0 0 3) ///
labels(`"Controls"' `"SES"' `"School types"' `"Reggio Only"' `"Mun. Only"' `"Observations"' `"\(R^{2}\)"' ) ) ///
keep($Disp) ///
mgroups("`lablvar'"	, pattern(1 0 0 0 0 0 0)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
}


*---* Adolescents: Instrumented regression, FIRST STAGE
local i=0
foreach var of varlist $outAdo{
//local var MigrTaste_cat
local i=`i'+1
local eq "IVAdo_`var'"
local lablvar: variable label `var'
di "`lablvar'"

eststo `eq'4a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter  Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle("with mom") $outregOption

eststo `eq'4b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3, robust first 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle("with mom") $outregOption

eststo `eq'5a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xmaterna  if sampleAdo==1 & Cohort==3, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle("with school") $outregOption

eststo `eq'5b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xasilo  if sampleAdo==1 & Cohort==3, robust first 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle("with school") $outregOption

eststo `eq'6a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3 & Reggio==1, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle("Reggio Only") $outregOption

eststo `eq'6b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3 & Reggio==1, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle("Reggio Only") $outregOption

esttab `eq'4a `eq'4b `eq'5a `eq'5b `eq'6a `eq'6b using IVAdo-`i'_First.tex, replace $Options ///  `eq'2 
stats(controls mom school reggio muni N r2 , fmt(0 0 0 0 0 0 0 3) ///
labels(`"Controls"' `"SES"' `"School types"' `"Reggio Only"' `"Mun. Only"' `"Observations"' `"\(R^{2}\)"' ) ) ///
keep($Disp) ///
mgroups("`lablvar'"	, pattern(1 0 0 0 0 0 0)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
}

//================================================================================================================================

eststo clear
*---* Italian Child, simple OLS
local i=0
foreach var of varlist $outChild{
local i=`i'+1
local eq "`var'"
local lablvar: variable label `var'
di "`lablvar'"

eststo `eq'0: reg `var' ReggioMaterna ReggioAsilo treated Parma Padova CAPI if sampleChild==1 & Cohort==1, robust // [=] at some point should use logit/probit
outreg2 using ItaChild_`i'.out, replace ctitle("DROP") $outregOption

eststo `eq'1a: reg `var' ReggioMaterna Parma Padova CAPI if sampleChild==1 & Cohort==1, robust // [=] at some point should use logit/probit
outreg2 using ItaChild_`i'.out, append ctitle("`var' Baseline") $outregOption

eststo `eq'1b: reg `var' ReggioAsilo Parma Padova CAPI if sampleChild==1 & Cohort==1, robust // [=] at some point should use logit/probit
outreg2 using ItaChild_`i'.out, append ctitle("`var' Baseline") $outregOption

eststo `eq'1c: reg `var' treated Parma Padova CAPI if sampleChild==1 & Cohort==1, robust // [=] at some point should use logit/probit
outreg2 using ItaChild_`i'.out, append ctitle("`var' Baseline") $outregOption

eststo `eq'3a: reg `var' ReggioMaterna Parma Padova $Controls $cgPA $cgmStatus $cgPA $cgmStatus  if sampleChild==1 & Cohort==1, robust 
	estadd local controls "Yes", replace
outreg2 using ItaChild_`i'.out, append ctitle("with Controls") $outregOption

eststo `eq'3b: reg `var' ReggioAsilo Parma Padova $Controls $cgPA $cgmStatus  if sampleChild==1 & Cohort==1, robust 
	estadd local controls "Yes", replace
outreg2 using ItaChild_`i'.out, append ctitle("with Controls") $outregOption

eststo `eq'3c: reg `var' treated Parma Padova $Controls $cgPA $cgmStatus  if sampleChild==1 & Cohort==1, robust 
	estadd local controls "Yes", replace
outreg2 using ItaChild_`i'.out, append ctitle("with Controls") $outregOption


eststo `eq'4a: reg `var' ReggioMaterna  Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using ItaChild_`i'.out, append ctitle("with mom") $outregOption

eststo `eq'4b: reg `var' ReggioAsilo Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using ItaChild_`i'.out, append ctitle("with mom") $outregOption

eststo `eq'4c: reg `var' treated Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using ItaChild_`i'.out, append ctitle("with mom") $outregOption

eststo `eq'5a: reg `var' ReggioMaterna Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xmaterna  if sampleChild==1 & Cohort==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using ItaChild_`i'.out, append ctitle("with school") $outregOption

eststo `eq'5b: reg `var' ReggioAsilo Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xasilo  if sampleChild==1 & Cohort==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using ItaChild_`i'.out, append ctitle("with school") $outregOption

eststo `eq'5c: reg `var' treated Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xmaterna $xasilo  if sampleChild==1 & Cohort==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using ItaChild_`i'.out, append ctitle("with school") $outregOption

eststo `eq'6a: reg `var' ReggioMaterna  $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using ItaChild_`i'.out, append ctitle("Reggio Only") $outregOption

eststo `eq'6b: reg `var' ReggioAsilo    $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using ItaChild_`i'.out, append ctitle("Reggio Only") $outregOption

eststo `eq'6c: reg `var' treated     $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using ItaChild_`i'.out, append ctitle("Reggio Only") $outregOption

eststo `eq'7a: reg `var' ReggioMaterna  Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1 & materna_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using ItaChild_`i'.out, append ctitle("Mun. only") $outregOption

eststo `eq'7b: reg `var' ReggioAsilo Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1 & asilo_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using ItaChild_`i'.out, append ctitle("Mun. only") $outregOption

eststo `eq'7c: reg `var' treated Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1 & (materna_Municipal==1 | asilo_Municipal==1), robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using ItaChild_`i'.out, append ctitle("Mun. only") $outregOption

esttab `eq'4a `eq'4b `eq'5a `eq'5b `eq'6a `eq'6b using ItaChild-`i'.tex, replace $Options ///  eq2 
stats(controls mom school reggio muni N r2 , fmt(0 0 0 0 0 0 0 3) ///
labels(`"Controls"' `"Mom beliefs"' `"School types"' `"Reggio Only"' `"Mun. Only"' `"Observations"' `"\(R^{2}\)"' ) ) ///
keep($Disp) ///
mgroups("`lablvar'"	, pattern(1 0 0 0 0 0 0)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
}

*---* Italian Child: Instrumented regression
local i=0
foreach var of varlist $outChild{
local i=`i'+1
local eq "IV_`var'"
local lablvar: variable label `var'
di "`lablvar'"

eststo `eq'0: ivregress 2sls `var' (ReggioMaterna ReggioAsilo treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter distCenter Parma Padova CAPI if sampleChild==1 & Cohort==1, robust // [=] at some point should use logit/probit
outreg2 using IVItaChild_`i'.out, replace ctitle("DROP") $outregOption

eststo `eq'1a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova CAPI if sampleChild==1 & Cohort==1, robust // [=] at some point should use logit/probit
outreg2 using IVItaChild_`i'.out, replace ctitle("`var' Baseline") $outregOption

eststo `eq'1b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova CAPI if sampleChild==1 & Cohort==1, robust // [=] at some point should use logit/probit
outreg2 using IVItaChild_`i'.out, append ctitle("`var' Baseline") $outregOption

eststo `eq'1c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova CAPI if sampleChild==1 & Cohort==1, robust // [=] at some point should use logit/probit
outreg2 using IVItaChild_`i'.out, append ctitle("`var' Baseline") $outregOption

eststo `eq'3a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus  if sampleChild==1 & Cohort==1, robust 
	estadd local controls "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle("with Controls") $outregOption

eststo `eq'3b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus  if sampleChild==1 & Cohort==1, robust 
	estadd local controls "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle("with Controls") $outregOption

eststo `eq'3c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus  if sampleChild==1 & Cohort==1, robust 
	estadd local controls "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle("with Controls") $outregOption

eststo `eq'4a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter  Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle("with mom") $outregOption

eststo `eq'4b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle("with mom") $outregOption

eststo `eq'4c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle("with mom") $outregOption

eststo `eq'5a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xmaterna  if sampleChild==1 & Cohort==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle("with school") $outregOption

eststo `eq'5b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xasilo  if sampleChild==1 & Cohort==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle("with school") $outregOption

eststo `eq'5c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xmaterna $xasilo  if sampleChild==1 & Cohort==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle("with school") $outregOption

eststo `eq'6a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle("Reggio Only") $outregOption

eststo `eq'6b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle("Reggio Only") $outregOption

eststo `eq'6c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter  $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle("Reggio Only") $outregOption

eststo `eq'7a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter  Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1 & materna_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle("Mun. only") $outregOption

eststo `eq'7b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1 & asilo_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle("Mun. only") $outregOption

eststo `eq'7c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1 & (materna_Municipal==1 | asilo_Municipal==1), robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle("Mun. only") $outregOption

esttab `eq'4a `eq'4b `eq'5a `eq'5b `eq'6a `eq'6b using IVItaChild-`i'.tex, replace $Options ///  eq2 
stats(controls mom school reggio muni N r2 , fmt(0 0 0 0 0 0 0 3) ///
labels(`"Controls"' `"SES"' `"School types"' `"Reggio Only"' `"Mun. Only"' `"Observations"' `"\(R^{2}\)"' ) ) ///
keep($Disp) ///
mgroups("`lablvar'"	, pattern(1 0 0 0 0 0 0)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
}


*---* Italian Child: Instrumented regression, FIRST STAGE
local i=0
foreach var of varlist $outChild{
local i=`i'+1
local eq "IV_`var'"
local lablvar: variable label `var'
di "`lablvar'"

eststo `eq'4a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter  Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle("with mom") $outregOption

eststo `eq'4b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle("with mom") $outregOption

eststo `eq'5a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xmaterna  if sampleChild==1 & Cohort==1, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle("with school") $outregOption

eststo `eq'5b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xasilo  if sampleChild==1 & Cohort==1, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle("with school") $outregOption

eststo `eq'6a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1 & Reggio==1, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle("Reggio Only") $outregOption

eststo `eq'6b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1 & Reggio==1, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle("Reggio Only") $outregOption

esttab `eq'4a `eq'4b `eq'5a `eq'5b `eq'6a `eq'6b using IVItaChild-`i'_First.tex, replace $Options ///  eq2 
stats(controls mom school reggio muni N r2 , fmt(0 0 0 0 0 0 0 3) ///
labels(`"Controls"' `"SES"' `"School types"' `"Reggio Only"' `"Mun. Only"' `"Observations"' `"\(R^{2}\)"' ) ) ///
keep($Disp) ///
mgroups("`lablvar'"	, pattern(1 0 0 0 0 0 0)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
}

//==========================================================================================================

eststo clear
*---* Migrant Child, simple OLS
local i=0
foreach var of varlist $outChild{
local i=`i'+1
local eq "`var'"
local lablvar: variable label `var'
di "`lablvar'"

eststo `eq'0: reg `var' ReggioMaterna ReggioAsilo treated Parma Padova CAPI if sampleMigr==1 & Cohort==2, robust // [=] at some point should use logit/probit
outreg2 using MigrChild_`i'.out, replace ctitle("DROP") $outregOption

eststo `eq'1a: reg `var' ReggioMaterna Parma Padova CAPI if sampleMigr==1 & Cohort==2, robust // [=] at some point should use logit/probit
outreg2 using MigrChild_`i'.out, append ctitle("`var' Baseline") $outregOption

eststo `eq'1b: reg `var' ReggioAsilo Parma Padova CAPI if sampleMigr==1 & Cohort==2, robust // [=] at some point should use logit/probit
outreg2 using MigrChild_`i'.out, append ctitle("`var' Baseline") $outregOption

eststo `eq'1c: reg `var' treated Parma Padova CAPI if sampleMigr==1 & Cohort==2, robust // [=] at some point should use logit/probit
outreg2 using MigrChild_`i'.out, append ctitle("`var' Baseline") $outregOption

eststo `eq'3a: reg `var' ReggioMaterna Parma Padova $Controls $cgPA $cgmStatus $cgPA $cgmStatus  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle("with Controls") $outregOption

eststo `eq'3b: reg `var' ReggioAsilo Parma Padova $Controls $cgPA $cgmStatus  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle("with Controls") $outregOption

eststo `eq'3c: reg `var' treated Parma Padova $Controls $cgPA $cgmStatus  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle("with Controls") $outregOption

eststo `eq'4a: reg `var' ReggioMaterna  Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle("with mom") $outregOption

eststo `eq'4b: reg `var' ReggioAsilo Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle("with mom") $outregOption

eststo `eq'4c: reg `var' treated Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle("with mom") $outregOption

eststo `eq'5a: reg `var' ReggioMaterna Parma Padova $Controls $cgPA $cgmStatus $Migr_other $xmaterna  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle("with school") $outregOption

eststo `eq'5b: reg `var' ReggioAsilo Parma Padova $Controls $cgPA $cgmStatus $Migr_other $xasilo  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle("with school") $outregOption

eststo `eq'5c: reg `var' treated Parma Padova $Controls $cgPA $cgmStatus $Migr_other $xmaterna $xasilo  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle("with school") $outregOption

eststo `eq'6a: reg `var' ReggioMaterna  $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle("Reggio Only") $outregOption

eststo `eq'6b: reg `var' ReggioAsilo    $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle("Reggio Only") $outregOption

eststo `eq'6c: reg `var' treated     $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle("Reggio Only") $outregOption

eststo `eq'7a: reg `var' ReggioMaterna  Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & materna_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle("Mun. only") $outregOption

eststo `eq'7b: reg `var' ReggioAsilo Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & asilo_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle("Mun. only") $outregOption

eststo `eq'7c: reg `var' treated Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & (materna_Municipal==1 | asilo_Municipal==1), robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle("Mun. only") $outregOption

esttab `eq'4a `eq'4b `eq'5a `eq'5b `eq'6a `eq'6b using MigrChild-`i'.tex, replace $Options ///  `eq'2 
stats(controls mom school reggio muni N r2 , fmt(0 0 0 0 0 0 0 3) ///
labels(`"Controls"' `"Mom beliefs"' `"School types"' `"Reggio Only"' `"Mun. Only"' `"Observations"' `"\(R^{2}\)"' ) ) ///
keep($Disp) ///
mgroups("`lablvar'"	, pattern(1 0 0 0 0 0 0)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
}

*---* Migrant Child: Instrumented regression
local i=0
foreach var of varlist $outChild{
local i=`i'+1
local eq "IV_`var'"
local lablvar: variable label `var'
di "`lablvar'"

eststo `eq'0: ivregress 2sls `var' (ReggioMaterna ReggioAsilo treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter distCenter Parma Padova CAPI if sampleMigr==1 & Cohort==2, robust // [=] at some point should use logit/probit
outreg2 using IVMigrChild_`i'.out, replace ctitle("DROP") $outregOption

eststo `eq'1a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova CAPI if sampleMigr==1 & Cohort==2, robust // [=] at some point should use logit/probit
outreg2 using IVMigrChild_`i'.out, replace ctitle("`var' Baseline")  $outregOption

eststo `eq'1b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova CAPI if sampleMigr==1 & Cohort==2, robust // [=] at some point should use logit/probit
outreg2 using IVMigrChild_`i'.out, append ctitle("`var' Baseline")  $outregOption

eststo `eq'1c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova CAPI if sampleMigr==1 & Cohort==2, robust // [=] at some point should use logit/probit
outreg2 using IVMigrChild_`i'.out, append ctitle("`var' Baseline") $outregOption

eststo `eq'3a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("with Controls") $outregOption

eststo `eq'3b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("with Controls") $outregOption

eststo `eq'3c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("with Controls") $outregOption

eststo `eq'4a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter  Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("with mom") $outregOption

eststo `eq'4b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("with mom") $outregOption

eststo `eq'4c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("with mom") $outregOption

eststo `eq'5a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Migr_other $xmaterna  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("with school") $outregOption

eststo `eq'5b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Migr_other $xasilo  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("with school") $outregOption

eststo `eq'5c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Migr_other $xmaterna $xasilo  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("with school") $outregOption

eststo `eq'6a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("Reggio Only") $outregOption

eststo `eq'6b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("Reggio Only") $outregOption

eststo `eq'6c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter  $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("Reggio Only") $outregOption

eststo `eq'7a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter  Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & materna_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("Mun. only") $outregOption

eststo `eq'7b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & asilo_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("Mun. only") $outregOption

eststo `eq'7c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & (materna_Municipal==1 | asilo_Municipal==1), robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("Mun. only") $outregOption

/*
esttab `eq'4a `eq'4b `eq'5a `eq'5b `eq'6a `eq'6b using IVMigrChild-`i'.tex, replace $Options ///  eq2 
stats(controls mom school reggio muni N r2 , fmt(0 0 0 0 0 0 0 3) ///
labels(`"Controls"' `"SES"' `"School types"' `"Reggio Only"' `"Mun. Only"' `"Observations"' `"\(R^{2}\)"' ) ) ///
keep($Disp) ///
mgroups("`lablvar'"	, pattern(1 0 0 0 0 0 0)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
*/
} // end of foreach var loop


*---* Migrant Child: Instrumented regression, First Stage
local i=0
foreach var of varlist $outChild{
local i=`i'+1
local eq "IV_`var'"
local lablvar: variable label `var'
di "`lablvar'"

eststo `eq'4a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter  Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("with mom") $outregOption

eststo `eq'4b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("with mom") $outregOption

eststo `eq'5a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Migr_other $xmaterna  if sampleMigr==1 & Cohort==2, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("with school") $outregOption

eststo `eq'5b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Migr_other $xasilo  if sampleMigr==1 & Cohort==2, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("with school") $outregOption

eststo `eq'6a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & Reggio==1, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("Reggio Only") $outregOption

eststo `eq'6b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & Reggio==1, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("Reggio Only") $outregOption
/*
esttab `eq'4a `eq'4b `eq'5a `eq'5b `eq'6a `eq'6b using IVMigrChild-`i'_First.tex, replace $Options ///  eq2 
stats(controls mom school reggio muni N r2 , fmt(0 0 0 0 0 0 0 3) ///
labels(`"Controls"' `"SES"' `"School types"' `"Reggio Only"' `"Mun. Only"' `"Observations"' `"\(R^{2}\)"' ) ) ///
keep($Disp) ///
mgroups("`lablvar'"	, pattern(1 0 0 0 0 0 0)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
*/
} // end of foreach var loop

} // end of if loop

capture log close
