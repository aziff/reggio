clear all
set more off
capture log close

/*
Author: Pietro Biroli (biroli@uchicago.edu)

Purpose:
-- Create some summary tables for the Reggio Project
-- Edit of old file to create tables in latex

This Draft: 11 Dec 2015

Input: 	Reggio.dta  --> see dataClean_all.do
		
Output:	Statistics tables
*/

global stat  = 1   // 1 = do the summary statistics, 0 skip that section

*** directory
local dir "C:\Users\pbiroli\Dropbox\ReggioChildren"
local outdir "`dir'\Analysis\descrittivePietro\Tables"
local datadir "`dir'\SURVEY_DATA_COLLECTION\data"
// local dir "/mnt/ide0/share/klmReggio/SURVEY_DATA_COLLECTION/data"
// local dir "/mnt/ide0/home/biroli/ChicaGo/Heckman/ReggioChildren/SURVEY_DATA_COLLECTION/data"

cd "`outdir'"

use `datadir'/Reggio.dta, clear

global childPRE    	Male noMom momAgeBirth momBornProvince momMaxEdu_* momHome06 ///
					noDad dadAgeBirth dadBornProvince dadMaxEdu_* ///
					famSize olderSibling youngSibling speakItal cgAsilo cgMaterna cgYrMarry ///
					grandAlive grand_nbrhood daily_grandCare ///
					childRelig cgRelig cgFaith ///
					cgIQ_score birthweight lowbirthweight birthpremature CAPI ///
					momPA_Empl momPA_OLF momPA_HouseWife dadPA_Empl dadPA_Unempl ///
					mommStatus_married dadmStatus_married ///
					houseOwn cgIncome25000 ///
					cgSES_worker cgSES_teacher cgSES_professional cgSES_self ///
					hhSES_worker hhSES_teacher hhSES_professional hhSES_self ///
					

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

*-* Predetermined Characteristics: by preschool type and city
local options se sdbracket vert nototal nptest //sd mtprob mtest bdec(3) ci cibrace nptest 
local group cityXmaterna
tabformprova $childPRE using children_PRE if Cohort==1, by(`group') `options'
tabformprova $childPRE using immigrant_PRE if Cohort==2, by(`group') `options'
tabformprova $childPRE using adolescent_PRE if Cohort==3, by(`group') `options'

tabformprova $adultPRE using adults_PRE if Cohort>3, by(`group') `options'
tabformprova $adultPRE using adult30_PRE if Cohort==4, by(`group') `options'
tabformprova $adultPRE using adult40_PRE if Cohort==5, by(`group') `options'
tabformprova $adultPRE using adult50_PRE if Cohort==6, by(`group') `options'


*-* Predetermined Characteristics: by infant-toddler center type and city
local options se sdbracket vert nototal nptest //sd mtprob mtest bdec(3) ci cibrace nptest 
local group cityXasilo
tabformprova $childPRE using children_PREasilo if Cohort==1, by(`group') `options'
tabformprova $childPRE using immigrant_PREasilo if Cohort==2, by(`group') `options'
tabformprova $childPRE using adolescent_PREasilo if Cohort==3, by(`group') `options'

tabformprova $adultPRE using adults_PREasilo if Cohort>3, by(`group') `options'
tabformprova $adultPRE using adult30_PREasilo if Cohort==4, by(`group') `options'
tabformprova $adultPRE using adult40_PREasilo if Cohort==5, by(`group') `options'
tabformprova $adultPRE using adult50_PREasilo if Cohort==6, by(`group') `options'

*-* Predetermined Characteristics in the other cities (Parma and Padova)
foreach city in Parma Padova{
foreach scuola in asilo materna{
local options se sdbracket vert nototal nptest //sd mtprob mtest bdec(3) ci cibrace nptest 
local group cityX`scuola'
tabformprova $childPRE using children_PRE`scuola'`city' if Cohort==1 & `city'==1, by(`group') `options'
tabformprova $childPRE using immigrant_PRE`scuola'`city' if Cohort==2 & `city'==1, by(`group') `options'
tabformprova $childPRE using adolescent_PRE`scuola'`city' if Cohort==3 & `city'==1, by(`group') `options'

tabformprova $adultPRE using adults_PRE`scuola'`city' if Cohort>3 & `city'==1, by(`group') `options'
tabformprova $adultPRE using adult30_PRE`scuola'`city' if Cohort==4 & `city'==1, by(`group') `options'
tabformprova $adultPRE using adult40_PRE`scuola'`city' if Cohort==5 & `city'==1, by(`group') `options'
tabformprova $adultPRE using adult50_PRE`scuola'`city' if Cohort==6 & `city'==1, by(`group') `options'
}
}


capture log close

/* for Jacobs

*------------------------------*
global family Male Age cgAge famSize children0_18 cgMarried noMom noDad cgMaxEdu cgHSgrad cgUni dadMaxEdu dadHSgrad dadUni cgEmpl cgUnempl cgHouseWife hhUnempl cgHrsWork hhHrsWork houseOwn cgIncomeCat cgWage
global school student asilo materna asiloBegin asiloEnd maternaBegin maternaEnd momHome06 difficultiesNone
global invest childinvReadTo childinvMusic childinvOut childinvFamMeal childinvReadSelf childinvSport childinvDance childinvTheater childinvFriends ///
              childinvOutWhere childinvOutWho childinvOutWhen childinvTalkSchool childinvTalkOut childinvTalkdad childinvTalkmom
global noncog *SDQ*score *SDQ*factor
global health cgHealth childHealth childSickDays cgHeight childHeight cgWeight childWeight cgFruit childFruit cgSnackFruit childSnackFruit sportTogether birthweight cgBMI childBMI childTotal_diag 
global caregiver cgLocusControl cgTrust cgSmoke cgDrinkNum cgIQ_score cgIQtime cgFriends cgSocialMeet cgPolitics cgFaith childRelig cgMigrFriend cgMigrTaste cgMigrCity cgMigrIntegCity
global child IQ_score IQtime likeSchool_child likeRead likeMath_child likeGym goodBoySchool childSuspended likeTV likeDraw likeSport lendFriend favorReturn revengeReturn funFamily faceMe faceFamily faceSchool faceGeneral candyGame
global adolescent likeSchool_ado likeMath_ado likeItal uniGoProb Health Height Fruit sport screen_hrs BMI Weight WeightPerception takeCareOth volunteer club Friends Politics Faith TimeSelf Stress MigrIntegr MigrAttitude MigrClass MigrFriend MigrTaste MigrGood closeMom closeDad optimist pessimist single SmokeEver Smoke Maria Drink Drink1Age DrinkNum ProbMarry25 ProbGrad ProbRich ProbLive80 ProbBabies 

*-* Do some Tables of Summary Statistics
local options se mtest sdbracket vert //sd mtprob
foreach group in Cohort City treatGroup{
di "doing group `group'"
tabformprova $family using family_`group', by(`group') `options'
tabformprova $school using school_`group', by(`group') `options'
di "invest - `group'"
tabformprova $invest using invest_`group', by(`group') `options'
tabformprova $noncog using noncog_`group', by(`group') `options'
di "health - `group'"
tabformprova $health using health_`group', by(`group') `options'
tabformprova $caregiver using caregiver_`group', by(`group') `options'
di "child - `group'"
tabformprova $child using child_`group' if Cohort<3, by(`group') `options'
tabformprova $adolescent using adolescent_`group' if Cohort==3, by(`group') `options'
}

*-* 9 way tables: by preschool type
local options se mtest sdbracket vert //sd mtprob
foreach group in cityXschool cohortXschool cohortXcity cohortXtreat{
di "doing group `group'"
tabformprova $family using family_`group', by(`group') `options'
tabformprova $school using school_`group', by(`group') `options'
di "invest - `group'"
tabformprova $invest using invest_`group', by(`group') `options'
tabformprova $noncog using noncog_`group', by(`group') `options'
di "health - `group'"
tabformprova $health using health_`group', by(`group') `options'
tabformprova $caregiver using caregiver_`group', by(`group') `options'
di "child - `group'"
tabformprova $child using child_`group' if Cohort<3, by(`group') `options'
tabformprova $adolescent using adolescent_`group' if Cohort==3, by(`group') `options'
}



local options se mtest sdbracket vert //sd mtprob
global JacobsChild Male Age cgAge famSize cgMarried cgEmpl cgHouseWife houseOwn cgHealthPerc cgBMI ///
              cgHSgrad dadHSgrad cgIncome25000 IQ_score likeSchool likeLit likeMath childHealthPerc childFruitDaily childBMI // cgUni dadUni 
des $JacobsChild

global JacobsChildLabel Male "Male" Age "Age" cgAge "Caregiver Age" famSize "Family Size" ///
cgMarried "Caregiver Married" cgEmpl "Caregiver Employed" cgHouseWife "Caregiver Housewife" ///
houseOwn "Own Home" cgHealthPerc "Caregiver Health Good" cgBMI "Caregiver BMI" ///
cgHSgrad "Caregiver High School" dadHSgrad "Dad High School" cgIncome25000 "Family Inc $>$ 25000" ///
IQ_score "IQ Score" likeSchool "Like School" likeLit "Like Reading" likeMath "Like Math" ///
childHealthPerc "Child Health Good" childFruitDaily "Eats Fruit" childBMI "Child BMI"

global JacobsAdult Male famSize childrenNum Married Empl HouseWife houseOwn /// numMarriage Age 
              HSgrad Uni votoMaturita votoUni Income25000 HrsWork HealthPerc BMI FruitDaily sportTwice SmokeEver Stressed Satisfied ///
	      volunteer Friends IQ_score //
des $JacobsAdult

global JacobsAdultLabel Male "Male" famSize "Family Size" childrenNum "Number Children" /// 
Married "Married" Empl "Employed" HouseWife "Housewife" houseOwn "Own Home" /// 
numMarriage "Number of Marriages" Age "Age" HSgrad "High School" Uni "University" ///
votoMaturita "High School Grade" votoUni "University Grade" Income25000 "Family Inc $>$ 25000" ///
HrsWork "Hours Worked/Week" HealthPerc "Health Good" BMI "BMI" FruitDaily "Eat Fruit" ///
sportTwice "Sport" SmokeEver "Smoked Ever" Stressed "Stressed" Satisfied "Satisfied" ///
volunteer "Volunteers" Friends "Number Friends" IQ_score "IQ Score" //


tabformprova $JacobsChild using JacobsChild_cohortXcity if Cohort<4, by(cohortXcity) `options' //$JacobsAdult 
tabformprova $JacobsAdult using JacobsAdult_cohortXcity if Cohort>3, by(cohortXcity) `options' //$JacobsChild 

tabformprova $JacobsChild using JacobsChild_cohortXtreat, by(cohortXtreat) `options'
tabformprova $JacobsAdult using JacobsAdult_cohortXtreat, by(cohortXtreat) `options'

local options se sdbracket vert //sd mtprob mtest 
tabformprova $JacobsChild using Jacobs_treatChild if Cohort==1, by(treatGroup) `options'
tabformprova $JacobsChild using Jacobs_treatImm   if Cohort==2, by(treatGroup) `options'
tabformprova $JacobsChild using Jacobs_treatAdo   if Cohort==3, by(treatGroup) `options'
tabformprova $JacobsAdult using Jacobs_treatAdult4 if Cohort==4, by(treatGroup) `options'
tabformprova $JacobsAdult using Jacobs_treatAdult5 if Cohort==5, by(treatGroup) `options'
tabformprova $JacobsAdult using Jacobs_treatAdult6 if Cohort==6, by(treatGroup) `options'

tabformprova $JacobsAdult using Jacobs_treatAdult if Cohort>=4, by(treatGroup) `options'

local options  main(mean %5.3f) aux(sd) nostar unstack ///
nonote nomtitle nonumber replace tex nogaps

estpost tabstat $JacobsChild ///
if (Cohort == 1), by(treatGroup) statistics(mean sd) columns(statistics)
esttab using JacobstreatChild.tex, `options' coef($JacobsChildLabel)

//tabformprova $JacobsChild using Jacobs_treatImm   if Cohort==2, by(treatGroup) `options'
estpost tabstat $JacobsChild ///
if (Cohort == 2), by(treatGroup) statistics(mean sd) columns(statistics)
esttab using JacobstreatImm.tex, `options' coef($JacobsChildLabel)

//tabformprova $JacobsChild using Jacobs_treatAdo   if Cohort==3, by(treatGroup) `options'
estpost tabstat $JacobsChild ///
if (Cohort == 3), by(treatGroup) statistics(mean sd) columns(statistics)
esttab using JacobstreatAdo.tex, `options' coef($JacobsChildLabel)

//tabformprova $JacobsAdult using Jacobs_treatAdult4 if Cohort==4, by(treatGroup) `options'
estpost tabstat $JacobsAdult ///
if (Cohort == 4), by(treatGroup) statistics(mean sd) columns(statistics)
esttab using JacobstreatAdult4.tex, `options' coef($JacobsAdultLabel)

//tabformprova $JacobsAdult using Jacobs_treatAdult5 if Cohort==5, by(treatGroup) `options'
estpost tabstat $JacobsAdult ///
if (Cohort == 5), by(treatGroup) statistics(mean sd) columns(statistics)
esttab using JacobstreatAdult5.tex, `options' coef($JacobsAdultLabel)

//tabformprova $JacobsAdult using Jacobs_treatAdult6 if Cohort==6, by(treatGroup) `options'
estpost tabstat $JacobsAdult ///
if (Cohort == 6), by(treatGroup) statistics(mean sd) columns(statistics)
esttab using JacobstreatAdult6.tex, `options' coef($JacobsAdultLabel)

//tabformprova $JacobsAdult using Jacobs_treatAdult if Cohort>=4, by(treatGroup) `options'
estpost tabstat $JacobsAdult ///
if (Cohort >= 4), by(treatGroup) statistics(mean sd) columns(statistics)
esttab using JacobstreatAdult.tex, `options' coef($JacobsAdultLabel)

forvalues Male=0/1{
	display "We're doing the tables of Male == `Male'"
	local options se sdbracket vert //sd mtprob mtest 
	tabformprova $JacobsChild using Jacobs_treatChild_Male`Male'  if Cohort==1 & Male==`Male', by(treatGroup) `options'
	tabformprova $JacobsChild using Jacobs_treatImm_Male`Male'    if Cohort==2 & Male==`Male', by(treatGroup) `options'
	tabformprova $JacobsChild using Jacobs_treatAdo_Male`Male'    if Cohort==3 & Male==`Male', by(treatGroup) `options'
	tabformprova $JacobsAdult using Jacobs_treatAdult4_Male`Male' if Cohort==4 & Male==`Male', by(treatGroup) `options'
	tabformprova $JacobsAdult using Jacobs_treatAdult5_Male`Male' if Cohort==5 & Male==`Male', by(treatGroup) `options'
	tabformprova $JacobsAdult using Jacobs_treatAdult6_Male`Male' if Cohort==6 & Male==`Male', by(treatGroup) `options'

	tabformprova $JacobsAdult using Jacobs_treatAdult_Male`Male' if Cohort>=4 & Male==`Male', by(treatGroup) `options'
}

/*** Latex output
forvalues Cohort =1/3{
forvalues treat=1/4{
eststo Cohort`Cohort'_treat`treat': estpost tabstat $JacobsChild if treatGroup==`treat' & Cohort == `Cohort' , statistics(mean sd) columns(statistics)
}
}

*OUTPUT LOCALS
local title "Children and Immigrant"
local note1 "Source: Reggio Children Data"
local results "Cohort1_treat1 Cohort1_treat2 Cohort1_treat3 Cohort1_treat4   Cohort2_treat1 Cohort2_treat2 Cohort2_treat3 Cohort2_treat4 "
local mtitles "Reggio_Children Reggio_Municipal Parma Padova Reggio_Children Reggio_Municipal Parma Padova "
local filename "prova"
*OUTPUT
esttab `results' using `filename', ///
main(mean %9.2f) aux(sd %9.2f) nogap label replace nonum nostar title(`title') ///
booktabs noobs addn(`note1') mtitle(`mtitles')  width(15in) /// fragment 
mgroups("Children" "Immigrants", pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
*/
cd .. //go back to data
*/
