*---------------- Trials for the best fitting IV -----------------------------------------------------*
global dir "/mnt/Data/Dropbox/ReggioChildren"
//global dir "C:/Users/pbiroli/Dropbox/ReggioChildren"
//global dir "C:/Users/Pronzato/Dropbox/ReggioChildren"

cd "$dir/Analysis/chiara&daniela/output"
use "$dir/SURVEY_DATA_COLLECTION/data/Reggio.dta", clear

global controls = "Age Male poorBHealth oldsibs momMaxEdu_Uni_F dadMaxEdu_Uni_F momMaxEdu_Uni_Miss dadMaxEdu_Uni_Miss HighInc_F HighInc_Miss houseOwn_F distCenter cgRelig_F cgRelig_Miss CAPI" //houseOwn_Miss 

*FINAL CUT: children
global IVnido =    "score75 cgAsilo_F distAsiloMunicipal1 distanza2 distanza3 distA_MomBorn distA_oldsibs" //distAsiloPrivate1 distA_distAsiloPrivate distA_poorBHealth 
global IVmaterna = "score75 distMaternaMunicipal1 distMaternaReligious1 distMR_relig distM_cgRelig_F" //   score75_cgRelig_F

*FINAL CUT: ado
global IVnido =    "score75 score75_momBornProvince momBornProvince_F cgAsilo_F distAsiloMunicipal1 distanza2 distanza3 distA_momBornProvince "   // distAsiloPrivate1 distA_distAsiloPrivate score75_momBornProvince    score50 score50_momBornProvince 
global IVmaterna = "score50 distMaternaMunicipal1 " // momBornProvince_F distM_dadMaxEdu_Uni_F momBornProvince_F distM_dadMaxEdu_Uni_F


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

capture drop score25 score50 score75 
sum score
sum score, d   //if Cohort==1 & City==1
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

sum $outcomes $controls $IVnido $IVmaterna
drop if(ReggioAsilo == . | ReggioMaterna == .)


if 1==1{//---------------------------- ADOLESCENTS ------------------------------------------------------------*
keep if Cohort==3

//redo score percentile for within-cohort
capture drop score25 score50 score75 
sum score
sum score if City==1, detail
gen score25 = (score <= r(p25))
gen score50 = (score > r(p25) & score <= r(p50))
gen score75 = (score > r(p50) & score <= r(p75))
label var score25 "25th pct of RA admission score"
label var score50 "50th pct of RA admission score"
label var score75 "75th pct of RA admission score"



* potential instruments
*Distance: this seems pretty linear
lowess ReggioAsilo distAsiloMunicipal1 if Reggio==1  & Cohort==3
lowess ReggioMaterna distMaternaMunicipal1 if Reggio==1  & Cohort==3

*Score: there is no effect in here!
lowess ReggioAsilo score if Reggio==1 & Cohort==3
lowess ReggioMaterna score if Reggio==1 & Cohort==3

/* Quantiles 
* Asilo
capture drop d_a_m_q*
xtile pct = distAsiloMunicipal1, n(5)
tab pct, gen(d_a_m_q)
drop pct d_a_m_q1 //keep the closest ars reference

capture drop scoreq*
xtile pct = distAsiloMunicipal1, n(5)
tab pct, gen(scoreq)
drop pct scoreq1 //keep the closest ars reference
*/

* Higher order -- they don't work
foreach var of varlist score { //distAsiloPrivate1 distAsiloReligious1 distMaternaMunicipal1 distAsiloMunicipal1 score distAsiloPrivate1 distAsiloReligious1 
gen `var'2 = `var'^2
gen `var'3 = `var'^3
}


gen distA2 = distAsiloMunicipal1^2
gen distA3 = distAsiloMunicipal1^3

gen distM2 = distMaternaMunicipal1^2
gen distM3 = distMaternaMunicipal1^3


* Materna
capture drop d_m_m_q*
xtile pct = distMaternaMunicipal1, n(5)
tab pct, gen(d_m_m_q)
drop pct d_m_m_q1 //keep the closest ars reference

//cgReddito_low cgSES_worker cgSES_teacher cgSES_professional cgSES_self momMaxEdu_low momMaxEdu_HS momMaxEdu_middle momMaxEdu_Uni 

foreach var of varlist $controls  momBorn* grandClose_F distAsiloPrivate1 distAsiloReligious1 cgAsilo_F { //$controls  momBorn* grandClose_F distAsiloPrivate1 distAsiloReligious1 cgAsilo_F 
replace `var'=0 if `var'==.
capture drop distA_`var' 
capture drop distM_`var' 
capture drop score75_`var' 
capture drop score_`var' 
capture drop score25_`var'
gen distA_`var' = distAsiloMunicipal1 * `var'
gen distM_`var' = distMaternaMunicipal1 * `var'
gen score75_`var' = score75 * `var'
gen score_`var' = score * `var'
gen score25_`var' = score25 * `var'
gen score50_`var' = score25 * `var'
}

////// CONSTRUCT AND KEEP
label var distA_oldsibs "distance asilo municipal x older sibs dummy"
label var distM_cgRelig_F "distance materna municipal x religious caregiver"

**** First stage: NOTE WE ARE NOT CONTROLLING FOR nido ... 
**Asilo
qui gen demand = (ReggioAsilo == 1)
qui gen supply = (ReggioAsilo == 1)

global IVnido =    "score50 momBornProvince_F cgAsilo_F distAsiloMunicipal1 distanza2 distanza3 distA_momBornProvince "   // distAsiloPrivate1 distA_distAsiloPrivate score75_momBornProvince    score50 score50_momBornProvince 
//momBornProvince_Miss dadBornProvince_Miss score score2 score3 momBornProvince_F dadBornProvince_F score75_Age  cgMaterna_F score75_cgAsilo_F score75_momBornProvince 
//distA_MomBorn  distAsiloReligious1 score75_distAsiloMuni distM_cgRelig_F distA_poorBHealth  distA_MomBorn distA_oldsibs distAsiloReligious1 distA_distAsiloReligious1 distA_cgAsilo_F 

reg    ReggioAsilo $IVnido $controls if(Reggio == 1), robu
test $IVnido

probit ReggioAsilo $IVnido $controls if(Reggio == 1)
matrix beta = e(b)
test $IVnido

global bipX = "Age Male poorBHealth oldsibs momMaxEdu_Uni_F dadMaxEdu_Uni_F HighInc_F houseOwn_F distCenter cgRelig_F CAPI " //houseOwn_Miss  cgRelig_Miss  momMaxEdu_Uni_Miss dadMaxEdu_Uni_Miss HighInc_Miss 
biprobit (supply = score50 $bipX) (demand = distAsiloMunicipal1 $bipX) if(Reggio == 1), partial difficult iter(200) from(beta, skip)
// score50  score50_momBornProvince momBornProvince_F momBornProvince_F 
// momBornProvince_F distA_momBornProvince cgAsilo_F distAsiloMunicipal1 distanza2 distanza3   cgAsilo_F 
 
**Materna
capture drop demand supply
qui gen demand = (ReggioMaterna == 1)
qui gen supply = (ReggioMaterna == 1)


//global IVmaterna = "score50 cgAsilo_F distMaternaMunicipal1 momBornProvince_F dadBornProvince_F momBornProvince_Miss dadBornProvince_Miss"
/*
cgMaterna_F cgAsilo_F 
distM2 distM3 
distMaternaPrivate1 distM_distMaternaPrivate distM_poorBHealth  

momBornProvince_Miss dadBornProvince_Miss score score2 score3 momBornProvince_F dadBornProvince_F distM_MomBorn  distMaternaReligious1 score75_distMaternaMuni score75_Age 
momBornProvince_F dadBornProvince_F 

gen distMR_relig = distMaternaReligious1*cgRelig_F
gen distMP_income = distMaternaPrivate1* HighInc_F
*/

global IVmaterna = "score50 distMaternaMunicipal1 " // momBornProvince_F distM_dadMaxEdu_Uni_F momBornProvince_F distM_dadMaxEdu_Uni_F

reg    ReggioMaterna $IVmaterna $controls if(Reggio == 1), robu
test $IVmaterna

probit ReggioMaterna $IVmaterna $controls if(Reggio == 1)
matrix beta = e(b)
test $IVmaterna

global bipX = "Age Male poorBHealth oldsibs momMaxEdu_Uni_F dadMaxEdu_Uni_F HighInc_F houseOwn_F distCenter cgRelig_F CAPI " //houseOwn_Miss  cgRelig_Miss  momMaxEdu_Uni_Miss dadMaxEdu_Uni_Miss HighInc_Miss 
biprobit (supply = score50 $bipX) (demand = distAsiloMunicipal1 $bipX) if(Reggio == 1), partial difficult iter(200) from(beta, skip)
biprobit (supply = score50 Male Age oldsibs) (demand = distAsiloMunicipal1 Male Age oldsibs) if(Reggio == 1), partial difficult iter(200) //from(beta, skip)
}
****
if 1==0{//---------------------------- CHILDREN  --------------------------------------------------------------*
keep if Cohort==1
des $controls $IVnido $IVmaterna

//redo score percentile for within-cohort
capture drop score25 score50 score75 
sum score
sum score, d
gen score25 = (score <= r(p25))
gen score50 = (score > r(p25) & score <= r(p50))
gen score75 = (score > r(p50) & score <= r(p75))
label var score25 "25th pct of RA admission score"
label var score50 "50th pct of RA admission score"
label var score75 "75th pct of RA admission score"


* potential instruments
*Distance
lowess ReggioAsilo distAsiloMunicipal1 if Reggio==1 & Cohort==1
lowess ReggioMaterna distMaternaMunicipal1 if Reggio==1 & Cohort==1

*Score
lowess ReggioAsilo score if Reggio==1 & Cohort==1
lowess ReggioMaterna score if Reggio==1 & Cohort==1

* Quantiles 
* Asilo
capture drop d_a_m_q*
xtile pct = distAsiloMunicipal1, n(5)
tab pct, gen(d_a_m_q)
drop pct d_a_m_q1 //keep the closest ars reference

capture drop scoreq*
xtile pct = distAsiloMunicipal1, n(5)
tab pct, gen(scoreq)
drop pct scoreq1 //keep the closest ars reference


* Higher order -- they don't work
gen dist2AsiloMunicipal1 = distAsiloMunicipal1^2
gen dist3AsiloMunicipal1 = distAsiloMunicipal1^3

gen score2 = score^2
gen score3 = score^3

foreach var of varlist distMaternaMunicipal1{ //distAsiloPrivate1 distAsiloReligious1
gen `var'2 = `var'^2
gen `var'3 = `var'^3
}


gen distM2 = distMaternaMunicipal1^2
gen distM3 = distMaternaMunicipal1^3


* Materna
capture drop d_m_m_q*
xtile pct = distMaternaMunicipal1, n(5)
tab pct, gen(d_m_m_q)
drop pct d_m_m_q1 //keep the closest ars reference

//cgReddito_low cgSES_worker cgSES_teacher cgSES_professional cgSES_self momMaxEdu_low momMaxEdu_HS momMaxEdu_middle momMaxEdu_Uni 
foreach var of varlist distAsiloMunicipal1 distAsiloPrivate1 distAsiloReligious1 { //distAsiloPrivate1 distAsiloReligious1 $controls  momBorn* grandClose_F
replace `var'=0 if `var'==.
gen distA_`var' = distAsiloMunicipal1 * `var'
//gen score75_`var' = score * `var'
}

//cgReddito_low cgSES_worker cgSES_teacher cgSES_professional cgSES_self momMaxEdu_low momMaxEdu_HS momMaxEdu_middle momMaxEdu_Uni 
foreach var of varlist distMaternaMunicipal1 distMaternaPrivate1 distMaternaReligious1 $controls  momBorn* grandClose_F{ //distMaternaPrivate1 distMaternaReligious1 $controls  momBorn* grandClose_F
replace `var'=0 if `var'==.
gen distM_`var' = distMaternaMunicipal1 * `var'
//gen score75_`var' = score * `var'
}



////// CONSTRUCT AND KEEP
gen distA_oldsibs = distAsiloMunicipal1 * oldsibs
label var distA_oldsibs "distance asilo municipal x older sibs dummy"

gen distMR_relig = distMaternaReligious1*cgRelig_F

gen distM_cgRelig_F = distMaternaMunicipal1*cgRelig_F
label var distM_cgRelig_F "distance materna municipal x religious caregiver"

**** First stage: NOTE WE ARE NOT CONTROLLING FOR nido ... 
**Asilo
qui gen demand = (ReggioAsilo == 1)
qui gen supply = (ReggioAsilo == 1)

global IVnido =    "score75 cgAsilo_F distAsiloMunicipal1 distanza2 distanza3 distA_MomBorn distA_oldsibs" //distAsiloPrivate1 distA_distAsiloPrivate distA_poorBHealth 
//momBornProvince_Miss dadBornProvince_Miss score score2 score3 momBornProvince_F dadBornProvince_F distA_MomBorn  distAsiloReligious1 score75_distAsiloMuni score75_Age  distM_cgRelig_F 

reg    ReggioAsilo $IVnido $controls if(Reggio == 1), robu
test $IVnido

probit ReggioAsilo $IVnido $controls if(Reggio == 1)
test $IVnido

biprobit (supply = score75 $controls) (demand = cgAsilo_F distAsiloMunicipal1 distanza2 distanza3 distA_MomBorn distA_oldsibs $controls) if(Reggio == 1), partial difficult

**Materna
qui gen demand = (ReggioMaterna == 1)
qui gen supply = (ReggioMaterna == 1)


//global IVmaterna = "score50 cgAsilo_F distMaternaMunicipal1 momBornProvince_F dadBornProvince_F momBornProvince_Miss dadBornProvince_Miss"
/*
cgMaterna_F cgAsilo_F 
distM2 distM3 
distMaternaPrivate1 distM_distMaternaPrivate distM_poorBHealth  

momBornProvince_Miss dadBornProvince_Miss score score2 score3 momBornProvince_F dadBornProvince_F distM_MomBorn  distMaternaReligious1 score75_distMaternaMuni score75_Age 
momBornProvince_F dadBornProvince_F 

gen distMR_relig = distMaternaReligious1*cgRelig_F
gen distMP_income = distMaternaPrivate1* HighInc_F
*/

global IVmaterna = "score25 distMaternaMunicipal1 distMaternaReligious1 distMR_relig distM_cgRelig_F" //   score75_cgRelig_F

reg    ReggioMaterna $IVmaterna $controls if(Reggio == 1), robu
test $IVmaterna

probit ReggioMaterna $IVmaterna $controls if(Reggio == 1)
test $IVmaterna
//score75_cgRelig_F 
biprobit (supply = score75 $controls) (demand = score75 distMaternaMunicipal1 distMaternaReligious1 distMR_relig distM_cgRelig_F $controls) if(Reggio == 1), partial difficult //this is cheating, score75 should't be there in the demand ...
}

