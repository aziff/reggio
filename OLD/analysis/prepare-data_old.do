* ---------------------------------------------------------------------------- *
* Prepare Data for Analysis
* Run this code before other analysis .do-files
* Contributors:                      Pietro Biroli, Chiara Pronzato, 
*                                    Jessica Yu Kyung Koh, Anna Ziff
* Original version:          Modified from 12/11/15
* Current version:                   1/25/16
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

global klmReggio    :    env klmReggio
global data_reggio  :    env data_reggio
global git_reggio   :    env git_reggio

cd $data_reggio
use Reggio, clear

cd ${klmReggio}/Analysis/Output/
* ---------------------------------------------------------------------------- *
* Create locals and label variables
** Categories
local cities                         Reggio Parma Padova
local school_types                   None Muni Stat Reli Priv
local school_age_types               Asilo Materna
local cohorts                        Child Adol Adult 

local Asilo_name                     Infant-Toddler Center
local Materna_name                   Preschool

** Outcomes
local outcomes                        childSDQ_score SDQ_score Depression_score HealthPerc childHealthPerc MigrTaste_cat 
local outChild                        childSDQ_score childHealthPerc 
local outAdol                         childSDQ_score SDQ_score Depression_score HealthPerc childHealthPerc MigrTaste_cat
local outAdult                        Depression_score HealthPerc MigrTaste_cat 

local childSDQ_score_name             Child SDQ Score
local SDQ_score_name                  SDQ Score
local Depression_score_name           Depression Score
local HealthPerc_name                 Health Perception
local childHealthPerc_name            Child Health Perception
local MigrTaste_cat_name              Migration Taste // these are for titles in graphs.

** Abbreviations for outcomes
local childSDQ_score_short            CS
local SDQ_score_short                 S
local childHealthPerc_short           CH
local HealthPerc_short                H
local Depression_score_short          D
local MigrTaste_cat_short             M

** Controls
local Xcontrol                       CAPI Male Age Age_sq momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni momAgeBirth dadAgeBirth ///missing cat: low edu
                                     dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni ///missing cat: low edu
                                     momBornProvince dadBornProvince cgRelig houseOwn cgReddito_2 cgReddito_3 cgReddito_4 cgReddito_5 cgReddito_6 cgReddito_7 /// missing cat: income below 5,000
									 Cohort_Adult40 Cohort_Adult50
local Xright                    	 `Xcontrol' Postal_* 
local Xleft                          lowbirthweight birthpremature
local Xadultint					 	 adt_x*	// interaction between (Cohort_Adult40 + Cohort_Adult50) and xm* xa*
local xmaterna                       xm*
local xasilo                         xa*

local main_name                      Control 1
local inter_name                     Control 2
local right_name                     Control 3
local all_name                       Control 4

** Variable labels
label var ReggioMaterna         "RCH preschool"
label var ReggioAsilo           "RCH infant-toddler"

label var CAPI                  "CAPI"
label var Cohort_Adult30        "30 year olds"
label var Cohort_Adult40        "40 year olds"
label var Male                  "Male dummy"
label var asilo_Attend          "Any infant-toddler center"
label var asilo_Municipal       "Municipal infant-toddler center"
label var materna_Municipal     "Municipal preschool"
label var materna_Religious     "Religious preschool"
label var materna_State         "State preschool"
label var materna_Private       "Private preschool"

label var cgPA_HouseWife        "Caregiver Housewife"
label var dadPA_Unempl          "Father Unemployed" 
label var cgmStatus_div         "Caregiver Divorced"
label var momHome06             "Mom Home at 6"
label var numSiblings           "Num. Siblings"
label var childrenSibTot        "Num. Siblings"
label var houseOwn              "Own Home"
label var MaxEdu_Uni            "University"

label var momBornProvince       "Mom born in the province"
label var dadBornProvince       "Dad born in the province"


label var SDQ_score             "SDQ score (self rep.)"
label var childSDQ_score        "SDQ score (mom rep.)"
label var Depression_score      "Depression score (CESD)"
label var HealthPerc            "Respondent health is good (%)"
label var childHealthPerc       "Child health is good (%) - mom report"
label var MigrTaste_cat         "Bothered by migrants (%)"

label var Age                   "Age"
label var Age_sq                "Age sq."
label var lowbirthweight        "Low birthweight"
label var birthpremature        "Premature"


* ---------------------------------------------------------------------------- *
** Dummy variables for zipcode fixed effects
tabulate Postal, gen(Postal_)

** Dummy variables for categories in Month_int
gen Month_int = mofd(Date_int)
dummieslab Month_int // install dummislab command if you haven't already

** Dummy variables for categories in IncomeCat_manual 
tab IncomeCat_manual, miss gen(Reddito_)
rename Reddito_8 Reddito_miss  
label var Reddito_1           "Income below 5k eur"
label var Reddito_2           "Income 5k-10k eur"
label var Reddito_3           "Income 10k-25k eur"
label var Reddito_4           "Income 25k-50k eur"
label var Reddito_5           "Income 50k-100k eur"
label var Reddito_6           "Income 100k-250k eur"
label var Reddito_7           "Income more 250k eur"

** Dummy variables for categories in cgIncomeCat_manual
tab cgIncomeCat_manual, miss gen(cgReddito_)
gen cgReddito_miss = (cgIncomeCat_manual >= .) 
drop cgReddito_8 cgReddito_9
label var cgReddito_1           "Income below 5k eur"
label var cgReddito_2           "Income 5k-10k eur"
label var cgReddito_3           "Income 10k-25k eur"
label var cgReddito_4           "Income 25k-50k eur"
label var cgReddito_5           "Income 50k-100k eur"
label var cgReddito_6           "Income 100k-250k eur"
label var cgReddito_7           "Income more 250k eur"

** Replace caregiver religiosity with mother's religiosity for adults
replace cgRelig = momRelig if Cohort>=4 & momRelig<.
replace cgRelig = dadRelig if Cohort>=4 & (momRelig>=. & dadRelig<.)

replace houseOwn = 0 if Cohort>=4 //it's endogenous for adults, replace it with no-variation so that it will be dropped

* Dummy for Cohort_Adult50
generate Cohort_Adult50 = (Cohort == 6)

* Regression on STATA does not work if all the variables are missing. "lowbirthweight birthpremature momAgeBirth" do not exist for Adults. Fill the values out as 0.
foreach var in lowbirthweight birthpremature momAgeBirth dadAgeBirth {
	replace `var' = 0 if (Cohort == 4 | Cohort == 5 | Cohort == 6) & (`var' == .)
}

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
	 gen xa`city'Some = (xa`city'Reli==1 | xa`city'Stat==1 | xa`city'Priv==1)
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
	 gen xm`city'Some = (xm`city'Reli==1 | xm`city'Stat==1 | xm`city'Priv==1)
         local city_val = `city_val' + 1
}

* ---------------------------------------------------------------------------- *
* Create interactions of schooltype, city, and cohort
rename Cohort_Children 		Cohort_Child
rename Cohort_Adolescents	Cohort_Adol
//generate Cohort_Adult50 = (Cohort == 6)

foreach age in xa xm {
	foreach city in `cities' {
		foreach type in `school_types' {
			foreach cohort in Child Adol Adult30 Adult40 Adult50 {
				generate `age'`city'`type'`cohort' = Cohort_`cohort'*`age'`city'`type'
				label var `age'`city'`type'`cohort' "`city' `type' * `cohort'"
			}
		}
	}
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

foreach var in momBornProvince dadBornProvince cgRelig houseOwn lowbirthweight birthpremature{
         gen `var'_miss = (`var' >= .)
         replace `var' = 0 if `var'_miss == 1
}

* ---------------------------------------------------------------------------- *
* Create ParmaAsilo, ParmaMaterna, PadovaAsilo, PadovaMaterna (not created by the cleaning do files.)

gen ParmaAsilo   = (City == 2 & asiloType == 1) if asiloType < .  
gen ParmaMaterna = (City == 2 & maternaType == 1) if maternaType < . 
replace ParmaMaterna = 0 if maternaComment == "Living in Parma, attended school in Reggio" & maternaType == 1 // There are 16 people from Parma gone to Reggio Children

gen PadovaAsilo   = (City == 3 & asiloType == 1) if asiloType < .  
gen PadovaMaterna = (City == 3 & maternaType == 1) if maternaType < .

* ---------------------------------------------------------------------------- *
* Pooled Regression Analysis
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

