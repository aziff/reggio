* ---------------------------------------------------------------------------- *
* Prepare Data for Analysis
* Run this code before other analysis .do-files
* Contributors:                      Pietro Biroli, Chiara Pronzato, 
*                                    Jessica Yu Kyung Koh, Anna Ziff
* Original version: Modified from 12/11/15
* Current version:  04/05/16
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
local cities                          Reggio Parma Padova
local school_types                    None Muni Stat Reli Priv
local school_age_types                Asilo Materna
local cohorts                         Child Adol Adult // Adult30 Adult40 Adult50 
local cohorts_new					  Child Migr Adol Adult30 Adult40 Adult50

local Asilo_name                      Infant-Toddler Center
local Materna_name                    Preschool

** Outcomes
//local outcomes                        childSDQ_score SDQ_score Depression_score HealthPerc childHealthPerc MigrTaste_cat  
local outChild                        childSDQ_score childHealthPerc likeSchool likeMath likeLit difficultiesSit difficultiesInterest difficultiesObey difficultiesEat difficulties
local outAdol                         childSDQ_score SDQ_score Depression_score HealthPerc childHealthPerc MigrTaste_cat likeSchool likeMath likeLit difficultiesSit difficultiesInterest difficultiesObey difficultiesEat difficulties
local outAdult                        Depression_score HealthPerc MigrTaste_cat

local outChildAdol                    childSDQ_score childHealthPerc
local outAdolAdult                    Depression_score HealthPerc MigrTaste_cat

local childSDQ_score_name             Child SDQ Score
local SDQ_score_name                  SDQ Score
local Depression_score_name           Depression Score
local HealthPerc_name                 Health Perception
local childHealthPerc_name            Child Health Perception
local MigrTaste_cat_name              Migration Taste // these are for titles in graphs.
local likeSchool_name                 Like school
local likeMath_name                   Like math
local likeLit_name                    Like reading
local difficultiesSit_name            Diff. sitting
local difficultiesInterest_name       Diff. keep focus
local difficultiesObey_name           Diff. obey
local difficultiesEat_name            Diff. eat
local difficulties_name               Any diff.

** Abbreviations for outcomes
local childSDQ_score_short            CS
local SDQ_score_short                 S
local childHealthPerc_short           CH
local HealthPerc_short                H
local Depression_score_short          D
local MigrTaste_cat_short             M
local likeSchool_short                LS
local likeMath_short                  LM
local likeLit_short                   LL
local difficultiesSit_short           DS
local difficultiesInterest_short      DI
local difficultiesObey_short          DO
local difficultiesEat_short           DE
local difficulties_short              DIFF

** Controls
local Xcontrol                       CAPI Male Age Age_sq momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni momAgeBirth dadAgeBirth ///missing cat: low edu
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

** Instruments
local potentialIV                    distAsilo*1 distAsilo*2 distMaterna*1 distMaterna*2 ///
                                     score score2 grand_city lone_parent numSibling 

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
* Create some variables for the regressions (maybe some of this should be in the cleaning do files)
* ---------------------------------------------------------------------------- *
* Create ParmaAsilo, ParmaMaterna, PadovaAsilo, PadovaMaterna

gen ParmaAsilo   = (City == 2 & asiloType == 1) if asiloType < .  
gen ParmaMaterna = (City == 2 & maternaType == 1) if maternaType < . 
replace ParmaMaterna = 0 if maternaComment == "Living in Parma, attended school in Reggio" & maternaType == 1 // There are 16 people from Parma gone to Reggio Children

gen PadovaAsilo   = (City == 3 & asiloType == 1) if asiloType < .  
gen PadovaMaterna = (City == 3 & maternaType == 1) if maternaType < .

** For convenience, group all adults into a same cohort
generate Cohort_new = 0
replace Cohort_new = 1 if Cohort == 1 // children
replace Cohort_new = 2 if Cohort == 3 // adolescents
replace Cohort_new = 3 if Cohort == 4 | Cohort == 5 | Cohort == 6 // adults

** Comparison groups used in the regression
gen asiloG1 = (ReggioAsilo==0) if Reggio==1 & ReggioAsilo<.
gen asiloG2 = (Parma==1 | Padova==1)
replace asiloG2 = . if (Reggio==1 & ReggioAsilo==0) & ReggioAsilo<.
gen asiloG3 = (ReggioAsilo==0) if ReggioAsilo<.
label var asiloG1 "asilo group 1 (other Reggio)"
label var asiloG2 "asilo group 2 (Parma Padova)"
label var asiloG3 "asilo group 3 (all but RCA)"
tab asiloG1 asiloG2, miss
tab asiloG1 asiloG3, miss
tab asiloG2 asiloG3, miss

gen maternaG1 = (ReggioMaterna==0) if Reggio==1 & ReggioMaterna<.
gen maternaG2 = (Parma==1 | Padova==1)
replace maternaG2 = . if (Reggio==1 & ReggioMaterna==0) & ReggioMaterna<.
gen maternaG3 = (ReggioMaterna==0) if ReggioMaterna<.
label var maternaG1 "materna group 1 (other Reggio)"
label var maternaG2 "materna group 2 (Parma Padova)"
label var maternaG3 "materna group 3 (all but RCA)"
tab maternaG1 maternaG2, miss
tab maternaG1 maternaG3, miss
tab maternaG2 maternaG3, miss

gen asiloG_1_2 = asiloG1
replace asiloG_1_2 = 2 if (asiloG2==1)
gen maternaG_1_2 = maternaG1
replace maternaG_1_2 = 2 if (maternaG2==1)

label define G_1_2 0 "RCA" 1 "Reggio other" 2 "Parma Padova"
label values asiloG_1_2 maternaG_1_2 G_1_2

*** Reggio score
sum score
sum score if(Reggio == 1)
gen score2 = score^2
gen low_score = (score <= 19)
gen med_score = (score > 19 & score <= 24.5)

*** distance from nido 
sum distAsiloMunicipal1
gen dist175m = (distAsiloMunicipal1<= .175)

*** Siblings
capture drop otherSib
tab childrenSibTot if Cohort>3
tab numSiblings if Cohort<3
gen otherSib = (numSibling>0) if numSibling<.
replace otherSib = 1 if childrenSibTot>0 & childrenSibTot<.
replace otherSib = 0 if otherSib == . 
tab Cohort otherSib, row

* ---------------------------------------------------------------------------- *
** Dummy variables for zipcode fixed effects
dummieslab Postal
//drop one big postal code for each city to avoid multicollinearity
tab Postal if City==1
tab Postal if City==2
tab Postal if City==3

drop Postal_42123 Postal_43123 Postal_35129
//small Postal codes: drop Postal_22 Postal_2 Postal_10 Postal_18 Postal_27 Postal_1 Postal_16 Postal_19 Postal_3 Postal_17 Postal_12 Postal_4 Postal_28  

** Dummy variables for categories in Month_int
gen Month_int = mofd(Date_int)
dummieslab Month_int // install dummislab command if you haven't already

** Dummy variables for categories in IncomeCat_manual 
tab IncomeCat_manual, miss gen(Reddito_)
rename Reddito_8 Reddito_miss  
gen Reddito_low = (Reddito_1==1 | Reddito_2==1)
label var Reddito_low         "Income below 10k eur"
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
gen cgReddito_low = (cgReddito_1==1 | cgReddito_2==1)
label var cgReddito_low         "Income below 10k eur"
label var cgReddito_1           "Income below 5k eur"
label var cgReddito_2           "Income 5k-10k eur"
label var cgReddito_3           "Income 10k-25k eur"
label var cgReddito_4           "Income 25k-50k eur"
label var cgReddito_5           "Income 50k-100k eur"
label var cgReddito_6           "Income 100k-250k eur"
label var cgReddito_7           "Income more 250k eur"

** Replacing to make adults and younger cohorts similar
*caregiver religiosity with mother's religiosity for adults
replace cgRelig = momRelig if Cohort>=4 & momRelig<.
replace cgRelig = dadRelig if Cohort>=4 & (momRelig>=. & dadRelig<.)
replace numSibling = childrenSibTot if numSibling>=. 

replace houseOwn = 0 if Cohort>=4 //it's endogenous for adults, replace it with no-variation so that it will be dropped

* Dummy for Cohort_Adult50
generate Cohort_Adult   = (Cohort >= 4) if Cohort<.
generate Cohort_Adult50 = (Cohort == 6) if Cohort<.

generate Cohort_ChildAdol = (Cohort == 1 | Cohort == 3) if Cohort<.
generate Cohort_AdolAdult = (Cohort >= 3) if Cohort<.

* Rename Child and Adol Cohorts (to make it easier to loop over)
rename Cohort_Children         Cohort_Child
rename Cohort_Adolescents      Cohort_Adol

* Regression on STATA does not work if all the variables are missing. "lowbirthweight birthpremature momAgeBirth" do not exist for Adults. Fill the values out as 0.
foreach var in lowbirthweight birthpremature momAgeBirth dadAgeBirth {
      replace `var' = 0 if (Cohort == 4 | Cohort == 5 | Cohort == 6) & (`var' == .)
}

* ---------------------------------------------------------------------------- *
* Create the triple interactions of schooltype, city, and cohort
** For Asilo (Age 0-3)

local city_val = 1
foreach city in `cities' {
      local asilo_val = 0
      foreach type in `school_types' {
            generate xa`city'`type' = (asiloType == `asilo_val' & City == `city_val') if asiloType < .
            label var xa`city'`type' "`city' `type' ITC"
			local cohort_val = 1
            foreach cohort in `cohorts_new' {
                    qui generate xa`city'`type'`cohort' = (asiloType == `asilo_val' & City == `city_val' & Cohort == `cohort_val') if asiloType < .
                    label var xa`city'`type'`cohort' "`city' `type' ITC, `cohort'"
					local cohort_val = `cohort_val' + 1
            }
            local asilo_val = `asilo_val' + 1
      }
      **combine non-municipal schools into "Some"
 /*     gen xa`city'Some = (xa`city'Reli==1 | xa`city'Stat==1 | xa`city'Priv==1)
      label var xa`city'Some "`city' other ITC"
      foreach cohort in `cohorts' {
          gen xa`city'Some`cohort'  = (xa`city'Reli`cohort' ==1 | xa`city'Stat`cohort' ==1 | xa`city'Priv`cohort' ==1) if asiloType < .
          label var xa`city'Some`cohort' "`city' other ITC, `cohort'"
      } */
      local city_val = `city_val' + 1
}
* checks
/*
tab Cohort xaReggioSomeChild, miss
tab City xaReggioSomeChild, miss
tab asiloType xaReggioSomeChild if Cohort==1 & Reggio==1, miss */

** For Materna (Age 3-6)
local city_val = 1

foreach city in `cities' {
      local materna_val = 0
      foreach type in `school_types' {
            generate xm`city'`type' = (maternaType == `materna_val' & City == `city_val') if maternaType < .
            label var xm`city'`type' "`city' `type' Preschool"
			local cohort_val = 1
            foreach cohort in `cohorts_new' {
                        generate xm`city'`type'`cohort' = (maternaType == `materna_val' & City == `city_val' & Cohort == `cohort_val') if maternaType < .
                        label var xm`city'`type'`cohort' "`city' `type' preschool, `cohort'"
						local cohort_val = `cohort_val' + 1
            }
            local materna_val = `materna_val' + 1
      }       
      **combine non-municipal schools into "Some"
	  /*
      gen xm`city'Some = (xm`city'Reli==1 | xm`city'Stat==1 | xm`city'Priv==1)
      label var xm`city'Some "`city' other preschool"
      foreach cohort in `cohorts' {
          gen xm`city'Some`cohort'  = (xm`city'Reli`cohort' ==1 | xm`city'Stat`cohort' ==1 | xm`city'Priv`cohort' ==1) if maternaType < .
          label var xm`city'Some`cohort' "`city' other preschool, `cohort'"
      } */
      local city_val = `city_val' + 1
}
* checks
/*
tab Cohort      xmReggioSomeChild, miss
tab City        xmReggioSomeChild, miss
tab maternaType xmReggioSomeChild if Cohort==1 & Reggio==1, miss
*/

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
* Generate variables that interact all controls and instruments with city dummies and cohort dummies
** Controls (city and cohort dummies)
foreach var of varlist `Xcontrol' `potentialIV'{
      di "`var'"

      foreach cohort in `cohorts' {
           capture generate `var'_`cohort' = `var'*Cohort_`cohort'
      }

      foreach city in `cities' {
      capture generate `var'_`city' = `var'*`city'
            foreach cohort in `cohorts' {
                capture generate `var'_`city'_`cohort' = `var'_`city'*Cohort_`cohort'
            }
      }
}

* ---------------------------------------------------------------------------- *
* Locals for the pooled variables
** Controls
*** Xright for Parma and its cohorts

foreach city in `cities' {
    local Xright_`city'     Male_`city' momMaxEdu_*_`city' dadMaxEdu_*_`city' CAPI_`city' momAgeBirth_`city' dadAgeBirth_`city' ///
                            momBornProvince_`city' dadBornProvince_`city' cgRelig_`city' houseOwn_`city' ///
                            cgReddito_*_`city' Age_`city' Age_sq_`city' /*Cohort_Adult40_`city' Cohort_Adult50_`city'*/                                    
    foreach cohort in `cohorts' {
        local Xright_`cohort'   Male_`cohort' momMaxEdu_*_`cohort' dadMaxEdu_*_`cohort' CAPI_`cohort' momAgeBirth_`cohort' dadAgeBirth_`cohort' ///
                                momBornProvince_`cohort' dadBornProvince_`cohort' cgRelig_`cohort' houseOwn_`cohort' ///
                                cgReddito_*_`cohort' Age_`cohort' Age_sq_`cohort'

        local Xright_`city'_`cohort' Male_`city'_`cohort' momMaxEdu_*_`city'_`cohort' dadMaxEdu_*_`city'_`cohort' CAPI_`city'_`cohort' momAgeBirth_`city'_`cohort' dadAgeBirth_`city'_`cohort' ///
                                     momBornProvince_`city'_`cohort' dadBornProvince_`city'_`cohort' cgRelig_`city'_`cohort' houseOwn_`city'_`cohort' ///
                                     cgReddito_*_`city'_`cohort' Age_`city'_`cohort' Age_sq_`city'_`cohort'
        di "`Xright_`city'_`cohort''" // to check if the loop goes over right
    }
}

global fullX `Xright' `Xleft' `Xright_Parma' `Xright_Padova' `Xleft_Parma' `Xleft_Padova'
global someX `Xright' `Xleft' 

/*
sum `Xright_Parma_Adol'
sum `Xright_Adol'
*/
