* ---------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - Selection into Different School Types
* Authors: Pietro Biroli, Chiara Pronzato
* Editors: Jessica Yu Kyung Koh, Anna Ziff
* Created: 12/11/2015
* Edited: 01/08/2016
* ---------------------------------------------------------------------------- *

clear all
set more off

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

cd $data_reggio
use Reggio, clear

cd ${klmReggio}/Analysis/jk-az-analysis/Output/
* ---------------------------------------------------------------------------- *
* Create locals and label variables

** Categories
local cities				Reggio Parma Padova
local school_types 			None Muni Stat Reli Priv
local school_age_types		Asilo Materna
local cohorts				Child Adol Adult

** Outcomes
local outcomes 				childSDQ_score SDQ_score Depression_score HealthPerc childHealthPerc MigrTaste_cat 
local outChild 				childSDQ_score childHealthPerc 
local outAdol 				childSDQ_score SDQ_score Depression_score HealthPerc childHealthPerc MigrTaste_cat
local outAdult 				Depression_score HealthPerc MigrTaste_cat 

local childSDQ_score_name	Child SDQ Score
local SDQ_score_name		SDQ Score
local Depression_score_name	Depression Score
local HealthPerc_name		Health Perception
local childHealthPerc_name	Child Health Perception
local MigrTaste_cat_name	Migration Taste // these are for titles in graphs.

** Abbreviations for outcomes
local childSDQ_score_short 		CS
local SDQ_score_short			S
local childHealthPerc_short	   	CH
local HealthPerc_short          H
local Depression_score_short	D
local MigrTaste_cat_short		M

** Controls
local Xright		  	    Male momMaxEdu_* dadMaxEdu_* internr_* CAPI momBornProvince dadBornProvince cgRelig houseOwn cgReddito_* Age Age_sq 
//Xright does not have missing value for all cohort
local XleftChild			lowbirthweight birthpremature 	
local XleftAdol				lowbirthweight birthpremature 
local XleftAdult			lowbirthweight				
local xmaterna 				xm*
local xasilo 				xa*

local main_name				Control 1
local inter_name			Control 2
local right_name			Control 3
local all_name				Control 4

** Outreg option
local outregOptionChild 	bracket dec(3) sortvar(ReggioAsilo xa* `XleftChild' internr_*) drop(o.* *internr_* *Month_int_*) 
local outregOptionAdol	 	bracket dec(3) sortvar(ReggioAsilo xa* `XleftAdol' internr_*) drop(o.* *internr_* *Month_int_*) 
local outregOptionAdult 	bracket dec(3) sortvar(ReggioAsilo xa* `XleftAdult' internr_*) drop(o.* *internr_* *Month_int_*) 

** Variable labels
label var ReggioMaterna 	"RCH preschool"
label var ReggioAsilo 		"RCH infant-toddler"

label var CAPI 				"CAPI"
label var Cohort_Adult30 	"30 year olds"
label var Cohort_Adult40	"40 year olds"
label var Male 				"Male dummy"
label var asilo_Attend 		"Any infant-toddler center"
label var asilo_Municipal 	"Municipal infant-toddler center"
label var materna_Municipal "Municipal preschool"
label var materna_Religious "Religious preschool"
label var materna_State 	"State preschool"
label var materna_Private 	"Private preschool"

label var dadMaxEdu_Uni 	"Father College" 
label var momMaxEdu_Uni 	"Mother College" 
label var cgPA_HouseWife 	"Caregiver Housewife"
label var dadPA_Unempl 		"Father Unemployed" 
label var cgmStatus_div 	"Caregiver Divorced"
label var momHome06 		"Mom Home at 6"
label var numSiblings 		"Num. Siblings"
label var childrenSibTot 	"Num. Siblings"
label var houseOwn 			"Own Home"
label var MaxEdu_Uni 		"College"

label var Depression_score 	"Depression"

* ---------------------------------------------------------------------------- *
* Create variables for interview date fixed effects

** Dummy variables for categories in Month_int
gen Month_int = mofd(Date_int)
dummieslab Month_int // install dummislab command if you haven't already

** Dummy variables for categories in IncomeCat_manual 
tab IncomeCat_manual, miss gen(Reddito_)
rename Reddito_8 Reddito_miss  

** Dummy variables for categories in cgIncomeCat_manual
tab cgIncomeCat_manual, miss gen(cgReddito_)
gen cgReddito_miss = (cgIncomeCat_manual >= .) 
drop cgReddito_8 cgReddito_9

* ---------------------------------------------------------------------------- *
* Create the double interactions of schooltype and city

** For Asilo (Age 0-3)
capture drop xa*
local city_val = 1

foreach city in `cities' {
	local asilo_val = 0
	foreach type in `school_types' {
		generate xa`city'`type' = (asiloType == `asilo_val' & City == `city_val') if asiloType < .
		label var xa`city'`type' "`city' `type' ITC"
		local asilo_val = `asilo_val' + 1
	}
	local city_val = `city_val' + 1
}

** For Materna (Age 3-6)
capture drop xm*
local city_val = 1

foreach city in `cities' {
	local materna_val = 0
	foreach type in `school_types' {
		generate xm`city'`type' = (maternaType == `materna_val' & City == `city_val') if maternaType < .
		label var xm`city'`type' "`city' `type' Preschool"
		local materna_val = `materna_val' + 1
	}
	local city_val = `city_val' + 1
}

* ---------------------------------------------------------------------------- *
* Fix missing value problems for controls

** Replace missing with zeros and put missing variable
foreach parent in mom dad {
	foreach categ in MaxEdu mStatus PA {
		foreach var of varlist `parent'`categ'_* {
			replace `var' = 0 if `parent'`categ'_miss == 1
		} 
	}
}

foreach var in momBornProvince dadBornProvince cgRelig houseOwn lowbirthweight {
	gen `var'_miss = (`var' >= .)
	replace `var' = 0 if `var'_miss == 1
}

* ---------------------------------------------------------------------------- *
* Create ParmaAsilo, ParmaMaterna, PadovaAsilo, PadovaMaterna (not created by the cleaning do files.) --> PB where is this used?

gen ParmaAsilo   = (City == 2 & asiloType == 1) if asiloType < .  
gen ParmaMaterna = (City == 2 & maternaType == 1) if maternaType < . 
replace ParmaMaterna = 0 if maternaComment == "Living in Parma, attended school in Reggio" & maternaType == 1 // There are 16 people from Parma gone to Reggio Children

gen PadovaAsilo   = (City == 3 & asiloType == 1) if asiloType < .  
gen PadovaMaterna = (City == 3 & maternaType == 1) if maternaType < .

* ---------------------------------------------------------------------------- *
* Regression Analyses
/* Note: Children => Cohort == 1
		 Migrants => Cohort == 2
		 Adolescents => Cohort == 3 
		 Adult 30 => Cohort == 4
		 Adult 40 => Cohort == 5
		 Adult 50 => Cohort == 6 */
		 
** For convenience, group all adults into a same cohort
generate Cohort_new = 0
replace Cohort_new = 1 if Cohort == 1 // children
replace Cohort_new = 2 if Cohort == 3 // adolescents
replace Cohort_new = 3 if Cohort == 4 | Cohort == 5 | Cohort == 6 // adults

** Run regressions and save the outputs
local int xa 
foreach age in `school_age_types' { // Asilo or Materna
	local city_val = 1
	foreach city in `cities' {
		local cohort_val = 1
		** MAIN TREATMENT EFFECTS; CHANGE REFERENCE GROUP HERE
		if "`age'" == "Asilo" {
			local main_terms		`city'`age' `int'`city'Priv	`int'`city'None
		
		}
		else {
			local main_terms	`city'`age' `int'`city'Priv `int'`city'Stat `int'`city'None
		}
		
		foreach cohort in `cohorts' { // Child, Adol, or Adult
			foreach outcome in `out`cohort'' {
			    local large_sample_condition	largeSample_`city'`age'`cohort'``outcome'_short' == 1
				
				** Generate small sample		 
				//reg childSDQ_score `city'`age' `int'`city'Reli `int'`city'Priv `Xright' if (City == `city_val' & Cohort_new == `cohort_val' & momMaxEdu_miss == 0 & cgReddito_miss == 0), robust  
				//gen smallSample_`city'`age'`cohort' = e(sample)	
	
				** Generate large sample
				sum `outcome' `main_terms' `Xright' `Xleft`cohort''
				reg `outcome' `main_terms' `Xright' `Xleft`cohort'' if (City == `city_val' & Cohort_new == `cohort_val'), robust  
				gen largeSample_`city'`age'`cohort'``outcome'_short' = e(sample)	
				tab largeSample_`city'`age'`cohort'``outcome'_short'

				** Run regressions and store results into latex
				
				* 1. Only city/age terms
				reg `outcome' `main_terms' if `large_sample_condition', robust  
					estimates store `city'`age'`cohort'``outcome'_short'main
					estimates dir
					outreg2 using "${klmReggio}/Analysis/jk-az-analysis/Output/test`city'`age'`cohort'``outcome'_short'.out", replace `outregOption`cohort'' addtext(Controls, None)
				
				* 2. Adding interviewer fixed effects
				reg `outcome' `main_terms' CAPI internr_* if `large_sample_condition', robust  
					estimates store `city'`age'`cohort'``outcome'_short'inter
					estimates dir
					outreg2 using "${klmReggio}/Analysis/jk-az-analysis/Output/test`city'`age'`cohort'``outcome'_short'.out", append `outregOption`cohort'' addtext(Controls, Yes)


				* 3. Interviewer and demographic/family/interview characteristics
				reg `outcome' `main_terms' `Xright' if `large_sample_condition', robust  
					estimates store `city'`age'`cohort'``outcome'_short'right
					estimates dir
					outreg2 using "${klmReggio}/Analysis/jk-az-analysis/Output/test`city'`age'`cohort'``outcome'_short'.out", append `outregOption`cohort'' addtext(Controls, Yes)
				
				* 4. All controls
				reg `outcome' `main_terms' `Xright' `Xleft`cohort'' if `large_sample_condition', robust  
					estimates store `city'`age'`cohort'``outcome'_short'all
					estimates dir
					outreg2 using "${klmReggio}/Analysis/jk-az-analysis/Output/test`city'`age'`cohort'``outcome'_short'.out", append `outregOption`cohort'' addtext(Controls, all)
			
			
				** Save results
				foreach r in main inter right all {
					estimates restore `city'`age'`cohort'``outcome'_short'`r'
					
					scalar N_``outcome'_short'_`age'_`city'_`cohort'_`r' = e(N)
					matrix b_``outcome'_short'_`age'_`city'_`cohort'_`r' = e(b)
					matrix V_``outcome'_short'_`age'_`city'_`cohort'_`r' = e(V)
					
					forval i = 1/4 {
						gen b`i'``outcome'_short'_`age'_`city'_`cohort'_`r' = b_``outcome'_short'_`age'_`city'_`cohort'_`r'[1,`i'] // this is regression coefficient
						gen v`i'``outcome'_short'_`age'_`city'_`cohort'_`r' = sqrt(V_``outcome'_short'_`age'_`city'_`cohort'_`r'[`i',`i']) // this is standard error.
						
						gen u`i'``outcome'_short'_`age'_`city'_`cohort'_`r' = b`i'``outcome'_short'_`age'_`city'_`cohort'_`r' + 1.95*(v`i'``outcome'_short'_`age'_`city'_`cohort'_`r')/sqrt(N_``outcome'_short'_`age'_`city'_`cohort'_`r')
						gen l`i'``outcome'_short'_`age'_`city'_`cohort'_`r' = b`i'``outcome'_short'_`age'_`city'_`cohort'_`r' - 1.95*(v`i'``outcome'_short'_`age'_`city'_`cohort'_`r')/sqrt(N_``outcome'_short'_`age'_`city'_`cohort'_`r')
					}
					
					gen N_``outcome'_short'_`age'_`city'_`cohort'_`r' = N_``outcome'_short'_`age'_`city'_`cohort'_`r'
				}
			}
			local cohort_val = `cohort_val' + 1
		}
		local city_val = `city_val' + 1
	}
	local int xm
}



* ---------------------------------------------------------------------------- *

local graph_region		graphregion(color(white))

local yaxis				ylabel(-5(1)5, labsize(small)) yline(0,lcol(black) lwidth(thin)) ytitle(Est. difference wrt Religious)
local xaxisAsilo		xtick(none) xlabel(2 "Reggio" 6 "Parma"	10 "Padova")
local xaxisMaterna		xtick(none) xlabel(2.5 "Reggio" 7.5 "Parma" 12.5 "Padova")
	
local bar_look			lwidth(5)

local Asilo_bar1		col(dkgreen) //bar1 is municipal --> treatment
local Asilo_bar2		col(gs8)
local Asilo_bar3		col(dkorange)

local Materna_bar1		col(dkgreen) //bar1 is municipal --> treatment
local Materna_bar2		col(gs8)
local Materna_bar3		col(navy)
local Materna_bar4		col(dkorange)

local ci_lines			col(red)	lwidth(vvthin)

local Asilo_legend		legend(size(small) rows(1) holes(1) order(1 2 3) label(1 Municipal) label(2 Private) label(3 None))
local Materna_legend	legend(rows(1) order(1 2 3 4) label(1 Municipal) label(2 Private) label(3 State) label(4 None))

* ---------------------------------------------------------------------------- *
* For the plot
forval i = 0/20 {
	gen ref`i' = `i' // x values to plot the points
}


** Graph results
foreach age of local school_age_types { // Asilo or Materna
	foreach cohort in `cohorts' { // Child, Adol, or Adult
		foreach outcome in `out`cohort'' {
			foreach r in main inter right all {
				
				local title				title("`age': ``outcome'_name', ``r'_name'") //I need to put title here, otherwise STATA won't recognize all the category locals.
		
				if "`age'" == "Asilo" {
					# delimit ;
					twoway (rspike b1``outcome'_short'_`age'_Reggio_`cohort'_`r' ref0 ref1, `bar_look' `Asilo_bar1') 
							(rspike b2``outcome'_short'_`age'_Reggio_`cohort'_`r' ref0 ref2, `bar_look' `Asilo_bar2') 
							(rspike b3``outcome'_short'_`age'_Reggio_`cohort'_`r' ref0 ref3,  `bar_look' `Asilo_bar3')
							(rspike b1``outcome'_short'_`age'_Parma_`cohort'_`r' ref0 ref5,  `bar_look' `Asilo_bar1') 
							(rspike b2``outcome'_short'_`age'_Parma_`cohort'_`r' ref0 ref6,  `bar_look' `Asilo_bar2') 
							(rspike b3``outcome'_short'_`age'_Parma_`cohort'_`r' ref0 ref7, `bar_look' `Asilo_bar3')
							(rspike b1``outcome'_short'_`age'_Padova_`cohort'_`r' ref0 ref9,  `bar_look' `Asilo_bar1') 
							(rspike b2``outcome'_short'_`age'_Padova_`cohort'_`r' ref0 ref10,  `bar_look' `Asilo_bar2') 
							(rspike b3``outcome'_short'_`age'_Padova_`cohort'_`r' ref0 ref11,  `bar_look' `Asilo_bar3')
							(rcap 		l1``outcome'_short'_`age'_Reggio_`cohort'_`r' 
										u1``outcome'_short'_`age'_Reggio_`cohort'_`r' ref1, `ci_lines')
							(rcap 		l2``outcome'_short'_`age'_Reggio_`cohort'_`r' 
										u2``outcome'_short'_`age'_Reggio_`cohort'_`r' ref2, `ci_lines')
							(rcap 		l3``outcome'_short'_`age'_Reggio_`cohort'_`r' 
										u3``outcome'_short'_`age'_Reggio_`cohort'_`r' ref3, `ci_lines')
							(rcap 		l1``outcome'_short'_`age'_Parma_`cohort'_`r' 
										u1``outcome'_short'_`age'_Parma_`cohort'_`r' ref5, `ci_lines')
							(rcap 		l2``outcome'_short'_`age'_Parma_`cohort'_`r' 
										u2``outcome'_short'_`age'_Parma_`cohort'_`r' ref6, `ci_lines')
							(rcap		l3``outcome'_short'_`age'_Parma_`cohort'_`r' 
										u3``outcome'_short'_`age'_Parma_`cohort'_`r' ref7, `ci_lines')
							(rcap 		l1``outcome'_short'_`age'_Padova_`cohort'_`r' 
										u1``outcome'_short'_`age'_Padova_`cohort'_`r' ref9, `ci_lines')
							(rcap 		l2``outcome'_short'_`age'_Padova_`cohort'_`r' 
										u2``outcome'_short'_`age'_Padova_`cohort'_`r' ref10, `ci_lines')
							(rcap 		l3``outcome'_short'_`age'_Padova_`cohort'_`r' 
										u3``outcome'_short'_`age'_Padova_`cohort'_`r' ref11, `ci_lines'
												`title' `yaxis' `xaxis`age''
												`Asilo_legend' 
												`graph_region' name(``outcome'_short'_`age'_`cohort'_`r',replace));
					//graph export "~/Desktop/graphs/``outcome'_short'_`age'_`cohort'_`r'.eps", replace as(eps);
					graph export "${klmReggio}/Analysis/jk-az-analysis/Output/graphs/``outcome'_short'_`age'_`cohort'_`r'.pdf", replace;
					# delimit cr
				}
				
				else {
					# delimit ;
					twoway (rspike b1``outcome'_short'_`age'_Reggio_`cohort'_`r' ref0 ref1, `bar_look' `Materna_bar1') 
							(rspike b2``outcome'_short'_`age'_Reggio_`cohort'_`r' ref0 ref2, `bar_look' `Materna_bar2') 
							(rspike b3``outcome'_short'_`age'_Reggio_`cohort'_`r' ref0 ref3, `bar_look' `Materna_bar3')
							(rspike b4``outcome'_short'_`age'_Reggio_`cohort'_`r' ref0 ref4, `bar_look' `Materna_bar4')
							(rspike b1``outcome'_short'_`age'_Parma_`cohort'_`r' ref0 ref6, `bar_look' `Materna_bar1') 
							(rspike b2``outcome'_short'_`age'_Parma_`cohort'_`r' ref0 ref7, `bar_look' `Materna_bar2') 
							(rspike b3``outcome'_short'_`age'_Parma_`cohort'_`r' ref0 ref8, `bar_look' `Materna_bar3')
							(rspike b4``outcome'_short'_`age'_Parma_`cohort'_`r' ref0 ref9, `bar_look' `Materna_bar4')
							(rspike b1``outcome'_short'_`age'_Padova_`cohort'_`r' ref0 ref11, `bar_look' `Materna_bar1') 
							(rspike b2``outcome'_short'_`age'_Padova_`cohort'_`r' ref0 ref12, `bar_look' `Materna_bar2') 
							(rspike b3``outcome'_short'_`age'_Padova_`cohort'_`r' ref0 ref13, `bar_look' `Materna_bar3')
							(rspike b4``outcome'_short'_`age'_Padova_`cohort'_`r' ref0 ref14, `bar_look' `Materna_bar4')
							(rcap		l1``outcome'_short'_`age'_Reggio_`cohort'_`r' 
										u1``outcome'_short'_`age'_Reggio_`cohort'_`r' ref1, `ci_lines')
							(rcap	 	l2``outcome'_short'_`age'_Reggio_`cohort'_`r' 
										u2``outcome'_short'_`age'_Reggio_`cohort'_`r' ref2, `ci_lines')
							(rcap	 	l3``outcome'_short'_`age'_Reggio_`cohort'_`r' 
										u3``outcome'_short'_`age'_Reggio_`cohort'_`r' ref3, `ci_lines')
							(rcap		l4``outcome'_short'_`age'_Reggio_`cohort'_`r' 
										u4``outcome'_short'_`age'_Reggio_`cohort'_`r' ref4, `ci_lines')
							(rcap	 	l1``outcome'_short'_`age'_Parma_`cohort'_`r' 
										u1``outcome'_short'_`age'_Parma_`cohort'_`r' ref6, `ci_lines')
							(rcap	 	l2``outcome'_short'_`age'_Parma_`cohort'_`r' 
										u2``outcome'_short'_`age'_Parma_`cohort'_`r' ref7, `ci_lines')
							(rcap	 	l3``outcome'_short'_`age'_Parma_`cohort'_`r' 
										u3``outcome'_short'_`age'_Parma_`cohort'_`r' ref8, `ci_lines')
							(rcap	 	l4``outcome'_short'_`age'_Parma_`cohort'_`r' 
										u4``outcome'_short'_`age'_Parma_`cohort'_`r' ref9, `ci_lines')
							(rcap	 	l1``outcome'_short'_`age'_Padova_`cohort'_`r'
										u1``outcome'_short'_`age'_Padova_`cohort'_`r' ref11, `ci_lines')
							(rcap	 	l2``outcome'_short'_`age'_Padova_`cohort'_`r' 
										u2``outcome'_short'_`age'_Padova_`cohort'_`r' ref12, `ci_lines')
							(rcap	 	l3``outcome'_short'_`age'_Padova_`cohort'_`r' 
										u3``outcome'_short'_`age'_Padova_`cohort'_`r' ref13, `ci_lines')
							(rcap	 	l4``outcome'_short'_`age'_Padova_`cohort'_`r' 
										u4``outcome'_short'_`age'_Padova_`cohort'_`r' ref14, `ci_lines'
												`title' `yaxis' `xaxis`age''
												`Materna_legend' 
												`graph_region');
					//graph export "~/Desktop/graphs/``outcome'_short'_`age'_`cohort'_`r'.eps", replace as(eps);							
					graph export "${klmReggio}/Analysis/jk-az-analysis/Output/graphs/``outcome'_short'_`age'_`cohort'_`r'.pdf", replace;
					# delimit cr
						
				}
				
			}
		}
	}
}
