clear all
set more off
capture log close

/*
Author: Pietro Biroli (biroli@uchicago.edu)
Purpose: Analyze the Reggio Children Evaluation Survey to understand impact on Immigrants and Assimilation

This Draft: 2 May 2015
  
[=] Signal questions to be addressed
*/

*-*-* directory
global dir "C:\Users\Pietro\Documents\ChicaGo\Heckman\ReggioChildren\SURVEY_DATA_COLLECTION\data"
// global dir "/mnt/ide0/share/klmReggio/SURVEY_DATA_COLLECTION/data"
//global dir "/Volumes/klmReggio/SURVEY_DATA_COLLECTION/data"

cd $dir

global construct=0 // =1 if want to construct the dataset 
global tables=0    // =1 if want output of summary statistics tables
global reg=1       // =1 if want output regression tables

// log using gitReggioCode/MigrantsPB/Migrants-ReggioEVal, replace


*--------------------------------------------------------*
* (item) Variable List
	// Asked to the Italian Caregivers (Bambini+Ado)
global cgIta  cgMigrIntegr_cat cgMigrAttitude_cat cgMigrSchoolPerc cgMigrProgram_cat cgMigrFriend /// cgMigrClass_cat 
                 cgMigrMeetNo cgMigrMeetWork cgMigrMeetChurch cgMigrMeetSport cgMigrMeetOther ///
                 /// self-completed
                 cgMigrTaste_cat cgMigrAfri_N cgMigrArab_N cgMigrAsia_N cgMigrEngl_N  cgMigrSAme_N cgMigrSwed_N /// cgMigrMeet_open
                 // cgTrust // NOTE: trust has been asked to everybody

	// Asked to the Migrant Caregivers (Bambini)
global cgMigrant cgMigrTimeFit cgMigrTimeSpeak cgMigrTimeFriends cgMigrTimeSatis ///
                 cgMigrFrComp cgMigrFrIta cgMigrFrCity cgMigrFrOther ///
                 /// self-completed
                 cgMigrCity_cat cgMigrIntegCity_cat cgMigrIntegIt_cat // cgMigrIntegCityHarder

	// Asked to the Italian Adolescents and Adults
global Ita    MigrTaste_cat MigrGood_cat MigrBetterHost MigrBetterAid MigrAfri_N MigrArab_N MigrAsia_N MigrEngl_N MigrSAme_N MigrSwed_N /// MigrMeetOther_open /// self-completed
                 /// Trust
				 MigrIntegr_cat MigrAttitude_cat MigrProgram_cat MigrFriend /// MigrClassChild
                 MigrMeetNo MigrMeetWork MigrMeetChurch MigrMeetSport MigrMeetOther /// MigrClass MigrClassIntegr 

global ItaAdo    $Ita MigrClass MigrClassIntegr_cat MigrFriendAfri_N MigrFriendArab_N MigrFriendAsia_N MigrFriendEngl_N MigrFriendSAme_N MigrFriendSwed_N // MigrNation_open MigrFriendNation_open
global ItaAdult  $Ita MigrClassChild_cat
	// Asked to the Italian Children
global ItaMigrChild Ita*Fig_white Migr*Fig_white
global ItaRacial Ita*Fig_black Migr*Fig_black


if $construct==1{ // construct the dataset
cd $dir
use Reggio.dta, clear
// drop if interPadova==1

*--------------------------------------------------------*
* (item) Look at the main nationalities
tab nationality Cohort, miss
tab nationality City if Cohort==2


*--------------------------------------------------------*
* (item) Change some labels

foreach var of varlist _all{
local u : variable label `var'
local l = subinstr("`u'","dv: ","",1) // take away all the "derived"
local l = trim("`l'")
label var `var' "`l'"
}

sum $cgIta cgTrust $cgMigrant $ItaAdo $ItaAdult $ItaMigrChild Trust
des $cgIta cgTrust $cgMigrant $ItaAdo $ItaAdult $ItaMigrChild Trust

mvencode $cgIta cgTrust $cgMigrant $ItaAdo $ItaAdult $ItaMigrChild Trust, mv(99999) // SEM doesn't handle well extended missing values
mvdecode $cgIta cgTrust $cgMigrant $ItaAdo $ItaAdult $ItaMigrChild Trust, mv(99999)


*--------------------------------------------------------*
* (item) Factors
* * Italian Children
global ItaChildFactor ItaBadFig_white ItaFriendFig_white ItaNiceFig_white ItaSimilarFig_white ///
					  ItaBadFig_black ItaFriendFig_black ItaNiceFig_black ItaSimilarFig_black ///
						
factor $ItaChildFactor if Cohort==1
predict ItaChildFactor_simple
sem ( X -> $ItaChildFactor) if Cohort==1, latent(X) var(X@1) iter(500) method(mlmv)
predict ItaChildFactor if e(sample), latent(X)
label var ItaChildFactor "Italian Children attitudes towards migration - factor score"

* * Migrant Children
global MigrChildFactor MigrBadFig_white MigrFriendFig_white MigrNiceFig_white MigrSimilarFig_white ///
					   MigrBadFig_black MigrFriendFig_black MigrNiceFig_black MigrSimilarFig_black 
					   
factor $MigrChildFactor 
predict MigrChildFactor_simple
sem ( X -> $MigrChildFactor) , latent(X) var(X@1) iter(500) method(mlmv)
predict MigrChildFactor if e(sample), latent(X)
label var MigrChildFactor "Migrant Children attitudes - factor score"


* * Adolescents
global adoFactor MigrTaste MigrGood MigrIntegr MigrAttitude MigrProgram MigrFriend MigrMeetNo MigrMeetChurch /// MigrMeetWork MigrMeetOther 
              MigrMeetSport MigrBetterHost MigrBetterAid /// 
	      MigrAfri_N MigrArab_N MigrAsia_N MigrEngl_N MigrSAme_N MigrSwed_N ///
	      MigrFriendAfri_N MigrFriendArab_N MigrFriendAsia_N MigrFriendEngl_N MigrFriendSAme_N MigrFriendSwed_N Trust // MigrClass MigrClassIntegr 

factor $adoFactor if Cohort==3, factor(7)
predict adoFactor_simple
sem ( X -> $adoFactor) if Cohort==3, latent(X) var(X@1) iter(500) method(mlmv)
predict adoFactor if e(sample), latent(X)
label var adoFactor "Adolescent attitudes towards migration - factor score"

* * Adults
global adultFactor MigrTaste MigrGood MigrIntegr MigrAttitude MigrProgram MigrFriend MigrMeetNo MigrMeetWork MigrMeetChurch /// MigrMeetOther MigrMeetWork 
              MigrMeetSport MigrBetterHost MigrBetterAid /// 
	      MigrAfri_N MigrArab_N MigrAsia_N MigrEngl_N MigrSAme_N MigrSwed_N ///
	      Trust // NOTE: even running without trust, the two estimated factors are .999 correlated!

factor $adultFactor if Cohort>3, factor(7)
predict adultFactor_simple
sem ( X -> $adultFactor) if Cohort>3, latent(X) var(X@1) iter(500) method(mlmv)
predict adultFactor if e(sample), latent(X)
label var adultFactor "Adult attitudes towards migration - factor score"

* * Caregivers: both children and adolescents
global cgItaFactor cgMigrFriend cgMigrMeetNo ///cgMigrClass cgMigrSchoolPerc cgMigrIntegr cgMigrAttitude cgMigrProgram 
              cgMigrMeetChurch cgMigrMeetSport cgMigrAfri_N cgMigrArab_N /// cgMigrMeetWork cgMigrMeetOther    
              cgMigrAsia_N cgMigrEngl_N cgMigrSAme_N cgMigrSwed_N cgTrust // important but a lot of missing: cgMigrTaste  
	      

factor $cgItaFactor if (Cohort==1 | Cohort==3), factor(7)
predict cgItaFactor_simple
sem ( X -> $cgItaFactor) if (Cohort==1 | Cohort==3), latent(X) var(X@1) iter(500) method(mlmv)
predict cgItaFactor if e(sample) & (Cohort==1 | Cohort==3), latent(X)
label var cgItaFactor "Italian Caregivers: attitudes towards migration - factor score"

* * Caregivers: migrants
global cgMigrFactor cgMigrFrIta cgMigrFrCity /// cgMigrTimeFit cgMigrFrComp cgMigrFrOther 
		    cgMigrCity cgMigrIntegCity cgMigrIntegIt /// cgMigrIntegCityHarder
		    cgMigrTimeFit cgMigrTimeSpeak cgMigrTimeFriends cgMigrTimeSatis ///

factor $cgMigrFactor if Cohort==2, factor(7)
predict cgMigrFactor_simple
sem ( X -> $cgMigrFactor) if Cohort==2, latent(X) var(X@1) iter(500) method(mlmv)
predict cgMigrFactor if e(sample) & Cohort==2, latent(X)
label var cgMigrFactor "Migrant Caregivers: attitudes towards migration - factor score"

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

* more relabelling 
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

*-* Sample:
capture drop sample*
reg MigrTaste_cat ReggioMaterna Parma Padova $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus $xmaterna if Cohort>3, robust 
gen sampleAdult = e(sample)
reg MigrTaste_cat ReggioMaterna Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xmaterna if Cohort==3, robust
gen sampleAdo = e(sample)
reg ItaFriendFig_white ReggioMaterna Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xmaterna if Cohort==1, robust 
gen sampleChild = e(sample)
reg MigrFriendFig_white ReggioMaterna Parma Padova $Controls $cgPA $cgmStatus $Migr_other $xmaterna if Cohort==2, robust 
gen sampleMigr = e(sample)

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

save $dir/ReggioMigrant.dta, replace
}

if $tables==1{ // Export some tables of summary statistics
*--------------------------------------------------------*
* (item) Some Summary Statistics
use $dir/ReggioMigrant.dta, clear
cd $dir/gitReggioCode/MigrantsPB/tables
*-* Do some Tables of Summary Statistics

global options  main(mean %5.2f) aux(sd %5.2f) unstack /// nostar 
nonote nomtitle nonumber replace tex nogaps

// Origin
tab cgNationality City
tab cgNationality City if Cohort<=2
tab cgNationality City if Cohort==2

*-------------------------------------
global ChildGeneral Male Age cgAge famSize cgMarried cgEmpl cgHouseWife houseOwn cgHealthPerc cgBMI ///
              cgHSgrad dadHSgrad cgIncome25000 difficultiesNone IQ_score likeSchool likeLit likeMath childHealthPerc childFruitDaily childBMI childinvFriends // cgUni dadUni 
des $ChildGeneral

global ChildGeneralLabel Male "Male (\%)" Age "Age" cgAge "Caregiver Age" famSize "Family Size" ///
cgMarried "Caregiver Married (\%)" cgEmpl "Caregiver Employed (\%)" cgHouseWife "Caregiver Housewife (\%)" ///
houseOwn "Own Home (\%)" cgHealthPerc "Caregiver health is good (\%)" cgBMI "Caregiver BMI" ///
cgHSgrad "Caregiver has High School Diploma (\%)" dadHSgrad "Dad has High School Diploma (\%)" cgIncome25000 "Family Inc $<$ 25000 (\%)" ///
difficultiesNone "Child had no difficulties starting school (\%)" IQ_score "IQ (\% correct)" likeSchool "Child likes School (\%)" likeLit "Child likes reading (\%)" likeMath "Child likes math (\%)" ///
childHealthPerc "Child health is good (\%)" childFruitDaily "Child eats fruit daily (\%)" childBMI "Child BMI" childinvFriends "Child's number of close friends"

// Children vs migrants summary statistics
estpost tabstat $ChildGeneral ///
if (Cohort <= 2), by(Cohort) statistics(mean sd) columns(statistics)
esttab using Child_vs_Imm.tex, $options coef($ChildGeneralLabel)

*--------------- Graph I for Summary Statistics -----------------

gen cgAge_under35 = (cgAge < 35)
gen famSize_greater4 = (famSize > 4)

preserve

keep if(Cohort <= 2)

collapse (mean) m1 = cgIncome25000 m2 = dadHSgrad m3 = cgHSgrad m4 = cgHealthPerc ///
m5 = houseOwn m6 = cgHouseWife m7 = cgEmpl m8 = cgMarried m9 = famSize_greater4 ///
m10 = cgAge_under35 m11 = Male (semean) s1 = cgIncome25000 s2 = dadHSgrad s3 = cgHSgrad ///
s4 = cgHealthPerc s5 = houseOwn s6 = cgHouseWife s7 = cgEmpl s8 = cgMarried ///
s9 = famSize_greater4 s10 = cgAge_under35 s11 = Male, by(Cohort)

reshape long m s, i(Cohort) j(variable)

gen hi = m + 1.96 * s
gen lo = m - 1.96 * s

capture gen varXcohort = .
local SUM 1
forvalues i = 1(1)11 {
	replace varXcohort = `SUM' if(variable == `i' & Cohort == 1)
	replace varXcohort = `SUM' + 1 if(variable == `i' & Cohort == 2)
	local SUM = `SUM' + 4
}

global ylabs 41.5 "Male (%)" 37.5 "Caregiver Age < 35 (%)" 33.5 "Family Size > 4 (%)" 29.5 "Caregiver Married (%)" 25.5 "Caregiver Employed (%)" 21.5 "Caregiver Housewife (%)" ///
17.5 "Own Home (%)" 13.5 "Caregiver health is good (%)" 9.5 "Caregiver has High School Diploma (%)" ///
5.5 "Dad has High School Diploma (%)" 1.5 "Family Inc < 25000 (%)" 

twoway (bar m varXcohort if Cohort == 1, horizontal) ///
(bar m varXcohort if Cohort == 2, horizontal) ///
(rcap hi lo varXcohort, horizontal lcolor(red)), ///
legend(order(1 "Children" 2 "Migrants")) ///
ylabel($ylabs, noticks angle(horizontal) labsize(small)) ///
graphregion(color(white)) ytitle("")

graph export summaryBars1.png, replace width(800) height(600)

*--------------- Graph II for Summary Statistics -----------------

restore, preserve

preserve
keep if(Cohort <= 2)

collapse (mean) m1 = childz_BMI m2 = childFruitDaily  m3 = childHealthPerc ///
m4 = likeMath m5 = likeLit m6 = likeSchool m7 = IQ_score m8 = difficultiesNone ///
(semean) s1 = childz_BMI s2 = childFruitDaily  s3 = childHealthPerc ///
s4 = likeMath s5 = likeLit s6 = likeSchool s7 = IQ_score s8 = difficultiesNone, ///
by(Cohort) 

reshape long m s, i(Cohort) j(variable)

gen hi = m + 1.96 * s
gen lo = m - 1.96 * s

capture gen varXcohort = .
local SUM 1
forvalues i = 1(1)8 {
	replace varXcohort = `SUM' if(variable == `i' & Cohort == 1)
	replace varXcohort = `SUM' + 1 if(variable == `i' & Cohort == 2)
	local SUM = `SUM' + 4
}

global ylabs 1.5 "Child z-BMI" 5.5 "Child eats fruit daily (%)" 9.5 "Child health is good (%)" ///
13.5 "Child likes math (%)" 17.5 "Child likes reading (%)" 21.5 "Child likes School (%)" ///
25.5 "IQ (% correct)" 29.5 "Child had no difficulties starting school (%)"

twoway (bar m varXcohort if Cohort == 1, horizontal) ///
(bar m varXcohort if Cohort == 2, horizontal) ///
(rcap hi lo varXcohort, horizontal lcolor(red)), ///
legend(order(1 "Children" 2 "Migrants")) ///
ylabel($ylabs, noticks angle(horizontal) labsize(small)) ///
graphregion(color(white)) ytitle("")

graph export summaryBars2.png, replace width(800) height(600)

restore, preserve
restore, not

*-------------------------------------------

// Children summary statistics
estpost tabstat $ChildGeneral ///
if (Cohort == 1), by(treatGroup) statistics(mean sd) columns(statistics)
esttab using ChildGeneral.tex, $options coef($ChildGeneralLabel)

// Migrant summary statistics
estpost tabstat $ChildGeneral ///
if (Cohort == 2), by(treatGroup) statistics(mean sd) columns(statistics)
esttab using ImmGeneral.tex, $options coef($ChildGeneralLabel)

global Child FriendFig_white NiceFig_white BadFig_white SimilarFig_white ///
	     FriendFig_black NiceFig_black BadFig_black SimilarFig_black 

global ChildLabel /// 
FriendFig_white "Want white as friend  \%" /// 
NiceFig_white "White seems friendly  \%" /// 
BadFig_white "White seems bad  \%" /// 
SimilarFig_white "White seems like me  \%" /// 
FriendFig_black "Want black as friend  \%" /// 
NiceFig_black "Black seems friendly  \%" /// 
BadFig_black "Black seems bad  \%" /// 
SimilarFig_black "Black seems like me  \%" /// 

global MigrChildLabel /// 
ItaFriendFig_white "Want white as friend (ita) \%" /// 
ItaNiceFig_white "White seems friendly (ita) \%" /// 
ItaBadFig_white "White seems bad (ita) \%" /// 
ItaSimilarFig_white "White seems like me (ita) \%" /// 
MigrFriendFig_white "Want white as friend (migrant) \%" /// 
MigrNiceFig_white "White seems friendly (migrant) \%" /// 
MigrBadFig_white "White seems bad (migrant) \%" /// 
MigrSimilarFig_white "White seems like me (migrant) \%" /// 

global ItaRacialLabel /// 
ItaFriendFig_black "Want black as friend (ita) \%" /// 
ItaNiceFig_black "Black seems friendly (ita) \%" /// 
ItaBadFig_black "Black seems bad (ita) \%" /// 
ItaSimilarFig_black "Black seems like me (ita) \%" /// 
MigrFriendFig_black "Want black as friend (migrant) \%" /// 
MigrNiceFig_black "Black seems friendly (migrant) \%" /// 
MigrBadFig_black "Black seems bad (migrant) \%" /// 
MigrSimilarFig_black "Black seems like me (migrant) \%" /// 

*-------------------------------------*
//Chid and Immigrant racism
estpost tabstat $Child ///
if (Cohort <= 2), by(Cohort) statistics(mean sd) columns(statistics)
esttab using Child.tex, $options coef($ChildLabel)


estpost tabstat $ItaMigrChild ///
if (Cohort <= 2), by(treatGroup) statistics(mean sd) columns(statistics)
esttab using ChildRacism.tex, $options coef($ItaMigrChildLabel)

estpost tabstat $ItaRacial ///
if (Cohort <= 2), by(City) statistics(mean sd) columns(statistics)
esttab using ChildRacism2.tex, $options coef($ItaRacialLabel)

estpost tabstat $ItaRacial ///
if (Cohort == 1), by(treatGroup) statistics(mean sd) columns(statistics)
esttab using ChildRacismLong.tex, $options coef($ItaRacialLabel)

estpost tabstat $ItaMigrChild ///
if (Cohort == 2), by(treatGroup) statistics(mean sd) columns(statistics)
esttab using MigrRacism.tex, $options coef($ItaMigrChildLabel)


global cgMigrantLabel ///
cgMigrTimeFit "Time taken to fit in (in months)" /// 
cgMigrTimeSpeak "Time taken to speak language (in months)" /// 
cgMigrTimeFriends "Time taken to find friends (in months)" /// 
cgMigrTimeSatis "Time taken to feel satisfied (in months)" /// 
cgMigrFrComp "Have own countrymen among friends" /// 
cgMigrFrIta "Have Italian among friends" /// 
cgMigrFrCity "Have friends from this city" /// 
cgMigrFrOther "Have other immigrants among friends" /// 
cgMigrCity_cat "City hostile to migrants" /// 
cgMigrIntegCity_cat "Hard to integrate into city" /// 
cgMigrIntegIt_cat "Hard to integrate in Italy" /// 

*-------------------------------------*
//Immigrant Caregiver racism
estpost tabstat $cgMigrant ///
if (Cohort <= 2), by(treatGroup) statistics(mean sd) columns(statistics)
esttab using cgMigrantRacism.tex, $options coef($cgMigrantLabel)

estpost tabstat $cgMigrant ///
if (Cohort <= 2), by(City) statistics(mean sd) columns(statistics)
esttab using cgMigrantRacism2.tex, $options coef($cgMigrantLabel)

*-------------------------------------*
//Natives racism
global ItaAdoLabel ///
MigrTaste_cat   "Bothered by immigration into city" ///
MigrGood_cat   "Immigration is bad for our country" ///
MigrBetterHost   "Better to host migrants" ///
MigrBetterAid   "Better to send aid to migrants' own country" ///
MigrAfri_N   "Would not like to have African Neighbour" ///
MigrArab_N   "Would not like to have Arab Neighbour" ///
MigrAsia_N   "Would not like to have Asian Neighbour" ///
MigrEngl_N   "Would not like to have English Neighbour" ///
MigrSAme_N   "Would not like to have South American Neighbour" ///
MigrSwed_N   "Would not like to have Swedish Neighbour" ///
MigrIntegr_cat   "Schools help migration" ///
MigrAttitude_cat   "Diffident toward migrants" ///
MigrProgram_cat   "Migrants slow down class curriculum" ///
MigrFriend   "Ever had foreign friends?" ///
MigrMeetNo   "No foreigners in own social network" ///
MigrMeetWork   "Meet foreigners at work/school" ///
MigrMeetChurch   "Meet foreigners at church" ///
MigrMeetSport   "Meet foreigners in my sport/association" ///
MigrMeetOther   "Meet foreigners in ____ other" ///
MigrClass   "Migrants in classroom" ///
MigrClassIntegr_cat   "Migrants are well integrated in classroom" ///
MigrFriendAfri_N   "Would not like to have African Friend" ///
MigrFriendArab_N   "Would not like to have Arab Friend" ///
MigrFriendAsia_N   "Would not like to have Asian Friend" ///
MigrFriendEngl_N   "Would not like to have English Friend" ///
MigrFriendSAme_N   "Would not like to have South American Friend" ///
MigrFriendSwed_N   "Would not like to have Swedish Friend" ///

estpost tabstat $ItaAdo ///
if (Cohort == 3), by(treatGroup) statistics(mean sd) columns(statistics)
esttab using adoRacism.tex, $options coef($ItaAdoLabel)

estpost tabstat $ItaAdo ///
if (Cohort == 3), by(City) statistics(mean sd) columns(statistics)
esttab using adoRacism2.tex, $options coef($ItaAdoLabel)


global ItaAdultLabel ///
MigrTaste_cat   "Bothered by immigration into city" ///
MigrGood_cat   "Immigration is bad for our country" ///
MigrBetterHost   "Better to host migrants" ///
MigrBetterAid   "Better to send aid to migrants' own country" ///
MigrAfri_N   "Would not like to have African Neighbour" ///
MigrArab_N   "Would not like to have Arab Neighbour" ///
MigrAsia_N   "Would not like to have Asian Neighbour" ///
MigrEngl_N   "Would not like to have English Neighbour" ///
MigrSAme_N   "Would not like to have South American Neighbour" ///
MigrSwed_N   "Would not like to have Swedish Neighbour" ///
MigrIntegr_cat   "Schools help migration" ///
MigrAttitude_cat   "Diffident toward migrants" ///
MigrProgram_cat   "Migrants slow down class curriculum" ///
MigrFriend   "Ever had foreign friends?" ///
MigrMeetNo   "No foreigners in own social network" ///
MigrMeetWork   "Meet foreigners at work/school" ///
MigrMeetChurch   "Meet foreigners at church" ///
MigrMeetSport   "Meet foreigners in my sport/association" ///
MigrMeetOther   "Meet foreigners in ____ other" ///
MigrClassChild_cat   "Too many migrants in child's classroom" ///

estpost tabstat $ItaAdult ///
if (Cohort > 3), by(treatGroup) statistics(mean sd) columns(statistics)
esttab using adultRacism.tex, $options coef($ItaAdultLabel)

estpost tabstat $ItaAdult ///
if (Cohort > 3), by(City) statistics(mean sd) columns(statistics)
esttab using adultRacism2.tex, $options coef($ItaAdultLabel)

forvalue i=4/6{
estpost tabstat $ItaAdult ///
if (Cohort == `i'), by(treatGroup) statistics(mean sd) columns(statistics)
esttab using adultRacism_`i'.tex, $options coef($ItaAdultLabel)

estpost tabstat $ItaAdult ///
if (Cohort == `i'), by(City) statistics(mean sd) columns(statistics)
esttab using adultRacism2_`i'.tex, $options coef($ItaAdultLabel)
}

gen group = 1 if Cohort==3
replace group = 2 if Cohort>3

estpost tabstat  MigrTaste_cat MigrGood_cat MigrAfri_N MigrArab_N MigrFriend ///
if (Cohort >= 3), by(group) statistics(mean sd) columns(statistics)
esttab using adultRacism-new.tex, $options coef($ItaAdultLabel)

estpost tabstat  cgMigrTaste_cat cgMigrAfri_N cgMigrArab_N cgMigrFriend /// cgMigrGood_cat 
if (Cohort == 3), statistics(mean sd) columns(statistics)


/* TABFORM 
local options se sdbracket vert // sd mtprob mtest
foreach group in treatGroup cityXschool { // City 
	di "Caregivers"
	tabform $cgIta cgTrust using cgIta_`group'  if Cohort<=3, by(`group') `options'
	tabform $cgMigrant using cgMigrant_`group' if Cohort<=3, by(`group') `options'
	di "Child, Ado, Adult"
	tabform $ItaMigrChild Trust *ChildFactor using ItaMigrChild_`group' if Cohort<=2, by(`group') `options'
	tabform $ItaAdo Trust adoFactor          using ItaAdo_`group'   if Cohort==3, by(`group') `options'
	tabform $ItaAdult Trust adultFactor      using ItaAdult_`group' if Cohort>3, by(`group') `options'
}
forvalue i=4/6{
	tabform $ItaAdult Trust adultFactor using ItaAdult_treat`i' if Cohort==`i', by(treatGroup) `options'
}
*/

*============================ Make the Graphs =============================

global graphOptions over(maternaType, label(angle(45))) over(City) asyvars  ytitle("Mean") 
global graphExport replace width(800) height(600)

*--------------------------------- Children ------------------------------------
foreach var of varlist $ItaMigrChild $ItaRacial {		
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
			 yscale(range(-0.2 1))  ylabel(#8)
         	 
		restore, preserve
	
		graph export `var'_Child.png, $graphExport //export the graph
		
		restore, not
}

*--------------------------------- Migrants ------------------------------------
foreach var of varlist $ItaMigrChild $ItaRacial {
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
			 yscale(range(-0.2 1))  ylabel(#8)

		restore, preserve
	
		graph export `var'_Migrant.png, $graphExport //export the graph
		
		restore, not
}

*------------------------------- Adolescents -----------------------------------
foreach var of varlist $ItaAdo {
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
			 yscale(range(-0.2 1))  ylabel(#8)
         	 
		restore, preserve
	
		graph export `var'_Ado.png, $graphExport //export the graph
		
		restore, not
}

*--------------------------------- Adult 30 ------------------------------------
foreach var of varlist $ItaAdult {
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
			 yscale(range(-0.2 1))  ylabel(#8)
		
		restore, preserve
	
		graph export `var'_Adult30.png, $graphExport //export the graph
		
		restore, not
}

*--------------------------------- Adult 40 ------------------------------------
foreach var of varlist $ItaAdult {
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
			 yscale(range(-0.2 1))  ylabel(#8)
		restore, preserve
	
		graph export `var'_Adult40.png, $graphExport //export the graph
		
		restore, not
}

*--------------------------------- Adult 50 ------------------------------------
foreach var of varlist $ItaAdult {
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
			 yscale(range(-0.2 1))  ylabel(#8)

		restore, preserve
	
		graph export `var'_Adult50.png, $graphExport //export the graph
		
		restore, not
}

*-------------------------------- All Adults -----------------------------------
foreach var of varlist $ItaAdult {
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
			 yscale(range(-0.2 1))  ylabel(#8)

		
		restore, preserve
	
		graph export `var'_AllAdults.png, $graphExport //export the graph
		
		restore, not
}

}
*--------------------------------------------------------*
if $reg==1{ //  (item) Some Regression
use $dir/ReggioMigrant.dta, clear
cd $dir/gitReggioCode/MigrantsPB/tables

* (item) global variables for controls
global Controls CAPI Age Age_sq Male momHome06 famSize_4 famSize_5plus houseOwn /// famSize_2 famSize_3=reference category Cohort_* 
				dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni /// noDad -> omitted for collinearity
				momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni ///
				grand_nbrhood grand_city grand_far ///
				Month_int_* //i.Month_int PadovaReinterview (all the re-interviews were later, not needed if controlling for month)
				// Parma Padova //--> include every time when needed

global xmaterna xm*
global xasilo xa*
			   
global NoSchool asilo_NotAttended materna_NotAttended

global controlsMigr ytItaly yrCity momMigrant dadMigrant childMigrant speakFore

// only for children and ado
global cgPA cgPA_Unempl cgPA_OutLF cgPA_HouseWife dadPA_Unempl dadPA_OutLF cgSES_teacher cgSES_professional cgSES_self hhSES_teacher hhSES_professional hhSES_self 
global cgmStatus cgmStatus_married cgmStatus_div cgmStatus_cohab lone_parent childrenSibTot  // noDad nonMom
global Ita_other speakDial speakFore cgItaFactor //speak dialect or foreign language, no missing
global Migr_other speakDial speakFore cgMigrFactor //speak dialect or foreign language, no missing

// only for adults
global MaxEdu MaxEdu_middle MaxEdu_HS MaxEdu_Uni
global PA PA_Unempl PA_OutLF PA_HouseWife SES_teacher SES_professional SES_self
global mStatus mStatus_married mStatus_div mStatus_cohab numSiblings 

// NOTE: omitted category -- PAPI, Reggio, Female, Famsize=3,


*-* OutReg Options:
// List Variables to Be Displayed in the Latex Output (not all fit on page)
global Disp ReggioMaterna ReggioAsilo xmReggioNone xmReggioStat xmReggioPriv xaReggioNone xaReggioPriv // CAPI treated Male Parma Padova $xmaterna $xasilo
global aduDisp $Disp //Cohort_Adult30 Cohort_Adult40
// List different options for outreg -- global Options se tex fragment blankrows starlevels(10 5 1) sigsymb(*,**,***) starloc(1) summstat(N) // keep($Display)
// List of option for esttab
global Options compress nomtitles nodepvars wrap booktabs nonotes label  se(%4.3f) b(3) eqlabels(none) star(* 0.10 ** 0.05 *** 0.01) 

*-* Sample:
capture drop sample*
reg MigrTaste_cat ReggioMaterna Parma Padova $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus $xmaterna if Cohort>3, robust 
gen sampleAdult = e(sample)
reg MigrTaste_cat ReggioMaterna Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xmaterna if Cohort==3, robust
gen sampleAdo = e(sample)
reg ItaFriendFig_white ReggioMaterna Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xmaterna if Cohort==1, robust 
gen sampleChild = e(sample)
reg MigrFriendFig_white ReggioMaterna Parma Padova $Controls $cgPA $cgmStatus $Migr_other $xmaterna if Cohort==2, robust 
gen sampleMigr = e(sample)

*---* Adults
local i=0
//foreach var of varlist $ItaAdult adultFactor{
foreach var of varlist MigrTaste_cat MigrGood_cat MigrAfri_N MigrArab_N adultFactor{
//local var MigrTaste_cat
local i=`i'+1
local eq "eqAdult_`var'"
local lablvar: variable label `var'
di "`lablvar'"

eststo `eq'0: reg `var' ReggioMaterna ReggioAsilo treated Parma Padova Cohort_Adult* CAPI if sampleAdult==1 & Cohort>3, robust // [=] at some point should use logit/probit
outreg2 using ItaAdult_`i'.out, replace ctitle("Baseline") title("`lablvar'") 

eststo `eq'1a: reg `var' ReggioMaterna Parma Padova Cohort_Adult* CAPI if sampleAdult==1 & Cohort>3, robust // [=] at some point should use logit/probit
outreg2 using ItaAdult_`i'.out, append ctitle("Baseline") title("`lablvar'") 

eststo `eq'1b: reg `var' ReggioAsilo Parma Padova Cohort_Adult* CAPI if sampleAdult==1 & Cohort>3, robust // [=] at some point should use logit/probit
outreg2 using ItaAdult_`i'.out, append ctitle("Baseline") title("`lablvar'")

eststo `eq'1c: reg `var' treated Parma Padova Cohort_Adult* CAPI if sampleAdult==1 & Cohort>3, robust // [=] at some point should use logit/probit
outreg2 using ItaAdult_`i'.out, append ctitle("Baseline") title("`lablvar'")

eststo `eq'3a: reg `var' ReggioMaterna Parma Padova Cohort_Adult* $Controls  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
outreg2 using ItaAdult_`i'.out, append ctitle(" + Controls")

eststo `eq'3b: reg `var' ReggioAsilo Parma Padova Cohort_Adult* $Controls  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
outreg2 using ItaAdult_`i'.out, append ctitle(" + Controls")

eststo `eq'3c: reg `var' treated Parma Padova Cohort_Adult* $Controls  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
outreg2 using ItaAdult_`i'.out, append ctitle(" + Controls")


eststo `eq'4a: reg `var' ReggioMaterna  Parma Padova Cohort_Adult* $Controls $MaxEdu $PA $mStatus i.IncomeCat_manual  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
outreg2 using ItaAdult_`i'.out, append ctitle(" +income")

eststo `eq'4b: reg `var' ReggioAsilo Parma Padova Cohort_Adult* $Controls $MaxEdu $PA $mStatus i.IncomeCat_manual  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
outreg2 using ItaAdult_`i'.out, append ctitle(" +income")

eststo `eq'4c: reg `var' treated Parma Padova Cohort_Adult* $Controls $MaxEdu $PA $mStatus i.IncomeCat_manual  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
outreg2 using ItaAdult_`i'.out, append ctitle(" +income")

eststo `eq'5a: reg `var' ReggioMaterna Parma Padova Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus $xmaterna  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using ItaAdult_`i'.out, append ctitle(" +school")

eststo `eq'5b: reg `var' ReggioAsilo Parma Padova Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus $xasilo  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using ItaAdult_`i'.out, append ctitle(" +school")

eststo `eq'5c: reg `var' treated Parma Padova Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus $xmaterna $xasilo  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using ItaAdult_`i'.out, append ctitle(" +school")

eststo `eq'6a: reg `var' ReggioMaterna       Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus if sampleAdult==1 & Cohort>3 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using ItaAdult_`i'.out, append ctitle("Reggio Only")

eststo `eq'6b: reg `var' ReggioAsilo         Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus if sampleAdult==1 & Cohort>3 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using ItaAdult_`i'.out, append ctitle("Reggio Only")

eststo `eq'6c: reg `var' treated               Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus if sampleAdult==1 & Cohort>3 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using ItaAdult_`i'.out, append ctitle("Reggio Only")

eststo `eq'7a: reg `var' ReggioMaterna  Parma Padova Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus if sampleAdult==1 & Cohort>3 & materna_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using ItaAdult_`i'.out, append ctitle("Mun. only")

eststo `eq'7b: reg `var' ReggioAsilo Parma Padova Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus if sampleAdult==1 & Cohort>3 & asilo_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using ItaAdult_`i'.out, append ctitle("Mun. only")

eststo `eq'7b: reg `var' treated Parma Padova Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus if sampleAdult==1 & Cohort>3 & (materna_Municipal==1 | asilo_Municipal==1), robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using ItaAdult_`i'.out, append ctitle("Mun. only")

esttab `eq'4a `eq'4b `eq'5a `eq'5b `eq'6a `eq'6b using ItaAdult-`i'.tex, replace $Options ///  eq2 eq7a eq7b 
stats(controls income school reggio muni N r2 , fmt(0 0 0 0 0 0 0 3) ///
labels(`"Controls"' `"SES"' `"School types"' `"Reggio Only"' `"Mun. Only"' `"Observations"' `"\(R^{2}\)"' ) ) ///
keep($aduDisp) ///
mgroups("`lablvar'"	, pattern(1 0 0 0 0 0 0)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
}

*---* Adults: Instrumented regression
local i=0
//foreach var of varlist $ItaAdult adultFactor{
foreach var of varlist MigrTaste_cat MigrGood_cat MigrAfri_N MigrArab_N adultFactor{
//local var MigrTaste_cat
local i=`i'+1
local eq "IVAdult_`var'"
local lablvar: variable label `var'
di "`lablvar'"

eststo `eq'0: ivregress 2sls `var' (ReggioMaterna ReggioAsilo treated =  IV_distMat IV_distAsi IV_score IV_m*) distCenter Parma Padova Cohort_Adult* CAPI if sampleAdult==1 & Cohort>3, robust // [=] at some point should use logit/probit
outreg2 using IVAdult_`i'.out, replace ctitle("Baseline") title("`lablvar'") 

eststo `eq'1a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova Cohort_Adult* CAPI if sampleAdult==1 & Cohort>3, robust // [=] at some point should use logit/probit
outreg2 using IVAdult_`i'.out, append ctitle("Baseline") title("`lablvar'") 

eststo `eq'1b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova Cohort_Adult* CAPI if sampleAdult==1 & Cohort>3, robust // [=] at some point should use logit/probit
outreg2 using IVAdult_`i'.out, append ctitle("Baseline") title("`lablvar'")

eststo `eq'1c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova Cohort_Adult* CAPI if sampleAdult==1 & Cohort>3, robust // [=] at some point should use logit/probit
outreg2 using IVAdult_`i'.out, append ctitle("Baseline") title("`lablvar'")

eststo `eq'3a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova Cohort_Adult* $Controls  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle(" + Controls")

eststo `eq'3b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova Cohort_Adult* $Controls  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle(" + Controls")

eststo `eq'3c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova Cohort_Adult* $Controls  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle(" + Controls")


eststo `eq'4a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter  Parma Padova Cohort_Adult* $Controls $MaxEdu $PA $mStatus i.IncomeCat_manual  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle(" +income")

eststo `eq'4b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova Cohort_Adult* $Controls $MaxEdu $PA $mStatus i.IncomeCat_manual  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle(" +income")

eststo `eq'4c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova Cohort_Adult* $Controls $MaxEdu $PA $mStatus i.IncomeCat_manual  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle(" +income")

eststo `eq'5a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus $xmaterna  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle(" +school")

eststo `eq'5b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus $xasilo  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle(" +school")

eststo `eq'5c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus $xmaterna $xasilo  if sampleAdult==1 & Cohort>3, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle(" +school")

eststo `eq'6a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter       Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus if sampleAdult==1 & Cohort>3 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle("Reggio Only")

eststo `eq'6b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter         Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus if sampleAdult==1 & Cohort>3 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle("Reggio Only")

eststo `eq'6c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter               Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus if sampleAdult==1 & Cohort>3 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle("Reggio Only")

eststo `eq'7a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter  Parma Padova Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus if sampleAdult==1 & Cohort>3 & materna_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle("Mun. only")

eststo `eq'7b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus if sampleAdult==1 & Cohort>3 & asilo_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle("Mun. only")

eststo `eq'7b: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus if sampleAdult==1 & Cohort>3 & (materna_Municipal==1 | asilo_Municipal==1), robust 
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle("Mun. only")

esttab `eq'4a `eq'4b `eq'5a `eq'5b `eq'6a `eq'6b using IVAdult-`i'.tex, replace $Options ///  eq2 
stats(controls income school reggio muni N r2 , fmt(0 0 0 0 0 0 0 3) ///
labels(`"Controls"' `"SES"' `"School types"' `"Reggio Only"' `"Mun. Only"' `"Observations"' `"\(R^{2}\)"' ) ) ///
keep($aduDisp) ///
mgroups("`lablvar'"	, pattern(1 0 0 0 0 0 0)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
}



*---* Adults: Instrumented regression, FIRST STAGE
local i=0
//foreach var of varlist $ItaAdult adultFactor{
foreach var of varlist MigrTaste_cat MigrGood_cat MigrAfri_N MigrArab_N adultFactor{
//local var MigrTaste_cat
local i=`i'+1
local eq "IVAdult_`var'"
local lablvar: variable label `var'
di "`lablvar'"

eststo `eq'4a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter  Parma Padova Cohort_Adult* $Controls $MaxEdu $PA $mStatus i.IncomeCat_manual  if sampleAdult==1 & Cohort>3, robust first
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle(" +income")

eststo `eq'4b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova Cohort_Adult* $Controls $MaxEdu $PA $mStatus i.IncomeCat_manual  if sampleAdult==1 & Cohort>3, robust first
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle(" +income")

eststo `eq'5a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus $xmaterna  if sampleAdult==1 & Cohort>3, robust first
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle(" +school")

eststo `eq'5b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus $xasilo  if sampleAdult==1 & Cohort>3, robust first
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle(" +school")

eststo `eq'6a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter       Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus if sampleAdult==1 & Cohort>3 & Reggio==1, robust first
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle("Reggio Only")

eststo `eq'6b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter         Cohort_Adult* $Controls $MaxEdu $PA i.IncomeCat_manual $mStatus if sampleAdult==1 & Cohort>3 & Reggio==1, robust first
	estadd local controls "Yes", replace
	estadd local income   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVAdult_`i'.out, append ctitle("Reggio Only")

esttab `eq'4a `eq'4b `eq'5a `eq'5b `eq'6a `eq'6b using IVAdult-`i'_First.tex, replace $Options ///  eq2 
stats(controls income school reggio muni N r2 , fmt(0 0 0 0 0 0 0 3) ///
labels(`"Controls"' `"SES"' `"School types"' `"Reggio Only"' `"Mun. Only"' `"Observations"' `"\(R^{2}\)"' ) ) ///
keep($aduDisp) ///
mgroups("`lablvar'"	, pattern(1 0 0 0 0 0 0)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
}


//==================================================================================================================================

*---* Adolescents
local i=0
//foreach var of varlist $ItaAdolescent adoFactor{
foreach var of varlist MigrTaste_cat MigrGood_cat MigrAfri_N MigrArab_N adoFactor{
//local var MigrTaste_cat
local i=`i'+1
local eq "eqAdo_`var'"
local lablvar: variable label `var'
di "`lablvar'"

eststo `eq'0: reg `var' ReggioMaterna ReggioAsilo treated Parma Padova CAPI if sampleAdo==1 & Cohort==3, robust // [=] at some point should use logit/probit
outreg2 using ItaAdo_`i'.out, replace ctitle("Baseline") title("`lablvar'") 

eststo `eq'1a: reg `var' ReggioMaterna Parma Padova CAPI if sampleAdo==1 & Cohort==3, robust // [=] at some point should use logit/probit
outreg2 using ItaAdo_`i'.out, append ctitle("Baseline") title("`lablvar'") 

eststo `eq'1b: reg `var' ReggioAsilo Parma Padova CAPI if sampleAdo==1 & Cohort==3, robust // [=] at some point should use logit/probit
outreg2 using ItaAdo_`i'.out, append ctitle("Baseline") title("`lablvar'")

eststo `eq'1c: reg `var' treated Parma Padova CAPI if sampleAdo==1 & Cohort==3, robust // [=] at some point should use logit/probit
outreg2 using ItaAdo_`i'.out, append ctitle("Baseline") title("`lablvar'")

eststo `eq'3a: reg `var' ReggioMaterna Parma Padova $Controls $cgPA $cgmStatus $cgPA $cgmStatus  if sampleAdo==1 & Cohort==3, robust 
	estadd local controls "Yes", replace
outreg2 using ItaAdo_`i'.out, append ctitle(" + Controls")

eststo `eq'3b: reg `var' ReggioAsilo Parma Padova $Controls $cgPA $cgmStatus  if sampleAdo==1 & Cohort==3, robust 
	estadd local controls "Yes", replace
outreg2 using ItaAdo_`i'.out, append ctitle(" + Controls")

eststo `eq'3c: reg `var' treated Parma Padova $Controls $cgPA $cgmStatus  if sampleAdo==1 & Cohort==3, robust 
	estadd local controls "Yes", replace
outreg2 using ItaAdo_`i'.out, append ctitle(" + Controls")


eststo `eq'4a: reg `var' ReggioMaterna  Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using ItaAdo_`i'.out, append ctitle(" +mom")

eststo `eq'4b: reg `var' ReggioAsilo Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using ItaAdo_`i'.out, append ctitle(" +mom")

eststo `eq'4c: reg `var' treated Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using ItaAdo_`i'.out, append ctitle(" +mom")

eststo `eq'5a: reg `var' ReggioMaterna Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xmaterna  if sampleAdo==1 & Cohort==3, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using ItaAdo_`i'.out, append ctitle(" +school")

eststo `eq'5b: reg `var' ReggioAsilo Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xasilo  if sampleAdo==1 & Cohort==3, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using ItaAdo_`i'.out, append ctitle(" +school")

eststo `eq'5c: reg `var' treated Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xmaterna $xasilo  if sampleAdo==1 & Cohort==3, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using ItaAdo_`i'.out, append ctitle(" +school")

eststo `eq'6a: reg `var' ReggioMaterna  $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using ItaAdo_`i'.out, append ctitle("Reggio Only")

eststo `eq'6b: reg `var' ReggioAsilo    $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using ItaAdo_`i'.out, append ctitle("Reggio Only")

eststo `eq'6c: reg `var' treated     $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using ItaAdo_`i'.out, append ctitle("Reggio Only")

eststo `eq'7a: reg `var' ReggioMaterna  Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3 & materna_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using ItaAdo_`i'.out, append ctitle("Mun. only")

eststo `eq'7b: reg `var' ReggioAsilo Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3 & asilo_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using ItaAdo_`i'.out, append ctitle("Mun. only")

eststo `eq'7b: reg `var' treated Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3 & (materna_Municipal==1 | asilo_Municipal==1), robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using ItaAdo_`i'.out, append ctitle("Mun. only")

esttab `eq'4a `eq'4b `eq'5a `eq'5b `eq'6a `eq'6b using ItaAdo-`i'.tex, replace $Options ///  `eq'2 
stats(controls mom school reggio muni N r2 , fmt(0 0 0 0 0 0 0 3) ///
labels(`"Controls"' `"Mom beliefs"' `"School types"' `"Reggio Only"' `"Mun. Only"' `"Observations"' `"\(R^{2}\)"' ) ) ///
keep($Disp) ///
mgroups("`lablvar'"	, pattern(1 0 0 0 0 0 0)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
}

*---* Adolescents: Instrumented regression
local i=0
//foreach var of varlist $ItaAdolescent adoFactor{
foreach var of varlist MigrTaste_cat MigrGood_cat MigrAfri_N MigrArab_N adoFactor{
//local var MigrTaste_cat
local i=`i'+1
local eq "IVAdo_`var'"
local lablvar: variable label `var'
di "`lablvar'"

eststo `eq'0: ivregress 2sls `var' (ReggioMaterna ReggioAsilo treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter distCenter Parma Padova CAPI if sampleAdo==1 & Cohort==3, robust // [=] at some point should use logit/probit
outreg2 using IVAdo_`i'.out, replace ctitle("Baseline") title("`lablvar'") 

eststo `eq'1a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova CAPI if sampleAdo==1 & Cohort==3, robust // [=] at some point should use logit/probit
outreg2 using IVAdo_`i'.out, replace ctitle("Baseline") title("`lablvar'") 

eststo `eq'1b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova CAPI if sampleAdo==1 & Cohort==3, robust // [=] at some point should use logit/probit
outreg2 using IVAdo_`i'.out, append ctitle("Baseline") title("`lablvar'")

eststo `eq'1c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova CAPI if sampleAdo==1 & Cohort==3, robust // [=] at some point should use logit/probit
outreg2 using IVAdo_`i'.out, append ctitle("Baseline") title("`lablvar'")

eststo `eq'3a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus  if sampleAdo==1 & Cohort==3, robust 
	estadd local controls "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle(" + Controls")

eststo `eq'3b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus  if sampleAdo==1 & Cohort==3, robust 
	estadd local controls "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle(" + Controls")

eststo `eq'3c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus  if sampleAdo==1 & Cohort==3, robust 
	estadd local controls "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle(" + Controls")

eststo `eq'4a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter  Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle(" +mom")

eststo `eq'4b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle(" +mom")

eststo `eq'4c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle(" +mom")

eststo `eq'5a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xmaterna  if sampleAdo==1 & Cohort==3, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle(" +school")

eststo `eq'5b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xasilo  if sampleAdo==1 & Cohort==3, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle(" +school")

eststo `eq'5c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xmaterna $xasilo  if sampleAdo==1 & Cohort==3, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle(" +school")

eststo `eq'6a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle("Reggio Only")

eststo `eq'6b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle("Reggio Only")

eststo `eq'6c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter  $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle("Reggio Only")

eststo `eq'7a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter  Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3 & materna_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle("Mun. only")

eststo `eq'7b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3 & asilo_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle("Mun. only")

eststo `eq'7b: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3 & (materna_Municipal==1 | asilo_Municipal==1), robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle("Mun. only")

esttab `eq'4a `eq'4b `eq'5a `eq'5b `eq'6a `eq'6b using IVAdo-`i'.tex, replace $Options ///  `eq'2 
stats(controls mom school reggio muni N r2 , fmt(0 0 0 0 0 0 0 3) ///
labels(`"Controls"' `"SES"' `"School types"' `"Reggio Only"' `"Mun. Only"' `"Observations"' `"\(R^{2}\)"' ) ) ///
keep($Disp) ///
mgroups("`lablvar'"	, pattern(1 0 0 0 0 0 0)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
}


*---* Adolescents: Instrumented regression, FIRST STAGE
local i=0
//foreach var of varlist $ItaAdolescent adoFactor{
foreach var of varlist MigrTaste_cat MigrGood_cat MigrAfri_N MigrArab_N adoFactor{
//local var MigrTaste_cat
local i=`i'+1
local eq "IVAdo_`var'"
local lablvar: variable label `var'
di "`lablvar'"

eststo `eq'4a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter  Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle(" +mom")

eststo `eq'4b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3, robust first 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle(" +mom")

eststo `eq'5a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xmaterna  if sampleAdo==1 & Cohort==3, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle(" +school")

eststo `eq'5b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xasilo  if sampleAdo==1 & Cohort==3, robust first 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle(" +school")

eststo `eq'6a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3 & Reggio==1, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle("Reggio Only")

eststo `eq'6b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter $Controls $cgPA $cgmStatus $Ita_other if sampleAdo==1 & Cohort==3 & Reggio==1, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVAdo_`i'.out, append ctitle("Reggio Only")

esttab `eq'4a `eq'4b `eq'5a `eq'5b `eq'6a `eq'6b using IVAdo-`i'_First.tex, replace $Options ///  `eq'2 
stats(controls mom school reggio muni N r2 , fmt(0 0 0 0 0 0 0 3) ///
labels(`"Controls"' `"SES"' `"School types"' `"Reggio Only"' `"Mun. Only"' `"Observations"' `"\(R^{2}\)"' ) ) ///
keep($Disp) ///
mgroups("`lablvar'"	, pattern(1 0 0 0 0 0 0)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
}

//================================================================================================================================

*---* Italian Child
local i=0
foreach var of varlist Ita*_white Ita*_black ItaChildFactor{
local i=`i'+1
local eq "`var'"
local lablvar: variable label `var'
di "`lablvar'"

eststo `eq'0: reg `var' ReggioMaterna ReggioAsilo treated Parma Padova CAPI if sampleChild==1 & Cohort==1, robust // [=] at some point should use logit/probit
outreg2 using ItaChild_`i'.out, replace ctitle("Baseline") title("`lablvar'") 

eststo `eq'1a: reg `var' ReggioMaterna Parma Padova CAPI if sampleChild==1 & Cohort==1, robust // [=] at some point should use logit/probit
outreg2 using ItaChild_`i'.out, append ctitle("Baseline") title("`lablvar'") 

eststo `eq'1b: reg `var' ReggioAsilo Parma Padova CAPI if sampleChild==1 & Cohort==1, robust // [=] at some point should use logit/probit
outreg2 using ItaChild_`i'.out, append ctitle("Baseline") title("`lablvar'")

eststo `eq'1c: reg `var' treated Parma Padova CAPI if sampleChild==1 & Cohort==1, robust // [=] at some point should use logit/probit
outreg2 using ItaChild_`i'.out, append ctitle("Baseline") title("`lablvar'")

eststo `eq'3a: reg `var' ReggioMaterna Parma Padova $Controls $cgPA $cgmStatus $cgPA $cgmStatus  if sampleChild==1 & Cohort==1, robust 
	estadd local controls "Yes", replace
outreg2 using ItaChild_`i'.out, append ctitle(" + Controls")

eststo `eq'3b: reg `var' ReggioAsilo Parma Padova $Controls $cgPA $cgmStatus  if sampleChild==1 & Cohort==1, robust 
	estadd local controls "Yes", replace
outreg2 using ItaChild_`i'.out, append ctitle(" + Controls")

eststo `eq'3c: reg `var' treated Parma Padova $Controls $cgPA $cgmStatus  if sampleChild==1 & Cohort==1, robust 
	estadd local controls "Yes", replace
outreg2 using ItaChild_`i'.out, append ctitle(" + Controls")


eststo `eq'4a: reg `var' ReggioMaterna  Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using ItaChild_`i'.out, append ctitle(" +mom")

eststo `eq'4b: reg `var' ReggioAsilo Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using ItaChild_`i'.out, append ctitle(" +mom")

eststo `eq'4c: reg `var' treated Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using ItaChild_`i'.out, append ctitle(" +mom")

eststo `eq'5a: reg `var' ReggioMaterna Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xmaterna  if sampleChild==1 & Cohort==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using ItaChild_`i'.out, append ctitle(" +school")

eststo `eq'5b: reg `var' ReggioAsilo Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xasilo  if sampleChild==1 & Cohort==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using ItaChild_`i'.out, append ctitle(" +school")

eststo `eq'5c: reg `var' treated Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xmaterna $xasilo  if sampleChild==1 & Cohort==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using ItaChild_`i'.out, append ctitle(" +school")

eststo `eq'6a: reg `var' ReggioMaterna  $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using ItaChild_`i'.out, append ctitle("Reggio Only")

eststo `eq'6b: reg `var' ReggioAsilo    $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using ItaChild_`i'.out, append ctitle("Reggio Only")

eststo `eq'6c: reg `var' treated     $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using ItaChild_`i'.out, append ctitle("Reggio Only")

eststo `eq'7a: reg `var' ReggioMaterna  Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1 & materna_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using ItaChild_`i'.out, append ctitle("Mun. only")

eststo `eq'7b: reg `var' ReggioAsilo Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1 & asilo_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using ItaChild_`i'.out, append ctitle("Mun. only")

eststo `eq'7b: reg `var' treated Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1 & (materna_Municipal==1 | asilo_Municipal==1), robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using ItaChild_`i'.out, append ctitle("Mun. only")

esttab `eq'4a `eq'4b `eq'5a `eq'5b `eq'6a `eq'6b using ItaChild-`i'.tex, replace $Options ///  eq2 
stats(controls mom school reggio muni N r2 , fmt(0 0 0 0 0 0 0 3) ///
labels(`"Controls"' `"Mom beliefs"' `"School types"' `"Reggio Only"' `"Mun. Only"' `"Observations"' `"\(R^{2}\)"' ) ) ///
keep($Disp) ///
mgroups("`lablvar'"	, pattern(1 0 0 0 0 0 0)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
}

*---* Italian Child: Instrumented regression
local i=0
foreach var of varlist Ita*_white Ita*_black ItaChildFactor{
local i=`i'+1
local eq "IV_`var'"
local lablvar: variable label `var'
di "`lablvar'"

eststo `eq'0: ivregress 2sls `var' (ReggioMaterna ReggioAsilo treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter distCenter Parma Padova CAPI if sampleChild==1 & Cohort==1, robust // [=] at some point should use logit/probit
outreg2 using IVItaChild_`i'.out, replace ctitle("Baseline") title("`lablvar'") 

eststo `eq'1a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova CAPI if sampleChild==1 & Cohort==1, robust // [=] at some point should use logit/probit
outreg2 using IVItaChild_`i'.out, replace ctitle("Baseline") title("`lablvar'") 

eststo `eq'1b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova CAPI if sampleChild==1 & Cohort==1, robust // [=] at some point should use logit/probit
outreg2 using IVItaChild_`i'.out, append ctitle("Baseline") title("`lablvar'")

eststo `eq'1c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova CAPI if sampleChild==1 & Cohort==1, robust // [=] at some point should use logit/probit
outreg2 using IVItaChild_`i'.out, append ctitle("Baseline") title("`lablvar'")

eststo `eq'3a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus  if sampleChild==1 & Cohort==1, robust 
	estadd local controls "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle(" + Controls")

eststo `eq'3b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus  if sampleChild==1 & Cohort==1, robust 
	estadd local controls "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle(" + Controls")

eststo `eq'3c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus  if sampleChild==1 & Cohort==1, robust 
	estadd local controls "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle(" + Controls")

eststo `eq'4a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter  Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle(" +mom")

eststo `eq'4b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle(" +mom")

eststo `eq'4c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle(" +mom")

eststo `eq'5a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xmaterna  if sampleChild==1 & Cohort==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle(" +school")

eststo `eq'5b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xasilo  if sampleChild==1 & Cohort==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle(" +school")

eststo `eq'5c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xmaterna $xasilo  if sampleChild==1 & Cohort==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle(" +school")

eststo `eq'6a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle("Reggio Only")

eststo `eq'6b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle("Reggio Only")

eststo `eq'6c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter  $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle("Reggio Only")

eststo `eq'7a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter  Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1 & materna_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle("Mun. only")

eststo `eq'7b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1 & asilo_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle("Mun. only")

eststo `eq'7b: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1 & (materna_Municipal==1 | asilo_Municipal==1), robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle("Mun. only")

esttab `eq'4a `eq'4b `eq'5a `eq'5b `eq'6a `eq'6b using IVItaChild-`i'.tex, replace $Options ///  eq2 
stats(controls mom school reggio muni N r2 , fmt(0 0 0 0 0 0 0 3) ///
labels(`"Controls"' `"SES"' `"School types"' `"Reggio Only"' `"Mun. Only"' `"Observations"' `"\(R^{2}\)"' ) ) ///
keep($Disp) ///
mgroups("`lablvar'"	, pattern(1 0 0 0 0 0 0)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
}


*---* Italian Child: Instrumented regression, FIRST STAGE
local i=0
foreach var of varlist Ita*_white Ita*_black ItaChildFactor{
local i=`i'+1
local eq "IV_`var'"
local lablvar: variable label `var'
di "`lablvar'"

eststo `eq'4a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter  Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle(" +mom")

eststo `eq'4b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle(" +mom")

eststo `eq'5a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xmaterna  if sampleChild==1 & Cohort==1, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle(" +school")

eststo `eq'5b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Ita_other $xasilo  if sampleChild==1 & Cohort==1, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle(" +school")

eststo `eq'6a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1 & Reggio==1, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle("Reggio Only")

eststo `eq'6b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter $Controls $cgPA $cgmStatus $Ita_other if sampleChild==1 & Cohort==1 & Reggio==1, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVItaChild_`i'.out, append ctitle("Reggio Only")

esttab `eq'4a `eq'4b `eq'5a `eq'5b `eq'6a `eq'6b using IVItaChild-`i'_First.tex, replace $Options ///  eq2 
stats(controls mom school reggio muni N r2 , fmt(0 0 0 0 0 0 0 3) ///
labels(`"Controls"' `"SES"' `"School types"' `"Reggio Only"' `"Mun. Only"' `"Observations"' `"\(R^{2}\)"' ) ) ///
keep($Disp) ///
mgroups("`lablvar'"	, pattern(1 0 0 0 0 0 0)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
}

//==========================================================================================================

*---* Migrant Child
local i=0
foreach var of varlist Migr*_white Migr*_black MigrChildFactor{
local i=`i'+1
local eq "`var'"
local lablvar: variable label `var'
di "`lablvar'"

eststo `eq'0: reg `var' ReggioMaterna ReggioAsilo treated Parma Padova CAPI if sampleMigr==1 & Cohort==2, robust // [=] at some point should use logit/probit
outreg2 using MigrChild_`i'.out, replace ctitle("Baseline") title("`lablvar'") 

eststo `eq'1a: reg `var' ReggioMaterna Parma Padova CAPI if sampleMigr==1 & Cohort==2, robust // [=] at some point should use logit/probit
outreg2 using MigrChild_`i'.out, append ctitle("Baseline") title("`lablvar'") 

eststo `eq'1b: reg `var' ReggioAsilo Parma Padova CAPI if sampleMigr==1 & Cohort==2, robust // [=] at some point should use logit/probit
outreg2 using MigrChild_`i'.out, append ctitle("Baseline") title("`lablvar'")

eststo `eq'1c: reg `var' treated Parma Padova CAPI if sampleMigr==1 & Cohort==2, robust // [=] at some point should use logit/probit
outreg2 using MigrChild_`i'.out, append ctitle("Baseline") title("`lablvar'")

eststo `eq'3a: reg `var' ReggioMaterna Parma Padova $Controls $cgPA $cgmStatus $cgPA $cgmStatus  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle(" + Controls")

eststo `eq'3b: reg `var' ReggioAsilo Parma Padova $Controls $cgPA $cgmStatus  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle(" + Controls")

eststo `eq'3c: reg `var' treated Parma Padova $Controls $cgPA $cgmStatus  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle(" + Controls")

eststo `eq'4a: reg `var' ReggioMaterna  Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle(" +mom")

eststo `eq'4b: reg `var' ReggioAsilo Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle(" +mom")

eststo `eq'4c: reg `var' treated Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle(" +mom")

eststo `eq'5a: reg `var' ReggioMaterna Parma Padova $Controls $cgPA $cgmStatus $Migr_other $xmaterna  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle(" +school")

eststo `eq'5b: reg `var' ReggioAsilo Parma Padova $Controls $cgPA $cgmStatus $Migr_other $xasilo  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle(" +school")

eststo `eq'5c: reg `var' treated Parma Padova $Controls $cgPA $cgmStatus $Migr_other $xmaterna $xasilo  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle(" +school")

eststo `eq'6a: reg `var' ReggioMaterna  $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle("Reggio Only")

eststo `eq'6b: reg `var' ReggioAsilo    $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle("Reggio Only")

eststo `eq'6c: reg `var' treated     $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle("Reggio Only")

eststo `eq'7a: reg `var' ReggioMaterna  Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & materna_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle("Mun. only")

eststo `eq'7b: reg `var' ReggioAsilo Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & asilo_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle("Mun. only")

eststo `eq'7b: reg `var' treated Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & (materna_Municipal==1 | asilo_Municipal==1), robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle("Mun. only")

esttab `eq'4a `eq'4b `eq'5a `eq'5b `eq'6a `eq'6b using MigrChild-`i'.tex, replace $Options ///  `eq'2 
stats(controls mom school reggio muni N r2 , fmt(0 0 0 0 0 0 0 3) ///
labels(`"Controls"' `"Mom beliefs"' `"School types"' `"Reggio Only"' `"Mun. Only"' `"Observations"' `"\(R^{2}\)"' ) ) ///
keep($Disp) ///
mgroups("`lablvar'"	, pattern(1 0 0 0 0 0 0)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
}

*---* Migrant Child: Instrumented regression
local i=0
foreach var of varlist Migr*_white Migr*_black MigrChildFactor{
local i=`i'+1
local eq "IV_`var'"
local lablvar: variable label `var'
di "`lablvar'"

eststo `eq'0: ivregress 2sls `var' (ReggioMaterna ReggioAsilo treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter distCenter Parma Padova CAPI if sampleMigr==1 & Cohort==2, robust // [=] at some point should use logit/probit
outreg2 using IVMigrChild_`i'.out, replace ctitle("Baseline") title("`lablvar'") 

eststo `eq'1a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova CAPI if sampleMigr==1 & Cohort==2, robust // [=] at some point should use logit/probit
outreg2 using IVMigrChild_`i'.out, replace ctitle("Baseline") title("`lablvar'") 

eststo `eq'1b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova CAPI if sampleMigr==1 & Cohort==2, robust // [=] at some point should use logit/probit
outreg2 using IVMigrChild_`i'.out, append ctitle("Baseline") title("`lablvar'")

eststo `eq'1c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova CAPI if sampleMigr==1 & Cohort==2, robust // [=] at some point should use logit/probit
outreg2 using IVMigrChild_`i'.out, append ctitle("Baseline") title("`lablvar'")

eststo `eq'3a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle(" + Controls")

eststo `eq'3b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle(" + Controls")

eststo `eq'3c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle(" + Controls")

eststo `eq'4a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter  Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle(" +mom")

eststo `eq'4b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle(" +mom")

eststo `eq'4c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle(" +mom")

eststo `eq'5a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Migr_other $xmaterna  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle(" +school")

eststo `eq'5b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Migr_other $xasilo  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle(" +school")

eststo `eq'5c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Migr_other $xmaterna $xasilo  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle(" +school")

eststo `eq'6a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("Reggio Only")

eststo `eq'6b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("Reggio Only")

eststo `eq'6c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter  $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("Reggio Only")

eststo `eq'7a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter  Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & materna_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("Mun. only")

eststo `eq'7b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & asilo_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("Mun. only")

eststo `eq'7b: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & (materna_Municipal==1 | asilo_Municipal==1), robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("Mun. only")

esttab `eq'4a `eq'4b `eq'5a `eq'5b `eq'6a `eq'6b using IVMigrChild-`i'.tex, replace $Options ///  eq2 
stats(controls mom school reggio muni N r2 , fmt(0 0 0 0 0 0 0 3) ///
labels(`"Controls"' `"SES"' `"School types"' `"Reggio Only"' `"Mun. Only"' `"Observations"' `"\(R^{2}\)"' ) ) ///
keep($Disp) ///
mgroups("`lablvar'"	, pattern(1 0 0 0 0 0 0)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
} // end of foreach var loop


*---* Migrant Child: Instrumented regression, First Stage
local i=0
foreach var of varlist Migr*_white Migr*_black MigrChildFactor{
local i=`i'+1
local eq "IV_`var'"
local lablvar: variable label `var'
di "`lablvar'"

eststo `eq'4a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter  Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle(" +mom")

eststo `eq'4b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle(" +mom")

eststo `eq'5a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Migr_other $xmaterna  if sampleMigr==1 & Cohort==2, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle(" +school")

eststo `eq'5b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Migr_other $xasilo  if sampleMigr==1 & Cohort==2, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle(" +school")

eststo `eq'6a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & Reggio==1, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("Reggio Only")

eststo `eq'6b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & Reggio==1, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("Reggio Only")

esttab `eq'4a `eq'4b `eq'5a `eq'5b `eq'6a `eq'6b using IVMigrChild-`i'_First.tex, replace $Options ///  eq2 
stats(controls mom school reggio muni N r2 , fmt(0 0 0 0 0 0 0 3) ///
labels(`"Controls"' `"SES"' `"School types"' `"Reggio Only"' `"Mun. Only"' `"Observations"' `"\(R^{2}\)"' ) ) ///
keep($Disp) ///
mgroups("`lablvar'"	, pattern(1 0 0 0 0 0 0)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
} // end of foreach var loop

} // end of if loop

cd ../.. // back to Data
capture log close
