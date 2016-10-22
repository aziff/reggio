clear all
set more off
capture log close

global dir "/mnt/Data/Dropbox/ReggioChildren"
global dir "C:/Users/pbiroli/Dropbox/ReggioChildren"
//global dir "C:/Users/Pronzato/Dropbox/ReggioChildren"

cd "$dir/Analysis/chiara&daniela/output"

local day=subinstr("$S_DATE"," ","",.)
log using "ado_regression`day'.log", text replace

**** ONLY COHORT 1994 
**** 20 regressions

*** INFANT-TODDLER (10 regressions)
** sample: RC versus noRC in Reggio
* 1) OLS 
* 2) IV
* 3) CF
** sample: RC versus noRC in Parma and Padua
* 4) OLS 
* 5) PSM (tradional)
* 6) PSM (with demand and supply)
** sample: RC versus noRC in Reggio, Parma and Padua
* 7) OLS with Parma 
* 8) diff-in-diff with Parma
* 9) OLS with Padova
* 10) diff-in-diff with Padova

*** PRE-SCHOOL (10 regressions)
** sample: RC versus noRC in Parma and Padua
* 11) OLS 
* 12) IV
* 13) CF
** sample: RC versus noRC in Parma and Padua
* 14) OLS 
* 15) PSM (tradional)
* 16) PSM (with demand and supply)
** sample: RC versus noRC in Reggio, Parma and Padua
* 17) OLS with Parma 
* 18) diff-in-diff with Parma
* 19) OLS with Padova
* 20) diff-in-diff with Padova

********************************************************************************
*** COHORT 1994

//use "$dir/SURVEY_DATA_COLLECTION/data/Reggio.dta", clear
use "$dir/Analysis/chiara&daniela/do/Reggio1994outcomes.dta", clear

*** only adolescents
keep if Cohort == 3
count

*** childcare variables

sum ReggioAsilo ReggioMaterna
sum ReggioAsilo ReggioMaterna if(Reggio == 1)
sum ReggioAsilo ReggioMaterna if(Reggio == 0)

tab asilo
tab asilo, nol m
gen nido = (asilo == 1)
replace nido = . if(asilo > 3)
tab nido, m
tab nido ReggioAsilo if(Reggio == 1), m

*** control variables

sum Age Male

gen  poorBHealth=(lowbirthweight==1|birthpremature==1) 
sum poorBHealth

gen  oldsibs=0
forvalues i = 3/10 {
replace oldsibs=oldsibs+1*(Relation`i'==11&year`i'<1994) 
}
sum oldsibs
replace oldsibs=1 if oldsibs>=1 & oldsibs<.

sum momMaxEdu_Uni dadMaxEdu_Uni
gen dadMaxEdu_Uni_F=dadMaxEdu_Uni
replace dadMaxEdu_Uni_F=0 if dadMaxEdu_Uni==.
gen dadMaxEdu_Uni_Miss=dadMaxEdu_Uni==.
gen momMaxEdu_Uni_F=momMaxEdu_Uni
replace momMaxEdu_Uni_F=0 if momMaxEdu_Uni==.
gen momMaxEdu_Uni_Miss=momMaxEdu_Uni==.
sum momMaxEdu_Uni_* dadMaxEdu_Uni_*

tab cgIncomeCat, g(IncCat_)
gen HighInc=(IncCat_5==1|IncCat_6==1) if !mi(cgIncomeCat)
gen HighInc_F=HighInc
replace HighInc_F=0 if HighInc==.
gen HighInc_Miss=HighInc==.
sum HighInc_F HighInc_Miss

sum houseOwn
gen houseOwn_F = houseOwn if(houseOwn! = .)
gen houseOwn_Miss = (houseOwn == .)
replace houseOwn_F = 0 if(houseOwn == .)
sum houseOwn_*

sum distCenter

sum cgRelig 
replace cgRelig = . if(cgRelig > 1)
gen cgRelig_F = cgRelig if(cgRelig != .)
gen cgRelig_Miss = (cgRelig == .)
replace cgRelig_F = 0 if(cgRelig == .)
sum cgRelig_*

sum CAPI

*** instrumental variables

sum cgAsilo cgMaterna
gen cgAsilo_F = cgAsilo if(cgAsilo != .)
gen cgAsilo_Miss = (cgAsilo == .)
replace cgAsilo_F = 0 if(cgAsilo == .)
gen cgMaterna_F = cgMaterna if(cgMaterna != .)
gen cgMaterna_Miss = (cgMaterna == .)
replace cgMaterna_F = 0 if(cgMaterna == .)
sum cgAsilo_* cgMaterna_*
label var cgAsilo_F "Caregiver attended asilo"
label var cgMaterna_F "Caregiver attended materna"

sum score
sum score, d
gen score25 = (score <= r(p25))
gen score50 = (score > r(p25) & score <= r(p50))
gen score75 = (score > r(p50) & score <= r(p75))
label var score25 "25th pct of RA admission score"
label var score50 "50th pct of RA admission score"
label var score75 "75th pct of RA admission score"

sum distAsiloMunicipal1 distMaternaMunicipal1
sum distAsiloMunicipal1
gen distanza2 = distAsiloMunicipal1^2
gen distanza3 = distAsiloMunicipal1^3
label var distanza2 "square ditance to municipal asilo"
label var distanza3 "cube distance to municipal asilo"

sum momBornProvince dadBornProvince
gen momBornProvince_F = momBornProvince if(momBornProvince != .)
gen momBornProvince_Miss = (momBornProvince == .)
replace momBornProvince_F = 0 if (momBornProvince == .)
gen dadBornProvince_F = dadBornProvince if(dadBornProvince != .)
gen dadBornProvince_Miss = (dadBornProvince == .)
replace dadBornProvince_F = 0 if (dadBornProvince == .)
sum momBornProvince_* dadBornProvince_*
label var momBornProvince_F "mom born in current province"
label var dadBornProvince_F "dad born in current province"

tab grandDist, m
tab grandDist, m nol
gen grandClose_F = (grandDist <= 4)
gen grandClose_Miss = (grandDist > 7)
sum grandClose_*
label var grandClose_F "grandparents lived in same city"

gen distA_MomEd=distAsiloMunicipal1*momMaxEdu_Uni_F
gen distM_MomEd=distMaternaMunicipal1*momMaxEdu_Uni_F
gen distA_MomBorn=distAsiloMunicipal1*momBornProvince_F
gen distM_MomBorn=distMaternaMunicipal1*momBornProvince_F
sum distA_Mom* distM_Mom*
label var distA_MomEd "distance asilo municipal x mom university edu"
label var distM_MomEd "distance materna municipal x mom university edu"
label var distA_MomBorn "distance asilo municipal x mom born in province"
label var distM_MomBorn "distance materna municipal x mom born in province"

gen distA_oldsibs = distAsiloMunicipal1*oldsibs
label var distA_oldsibs "distance asilo municipal x older sibs dummy"

gen distA_momBornProvince = distAsiloMunicipal1*momBornProvince
label var distA_oldsibs "distance asilo municipal x mother born in province"


gen distM_cgRelig_F = distMaternaMunicipal1*cgRelig_F
label var distM_cgRelig_F "distance materna municipal x religious caregiver"

gen distMR_relig = distMaternaReligious1*cgRelig_F
label var distMR_relig "distance materna religious x religious caregiver"

gen score75_momBornProvince = score75*momBornProvince
label var score75_momBornProvince "3rd quartile score x mother born in province"

gen score50_momBornProvince = score50*momBornProvince
label var score50_momBornProvince "2nd quartile score x mother born in province"


*** global
global outcomes childNone_diag childSnackFruit childSnackIce IQ1 IQ2 IQ3 IQ4 IQ5 IQ6 IQ7 IQ8 IQ9 IQ10 IQ11 IQ12 ///
childinvSex dropoutSchool SnackFruit SnackIce  goSchoolbus goSchoolfoot goSchoolbike  takeCareOth volunteer club facebookSocNet  discrNo ///
MigrFriend optimist optimist2 SextalkMom SextalkDad SextalkSib SextalkRelative SextalkGirl SextalkBoy SextalkOther MigrClassIntegr_bin BMI_cat_bin ///
difficultiesSit difficultiesInterest difficultiesObey difficultiesEat ///
childAsthma_diag childAllerg_diag childDigest_diag childEmot_diag childSleep_diag childGums_diag childOther_diag childSnackNo childSnackCan childSnackRoll  ///
childSnackChips childSnackOther SnackCandy SnackRoll SnackChips goSchoolCar goSchoolmoto MigrMeetNo ///
pessimist pessimist2 single  SextalkNo SmokeEver Smoke Maria Drink RiskSuspended ///
childinvFriends_bin ///
childSleep_bin childHeight_bin childBreakfast_bin childFruit_bin sportTogether_bin ///
IQ_score_bin IQ_factor_bin childSDQHype1_bin childSDQHype2_bin childSDQHype3_bin childSDQEmot1_bin childSDQEmot2_bin ///
childSDQEmot3_bin childSDQEmot4_bin childSDQEmot5_bin childSDQCond1_bin childSDQCond3_bin childSDQCond4_bin childSDQCond5_bin childSDQPeer1_bin childSDQPeer4_bin childSDQPeer5_bin ///
childinvTalkdad_bin  childinvFriendsMeet_bin childinvFriendsGender_bin ///
sport_bin Friends_bin TimeUseless_bin Stress_bin MigrProgram_bin MigrTaste_bin MigrGood_bin closeMom_bin closeDad_bin Locus3_bin reciprocity1_bin reciprocity3_bin SatisHealth_bin SatisSchool_bin ///
SatisFamily_bin Depress05_bin Depress08_bin Smoke1Age_bin Drink1Age_bin ProbMarry25_bin ProbGrad_bin ProbRich_bin ProbLive80_bin ProbBabies_bin Trust2_bin Trust3_bin Trust_bin ///
difficulties_bin childHealth_bin childSickDays_bin childWeight_bin childDoctor_bin childBMI_bin childTotal_diag_bin ///
childSDQPsoc1_bin childSDQPsoc2_bin childSDQPsoc3_bin childSDQPsoc4_bin childSDQPsoc5_bin ///
childSDQHype4_bin childSDQHype5_bin childSDQCond2_bin childSDQPeer2_bin childSDQPeer3_bin ///
childSDQPeer_score_bin childSDQPsoc_score_bin childSDQEmot_score_bin childSDQHype_score_bin childSDQCond_score_bin ///
childSDQ_score_bin childSDQ_factor_bin SDQ_score_bin SDQ_factor_bin ///
childinvOutWho_bin childinvOutWhen_bin childinvOutWhere_bin childinvTalkSchool_bin childinvTalkOut_bin childinvTalkmom_bin ///
childinvPeerpres_bin likeSchool_ado_bin likeMath_ado_bin likeItal_bin likeScience_bin likeLang_bin impSchool_bin uniGoProb_bin Health_bin Breakfast_bin Fruit_bin ///
PC_hrs_bin videoG_hrs_bin TV_hrs_bin screen_hrs_bin Weight_bin SocialMeet_bin TimeSelf_bin TimeParent_bin TimeRelat_bin TimeStudy_bin TimeFriend_bin TimeFree_bin TimeRest_bin ///
MigrIntegr_bin MigrAttitude_bin Locus1_bin Locus2_bin Locus4_bin LocusControl_bin reciprocity2_bin reciprocity4_bin Depress01_bin Depress02_bin Depress03_bin Depress04_bin Depress06_bin Depress07_bin ///
Depress09_bin Depress10_bin Depression_bin Cig_bin DrinkNum_bin RiskLie_bin RiskDanger_bin RiskSkip_bin RiskRob_bin RiskFight_bin RiskNota_bin RiskPirate_bin RiskDUI_bin Trust1_bin Satisfied

sum $outcomes, sep(0)

global outchosen Friends_bin childinvTalkOut_bin childinvTalkSchool_bin  closeDad_bin closeMom_bin childSDQ_score_bin BMI_cat_bin childHealth_bin childNone_diag childSnackNo childSnackFruit SmokeEver Drink ///
                 difficultiesInterest difficultiesSit dropoutSchool likeSchool_ado_bin Satisfied Depression_bin Trust_bin  
des $outchosen

global controls = "Age Male poorBHealth oldsibs momMaxEdu_Uni_F dadMaxEdu_Uni_F momMaxEdu_Uni_Miss dadMaxEdu_Uni_Miss HighInc_F HighInc_Miss houseOwn_F distCenter cgRelig_F cgRelig_Miss CAPI" //houseOwn_Miss 
global IVnido =    "score50 momBornProvince_F cgAsilo_F distAsiloMunicipal1 distanza2 distanza3 distA_momBornProvince "   // distAsiloPrivate1 distA_distAsiloPrivate score75_momBornProvince    score50 score50_momBornProvince 
global IVmaterna = "score50 distMaternaMunicipal1 " // momBornProvince_F distM_dadMaxEdu_Uni_F momBornProvince_F distM_dadMaxEdu_Uni_F


global outregOption excel bracket dec(3) sortvar(ReggioAsilo ReggioMaterna asilo) //label

sum $outcomes $controls $IVnido $IVmaterna
drop if(ReggioAsilo == . | ReggioMaterna == .)
keep $outcomes $controls $IVnido $IVmaterna ReggioAsilo ReggioMaterna nido asilo_Muni materna_Muni Reggio Parma Padova intnr score* City
sum 

** Output some summary statistics
local options se sdbracket vert nototal nptest //sd mtprob mtest bdec(3) ci cibrace nptest 
tabformprova $outcomes using ado_outcomesAll, by(City) `options'
tabformprova $outchosen using ado_outcomes, by(City) `options'

*** define the sample

gen sample1 = (Reggio == 1)
gen sampleAsilo2 = ((Reggio == 1 & ReggioAsilo == 1) | (Parma == 1) | (Padova == 1))
gen sampleMaterna2 = ((Reggio == 1 & ReggioMaterna == 1) | (Parma == 1) | (Padova == 1))
gen sample3 = (Reggio == 1 | Parma == 1)
gen sample4 = (Reggio == 1 | Padova == 1)
tab1 sample*

*** do the first stages out of the loop, to be quicker
***Asilo
probit ReggioAsilo $IVnido $controls if Reggio==1
predict pr_ReggioAsilo

gen unobsA = ReggioAsilo - pr_ReggioAsilo
gen unobsA2 = unobsA^2
gen unobsA3 = unobsA^3

gen weightA = (1 / pr_ReggioAsilo) if(ReggioAsilo == 1)
replace weightA = (1 / (1 - pr_ReggioAsilo)) if(ReggioAsilo == 0)

*biprobit
qui gen demand = (ReggioAsilo == 1)
qui gen supply = (ReggioAsilo == 1)

probit ReggioAsilo $IVnido $controls if(Reggio == 1)
matrix beta = e(b)

global bipX = "Age Male poorBHealth oldsibs momMaxEdu_Uni_F dadMaxEdu_Uni_F HighInc_F houseOwn_F distCenter cgRelig_F CAPI " //houseOwn_Miss  cgRelig_Miss  momMaxEdu_Uni_Miss dadMaxEdu_Uni_Miss HighInc_Miss 
biprobit (supply = score75 $bipX) (demand = distAsiloMunicipal1 $bipX) if(Reggio == 1), partial difficult iter(200) //from(beta, skip)

//keep if(sampleAsilo2 == 1)

predict p11, p11
predict p10, p10
gen pr_supply = p11+p10
predict p01, p01
gen pr_demand = p11+p01
sum pr_supply pr_demand, d

gen weightA_ds = 1 /(pr_d*pr_s) if(ReggioAsilo == 1)
replace weightA_ds = 1 /(1 - pr_d*pr_s) if(ReggioAsilo == 0)

sum weightA_ds

***Materna 
*probit
probit ReggioMaterna $IVmaterna $controls if Reggio==1
predict pr_ReggioMaterna

gen unobsM = ReggioMaterna - pr_ReggioMaterna
gen unobsM2 = unobsM^2
gen unobsM3 = unobsM^3

gen weightM = (1 / pr_ReggioMaterna) if(ReggioMaterna == 1)
replace weightM = (1 / (1 - pr_ReggioMaterna)) if(ReggioMaterna == 0)

*biprobit
capture drop demand supply p01 p11 p10 pr_supply pr_demand
gen demand = (ReggioMaterna == 1)
gen supply = (ReggioMaterna == 1)

//biprobit (supply = score75 $bipX) (demand = distMaternaMunicipal1 $bipX) if(Reggio == 1), partial difficult
biprobit (supply = score75 Male Age oldsibs) (demand = distAsiloMunicipal1 Male Age oldsibs) if(Reggio == 1), partial difficult iter(200) //from(beta, skip)

//keep if(sampleMaterna2 == 1)

predict p11, p11
predict p10, p10
gen pr_supply = p11+p10
predict p01, p01
gen pr_demand = p11+p01
sum pr_supply pr_demand, d

gen weightM_ds = 1 /(pr_d*pr_s) if(ReggioMaterna == 1)
replace weightM_ds = 1 /(1 - pr_d*pr_s) if(ReggioMaterna == 0)

sum weightM_ds


*interactions for the diff-in-diff
gen altroAsiloR  = ((nido == 1 & ReggioAsilo == 0) & Reggio == 1)
gen ParmaAsilo   = ((nido == 1 & asilo_Municipal == 1) & Parma == 1)
gen altroAsiloPr = ((nido == 1 & asilo_Municipal == 0) & Parma == 1)
gen PadovaAsilo  = ((nido == 1 & asilo_Municipal == 1) & Padova == 1)
gen altroAsiloPd = ((nido == 1 & asilo_Municipal == 0) & Padova == 1)

gen nidoXreggio = nido*Reggio

gen ParmaMaterna   = (materna_Municipal == 1 & Parma == 1)
gen PadovaMaterna  = (materna_Municipal == 1 & Padova == 1)
gen altraMaternaR  = (ReggioMaterna == 0 & Reggio == 1)
gen altraMaternaPr = (ParmaMaterna  == 0 & Parma ==1)
gen altraMaternaPd = (PadovaMaterna == 0 & Padova ==1)

des $outcomes, full
sum $outcomes, sep(0)
compress
saveold "$dir/Analysis/chiara&daniela/ado_data19July16.dta", replace

** Create a matrix where to store the number of significant results
unab vars: $outcomes
local nOut `: word count `vars''
di "`nOut'"
matrix Signcount = J(`nOut',4,.) //5 columns: varname, number of significant positive and significant negative for asilo and materna
matrix rowname Signcount = $outcomes
matrix colname Signcount = asilo+ asilo- materna+ materna-
matrix list Signcount

local row = 1 //counter for rows of the matrix
********************************************************************************
*                    Start the loop over the outcomes                          *
********************************************************************************
foreach varoutcome in $outcomes { // $outcomes  difficultiesSit childinvFriends_bin childSDQ_score_bin childSDQ_factor_bin SDQ_score_bin SDQ_factor_bin  Locus4_bin LocusControl_bin Friends_bin 
//initialize counters to zero for each new outcome
local cap = 0 // count asilo positive
local can = 0 // count asilo negative
local cmp = 0 // count materna positive
local cmn = 0 // count materna negative

di "********************************************************************************"
di "*** NIDO"

use "$dir/Analysis/chiara&daniela/ado_data19July16.dta", clear
keep if(sample1 == 1)
count
sum `varoutcome'
local varmean =  round(r(mean),0.01) //keep track of the overall mean and put it at the bottom of the tables

di "*** REGRESSION 1 (OLS REGGIO)"
reg `varoutcome' ReggioAsilo nido $controls, rob
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioAsilo]/_se[ReggioAsilo])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioAsilo])>0{
	     local ++cap //increase by one
	  }
	  if sign(_b[ReggioAsilo])<0{
	     local ++can //increase by one
	  }
	}
	outreg2 using `varoutcome'_asilo_ado, replace $outregOption ctitle("OLS") addtext(Sample, Reggio, Mean, `varmean') ///
	addnote(Mean = average of the y-variable for the whole sample considered. Sample: Reggio = only respondents in the city of Reggio Emilia. RAvsPrPd = Reggio Approach and all the respondents in Parma and Padova. RePr= all of the respondents in Reggio Emilia and Parma. RePd= all of the respondents in Reggio Emilia and Padova. Estimation Procedure: OLS = Ordinary Least Square; IV = Instrumental variable approach; CF = control function approach, cubic polynomial or residuals. PSM = simple propensity score matching. PSM2 = propensity sore matching using both demand and supply. DiD = differences-in-differences approach, municipal schools vs other schools across different cities)

di "*** REGRESSION 2 (IV REGGIO)"

ivreg2 `varoutcome' nido $controls (ReggioAsilo = $IVnido), robust small //NOTE: if I don't specify small, it doesn't return the degrees of freedom and I can't calculate pvalue
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioAsilo]/_se[ReggioAsilo])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioAsilo])>0{
	     local ++cap //increase by one
	  }
	  if sign(_b[ReggioAsilo])<0{
	     local ++can //increase by one
	  }
	}
	outreg2 using `varoutcome'_asilo_ado, append $outregOption ctitle("IV") addtext(Sample, Reggio, Mean, `varmean')

di "*** REGRESSION 3  (control function REGGIO)"
/* took out of the loop
probit ReggioAsilo $IVnido $controls
qui predict pr_ReggioAsilo

qui gen unobsA = ReggioAsilo - pr_ReggioAsilo
qui gen unobsA2 = unobsA^2
qui gen unobsA3 = unobsA^3
*/
reg `varoutcome' ReggioAsilo nido unobsA* $controls, rob
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioAsilo]/_se[ReggioAsilo])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioAsilo])>0{
	     local ++cap //increase by one
	  }
	  if sign(_b[ReggioAsilo])<0{
	     local ++can //increase by one
	  }
	}
	outreg2 using `varoutcome'_asilo_ado, append $outregOption ctitle("CF") addtext(Sample, Reggio, Mean, `varmean')

di "*** REGRESSION 4 (RC in REGGIO vs noRC in Parma and Padova)"
use "$dir/Analysis/chiara&daniela/ado_data19July16.dta", clear

reg `varoutcome' ReggioAsilo nido $controls if (sampleAsilo2 == 1), rob
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioAsilo]/_se[ReggioAsilo])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioAsilo])>0{
	     local ++cap //increase by one
	  }
	  if sign(_b[ReggioAsilo])<0{
	     local ++can //increase by one
	  }
	}
	outreg2 using `varoutcome'_asilo_ado, append $outregOption ctitle("OLS") addtext(Sample, RAvsPrPd, Mean, `varmean')

di "*** REGRESSION 5 (PSM classico)"
/*
qui probit ReggioAsilo $IVnido $controls if(Reggio == 1)
qui predict pr_ReggioAsilo

qui gen weightA = (1 / pr_ReggioAsilo) if(ReggioAsilo == 1)
qui replace weightA = (1 / (1 - pr_ReggioAsilo)) if(ReggioAsilo == 0)
*/
keep if(sampleAsilo2 == 1)

reg `varoutcome' ReggioAsilo nido $controls [iweight = weightA] if (sampleAsilo2 == 1), rob
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioAsilo]/_se[ReggioAsilo])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioAsilo])>0{
	     local ++cap //increase by one
	  }
	  if sign(_b[ReggioAsilo])<0{
	     local ++can //increase by one
	  }
	}
	outreg2 using `varoutcome'_asilo_ado, append $outregOption ctitle("PSM") addtext(Sample, RAvsPP, Mean, `varmean')

di "*** REGRESSION 6(PSM d&s)"
use "$dir/Analysis/chiara&daniela/ado_data19July16.dta", clear
/*
qui gen demand = (ReggioAsilo == 1)
qui gen supply = (ReggioAsilo == 1)

probit ReggioAsilo $IVnido $controls if(Reggio == 1)
matrix beta = e(b)

global bipX = "Age Male poorBHealth oldsibs momMaxEdu_Uni_F dadMaxEdu_Uni_F HighInc_F houseOwn_F distCenter cgRelig_F CAPI " //houseOwn_Miss  cgRelig_Miss  momMaxEdu_Uni_Miss dadMaxEdu_Uni_Miss HighInc_Miss 
biprobit (supply = score75 $bipX) (demand = distAsiloMunicipal1 $bipX) if(Reggio == 1), partial difficult iter(200) //from(beta, skip)

qui predict p11, p11
qui predict p10, p10
qui gen pr_supply = p11+p10
qui predict p01, p01
qui gen pr_demand = p11+p01
qui sum pr_supply pr_demand, d

qui gen weightA_ds = 1 /(pr_d*pr_s) if(ReggioAsilo == 1)
qui replace weightA_ds = 1 /(1 - pr_d*pr_s) if(ReggioAsilo == 0)

sum weightA_ds
*/
keep if(sampleAsilo2 == 1)

reg `varoutcome' ReggioAsilo nido $controls [iweight = weightA_ds] if (sampleAsilo2 == 1), rob
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioAsilo]/_se[ReggioAsilo])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioAsilo])>0{
	     local ++cap //increase by one
	  }
	  if sign(_b[ReggioAsilo])<0{
	     local ++can //increase by one
	  }
	}
	outreg2 using `varoutcome'_asilo_ado, append $outregOption ctitle("PSM2") addtext(Sample, RAvsPP, Mean, `varmean')

di "*** REGRESSION 7 (OLS Reggio + Parma)"

use "$dir/Analysis/chiara&daniela/ado_data19July16.dta", clear

keep if(sample3 == 1)
count

reg `varoutcome' ReggioAsilo nido $controls Parma, rob
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioAsilo]/_se[ReggioAsilo])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioAsilo])>0{
	     local ++cap //increase by one
	  }
	  if sign(_b[ReggioAsilo])<0{
	     local ++can //increase by one
	  }
	}
	outreg2 using `varoutcome'_asilo_ado, append $outregOption ctitle("OLS") addtext(Sample, RePr, Mean, `varmean')

di "*** REGRESSION 8 (diff-in-diff Reggio + Parma)"

use "$dir/Analysis/chiara&daniela/ado_data19July16.dta", clear

keep if(sample3 == 1)
count
/*
qui probit ReggioAsilo $IVnido $controls if(Reggio == 1)
qui predict pr_ReggioAsilo
qui gen weightA = (1 / pr_ReggioAsilo) if(ReggioAsilo == 1)
qui replace weightA = (1 / (1 - pr_ReggioAsilo)) if(ReggioAsilo == 0)

qui gen ParmaAsilo = ((nido == 1 & asilo_Municipal == 1) & Parma == 1)
qui gen altroAsiloR = ((nido == 1 & ReggioAsilo == 0) & Reggio == 1)
qui gen altroAsiloP = ((nido == 1 & asilo_Municipal == 0) & Parma == 1) //watch-out: Parma and Padova can be confusing here in altroAsiloP
qui gen nidoXreggio = nido*Reggio
*/
reg `varoutcome' ReggioAsilo nido Reggio nidoXreggio asilo_Municipal $controls [iweight = weightA] if(sample3 == 1), rob
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioAsilo]/_se[ReggioAsilo])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioAsilo])>0{
	     local ++cap //increase by one
	  }
	  if sign(_b[ReggioAsilo])<0{
	     local ++can //increase by one
	  }
	}
	outreg2 using `varoutcome'_asilo_ado, append $outregOption ctitle("DiD Pr") addtext(Sample, RePr, Mean, `varmean')

di "*check"
reg `varoutcome' ReggioAsilo ParmaAsilo altroAsiloR nido altroAsiloPr $controls Parma [iweight = weightA] if(sample3 == 1), rob
lincom (ReggioAsilo - altroAsiloR) - (ParmaAsilo - altroAsiloPr)

di "*** REGRESSION 9 (OLS Reggio + Padova)"

use "$dir/Analysis/chiara&daniela/ado_data19July16.dta", clear

keep if(sample4 == 1)
count

reg `varoutcome' ReggioAsilo nido $controls Padova, rob
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioAsilo]/_se[ReggioAsilo])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioAsilo])>0{
	     local ++cap //increase by one
	  }
	  if sign(_b[ReggioAsilo])<0{
	     local ++can //increase by one
	  }
	}
	outreg2 using `varoutcome'_asilo_ado, append $outregOption ctitle("OLS") addtext(Sample, RePd, Mean, `varmean')

di "*** REGRESSION 10 (diff-in-diff Reggio + Padova)"

use "$dir/Analysis/chiara&daniela/ado_data19July16.dta", clear

keep if(sample4 == 1)
count
/*
qui probit ReggioAsilo $IVnido $controls if(Reggio == 1)
qui predict pr_ReggioAsilo
qui gen weightA = (1 / pr_ReggioAsilo) if(ReggioAsilo == 1)
qui replace weightA = (1 / (1 - pr_ReggioAsilo)) if(ReggioAsilo == 0)

qui gen PadovaAsilo = ((nido == 1 & asilo_Municipal == 1) & Padova == 1)
qui gen altroAsiloR = ((nido == 1 & ReggioAsilo == 0) & Reggio == 1)
qui gen altroAsiloP = ((nido == 1 & asilo_Municipal == 0) & Padova == 1)
qui gen nidoXreggio = nido*Reggio
*/
reg `varoutcome' ReggioAsilo nido Reggio nidoXreggio asilo_Municipal $controls [iweight = weightA] if(sample4 == 1), rob
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioAsilo]/_se[ReggioAsilo])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioAsilo])>0{
	     local ++cap //increase by one
	  }
	  if sign(_b[ReggioAsilo])<0{
	     local ++can //increase by one
	  }
	}
	outreg2 using `varoutcome'_asilo_ado, append $outregOption ctitle("DiD Pd") addtext(Sample, RePd, Mean, `varmean')

**CHECK
reg `varoutcome' ReggioAsilo altroAsiloR PadovaAsilo nido $controls Padova [iweight = weightA] if(sample4 == 1), rob //altroAsiloPd 
lincom (ReggioAsilo - altroAsiloR) - (PadovaAsilo) //(PadovaAsilo - altroAsiloPd)


********************************************************************************
di "********************************************************************************"
di "*** SCUOLA MATERNA"

di "*** REGRESSION 1 (OLS REGGIO)"

use "$dir/Analysis/chiara&daniela/ado_data19July16.dta", clear

keep if(sample1 == 1)
count

sum `varoutcome'
local varmean =  round(r(mean),0.01) //keep track of the overall mean and put it at the bottom of the tables

reg `varoutcome' ReggioMaterna $controls, rob
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioMaterna]/_se[ReggioMaterna])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioMaterna])>0{
	     local ++cmp //increase by one
	  }
	  if sign(_b[ReggioMaterna])<0{
	     local ++cmn //increase by one
	  }
	}
	outreg2 using `varoutcome'_materna_ado, replace $outregOption ctitle("OLS") addtext(Sample, Reggio, Mean, `varmean') ///
	addnote(Mean = average of the y-variable for the whole sample considered. Sample: Reggio = only respondents in the city of Reggio Emilia. RAvsPrPd = Reggio Approach and all the respondents in Parma and Padova. RePr= all of the respondents in Reggio Emilia and Parma. RePd= all of the respondents in Reggio Emilia and Padova. Estimation Procedure: OLS = Ordinary Least Square; IV = Instrumental variable approach; CF = control function approach, cubic polynomial or residuals. PSM = simple propensity score matching. PSM2 = propensity sore matching using both demand and supply. DiD = differences-in-differences approach, municipal schools vs other schools across different cities)

di "*** REGRESSION 12 (IV REGGIO)"

ivreg2 `varoutcome' $controls (ReggioMaterna = $IVmaterna), robust small
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioMaterna]/_se[ReggioMaterna])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioMaterna])>0{
	     local ++cmp //increase by one
	  }
	  if sign(_b[ReggioMaterna])<0{
	     local ++cmn //increase by one
	  }
	}
	outreg2 using `varoutcome'_materna_ado, append $outregOption ctitle("IV") addtext(Sample, Reggio, Mean, `varmean')

di "*** REGRESSION 13  (control function REGGIO)"
/*
qui probit ReggioMaterna $IVmaterna $controls
qui predict pr_ReggioMaterna

qui gen unobsM = ReggioMaterna - pr_ReggioMaterna
qui gen unobsM2 = unobs^2
qui gen unobsM3 = unobs^3
*/
reg `varoutcome' ReggioMaterna unobsM* $controls, rob
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioMaterna]/_se[ReggioMaterna])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioMaterna])>0{
	     local ++cmp //increase by one
	  }
	  if sign(_b[ReggioMaterna])<0{
	     local ++cmn //increase by one
	  }
	}
	outreg2 using `varoutcome'_materna_ado, append $outregOption ctitle("CF") addtext(Sample, Reggio, Mean, `varmean')

di "*** REGRESSION 14 (RC in REGGIO vs noRC in Parma and Padova)"

use "$dir/Analysis/chiara&daniela/ado_data19July16.dta", clear

reg `varoutcome' ReggioMaterna $controls if (sampleMaterna2 == 1), rob
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioMaterna]/_se[ReggioMaterna])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioMaterna])>0{
	     local ++cmp //increase by one
	  }
	  if sign(_b[ReggioMaterna])<0{
	     local ++cmn //increase by one
	  }
	}
	outreg2 using `varoutcome'_materna_ado, append $outregOption ctitle("OLS") addtext(Sample, RAvsPrPd, Mean, `varmean')

di "*** REGRESSION 15 (PSM classico)"
/*
qui probit ReggioMaterna $IVmaterna $controls if(Reggio == 1)

qui predict pr_ReggioMaterna

qui gen weightM = (1 / pr_ReggioMaterna) if(ReggioMaterna == 1)
qui replace weightM = (1 / (1 - pr_ReggioMaterna)) if(ReggioMaterna == 0)
*/
keep if(sampleMaterna2 == 1)

reg `varoutcome' ReggioMaterna $controls [iweight = weightM] if (sampleMaterna2 == 1), rob
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioMaterna]/_se[ReggioMaterna])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioMaterna])>0{
	     local ++cmp //increase by one
	  }
	  if sign(_b[ReggioMaterna])<0{
	     local ++cmn //increase by one
	  }
	}
	outreg2 using `varoutcome'_materna_ado, append $outregOption ctitle("PSM") addtext(Sample, RAvsPP, Mean, `varmean')

di "*** REGRESSION 16(PSM d&s)"

use "$dir/Analysis/chiara&daniela/ado_data19July16.dta", clear
/*
capture drop demand supply
qui gen demand = (ReggioMaterna == 1)
qui gen supply = (ReggioMaterna == 1)

//biprobit (supply = score75 $bipX) (demand = distMaternaMunicipal1 $bipX) if(Reggio == 1), partial difficult
biprobit (supply = score75 Male Age oldsibs) (demand = distAsiloMunicipal1 Male Age oldsibs) if(Reggio == 1), partial difficult iter(200) //from(beta, skip)

qui predict p11, p11
qui predict p10, p10
qui gen pr_supply = p11+p10
qui predict p01, p01
qui gen pr_demand = p11+p01
sum pr_supply pr_demand, d

qui gen weight = 1 /(pr_d*pr_s) if(ReggioMaterna == 1)
qui replace weight = 1 /(1 - pr_d*pr_s) if(ReggioMaterna == 0)

sum weightM_ds
*/
keep if(sampleMaterna2 == 1)

reg `varoutcome' ReggioMaterna $controls [iweight = weightM_ds] if (sampleMaterna2 == 1), rob
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioMaterna]/_se[ReggioMaterna])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioMaterna])>0{
	     local ++cmp //increase by one
	  }
	  if sign(_b[ReggioMaterna])<0{
	     local ++cmn //increase by one
	  }
	}
	outreg2 using `varoutcome'_materna_ado, append $outregOption ctitle("PSM2") addtext(Sample, RAvsPP, Mean, `varmean')

di "*** REGRESSION 17 (OLS Reggio + Parma)"

use "$dir/Analysis/chiara&daniela/ado_data19July16.dta", clear
keep if(sample3 == 1)
count

reg `varoutcome' ReggioMaterna $controls Parma, rob
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioMaterna]/_se[ReggioMaterna])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioMaterna])>0{
	     local ++cmp //increase by one
	  }
	  if sign(_b[ReggioMaterna])<0{
	     local ++cmn //increase by one
	  }
	}
	outreg2 using `varoutcome'_materna_ado, append $outregOption ctitle("OLS") addtext(Sample, RePr, Mean, `varmean')

di "*** REGRESSION 18 (diff-in-diff Reggio + Parma)"

use "$dir/Analysis/chiara&daniela/ado_data19July16.dta", clear

keep if(sample3 == 1)
count
/*
qui probit ReggioMaterna $IVmaterna $controls if(Reggio == 1)
qui predict pr_ReggioMaterna
qui gen weightM = (1 / pr_ReggioMaterna) if(ReggioMaterna == 1)
qui replace weightM = (1 / (1 - pr_ReggioMaterna)) if(ReggioMaterna == 0)

qui gen ParmaMaterna = (materna_Municipal == 1 & Parma == 1)
qui gen altraMaternaR = (ReggioMaterna == 0 & Reggio == 1)
qui gen altraMaternaP = (ParmaMaterna  == 0 & Parma ==1)
*/

reg `varoutcome' ReggioMaterna Reggio materna_Municipal $controls [iweight = weightM] if sample3==1, rob 
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioMaterna]/_se[ReggioMaterna])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioMaterna])>0{
	     local ++cmp //increase by one
	  }
	  if sign(_b[ReggioMaterna])<0{
	     local ++cmn //increase by one
	  }
	}
	outreg2 using `varoutcome'_materna_ado, append $outregOption ctitle("DiD Pr") addtext(Sample, RePr, Mean, `varmean')

**Double check
reg `varoutcome' ReggioMaterna ParmaMaterna altraMaternaR $controls [iweight = weightM] if sample3==1, rob  //altraMaternaPr 
lincom (ReggioMaterna - altraMaternaR) - (ParmaMaterna) //(ParmaMaterna - altraMaternaPr)

di "*** REGRESSION 19 (OLS Reggio + Padova)"

use "$dir/Analysis/chiara&daniela/ado_data19July16.dta", clear

keep if(sample4 == 1)
count

reg `varoutcome' ReggioMaterna $controls Padova, rob
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioMaterna]/_se[ReggioMaterna])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioMaterna])>0{
	     local ++cmp //increase by one
	  }
	  if sign(_b[ReggioMaterna])<0{
	     local ++cmn //increase by one
	  }
	}
	outreg2 using `varoutcome'_materna_ado, append $outregOption ctitle("OLS") addtext(Sample, RePd, Mean, `varmean')

di "*** REGRESSION 20 (diff-in-diff Reggio + Padova)"

use "$dir/Analysis/chiara&daniela/ado_data19July16.dta", clear

keep if(sample4 == 1)
count
/*
qui probit ReggioMaterna $IVmaterna $controls if(Reggio == 1)
qui predict pr_ReggioMaterna
qui gen weightM = (1 / pr_ReggioMaterna) if(ReggioMaterna == 1)
qui replace weightM = (1 / (1 - pr_ReggioMaterna)) if(ReggioMaterna == 0)

qui gen PadovaMaterna = (materna_Municipal == 1 & Padova == 1)
qui gen altraMaternaR = (ReggioMaterna == 0 & Reggio == 1)
qui gen altraMaternaP = (PadovaMaterna  == 0 & Padova ==1)
*/
reg `varoutcome' ReggioMaterna Reggio materna_Municipal $controls [iweight = weightM] if sample4==1, rob //altraMaternaPd 
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioMaterna]/_se[ReggioMaterna])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioMaterna])>0{
	     local ++cmp //increase by one
	  }
	  if sign(_b[ReggioMaterna])<0{
	     local ++cmn //increase by one
	  }
	}
	outreg2 using `varoutcome'_materna_ado, append $outregOption ctitle("DiD Pd") addtext(Sample, RePd, Mean, `varmean')

**CHECK
reg `varoutcome' ReggioMaterna PadovaMaterna altraMaternaR $controls [iweight = weightM] if sample4==1, rob  //altraMaternaPd 
lincom (ReggioMaterna - altraMaternaR) - (PadovaMaterna) //(PadovaMaterna - altraMaternaPd)

di "----------------------- `cap' `can' `cmp' `cmn' --------------------"
matrix Signcount[`row',1] = `cap' 
matrix Signcount[`row',2] = `can' 
matrix Signcount[`row',3] = `cmp' 
matrix Signcount[`row',4] = `cmn' 
matrix list Signcount
local ++row
}

/* save the matrix in an excel sheet
putexcel set Signcount.xlsx, sheet(adolescents) modify
putexcel B3 = matrix(Signcount)
*/

log close
