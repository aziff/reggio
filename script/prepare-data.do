* ---------------------------------------------------------------------------- *
* Prepare Data for Analysis
* Run this code before other analysis .do-files
* Contributors:                      Pietro Biroli, Chiara Pronzato, 
*                                    Jessica Yu Kyung Koh, Anna Ziff
* Original version: Modified from 12/11/15
* Current version:  08/24/16
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

cd "$data_reggio"

use Reggio, clear

//cd ${klmReggio}/Analysis/Output/
* ---------------------------------------------------------------------------- *
* Create locals and label variables
** Categories
local cities                          Reggio Parma Padova
local school_types                    None Muni Stat Reli Priv
local school_age_types                Asilo Materna
local cohorts                         Child Migrants Adol Adult30 Adult40 Adult50 

local Asilo_name                      Infant-Toddler Center
local Materna_name                    Preschool

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
** Create dummy for school types
generate maternaNone = (maternaType == 0)
generate maternaMuni = (maternaType == 1)
generate maternaStat = (maternaType == 2)
generate maternaReli = (maternaType == 3)
generate maternaPriv = (maternaType == 4)
generate maternaYes = (maternaType != 0) // For those who attended any type of preschool

** Create interaction terms between school type and adult age cohort (except maternaMuni and age 50)
foreach type in None Muni Stat Reli Priv Yes {
	foreach age in Adult30 Adult40 Adult50 {
		generate xm`type'`age' = materna`type' * Cohort_`age'
	}
}

** Create interaction terms between school type and city (except Reggio and maternaMuni)
foreach type in None Muni Stat Reli Priv Yes {
	foreach city in Parma Padova Reggio {
		generate xm`type'`city' = materna`type' * `city'
	}
}


* ---------------------------------------------------------------------------- *
* Add variables that researchers are specifically interested in

*-* Adding variables
// married and cohabiting
gen mStatus_married_cohab = (mStatus_married == 1) | (mStatus_cohab == 1)
lab var mStatus_married_cohab "Married or cohabitating indicator"

// risk factors
gen i_RiskDUI = (RiskDUI > 1) if RiskDUI < .
lab var i_RiskDUI "Drove under the influence at least once"
gen i_RiskFight = (RiskFight > 1) if  RiskFight < .
lab var i_RiskFight "Engaged in a fight at least once"

// cigarettes
replace Smoke = 1 if Cig > 0
replace Cig = 0 if Smoke == 0

// alcohol
replace Drink = 1 if DrinkNum > 0
replace DrinkNum = 0 if Drink == 0

// reciprocity
lab var reciprocity1bin "If someone does me a favor, I am prepared to return it"
lab var reciprocity2bin "If someone puts me in a difficult situation, I will do the same to him/her"
lab var reciprocity3bin "I go out of my way to help somebody who has been kind to me before"
lab var reciprocity4bin "If somebody insults me, I will insult him/her back"

// opinons on work
gen r_StressWork = StressWork
recode r_StressWork (0=1) (1=0)
lab var r_StressWork "Work is not a source of stress"

gen binTimeWork = (TimeWork == 1)
lab var binTimeWork "Statisfied with amount of work or study"

// house is owned
gen all_houseOwn = (house < 3 & house != .)

// live with parent
gen live_parent = .
forvalues i = 1/10 {
	replace live_parent = 1 if Relation`i' > 6 & Relation`i' < 11 & Cohort > 3
}
replace live_parent = 0 if live_parent == . & Cohort > 3
lab var live_parent "Adult lives with at least one parent"


/* Baseline Variables */

// number of sibling dummies
gen numSibling_0 = (numSiblings == 0)
label var numSibling_0 "Number of sibling is 0"
gen numSibling_1 = (numSiblings == 1)
label var numSibling_1 "Number of sibling is 1"
gen numSibling_2 = (numSiblings == 2)
label var numSibling_2 "Number of sibling is 2"
gen numSibling_more = (numSiblings >= 3)
label var numSibling_more "Number of sibling is more than 3"

// teenage birth dummies
gen teenMomBirth = (momAgeBirth < 20)
label var teenMomBirth "Mother was a teenager at birth"
gen teenDadBirth = (dadAgeBirth < 20)
label var teenDadBirth "Father was a teenager at birth"

// Caregiver Faith 
label define cgfaith_lab 1 "Not at all religious" 2 "Little religious" 3 "Spiritual but not religious" 4 "Enough religious" 5 "Very religious"
label values cgFaith cgfaith_lab

// Catholic dummy
gen cgCatholic = (cgReligType == 1)
label var cgCatholic "Caregiver is Catholic"

// Interaction between being Catolic and level of religiousness
sum cgFaith, detail
gen cgFaithful = (cgFaith > 3)
gen int_cgCatFaith = cgFaithful * cgCatholic
label var int_cgCatFaith "Caregiver is Catholic and very faithful"

// Recode Health
gen goodHealth = 6 - Health

// Relabel parental education variables
* label define maxedu_lab 1 "Junior high school" 2 "Two years high school" 3 "Four or five years high school" 4 "University degree (4 years?)" 5 "Three year degree" 6 "Five year degree" 7 "Master degree (5 years including college?)" 8 "Master postgraduate" 9 "PhD"
label define maxedu_lab 1 "Junior HS" 2 "2Y HS" 3 "4-5Y HS" 4 "Univ." 5 "3Y Degree" 6 "5Y Degree" 7 "Master" 8 "Master+" 9 "PhD"
label values MaxEdu maxedu_lab

// Create parental years of education variable (SEE YKK's DOCUMENTATION)
gen momYearsEdu = .
replace momYearsEdu = 8 if momMaxEdu == 1
replace momYearsEdu = 10 if momMaxEdu == 2
replace momYearsEdu = 12 if momMaxEdu == 3
replace momYearsEdu = 16 if momMaxEdu == 4
replace momYearsEdu = 15 if momMaxEdu == 5
replace momYearsEdu = 17 if momMaxEdu == 6
replace momYearsEdu = 17 if momMaxEdu == 7
replace momYearsEdu = 19 if momMaxEdu == 8
replace momYearsEdu = 23 if momMaxEdu == 9
label var momYearsEdu "Mother: years of education"

gen dadYearsEdu = .
replace dadYearsEdu = 8 if dadMaxEdu == 1
replace dadYearsEdu = 10 if dadMaxEdu == 2
replace dadYearsEdu = 12 if dadMaxEdu == 3
replace dadYearsEdu = 16 if dadMaxEdu == 4
replace dadYearsEdu = 15 if dadMaxEdu == 5
replace dadYearsEdu = 17 if dadMaxEdu == 6
replace dadYearsEdu = 17 if dadMaxEdu == 7
replace dadYearsEdu = 19 if dadMaxEdu == 8
replace dadYearsEdu = 23 if dadMaxEdu == 9
label var dadYearsEdu "Father: years of education"

// Create actual value of family income variable
gen cgFamIncome_val = .
replace cgFamIncome_val = 2500 if cgIncomeCat == 1
replace cgFamIncome_val = 7500 if cgIncomeCat == 2
replace cgFamIncome_val = 17500 if cgIncomeCat == 3
replace cgFamIncome_val = 37500 if cgIncomeCat == 4
replace cgFamIncome_val = 75000 if cgIncomeCat == 5
replace cgFamIncome_val = 175000 if cgIncomeCat == 6
replace cgFamIncome_val = 375000 if cgIncomeCat == 7
label var cgFamIncome_val "Baseline family income"

// Create caregiver married and cohabiting variable
gen cgmStatus_married_cohab = (cgmStatus == 1) | (cgmStatus == 6)
lab var cgmStatus_married_cohab "Caregiver: married or cohabitating"

// Create more exact hourse worked variable (If cgSES == "Never Worked", then replace cgHrsTot = 0)
replace cgHrsTot = 0 if cgSES == 0
lab var cgHrsTot "Caregiver: hours of work per week"

// Relabel High School Type
label define hsType_lab 1 "Classic high school" 2 "Science high school" 3 "Language high school" 4 "Art, music, or choir school" 5 "Institute for socio-psycho-pedagogy" 6 "Conservatory" ///
						7 "Technical Institute (surveyor, accountancy, industrial etc.)" 8 "Professional (chemical, clectronic, etc.)" 9 "Art institute" 10 "Other"
label values highschoolType hsType_lab

// create satisfaction with family vars for adult and child that are roughly comparable

gen satFamily = 0 if faceFamily<. | SatisFamily<.
replace satFamily = 1 if faceFamily >= 7 & Cohort <3
replace satFamily = 1 if SatisFamily >= 4 & Cohort >=3

gen unsatFamily = 0 if faceFamily<. | SatisFamily<.
replace unsatFamily = 1 if faceFamily <= 3 & Cohort <3
replace unsatFamily = 1 if SatisFamily <= 2 & Cohort >=3

gen satneutralFamily = 0 if faceFamily<. | SatisFamily<.
replace satneutralFamily = 1 if faceFamily >3 & faceFamily<7 & Cohort <3
replace satneutralFamily = 1 if SatisFamily == 3 & Cohort >=3

// create perception of health during childhood vars that are roughly comparable across adults and children

gen C_A_HealthGood = 0 if childHealth<.|Health16<.
replace C_A_HealthGood = 1 if childHealth <= 2 & Cohort <3
replace C_A_HealthGood = 1 if Health16 <= 2 & Cohort >=3

gen C_A_HealthBad = 0 if childHealth<.|Health16<.
replace C_A_HealthBad = 1 if childHealth >= 4 & Cohort <3
replace C_A_HealthBad = 1 if Health16 >= 4 & Cohort >=3

gen C_A_HealthAvg = 0 if childHealth<.|Health16<.
replace C_A_HealthAvg = 1 if childHealth == 3 & Cohort <3
replace C_A_HealthAvg = 1 if Health16 == 3 & Cohort >=3



// Create BMI variable

gen BMI_obese = 0

* replace BMI for obese adults
replace BMI_obese = 1 if BMI>30 & Age>=20

* replace BMI for obese male children
replace BMI_obese = 1 if childBMI >= 19.2789 & Male == 1 & Age >=2 & Age< 3
replace BMI_obese = 1 if childBMI >= 18.23842 & Male == 1 & Age >=3 & Age< 4
replace BMI_obese = 1 if childBMI >= 17.83614 & Male == 1 & Age >=4 & Age< 5
replace BMI_obese = 1 if childBMI >= 17.93893 & Male == 1 & Age >=5 & Age< 6
replace BMI_obese = 1 if childBMI >= 18.41421 & Male == 1 & Age >=6 & Age< 7
replace BMI_obese = 1 if childBMI >= 19.15236 & Male == 1 & Age >=7 & Age< 8
replace BMI_obese = 1 if childBMI >= 20.06793 & Male == 1 & Age >=8 & Age< 9
replace BMI_obese = 1 if childBMI >= 21.08893 & Male == 1 & Age >=9 & Age< 10
replace BMI_obese = 1 if childBMI >= 22.15409 & Male == 1 & Age >=10 & Age< 11
replace BMI_obese = 1 if childBMI >= 23.21358 & Male == 1 & Age >=11 & Age< 12
replace BMI_obese = 1 if childBMI >= 24.22985 & Male == 1 & Age >=12 & Age< 13
replace BMI_obese = 1 if childBMI >= 25.17811 & Male == 1 & Age >=13 & Age< 14
replace BMI_obese = 1 if childBMI >= 26.04662 & Male == 1 & Age >=14 & Age< 15
replace BMI_obese = 1 if childBMI >= 26.83688 & Male == 1 & Age >=15 & Age< 16
replace BMI_obese = 1 if childBMI >= 27.56393 & Male == 1 & Age >=16 & Age< 17
replace BMI_obese = 1 if childBMI >= 28.25676 & Male == 1 & Age >=17 & Age< 18
replace BMI_obese = 1 if childBMI >= 28.95862 & Male == 1 & Age >=18 & Age< 19
replace BMI_obese = 1 if childBMI >= 29.72674 & Male == 1 & Age >=19 & Age< 20

* replace BMI for obese female children
replace BMI_obese = 1 if childBMI >= 19.05824 & Male == 0 & Age >=2 & Age< 3
replace BMI_obese = 1 if childBMI >= 18.25475 & Male == 0 & Age >=3 & Age< 4
replace BMI_obese = 1 if childBMI >= 18.02851 & Male == 0 & Age >=4 & Age< 5
replace BMI_obese = 1 if childBMI >= 18.25738 & Male == 0 & Age >=5 & Age< 6
replace BMI_obese = 1 if childBMI >= 18.83778 & Male == 0 & Age >=6 & Age< 7
replace BMI_obese = 1 if childBMI >= 19.67794 & Male == 0 & Age >=7 & Age< 8
replace BMI_obese = 1 if childBMI >= 20.69525 & Male == 0 & Age >=8 & Age< 9
replace BMI_obese = 1 if childBMI >= 21.81725 & Male == 0 & Age >=9 & Age< 10
replace BMI_obese = 1 if childBMI >= 22.98258 & Male == 0 & Age >=10 & Age< 11
replace BMI_obese = 1 if childBMI >= 24.14141 & Male == 0 & Age >=11 & Age< 12
replace BMI_obese = 1 if childBMI >= 25.25564 & Male == 0 & Age >=12 & Age< 13
replace BMI_obese = 1 if childBMI >= 26.2988 & Male == 0 & Age >=13 & Age< 14
replace BMI_obese = 1 if childBMI >= 27.25597 & Male == 0 & Age >=14 & Age< 15
replace BMI_obese = 1 if childBMI >= 28.12369 & Male == 0 & Age >=15 & Age< 16
replace BMI_obese = 1 if childBMI >= 28.90981 & Male == 0 & Age >=16 & Age< 17
replace BMI_obese = 1 if childBMI >= 29.6335 & Male == 0 & Age >=17 & Age< 18
replace BMI_obese = 1 if childBMI >= 30.32554 & Male == 0 & Age >=18 & Age< 19
replace BMI_obese = 1 if childBMI >= 31.0288 & Male == 0 & Age >=19 & Age< 20


gen BMI_overweight = 0

* replace BMI for overweight  adults
replace BMI_overweight = 1 if BMI >=25 & BMI<=29.9 & Age>=20

* replace BMI for overweight male children
replace BMI_overweight = 1 if childBMI >= 18.11955 & childBMI < 19.2789 & Male == 1 & Age >=2 & Age< 3
replace BMI_overweight = 1 if childBMI >= 17.32627 & childBMI < 18.23842 & Male == 1 & Age >=3 & Age< 4
replace BMI_overweight = 1 if childBMI >= 16.92501 & childBMI < 17.83614 & Male == 1 & Age >=4 & Age< 5
replace BMI_overweight = 1 if childBMI >= 16.84076 & childBMI < 17.93893 & Male == 1 & Age >=5 & Age< 6
replace BMI_overweight = 1 if childBMI >= 17.01418 & childBMI < 18.41421 & Male == 1 & Age >=6 & Age< 7
replace BMI_overweight = 1 if childBMI >= 17.40122 & childBMI < 19.15236 & Male == 1 & Age >=7 & Age< 8
replace BMI_overweight = 1 if childBMI >= 17.95575 & childBMI < 20.06793 & Male == 1 & Age >=8 & Age< 9
replace BMI_overweight = 1 if childBMI >= 18.63222 & childBMI < 21.08893 & Male == 1 & Age >=9 & Age< 10
replace BMI_overweight = 1 if childBMI >= 19.39041 & childBMI < 22.15409 & Male == 1 & Age >=10 & Age< 11
replace BMI_overweight = 1 if childBMI >= 20.19667 & childBMI < 23.21358 & Male == 1 & Age >=11 & Age< 12
replace BMI_overweight = 1 if childBMI >= 21.02386 & childBMI < 24.22985 & Male == 1 & Age >=12 & Age< 13
replace BMI_overweight = 1 if childBMI >= 21.85104 & childBMI < 25.17811 & Male == 1 & Age >=13 & Age< 14
replace BMI_overweight = 1 if childBMI >= 22.66325 & childBMI < 26.04662 & Male == 1 & Age >=14 & Age< 15
replace BMI_overweight = 1 if childBMI >= 23.45117 & childBMI < 26.83688 & Male == 1 & Age >=15 & Age< 16
replace BMI_overweight = 1 if childBMI >= 24.21087 & childBMI < 27.56393 & Male == 1 & Age >=16 & Age< 17
replace BMI_overweight = 1 if childBMI >= 24.94362 & childBMI < 28.25676 & Male == 1 & Age >=17 & Age< 18
replace BMI_overweight = 1 if childBMI >= 25.65601 & childBMI < 28.95862 & Male == 1 & Age >=18 & Age< 19
replace BMI_overweight = 1 if childBMI >= 26.36054 & childBMI < 29.72674 & Male == 1 & Age >=19 & Age< 20

* replace BMI for overweight female children
replace BMI_overweight = 1 if childBMI >= 17.97371 & childBMI < 19.05824 & Male == 0 & Age >=2 & Age< 3
replace BMI_overweight = 1 if childBMI >= 17.16634 & childBMI < 18.25475 & Male == 0 & Age >=3 & Age< 4
replace BMI_overweight = 1 if childBMI >= 16.80058 & childBMI < 18.02851 & Male == 0 & Age >=4 & Age< 5
replace BMI_overweight = 1 if childBMI >= 16.80197 & childBMI < 18.25738 & Male == 0 & Age >=5 & Age< 6
replace BMI_overweight = 1 if childBMI >= 17.09974 & childBMI < 18.83778 & Male == 0 & Age >=6 & Age< 7
replace BMI_overweight = 1 if childBMI >= 17.62557 & childBMI < 19.67794 & Male == 0 & Age >=7 & Age< 8
replace BMI_overweight = 1 if childBMI >= 18.31718 & childBMI < 20.69525 & Male == 0 & Age >=8 & Age< 9
replace BMI_overweight = 1 if childBMI >= 19.11937 & childBMI < 21.81725 & Male == 0 & Age >=9 & Age< 10
replace BMI_overweight = 1 if childBMI >= 19.984 & childBMI < 22.98258 & Male == 0 & Age >=10 & Age< 11
replace BMI_overweight = 1 if childBMI >= 20.86984 & childBMI < 24.14141 & Male == 0 & Age >=11 & Age< 12
replace BMI_overweight = 1 if childBMI >= 21.74263 & childBMI < 25.25564 & Male == 0 & Age >=12 & Age< 13
replace BMI_overweight = 1 if childBMI >= 22.57506 & childBMI < 26.2988 & Male == 0 & Age >=13 & Age< 14
replace BMI_overweight = 1 if childBMI >= 23.34689 & childBMI < 27.25597 & Male == 0 & Age >=14 & Age< 15
replace BMI_overweight = 1 if childBMI >= 24.04503 & childBMI < 28.12369 & Male == 0 & Age >=15 & Age< 16
replace BMI_overweight = 1 if childBMI >= 24.66372 & childBMI < 28.90981 & Male == 0 & Age >=16 & Age< 17
replace BMI_overweight = 1 if childBMI >= 25.20482 & childBMI < 29.6335 & Male == 0 & Age >=17 & Age< 18
replace BMI_overweight = 1 if childBMI >= 25.67786 & childBMI < 30.32554 & Male == 0 & Age >=18 & Age< 19
replace BMI_overweight = 1 if childBMI >= 26.09993 & childBMI < 31.0288 & Male == 0 & Age >=19 & Age< 20



// save as Reggio_prepareddata
*cd "${data_reggio}"
*save Reggio_prepared.dta, replace
