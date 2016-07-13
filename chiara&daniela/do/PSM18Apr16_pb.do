clear all
set more off
capture log close

global klmReggio	: 	env klmReggio		
global data_reggio	: 	env data_reggio
global git_reggio	: 	env git_reggio

**** ONLY COHORT 1994 
**** THREE OUTCOMES (HEALTH, DEPRESSION, SDQ) 
**** 18 regressions

*** INFANT-TODDLER (12 regressions)
** (nido 1) sample: RC versus noRC in Reggio
* (nido 1a) OLS 
* (nido 1b) PSM (tradional)
* (nido 1c) PSM (with demand and supply)
* (nido 1d) IV
** (nido 2) sample: RC versus noRC in Parma and Padua
* (nido 2a) OLS 
* (nido 2b) PSM (tradional)
* (nido 2c) PSM (with demand and supply)
* (nido 2d) IV
** (nido 3) sample: RC versus noRC in Reggio, Parma and Padua
* (nido 3a) OLS 
* (nido 3b) PSM (tradional)
* (nido 3c) PSM (with demand and supply)
* (nido 3d) IV

*** PRE-SCHOOL (12 regressions)
** (materna 1) sample: RC versus noRC in Reggio
* (materna 1a) OLS 
* (materna 1b) PSM (tradional)
* (materna 1c) PSM (with demand and supply)
* (materna 1d) IV
** (materna 2) sample: RC versus noRC in Parma and Padua
* (materna 2a) OLS 
* (materna 2b) PSM (tradional)
* (materna 2c) PSM (with demand and supply)
* (materna 2d) IV
** (materna 3) sample: RC versus noRC in Reggio, Parma and Padua
* (materna 3a) OLS 
* (materna 3b) PSM (tradional)
* (materna 3c) PSM (with demand and supply)
* (materna 3d) IV

********************************************************************************
*** COHORT 1994

include ${git_reggio}/prepare-data.do
*use "${data_reggio}/Reggio.dta", clear
cd "${klmReggio}/Analysis/chiara&daniela"

*** only 1994 
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

sum momMaxEdu_Uni dadMaxEdu_Uni
gen dadMaxEdu_Uni_F=dadMaxEdu_Uni
replace dadMaxEdu_Uni_F=0 if dadMaxEdu_Uni==.
gen dadMaxEdu_Uni_Miss=dadMaxEdu_Uni==.
gen momMaxEdu_Uni_F=momMaxEdu_Uni
replace momMaxEdu_Uni_F=0 if momMaxEdu_Uni==.
gen momMaxEdu_Uni_Miss=momMaxEdu_Uni==.
sum momMaxEdu_Uni_* dadMaxEdu_Uni_*

tab cgIncomeCat, g(IncCat_)
gen HighInc=(IncCat_5==1|IncCat_6==1|IncCat_7==1) if !mi(cgIncomeCat)
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

sum score
sum score, d
gen score25 = (score <= r(p25))
gen score50 = (score > r(p25) & score <= r(p50))
gen score75 = (score > r(p50) & score <= r(p75))

sum distAsiloMunicipal1 distMaternaMunicipal1
sum distAsiloMunicipal1
gen distanza2 = distAsiloMunicipal1^2
gen distanza3 = distAsiloMunicipal1^3

sum momBornProvince dadBornProvince
gen momBornProvince_F = momBornProvince if(momBornProvince != .)
gen momBornProvince_Miss = (momBornProvince == .)
replace momBornProvince_F = 0 if (momBornProvince == .)
gen dadBornProvince_F = dadBornProvince if(dadBornProvince != .)
gen dadBornProvince_Miss = (dadBornProvince == .)
replace dadBornProvince_F = 0 if (dadBornProvince == .)
sum momBornProvince_* dadBornProvince_*

tab grandDist, m
tab grandDist, m nol
gen grandClose_F = (grandDist <= 4)
gen grandClose_Miss = (grandDist > 7)
sum grandClose_*

gen distA_MomEd=distAsiloMunicipal1*momMaxEdu_Uni_F
gen distM_MomEd=distMaternaMunicipal1*momMaxEdu_Uni_F
gen distA_MomBorn=distAsiloMunicipal1*momBornProvince_F
gen distM_MomBorn=distMaternaMunicipal1*momBornProvince_F
sum distA_Mom* distM_Mom*

label var poorBHealth "Poor health at birth"
label var oldsibs "Older siblings "
label var momMaxEdu_Uni_F "Mom university edu "
label var dadMaxEdu_Uni_F "Dad university edu "
label var HighInc_F "Fam income over 50k "
label var HighInc_Miss "Fam income not reported "
label var houseOwn_F "Own home "
label var distCenter "Distance to center"
label var cgRelig_F "Caregiver religious "
label var CAPI "CAPI"
label var cgAsilo_F  "Caregiver to ITC"
label var cgMaterna_F  "Caregiver to PS"
label var score50  "RA score second quartile"
label var momBornProvince_F "Mom born in province"
label var dadBornProvince_F "Dad born in province"

*** global
global outcomes = "SDQ_score Depression childHealthPerc"
global controls = "Age Male poorBHealth oldsibs momMaxEdu_Uni_F dadMaxEdu_Uni_F HighInc_F HighInc_Miss houseOwn_F distCenter cgRelig_F CAPI"  
//no variation: momMaxEdu_Uni_Miss dadMaxEdu_Uni_Miss houseOwn_Miss cgRelig_Miss 
global IVnido = "cgAsilo_F score50 distAsiloMunicipal1 distanza2 distanza3 momBornProvince_F dadBornProvince_F distA_MomBorn"
//no variation: momBornProvince_Miss dadBornProvince_Miss 
global IVmaterna = "cgMaterna_F score50 distMaternaMunicipal1 momBornProvince_F dadBornProvince_F"
//no variation: momBornProvince_Miss dadBornProvince_Miss 

global outregoptions bracket dec(3) sortvar(ReggioAsilo ReggioMaterna)
//drop(o.* *internr_* *Month_int_* Male* mom* dad* cgRelig* houseOwn* cgReddito*) ctitle(" ") 
 

sum $outcomes $controls $IVnido $IVmaterna


if 1==1{ // Summary statistics
	*** Summary statistics
	local outAdol $outcomes

	*tables of outcomes
	local options se sdbracket vert nototal nptest //sd mtprob mtest bdec(3) ci cibrace nptest 
	local group cityXasilo
	tabformprova `outAdol'  using adolescent_OUTCOMEasilo if Cohort==3, by(`group') `options'
	local group cityXmaterna
	tabformprova `outAdol'  using adolescent_OUTCOMEmaterna if Cohort==3, by(`group') `options'

	*table of controls and IV
	local group asiloG_1_2
	tabformprova $outcomes $controls $IVnido using adolescent_CONTROL1asilo if Cohort==3, by(`group') `options'
	local group asiloG3
	tabformprova $outcomes $controls $IVnido using adolescent_CONTROL2asilo if Cohort==3, by(`group') `options'
	local group maternaG_1_2
	tabformprova $outcomes $controls $IVmaterna using adolescent_CONTROL1materna if Cohort==3, by(`group') `options'
	local group maternaG3
	tabformprova $outcomes $controls $IVmaterna using adolescent_CONTROL2materna if Cohort==3, by(`group') `options'
}


keep $outcomes $controls $IVnido $IVmaterna ReggioAsilo ReggioMaterna nido Reggio Parma Padova intnr Cohort
sum 


*** OLS REGRESSIONS n1a, n2a, n3a, m1a, m2a, m3a

local iter = 1
foreach j in $outcomes {
	* n1a *
	reg `j' ReggioAsilo nido $controls if(Reggio == 1), rob
	gen beta_`j'1 = _b[ReggioAsilo]
	gen se_`j'1 = _se[ReggioAsilo]
	gen t_`j'1 = abs(_b[ReggioAsilo]/_se[ReggioAsilo])
	gen obs_`j'1=e(N)
	if `iter'==1{
	di "sto facendo replace"
	outreg2 using "${klmReggio}/Analysis/chiara&daniela/resultsOLS.tex", replace tex(frag) $outregoptions 
	}
	else if `iter'>1{
	di "sto facendo append"
	outreg2 using "${klmReggio}/Analysis/chiara&daniela/resultsOLS.tex", append tex(frag) $outregoptions 
	}

	* n2a *
	reg `j' ReggioAsilo nido $controls Padova if((Reggio == 1 & ReggioAsilo == 1) | Reggio == 0), rob
	gen beta_`j'4 = _b[ReggioAsilo]
	gen se_`j'4 = _se[ReggioAsilo]
	gen t_`j'4 = abs(_b[ReggioAsilo]/_se[ReggioAsilo])
	gen obs_`j'4=e(N)
	outreg2 using "${klmReggio}/Analysis/chiara&daniela/resultsOLS.tex", append tex(frag) $outregoptions 
	* n3a *
	reg `j' ReggioAsilo nido $controls Parma Padova, rob
	gen beta_`j'7 = _b[ReggioAsilo]
	gen se_`j'7 = _se[ReggioAsilo]
	gen t_`j'7 = abs(_b[ReggioAsilo]/_se[ReggioAsilo])
	gen obs_`j'7=e(N)
	outreg2 using "${klmReggio}/Analysis/chiara&daniela/resultsOLS.tex", append tex(frag) $outregoptions 
	* m1a *
	reg `j' ReggioMaterna $controls if(Reggio == 1), rob
	gen beta_`j'10 = _b[ReggioMaterna]
	gen se_`j'10 = _se[ReggioMaterna]
	gen t_`j'10 = abs(_b[ReggioMaterna]/_se[ReggioMaterna])
	gen obs_`j'10=e(N)
	outreg2 using "${klmReggio}/Analysis/chiara&daniela/resultsOLS.tex", append tex(frag) $outregoptions 
	* m2a *
	reg `j' ReggioMaterna $controls Padova if((Reggio == 1 & ReggioMaterna == 1) | Reggio == 0), rob
	gen beta_`j'13 = _b[ReggioMaterna]
	gen se_`j'13 = _se[ReggioMaterna]
	gen t_`j'13 = abs(_b[ReggioMaterna]/_se[ReggioMaterna])
	gen obs_`j'13=e(N)
	outreg2 using "${klmReggio}/Analysis/chiara&daniela/resultsOLS.tex", append tex(frag) $outregoptions 
	* m3a *
	reg `j' ReggioMaterna $controls Parma Padova, rob
	gen beta_`j'16 = _b[ReggioMaterna]
	gen se_`j'16 = _se[ReggioMaterna]
	gen t_`j'16 = abs(_b[ReggioMaterna]/_se[ReggioMaterna])
	gen obs_`j'16=e(N)
	outreg2 using "${klmReggio}/Analysis/chiara&daniela/resultsOLS.tex", append tex(frag) $outregoptions 

	local iter = `iter'+1
}

preserve
keep beta_* se_* t_* obs_*
keep in 1
save "${klmReggio}/Analysis/chiara&daniela/resultsOLS.dta", replace
restore
drop beta_* se_* t_* obs_*

*** IV REGRESSIONS n1d, n2d, n3d, m1d, m2d, m3d

local iter=1
foreach j in $outcomes {
* n1a *
ivreg2 `j' (ReggioAsilo = $IVnido) nido $controls if(Reggio == 1), rob
gen beta_`j'_IV1 = _b[ReggioAsilo]
gen se_`j'_IV1 = _se[ReggioAsilo]
gen t_`j'_IV1 = abs(_b[ReggioAsilo]/_se[ReggioAsilo])
gen obs_`j'_IV1=e(N)
if `iter'==1{
di "sto facendo replace"
outreg2 using "${klmReggio}/Analysis/chiara&daniela/resultsIV.tex", replace tex(frag) $outregoptions 
}
else if `iter'>1{
di "sto facendo append"
outreg2 using "${klmReggio}/Analysis/chiara&daniela/resultsIV.tex", append tex(frag) $outregoptions 
}
* n2a *
ivreg2 `j' (ReggioAsilo = $IVnido) nido $controls Padova if((Reggio == 1 & ReggioAsilo == 1) | Reggio == 0), rob
gen beta_`j'_IV4 = _b[ReggioAsilo]
gen se_`j'_IV4 = _se[ReggioAsilo]
gen t_`j'_IV4 = abs(_b[ReggioAsilo]/_se[ReggioAsilo])
gen obs_`j'_IV4=e(N)
outreg2 using "${klmReggio}/Analysis/chiara&daniela/resultsIV.tex", append tex(frag) $outregoptions 
* n3a *
ivreg2 `j' (ReggioAsilo = $IVnido) nido $controls Parma Padova, rob
gen beta_`j'_IV7 = _b[ReggioAsilo]
gen se_`j'_IV7 = _se[ReggioAsilo]
gen t_`j'_IV7 = abs(_b[ReggioAsilo]/_se[ReggioAsilo])
gen obs_`j'_IV7=e(N)
outreg2 using "${klmReggio}/Analysis/chiara&daniela/resultsIV.tex", append tex(frag) $outregoptions 
* m1a *
ivreg2 `j' (ReggioMaterna = $IVmaterna) $controls if(Reggio == 1), rob
gen beta_`j'_IV10 = _b[ReggioMaterna]
gen se_`j'_IV10 = _se[ReggioMaterna]
gen t_`j'_IV10 = abs(_b[ReggioMaterna]/_se[ReggioMaterna])
gen obs_`j'_IV10=e(N)
outreg2 using "${klmReggio}/Analysis/chiara&daniela/resultsIV.tex", append tex(frag) $outregoptions 
* m2a *
ivreg2 `j' (ReggioMaterna = $IVmaterna) $controls Padova if((Reggio == 1 & ReggioMaterna == 1) | Reggio == 0), rob
gen beta_`j'_IV13 = _b[ReggioMaterna]
gen se_`j'_IV13 = _se[ReggioMaterna]
gen t_`j'_IV13 = abs(_b[ReggioMaterna]/_se[ReggioMaterna])
gen obs_`j'_IV13=e(N)
outreg2 using "${klmReggio}/Analysis/chiara&daniela/resultsIV.tex", append tex(frag) $outregoptions 
* m3a *
ivreg2 `j' (ReggioMaterna = $IVmaterna) $controls Parma Padova, rob
gen beta_`j'_IV16 = _b[ReggioMaterna]
gen se_`j'_IV16 = _se[ReggioMaterna]
gen t_`j'_IV16 = abs(_b[ReggioMaterna]/_se[ReggioMaterna])
gen obs_`j'_IV16=e(N)
outreg2 using "${klmReggio}/Analysis/chiara&daniela/resultsIV.tex", append tex(frag) $outregoptions 

local iter = `iter'+1
}

preserve
keep beta_* se_* t_* obs_*
keep in 1
save "${klmReggio}/Analysis/chiara&daniela/resultsIV.dta", replace
restore
drop beta_* se_* t_* obs_*


*** PSM REGRESSIONS TRADITIONAL n1b, n2b, n3b
probit ReggioAsilo $IVnido $controls if(Reggio == 1)
outreg2 using "${klmReggio}/Analysis/chiara&daniela/resultsPSM1.tex", replace tex(frag) $outregoptions 
predict pr_ReggioAsilo // perchè 6 missing??
sum pr_ReggioAsilo
sum pr_ReggioAsilo if(Reggio == 1 & ReggioAsilo == 1)
sum pr_ReggioAsilo if(Reggio == 1 & ReggioAsilo == 0)
sum pr_ReggioAsilo if(Parma == 1)
sum pr_ReggioAsilo if(Padova == 1)

* n1b *
foreach j in $outcomes {
psmatch2 ReggioAsilo if(Reggio == 1), outcome(`j') pscore(pr_ReggioAsilo) 
reg `j' ReggioAsilo nido [fweight = _weight], robust
gen beta_`j'2 = _b[ReggioAsilo]
gen se_`j'2 = _se[ReggioAsilo]
gen t_`j'2 = abs(_b[ReggioAsilo]/_se[ReggioAsilo])
gen obs_`j'2 = e(N)
outreg2 using "${klmReggio}/Analysis/chiara&daniela/resultsPSM1.tex", append tex(frag) $outregoptions 
}

drop _pscore _treated _support _weight _childHealthPerc _id _n1 _nn _pdif

* n2b *
foreach j in $outcomes {
psmatch2 ReggioAsilo if((Reggio == 1 & ReggioAsilo == 1)| (Reggio == 0)), outcome(`j') pscore(pr_ReggioAsilo) 
reg `j' ReggioAsilo nido Padova [fweight = _weight], robust
gen beta_`j'5 = _b[ReggioAsilo]
gen se_`j'5 = _se[ReggioAsilo]
gen t_`j'5 = abs(_b[ReggioAsilo]/_se[ReggioAsilo])
gen obs_`j'5 = e(N)
outreg2 using "${klmReggio}/Analysis/chiara&daniela/resultsPSM1.tex", append tex(frag) $outregoptions 
}

drop _pscore _treated _support _weight _childHealthPerc _id _n1 _nn _pdif

* n3b *
foreach j in $outcomes {
psmatch2 ReggioAsilo, outcome(`j') pscore(pr_ReggioAsilo) 
reg `j' ReggioAsilo nido [fweight = _weight], robust
gen beta_`j'8 = _b[ReggioAsilo]
gen se_`j'8 = _se[ReggioAsilo]
gen t_`j'8 = abs(_b[ReggioAsilo]/_se[ReggioAsilo])
gen obs_`j'8 = e(N)
outreg2 using "${klmReggio}/Analysis/chiara&daniela/resultsPSM1.tex", append tex(frag) $outregoptions 
}

drop _pscore _treated _support _weight _childHealthPerc _id _n1 _nn _pdif

preserve
keep beta_* se_* t_* obs_*
keep in 1
save "${klmReggio}/Analysis/chiara&daniela/resultsPSMasilo.dta", replace
restore
drop beta_* se_* t_* obs_*

*** PSM REGRESSIONS TRADITIONAL m1b, m2b, m3b

probit ReggioMaterna $IVmaterna $controls if(Reggio == 1)
outreg2 using "${klmReggio}/Analysis/chiara&daniela/resultsPSM1.tex", append tex(frag) $outregoptions 
predict pr_ReggioMaterna // perchè 44 missing??
sum pr_ReggioMaterna
sum pr_ReggioMaterna if(Reggio == 1 & ReggioMaterna == 1)
sum pr_ReggioMaterna if(Reggio == 1 & ReggioMaterna == 0)
sum pr_ReggioMaterna if(Parma == 1)
sum pr_ReggioMaterna if(Padova == 1)

* m1b *
foreach j in $outcomes {
psmatch2 ReggioMaterna if(Reggio == 1), outcome(`j' ) pscore(pr_ReggioMaterna) 
reg `j' ReggioMaterna [fweight = _weight], robust
gen beta_`j'11 = _b[ReggioMaterna]
gen se_`j'11 = _se[ReggioMaterna]
gen t_`j'11 = abs(_b[ReggioMaterna]/_se[ReggioMaterna])
gen obs_`j'11 = e(N)
outreg2 using "${klmReggio}/Analysis/chiara&daniela/resultsPSM1.tex", append tex(frag) $outregoptions 
}

drop _pscore _treated _support _weight _childHealthPerc _id _n1 _nn _pdif

* m2b *
foreach j in $outcomes {
psmatch2 ReggioMaterna if((Reggio == 1 & ReggioMaterna == 1) | Reggio == 0), outcome(`j') pscore(pr_ReggioMaterna) 
reg `j' ReggioMaterna Padova [fweight = _weight], robust
gen beta_`j'14 = _b[ReggioMaterna]
gen se_`j'14 = _se[ReggioMaterna]
gen t_`j'14 = abs(_b[ReggioMaterna]/_se[ReggioMaterna])
gen obs_`j'14 = e(N)
outreg2 using "${klmReggio}/Analysis/chiara&daniela/resultsPSM1.tex", append tex(frag) $outregoptions 
}

drop _pscore _treated _support _weight _childHealthPerc _id _n1 _nn _pdif

* m3b *
foreach j in $outcomes {
psmatch2 ReggioMaterna, outcome(`j') pscore(pr_ReggioMaterna) 
reg `j' ReggioMaterna Parma Padova [fweight = _weight], robust
gen beta_`j'17 = _b[ReggioMaterna]
gen se_`j'17 = _se[ReggioMaterna]
gen t_`j'17 = abs(_b[ReggioMaterna]/_se[ReggioMaterna])
gen obs_`j'17 = e(N)
outreg2 using "${klmReggio}/Analysis/chiara&daniela/resultsPSM1.tex", append tex(frag) $outregoptions 
}

drop _pscore _treated _support _weight _childHealthPerc _id _n1 _nn _pdif

preserve
keep beta_* se_* t_* obs_*
keep in 1
save "${klmReggio}/Analysis/chiara&daniela/resultsPSMmaterna.dta", replace
restore
drop beta_* se_* t_* obs_*

save "${klmReggio}/Analysis/chiara&daniela/dataDS.dta", replace

*** PSM REGRESSIONS BIVARIATE n1c, n2c, n3c

gen demand = (ReggioAsilo == 1)
gen supply = (ReggioAsilo == 1)
biprobit (supply = score50 Male Age momMaxEdu_Uni_F momMaxEdu_Uni_Miss HighInc_F HighInc_Miss houseOwn_F houseOwn_Miss) (demand = cgAsilo_F distAsiloMunicipal1 distanza2 distanza3 momBornProvince_F dadBornProvince_F momBornProvince_Miss dadBornProvince_Miss distA_MomBorn Male Age momMaxEdu_Uni_F momMaxEdu_Uni_Miss HighInc_F HighInc_Miss houseOwn_F houseOwn_Miss) if(Reggio == 1), partial difficult
outreg2 using "${klmReggio}/Analysis/chiara&daniela/resultsPSM2.tex", replace tex(frag) $outregoptions 

*** predicted probabilities

predict p11, p11
predict p10, p10
gen pr_supply = p11+p10
predict p01, p01
gen pr_demand = p11+p01
sum pr_supply pr_demand, d

*** treated group

preserve
keep if (ReggioAsilo == 1)
keep intnr $outcomes nido pr_demand pr_supply Parma Padova 
foreach j in intnr $outcomes nido pr_demand pr_supply Parma Padova {
ren `j' `j'1
}
gen id = _n
sort id
save "treatment.dta", replace
count
restore

*** possible controls

keep if (ReggioAsilo == 0) 
keep intnr $outcomes nido pr_demand pr_supply Parma Padova 
foreach j in intnr $outcomes nido pr_demand pr_supply Parma Padova {
ren `j' `j'0
}
count
expand 153
sort intnr
by intnr: gen id = _n
sort id
save "control.dta", replace
count


*** match treated and controls

use "treatment.dta", clear
merge id using "control.dta"
tab _m
drop _m

gen diff_supply = abs(pr_supply1 - pr_supply0)
gen diff_demand = abs(pr_demand1 - pr_demand0)

*** sample n1c (solo Reggio)

preserve
keep if(Parma0 == 0 & Padova0 == 0)
gsort id diff_supply diff_demand
by id: gen n = _n
keep if(n <= 1)
drop n id  pr_demand* pr_supply*
gen id = _n
gen weight1 = 1
gen weight0 = 1
reshape long SDQ_score Depression childHealthPerc weight intnr nido Parma Padova, i(id) j(ReggioAsilo)
count
tab ReggioAsilo
tab weight
foreach j in $outcomes {
reg `j' ReggioAsilo nido, robust
gen beta_`j'3 = _b[ReggioAsilo]
gen se_`j'3 = _se[ReggioAsilo]
gen t_`j'3 = abs(_b[ReggioAsilo]/_se[ReggioAsilo])
gen obs_`j'3 = e(N)
outreg2 using "${klmReggio}/Analysis/chiara&daniela/resultsPSM2.tex", append tex(frag) $outregoptions 
}
keep beta_* se_* t_* obs_*
keep in 1
save "${klmReggio}/Analysis/chiara&daniela/resultsDSnido3.dta", replace
restore

*** sample n2c (Reggio vs Parma + Padova)

preserve
keep if(Parma0 == 1 | Padova0 == 1)
gsort id diff_supply diff_demand
by id: gen n = _n
keep if(n <= 1)
drop n id  pr_demand* pr_supply*
gen id = _n
gen weight1 = 1
gen weight0 = 1
reshape long SDQ_score Depression childHealthPerc weight intnr nido Parma Padova, i(id) j(ReggioAsilo)
count
tab ReggioAsilo
tab weight
foreach j in $outcomes {
reg `j' ReggioAsilo nido Padova, robust
gen beta_`j'6 = _b[ReggioAsilo]
gen se_`j'6 = _se[ReggioAsilo]
gen t_`j'6 = abs(_b[ReggioAsilo]/_se[ReggioAsilo])
gen obs_`j'6 = e(N)
outreg2 using "${klmReggio}/Analysis/chiara&daniela/resultsPSM2.tex", append tex(frag) $outregoptions 
}
keep beta_* se_* t_* obs_*
keep in 1
save "${klmReggio}/Analysis/chiara&daniela/resultsDSnido6.dta", replace
restore

*** sample n3c (Reggio vs tutto)

preserve
gsort id diff_supply diff_demand
by id: gen n = _n
keep if(n <= 1)
drop n id  pr_demand* pr_supply*
gen id = _n
gen weight1 = 1
gen weight0 = 1
reshape long SDQ_score Depression childHealthPerc weight intnr nido Parma Padova, i(id) j(ReggioAsilo)
count
tab ReggioAsilo
tab weight
foreach j in $outcomes {
reg `j' ReggioAsilo nido Padova Parma, robust
gen beta_`j'9 = _b[ReggioAsilo]
gen se_`j'9 = _se[ReggioAsilo]
gen t_`j'9 = abs(_b[ReggioAsilo]/_se[ReggioAsilo])
gen obs_`j'9 = e(N)
outreg2 using "${klmReggio}/Analysis/chiara&daniela/resultsPSM2.tex", append tex(frag) $outregoptions 
}
keep beta_* se_* t_* obs_*
keep in 1
save "${klmReggio}/Analysis/chiara&daniela/resultsDSnido9.dta", replace
restore

*** PSM REGRESSIONS m1c, m2c, m3c

use "${klmReggio}/Analysis/chiara&daniela/dataDS.dta", clear

gen demand = (ReggioMaterna == 1)
gen supply = (ReggioMaterna == 1)
biprobit (supply = score50 Male Age momMaxEdu_Uni_F momMaxEdu_Uni_Miss houseOwn_F houseOwn_Miss) (demand = cgAsilo_F distMaternaMunicipal1 momBornProvince_F dadBornProvince_F momBornProvince_Miss dadBornProvince_Miss Male Age momMaxEdu_Uni_F momMaxEdu_Uni_Miss houseOwn_F houseOwn_Miss) if(Reggio == 1), partial difficult
outreg2 using "${klmReggio}/Analysis/chiara&daniela/resultsPSM2.tex", append tex(frag) $outregoptions 

*** predicted probabilities

predict p11, p11
predict p10, p10
gen pr_supply = p11+p10
predict p01, p01
gen pr_demand = p11+p01
sum pr_supply pr_demand, d

*** treated group

preserve
keep if (ReggioMaterna == 1)
keep intnr $outcomes nido pr_demand pr_supply Parma Padova 
foreach j in intnr $outcomes nido pr_demand pr_supply Parma Padova {
ren `j' `j'1
}
gen id = _n
sort id
save "treatment.dta", replace
count
restore

*** possible controls

keep if (ReggioMaterna == 0) 
keep intnr $outcomes nido pr_demand pr_supply Parma Padova 
foreach j in intnr $outcomes nido pr_demand pr_supply Parma Padova {
ren `j' `j'0
}
count
expand 164
sort intnr
by intnr: gen id = _n
sort id
save "control.dta", replace
count


*** match treated and controls

use "treatment.dta", clear
merge id using "control.dta"
tab _m
drop _m

gen diff_supply = abs(pr_supply1 - pr_supply0)
gen diff_demand = abs(pr_demand1 - pr_demand0)

*** sample m1c (solo Reggio)

preserve
keep if(Parma0 == 0 & Padova0 == 0)
gsort id diff_supply diff_demand
by id: gen n = _n
keep if(n <= 1)
drop n id  pr_demand* pr_supply*
gen id = _n
gen weight1 = 1
gen weight0 = 1
reshape long SDQ_score Depression childHealthPerc weight intnr nido Parma Padova, i(id) j(ReggioMaterna)
count
tab ReggioMaterna
tab weight
foreach j in $outcomes {
reg `j' ReggioMaterna, robust
gen beta_`j'12 = _b[ReggioMaterna]
gen se_`j'12 = _se[ReggioMaterna]
gen t_`j'12 = abs(_b[ReggioMaterna]/_se[ReggioMaterna])
gen obs_`j'12 = e(N)
outreg2 using "${klmReggio}/Analysis/chiara&daniela/resultsPSM2.tex", append tex(frag) $outregoptions 
}
keep beta_* se_* t_* obs_*
keep in 1
save "${klmReggio}/Analysis/chiara&daniela/resultsDSmaterna12.dta", replace
restore

*** sample m2c (Reggio vs Parma + Padova)

preserve
keep if(Parma0 == 1 | Padova0 == 1)
gsort id diff_supply diff_demand
by id: gen n = _n
keep if(n <= 1)
drop n id  pr_demand* pr_supply*
gen id = _n
gen weight1 = 1
gen weight0 = 1
reshape long SDQ_score Depression childHealthPerc weight intnr nido Parma Padova, i(id) j(ReggioMaterna)
count
tab ReggioMaterna
tab weight
foreach j in $outcomes {
reg `j' ReggioMaterna Padova, robust
gen beta_`j'15 = _b[ReggioMaterna]
gen se_`j'15 = _se[ReggioMaterna]
gen t_`j'15 = abs(_b[ReggioMaterna]/_se[ReggioMaterna])
gen obs_`j'15 = e(N)
outreg2 using "${klmReggio}/Analysis/chiara&daniela/resultsPSM2.tex", append tex(frag) $outregoptions 
}
keep beta_* se_* t_* obs_*
keep in 1
save "${klmReggio}/Analysis/chiara&daniela/resultsDSmaterna15.dta", replace
restore

*** sample m3c (Reggio vs tutto)

preserve
gsort id diff_supply diff_demand
by id: gen n = _n
keep if(n <= 1)
drop n id  pr_demand* pr_supply*
gen id = _n
gen weight1 = 1
gen weight0 = 1
reshape long SDQ_score Depression childHealthPerc weight intnr nido Parma Padova, i(id) j(ReggioMaterna)
count
tab ReggioMaterna
tab weight
foreach j in $outcomes {
reg `j' ReggioMaterna Padova Parma, robust
gen beta_`j'18 = _b[ReggioMaterna]
gen se_`j'18 = _se[ReggioMaterna]
gen t_`j'18 = abs(_b[ReggioMaterna]/_se[ReggioMaterna])
gen obs_`j'18 = e(N)
outreg2 using "${klmReggio}/Analysis/chiara&daniela/resultsPSM2.tex", append tex(frag) $outregoptions 
}
keep beta_* se_* t_* obs_*
keep in 1
save "${klmReggio}/Analysis/chiara&daniela/resultsDSmaterna18.dta", replace
restore
