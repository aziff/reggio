* ---------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - Xleft variable selection
* Authors: Pietro Biroli, Chiara Pronzato
* Editors: Jessica Yu Kyung Koh, Anna Ziff
* Created: 12/11/2015
* Edited: 01/15/2016
* ---------------------------------------------------------------------------- *

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

cd $data_reggio
use Reggio, clear

cd ${klmReggio}/Analysis/Output/
* ---------------------------------------------------------------------------- *
* Create locals and label variables

** Categories
local cities				Reggio Parma Padova
local school_types 			None Muni Stat Reli Priv
local school_age_types		Asilo Materna
local cohorts				Child Adol Adult 

local Asilo_name			Infant-Toddler Center
local Materna_name			Preschool

//local large_sample_condition	largeSample_`city'`age'`cohort'``outcome'_short' == 1

** Outcomes
local outcomes 			childSDQ_score SDQ_score Depression_score HealthPerc childHealthPerc MigrTaste_cat 
local outChild 			childSDQ_score childHealthPerc 
local outAdol 			childSDQ_score SDQ_score Depression_score HealthPerc childHealthPerc MigrTaste_cat
local outAdult 			Depression_score HealthPerc MigrTaste_cat 

local childSDQ_score_name	Child SDQ Score
local SDQ_score_name		SDQ Score
local Depression_score_name	Depression Score
local HealthPerc_name		Health Perception
local childHealthPerc_name	Child Health Perception
local MigrTaste_cat_name	Migration Taste // these are for titles in graphs.

** Abbreviations for outcomes to help define variables and locals
local childSDQ_score_short 	CS
local SDQ_score_short		S
local childHealthPerc_short	CH
local HealthPerc_short          H
local Depression_score_short	D
local MigrTaste_cat_short	M

** Controls
local Xright 		Male Age Age_sq momMaxEdu_middle momMaxEdu_mHS momMaxEdu_Uni ///missing cat: low edu
			dadMaxEdu_middle dadMaxEdu_mHS dadMaxEdu_Uni ///missing cat: low edu
			momBornProvince dadBornProvince cgRelig houseOwn cgReddito_2-cgReddito_7 /// missing cat: income below 5,000
			internr_* CAPI 
//Xright does not have missing value for all cohort
local XleftChild			lowbirthweight birthpremature 	
local XleftAdol				lowbirthweight birthpremature 
local XleftAdult			lowbirthweight				
local xmaterna 				xm*
local xasilo 				xa*

local main_name				Control 1
local inter_name			Control 2
local right_name			Control 3
local all_name				Control 4 // for titles in graphs

** Outreg option
local outregOptionChild 	bracket dec(3) sortvar(ReggioAsilo xa* `XleftChild' internr_*) drop(o.* *internr_* *Month_int_*) 
local outregOptionAdol	 	bracket dec(3) sortvar(ReggioAsilo xa* `XleftAdol' internr_*) drop(o.* *internr_* *Month_int_*) 
local outregOptionAdult 	bracket dec(3) sortvar(ReggioAsilo xa* `XleftAdult' internr_*) drop(o.* *internr_* *Month_int_*) 


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
		** MAIN TREATMENT EFFECTS; CHANGE REFERENCE GROUP HERE
		if "`age'" == "Asilo" {
			local main_terms		`city'`age' `int'`city'Priv	`int'`city'None
		
		}
		else {
			local main_terms	`city'`age' `int'`city'Priv `int'`city'Stat `int'`city'None
		}
		
		** Effect of school type on the Xleft variables
			*** Low Birthweight
			di "`city' `age'"
			reg lowbirthweight `main_terms' `Xright' if (City == `city_val' & Cohort_new == 1), robust
			outreg2 using "${klmReggio}/Analysis/Output/lowbw`city'`age'.tex", replace bracket dec(3) ctitle(Children) keep(`main_terms') addtext(Controls, Yes) tex(frag)
			
			di "`city' `age'"
			reg lowbirthweight `main_terms' `Xright' if (City == `city_val' & Cohort_new == 2), robust
			outreg2 using "${klmReggio}/Analysis/Output/lowbw`city'`age'.tex", append bracket dec(3) ctitle(Adolescents) keep(`main_terms') addtext(Controls, Yes) tex(frag)
			
			di "`city' `age'"
			reg lowbirthweight `main_terms' `Xright' if (City == `city_val' & Cohort_new == 3), robust
			outreg2 using "${klmReggio}/Analysis/Output/lowbw`city'`age'.tex", append bracket dec(3) ctitle(Adults) keep(`main_terms') addtext(Controls, Yes) tex(frag)
				
				
			*** Birth Premature
			di "`city' `age'"
			reg birthpremature `main_terms' `Xright' if (City == `city_val' & Cohort_new == 1), robust
			outreg2 using "${klmReggio}/Analysis/Output/birthpre`city'`age'.tex", replace bracket dec(3) ctitle(Children) keep(`main_terms') addtext(Controls, Yes) tex(frag)
			
			di "`city' `age'"
			reg birthpremature `main_terms' `Xright' if (City == `city_val' & Cohort_new == 2), robust
			outreg2 using "${klmReggio}/Analysis/Output/birthpre`city'`age'.tex", append bracket dec(3) ctitle(Adolescents) keep(`main_terms') addtext(Controls, Yes) tex(frag)
		
		local city_val = `city_val' + 1
	}
	local int xm
}

