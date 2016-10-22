clear all
set more off
capture log close

//global dir "/mnt/Data/Dropbox/ReggioChildren"
global dir "C:/Users/pbiroli/Dropbox/ReggioChildren"
//global dir "C:/Users/Pronzato/Dropbox/ReggioChildren"

cd "$dir/Analysis/chiara&daniela/output"

local day=subinstr("$S_DATE"," ","",.)
log using "child_regression`day'.log", text replace

**** ONLY COHORT 2006 
**** ONE OUTCOME (WELLBEING) 
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
*** COHORT 2006

use "$dir/SURVEY_DATA_COLLECTION/data/Reggio.dta", clear

*** only 2006 
keep if Cohort == 1
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

gen distM_cgRelig_F = distMaternaMunicipal1*cgRelig_F
label var distM_cgRelig_F "distance materna municipal x religious caregiver"

gen distMR_relig = distMaternaReligious1*cgRelig_F
label var distMR_relig "distance materna religious x religious caregiver"


*** flip these dummies (higher = better): do this in the analysis do file, otherwise things get messed up

sum difficultiesSit difficultiesInterest difficultiesObey difficultiesEat ///
childAsthma_* childAllerg_* childDigest_* childEmot_diag childSleep_diag childGums_diag childOther_diag childSnackNo childSnackCan childSnackRoll  ///
childSnackChips childSnackOther  worryMyself 

desc difficultiesSit difficultiesInterest difficultiesObey difficultiesEat ///
childAsthma_* childAllerg_* childDigest_* childEmot_diag childSleep_diag childGums_diag childOther_diag childSnackNo childSnackCan childSnackRoll  ///
childSnackChips childSnackOther  worryMyself

foreach j in difficultiesSit difficultiesInterest difficultiesObey difficultiesEat ///
childAsthma_ childAllerg_ childDigest_ childEmot_diag childSleep_diag childGums_diag childOther_diag childSnackNo childSnackCan childSnackRoll  ///
childSnackChips childSnackOther  worryMyself {

replace `j'= 1-`j'
//label var `j' "`j' flipped"
} 

*** global
global outcomes difficultiesSit difficultiesInterest difficultiesObey difficultiesEat difficultiesNone ///
childinvReadTo_bin childinvMusic childinvCom_bin childinvTV_hrs_bin childinvVideoG_hrs_bin childinvOut_bin childinvFamMeal_bin childinvChoresRoom_bin childinvChoresHelp_bin ///
childinvChoresHomew_bin ///
childinvReadSelf_bin childinvSport childinvDance childinvTheater childinvOther childFriends_bin ///
childSDQPsoc1_bin childSDQPsoc2_bin childSDQPsoc3_bin childSDQPsoc4_bin childSDQPsoc5_bin childSDQPsoc_score_bin /// childSDQPsoc_factor_bin 
childSDQHype1_bin childSDQHype2_bin childSDQHype3_bin childSDQHype4_bin childSDQHype5_bin childSDQHype_score_bin /// childSDQHype_factor_bin 
childSDQEmot1_bin childSDQEmot2_bin childSDQEmot3_bin childSDQEmot4_bin childSDQEmot5_bin childSDQEmot_score_bin /// childSDQEmot_factor_bin 
childSDQCond1_bin childSDQCond2_bin childSDQCond3_bin childSDQCond4_bin childSDQCond5_bin childSDQCond_score_bin /// childSDQCond_factor_bin 
childSDQPeer1_bin childSDQPeer2_bin childSDQPeer3_bin childSDQPeer4_bin childSDQPeer5_bin childSDQPeer_score_bin /// childSDQPeer_factor_bin 
childSDQ_score_bin childSDQ_factor_bin ///
childHealth_bin childnoSickDays_bin childSleep_bin childHeight_bin childWeight_bin childDoctor_bin childAsthma_diag childAllerg_diag childDigest_diag childEmot_diag ///
childSleep_diag childGums_diag childOther_diag childNone_diag childBreakfast_bin childFruit_bin childSnackNo childSnackFruit childSnackIce ///
childSnackCan childSnackRoll childSnackChips childSnackOther sportTogether_bin childBMI_bin childTotal_diag_bin /// 
likeSchool_child_bin likeRead_bin likeMath_child_bin likeGym_bin goodBoySchool_bin bullied_bin alienated_bin doGrowUp likeTV_bin likeDraw_bin likeSport_bin /// 
FriendsGender_bin bestFriend lendFriend_bin favorReturn_bin revengeReturn_bin ///
funFamily_bin worryMyself worryFriend worryHome worryTeacher faceMe_bin faceFamily_bin faceSchool_bin faceGeneral_bin brushTeeth_bin candyGame_bin ///
IQ1 IQ2 IQ3 IQ4 IQ5 IQ6 IQ7 IQ8 IQ9 IQ10 IQ11 IQ12 IQ13 IQ14 IQ15 IQ16 IQ17 IQ18 IQ_score_bin IQ_factor_bin 

global outchosen childFriends_bin childinvMusic childinvReadTo_bin childinvTheater childinvDance  childSDQ_score_bin worryMyself worryTeacher  ///
                 childBMI_bin  childHealth_bin childNone_diag childSnackNo childSnackFruit difficultiesInterest difficultiesSit ///
				 likeSchool_child_bin faceFamily_bin faceGeneral_bin candyGame_bin    

global controls = "Age Male poorBHealth oldsibs momMaxEdu_Uni_F dadMaxEdu_Uni_F momMaxEdu_Uni_Miss dadMaxEdu_Uni_Miss HighInc_F HighInc_Miss houseOwn_F distCenter cgRelig_F cgRelig_Miss CAPI" //houseOwn_Miss 
global IVnido =    "score75 cgAsilo_F distAsiloMunicipal1 distanza2 distanza3 distA_MomBorn distA_oldsibs" //
global IVmaterna = "score75 distMaternaMunicipal1 distMaternaReligious1 distMR_relig distM_cgRelig_F" // "cgAsilo_F score50 distMaternaMunicipal1 momBornProvince_F dadBornProvince_F momBornProvince_Miss dadBornProvince_Miss"

global outregOption excel bracket dec(3) sortvar(ReggioAsilo ReggioMaterna asilo) //label

sum $outcomes $controls $IVnido $IVmaterna
drop if(ReggioAsilo == . | ReggioMaterna == .)
keep $outcomes $controls $IVnido $IVmaterna ReggioAsilo ReggioMaterna nido asilo_Muni materna_Muni Reggio Parma Padova intnr Cohort City
sum 

** Output some summary statistics
local options se sdbracket vert nototal nptest //sd mtprob mtest bdec(3) ci cibrace nptest 
tabformprova $outcomes using child_outcomesAll, by(City) `options'
tabformprova $outchosen using child_outcomes, by(City) `options'


*** definire il sample

gen sample1 = (Reggio == 1)
gen sampleAsilo2 = ((Reggio == 1 & ReggioAsilo == 1) | (Parma == 1) | (Padova == 1))
gen sampleMaterna2 = ((Reggio == 1 & ReggioMaterna == 1) | (Parma == 1) | (Padova == 1))
gen sample3 = (Reggio == 1 | Parma == 1)
gen sample4 = (Reggio == 1 | Padova == 1)
tab1 sample*

compress
saveold "$dir/Analysis/chiara&daniela/child_data4July16.dta", replace


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
foreach varoutcome in childSDQ_factor_bin { //faceMe brushTeeth candyGame $outcomes 
//initialize counters to zero for each new outcome
local cap = 0 // count asilo positive
local can = 0 // count asilo negative
local cmp = 0 // count materna positive
local cmn = 0 // count materna negative

di "********************************************************************************"
di "*** NIDO"

use "$dir/Analysis/chiara&daniela/child_data4July16.dta", clear
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
	outreg2 using `varoutcome'_asilo_child, replace $outregOption ctitle("OLS") addtext(Sample, Reggio, Mean, `varmean') ///
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
	outreg2 using `varoutcome'_asilo_child, append $outregOption ctitle("IV") addtext(Sample, Reggio, Mean, `varmean')

di "*** REGRESSION 3  (control function REGGIO)"

qui probit ReggioAsilo $IVnido $controls
qui predict pr_ReggioAsilo

qui gen unobs = ReggioAsilo - pr_ReggioAsilo
qui gen unobs2 = unobs^2
qui gen unobs3 = unobs^3

reg `varoutcome' ReggioAsilo nido unobs* $controls, rob
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioAsilo]/_se[ReggioAsilo])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioAsilo])>0{
	     local ++cap //increase by one
	  }
	  if sign(_b[ReggioAsilo])<0{
	     local ++can //increase by one
	  }
	}
	outreg2 using `varoutcome'_asilo_child, append $outregOption ctitle("CF") addtext(Sample, Reggio, Mean, `varmean')

di "*** REGRESSION 4 (RC in REGGIO vs noRC in Parma and Padova)"
use "$dir/Analysis/chiara&daniela/child_data4July16.dta", clear

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
	outreg2 using `varoutcome'_asilo_child, append $outregOption ctitle("OLS") addtext(Sample, RAvsPrPd, Mean, `varmean')

di "*** REGRESSION 5 (PSM classico)"

qui probit ReggioAsilo $IVnido $controls if(Reggio == 1)
qui keep if(sampleAsilo2 == 1)
qui predict pr_ReggioAsilo

qui gen weight = (1 / pr_ReggioAsilo) if(ReggioAsilo == 1)
qui replace weight = (1 / (1 - pr_ReggioAsilo)) if(ReggioAsilo == 0)

reg `varoutcome' ReggioAsilo nido $controls [iweight = weight] if (sampleAsilo2 == 1), rob
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioAsilo]/_se[ReggioAsilo])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioAsilo])>0{
	     local ++cap //increase by one
	  }
	  if sign(_b[ReggioAsilo])<0{
	     local ++can //increase by one
	  }
	}
	outreg2 using `varoutcome'_asilo_child, append $outregOption ctitle("PSM") addtext(Sample, RAvsPP, Mean, `varmean')

di "*** REGRESSION 6(PSM d&s)"
use "$dir/Analysis/chiara&daniela/child_data4July16.dta", clear

qui gen demand = (ReggioAsilo == 1)
qui gen supply = (ReggioAsilo == 1)
//biprobit (supply = score50 Male Age momMaxEdu_Uni_F momMaxEdu_Uni_Miss HighInc_F HighInc_Miss) (demand = cgAsilo_F distAsiloMunicipal1 distanza2 momBornProvince_F dadBornProvince_F momBornProvince_Miss dadBornProvince_Miss Male Age momMaxEdu_Uni_F momMaxEdu_Uni_Miss HighInc_F HighInc_Miss) if(Reggio == 1), partial difficult
biprobit (supply = score75 $controls) (demand = cgAsilo_F distAsiloMunicipal1 distanza2 distanza3 distA_MomBorn distA_oldsibs $controls) if(Reggio == 1), partial difficult

keep if(sampleAsilo2 == 1)

qui predict p11, p11
qui predict p10, p10
qui gen pr_supply = p11+p10
qui predict p01, p01
qui gen pr_demand = p11+p01
qui sum pr_supply pr_demand, d

qui gen weight = 1 /(pr_d*pr_s) if(ReggioAsilo == 1)
qui replace weight = 1 /(1 - pr_d*pr_s) if(ReggioAsilo == 0)

sum weight

reg `varoutcome' ReggioAsilo nido $controls [iweight = weight] if (sampleAsilo2 == 1), rob
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioAsilo]/_se[ReggioAsilo])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioAsilo])>0{
	     local ++cap //increase by one
	  }
	  if sign(_b[ReggioAsilo])<0{
	     local ++can //increase by one
	  }
	}
	outreg2 using `varoutcome'_asilo_child, append $outregOption ctitle("PSM2") addtext(Sample, RAvsPP, Mean, `varmean')

di "*** REGRESSION 7 (OLS Reggio + Parma)"

use "$dir/Analysis/chiara&daniela/child_data4July16.dta", clear

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
	outreg2 using `varoutcome'_asilo_child, append $outregOption ctitle("OLS") addtext(Sample, RePr, Mean, `varmean')

di "*** REGRESSION 8 (diff-in-diff Reggio + Parma)"

use "$dir/Analysis/chiara&daniela/child_data4July16.dta", clear

keep if(sample3 == 1)
count

qui probit ReggioAsilo $IVnido $controls if(Reggio == 1)
qui predict pr_ReggioAsilo
qui gen weight = (1 / pr_ReggioAsilo) if(ReggioAsilo == 1)
qui replace weight = (1 / (1 - pr_ReggioAsilo)) if(ReggioAsilo == 0)

qui gen ParmaAsilo = ((nido == 1 & asilo_Municipal == 1) & Parma == 1)
qui gen altroAsiloR = ((nido == 1 & ReggioAsilo == 0) & Reggio == 1)
qui gen altroAsiloP = ((nido == 1 & asilo_Municipal == 0) & Parma == 1) //watch-out: Parma and Padova can be confusing here in altroAsiloP
qui gen nidoXreggio = nido*Reggio

reg `varoutcome' ReggioAsilo nido Reggio nidoXreggio asilo_Municipal $controls [iweight = weight] if(sample3 == 1), rob
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioAsilo]/_se[ReggioAsilo])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioAsilo])>0{
	     local ++cap //increase by one
	  }
	  if sign(_b[ReggioAsilo])<0{
	     local ++can //increase by one
	  }
	}
	outreg2 using `varoutcome'_asilo_child, append $outregOption ctitle("DiD Pr") addtext(Sample, RePr, Mean, `varmean')

di "*check"
reg `varoutcome' ReggioAsilo ParmaAsilo altroAsiloR nido altroAsiloP $controls Parma [iweight = weight] if(sample3 == 1), rob
lincom (ReggioAsilo - altroAsiloR) - (ParmaAsilo - altroAsiloP)

di "*** REGRESSION 9 (OLS Reggio + Padova)"

use "$dir/Analysis/chiara&daniela/child_data4July16.dta", clear

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
	outreg2 using `varoutcome'_asilo_child, append $outregOption ctitle("OLS") addtext(Sample, RePd, Mean, `varmean')

di "*** REGRESSION 10 (diff-in-diff Reggio + Padova)"

use "$dir/Analysis/chiara&daniela/child_data4July16.dta", clear

keep if(sample4 == 1)
count

qui probit ReggioAsilo $IVnido $controls if(Reggio == 1)
qui predict pr_ReggioAsilo
qui gen weight = (1 / pr_ReggioAsilo) if(ReggioAsilo == 1)
qui replace weight = (1 / (1 - pr_ReggioAsilo)) if(ReggioAsilo == 0)

qui gen PadovaAsilo = ((nido == 1 & asilo_Municipal == 1) & Padova == 1)
qui gen altroAsiloR = ((nido == 1 & ReggioAsilo == 0) & Reggio == 1)
qui gen altroAsiloP = ((nido == 1 & asilo_Municipal == 0) & Padova == 1)
qui gen nidoXreggio = nido*Reggio

reg `varoutcome' ReggioAsilo nido Reggio nidoXreggio asilo_Municipal $controls [iweight = weight] if(sample4 == 1), rob
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioAsilo]/_se[ReggioAsilo])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioAsilo])>0{
	     local ++cap //increase by one
	  }
	  if sign(_b[ReggioAsilo])<0{
	     local ++can //increase by one
	  }
	}
	outreg2 using `varoutcome'_asilo_child, append $outregOption ctitle("DiD Pd") addtext(Sample, RePd, Mean, `varmean')

**CHECK
reg `varoutcome' ReggioAsilo altroAsiloR PadovaAsilo nido $controls Padova [iweight = weight] if(sample4 == 1), rob //altroAsiloP 
lincom (ReggioAsilo - altroAsiloR) - (PadovaAsilo) //(PadovaAsilo - altroAsiloP)


********************************************************************************
di "********************************************************************************"
di "*** SCUOLA MATERNA"

di "*** REGRESSION 1 (OLS REGGIO)"

use "$dir/Analysis/chiara&daniela/child_data4July16.dta", clear

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
	outreg2 using `varoutcome'_materna_child, replace $outregOption ctitle("OLS") addtext(Sample, Reggio, Mean, `varmean') ///
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
	outreg2 using `varoutcome'_materna_child, append $outregOption ctitle("IV") addtext(Sample, Reggio, Mean, `varmean')

di "*** REGRESSION 13  (control function REGGIO)"

qui probit ReggioMaterna $IVmaterna $controls
qui predict pr_ReggioMaterna

qui gen unobs = ReggioMaterna - pr_ReggioMaterna
qui gen unobs2 = unobs^2
qui gen unobs3 = unobs^3

reg `varoutcome' ReggioMaterna unobs* $controls, rob
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioMaterna]/_se[ReggioMaterna])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioMaterna])>0{
	     local ++cmp //increase by one
	  }
	  if sign(_b[ReggioMaterna])<0{
	     local ++cmn //increase by one
	  }
	}
	outreg2 using `varoutcome'_materna_child, append $outregOption ctitle("CF") addtext(Sample, Reggio, Mean, `varmean')

di "*** REGRESSION 14 (RC in REGGIO vs noRC in Parma and Padova)"

use "$dir/Analysis/chiara&daniela/child_data4July16.dta", clear

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
	outreg2 using `varoutcome'_materna_child, append $outregOption ctitle("OLS") addtext(Sample, RAvsPrPd, Mean, `varmean')

di "*** REGRESSION 15 (PSM classico)"

qui probit ReggioMaterna $IVmaterna $controls if(Reggio == 1)
qui keep if(sampleMaterna2 == 1)

qui predict pr_ReggioMaterna

qui gen weight = (1 / pr_ReggioMaterna) if(ReggioMaterna == 1)
qui replace weight = (1 / (1 - pr_ReggioMaterna)) if(ReggioMaterna == 0)

reg `varoutcome' ReggioMaterna $controls [iweight = weight] if (sampleMaterna2 == 1), rob
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioMaterna]/_se[ReggioMaterna])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioMaterna])>0{
	     local ++cmp //increase by one
	  }
	  if sign(_b[ReggioMaterna])<0{
	     local ++cmn //increase by one
	  }
	}
	outreg2 using `varoutcome'_materna_child, append $outregOption ctitle("PSM") addtext(Sample, RAvsPP, Mean, `varmean')

di "*** REGRESSION 16(PSM d&s)"

use "$dir/Analysis/chiara&daniela/child_data4July16.dta", clear

qui gen demand = (ReggioMaterna == 1)
qui gen supply = (ReggioMaterna == 1)
//qui biprobit (supply = score50 Male Age momMaxEdu_Uni_F momMaxEdu_Uni_Miss houseOwn_F houseOwn_Miss) (demand = cgAsilo_F distMaternaMunicipal1 momBornProvince_F dadBornProvince_F momBornProvince_Miss dadBornProvince_Miss Male Age houseOwn_F houseOwn_Miss) if(Reggio == 1), partial difficult
biprobit (supply = score75 $controls) (demand = score75 distMaternaMunicipal1 distMaternaReligious1 distMR_relig distM_cgRelig_F $controls) if(Reggio == 1), partial difficult
//qui biprobit (supply = score75 Age Male momMaxEdu_Uni_F momMaxEdu_Uni_Miss dadMaxEdu_Uni_F dadMaxEdu_Uni_Miss houseOwn_F houseOwn_Miss) (demand = distMaternaMunicipal1 distMaternaReligious1 distMR_relig distM_cgRelig_F $controls) if(Reggio == 1), partial difficult iter(100)

qui keep if(sampleMaterna2 == 1)

qui predict p11, p11
qui predict p10, p10
qui gen pr_supply = p11+p10
qui predict p01, p01
qui gen pr_demand = p11+p01
sum pr_supply pr_demand, d

qui gen weight = 1 /(pr_d*pr_s) if(ReggioMaterna == 1)
qui replace weight = 1 /(1 - pr_d*pr_s) if(ReggioMaterna == 0)

sum weight

reg `varoutcome' ReggioMaterna $controls [iweight = weight] if (sampleMaterna2 == 1), rob
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioMaterna]/_se[ReggioMaterna])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioMaterna])>0{
	     local ++cmp //increase by one
	  }
	  if sign(_b[ReggioMaterna])<0{
	     local ++cmn //increase by one
	  }
	}
	outreg2 using `varoutcome'_materna_child, append $outregOption ctitle("PSM2") addtext(Sample, RAvsPP, Mean, `varmean')

di "*** REGRESSION 17 (OLS Reggio + Parma)"

use "$dir/Analysis/chiara&daniela/child_data4July16.dta", clear
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
	outreg2 using `varoutcome'_materna_child, append $outregOption ctitle("OLS") addtext(Sample, RePr, Mean, `varmean')

di "*** REGRESSION 18 (diff-in-diff Reggio + Parma)"

use "$dir/Analysis/chiara&daniela/child_data4July16.dta", clear

keep if(sample3 == 1)
count

qui probit ReggioMaterna $IVmaterna $controls if(Reggio == 1)
qui predict pr_ReggioMaterna
qui gen weight = (1 / pr_ReggioMaterna) if(ReggioMaterna == 1)
qui replace weight = (1 / (1 - pr_ReggioMaterna)) if(ReggioMaterna == 0)

qui gen ParmaMaterna = (materna_Municipal == 1 & Parma == 1)
qui gen altraMaternaR = (ReggioMaterna == 0 & Reggio == 1)
qui gen altraMaternaP = (ParmaMaterna  == 0 & Parma ==1)


reg `varoutcome' ReggioMaterna Reggio materna_Municipal $controls [iweight = weight] if sample3==1, rob 
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioMaterna]/_se[ReggioMaterna])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioMaterna])>0{
	     local ++cmp //increase by one
	  }
	  if sign(_b[ReggioMaterna])<0{
	     local ++cmn //increase by one
	  }
	}
	outreg2 using `varoutcome'_materna_child, append $outregOption ctitle("DiD Pr") addtext(Sample, RePr, Mean, `varmean')

**Double check
reg `varoutcome' ReggioMaterna ParmaMaterna altraMaternaR $controls [iweight = weight] if sample3==1, rob  //altraMaternaP 
lincom (ReggioMaterna - altraMaternaR) - (ParmaMaterna) //(ParmaMaterna - altraMaternaP)

di "*** REGRESSION 19 (OLS Reggio + Padova)"

use "$dir/Analysis/chiara&daniela/child_data4July16.dta", clear

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
	outreg2 using `varoutcome'_materna_child, append $outregOption ctitle("OLS") addtext(Sample, RePd, Mean, `varmean')

di "*** REGRESSION 20 (diff-in-diff Reggio + Padova)"

use "$dir/Analysis/chiara&daniela/child_data4July16.dta", clear

keep if(sample4 == 1)
count

qui probit ReggioMaterna $IVmaterna $controls if(Reggio == 1)
qui predict pr_ReggioMaterna
qui gen weight = (1 / pr_ReggioMaterna) if(ReggioMaterna == 1)
qui replace weight = (1 / (1 - pr_ReggioMaterna)) if(ReggioMaterna == 0)

qui gen PadovaMaterna = (materna_Municipal == 1 & Padova == 1)
qui gen altraMaternaR = (ReggioMaterna == 0 & Reggio == 1)
qui gen altraMaternaP = (PadovaMaterna  == 0 & Padova ==1)

reg `varoutcome' ReggioMaterna Reggio materna_Municipal $controls [iweight = weight] if sample4==1, rob //altraMaternaP 
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioMaterna]/_se[ReggioMaterna])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioMaterna])>0{
	     local ++cmp //increase by one
	  }
	  if sign(_b[ReggioMaterna])<0{
	     local ++cmn //increase by one
	  }
	}
	outreg2 using `varoutcome'_materna_child, append $outregOption ctitle("DiD Pd") addtext(Sample, RePd, Mean, `varmean')

**CHECK
reg `varoutcome' ReggioMaterna PadovaMaterna altraMaternaR $controls [iweight = weight] if sample4==1, rob  //altraMaternaP 
lincom (ReggioMaterna - altraMaternaR) - (PadovaMaterna) //(PadovaMaterna - altraMaternaP)

di "----------------------- `cap' `can' `cmp' `cmn' --------------------"
matrix Signcount[`row',1] = `cap' 
matrix Signcount[`row',2] = `can' 
matrix Signcount[`row',3] = `cmp' 
matrix Signcount[`row',4] = `cmn' 
matrix list Signcount
local ++row
}

/* save the matrix in an excel sheet
putexcel set Signcount.xlsx, sheet(children) modify
putexcel B3 = matrix(Signcount)
*/

log close
