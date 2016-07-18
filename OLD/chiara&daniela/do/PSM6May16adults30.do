clear all
set more off
capture log close

**** ONLY COHORT 80s 
**** THREE OUTCOMES (HEALTH, DEPRESSION) 
**** 18 regressions

*** INFANT-TODDLER (9 regressions)
** sample: RC versus noRC in Reggio
* 1) OLS 
* 2) PSM (tradional)
* 3) PSM (with demand and supply)
** sample: RC versus noRC in Parma and Padua
* 4) OLS 
* 5) PSM (tradional)
* 6) PSM (with demand and supply)
** sample: RC versus noRC in Reggio, Parma and Padua
* 7) OLS 
* 8) PSM (tradional)
* 9) PSM (with demand and supply)

*** PRE-SCHOOL (9 regressions)
** sample: RC versus noRC in Reggio
* 10) OLS 
* 11) PSM (tradional)
* 12) PSM (with demand and supply)
** sample: RC versus noRC in Parma and Padua
* 13) OLS 
* 14) PSM (tradional)
* 15) PSM (with demand and supply)
** sample: RC versus noRC in Reggio, Parma and Padua
* 16) OLS 
* 17) PSM (tradional)
* 18) PSM (with demand and supply)

********************************************************************************
*** COHORT 80s

use "C:\Users\Pronzato\Dropbox\ReggioChildren\SURVEY_DATA_COLLECTION\data\Reggio.dta", clear

*** only 80s 
* cambiato rispetto ad adolescents

keep if Cohort == 4
count

*** outcomes

* cambiato rispetto ad adolescents
sum Depression_factor HealthPerc 

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

* cambiato rispetto ad adolescents
tab IncomeCat, g(IncCat_)
* cambiato rispetto ad adolescents
gen HighInc=(IncCat_4==1|IncCat_5==1|IncCat_6==1) if !mi(cgIncomeCat)
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

*** global

global outcomes = "SDQ_score Depression childHealthPerc"
global controls = "Age Male poorBHealth oldsibs momMaxEdu_Uni_F dadMaxEdu_Uni_F momMaxEdu_Uni_Miss dadMaxEdu_Uni_Miss HighInc_F HighInc_Miss houseOwn_F houseOwn_Miss distCenter cgRelig_F cgRelig_Miss CAPI"
*global IVnido = "cgAsilo_F cgAsilo_Miss cgMaterna_F cgMaterna_Miss score distAsiloMunicipal1 momBornProvince_F dadBornProvince_F momBornProvince_Miss dadBornProvince_Miss  grandClose_Miss distA_MomEd distA_MomBorn"
global IVnido = "cgAsilo_F score50 distAsiloMunicipal1 distanza2 distanza3 momBornProvince_F dadBornProvince_F momBornProvince_Miss dadBornProvince_Miss distA_MomBorn"
*global IVmaterna = "cgAsilo_F cgAsilo_Miss cgMaterna_F cgMaterna_Miss score distMaternaMunicipal1 momBornProvince_F dadBornProvince_F momBornProvince_Miss dadBornProvince_Miss grandClose_F grandClose_Miss distM_MomEd distM_MomBorn"
global IVmaterna = "cgAsilo_F score50 distMaternaMunicipal1 momBornProvince_F dadBornProvince_F momBornProvince_Miss dadBornProvince_Miss"

sum $outcomes $controls $IVnido $IVmaterna
keep $outcomes $controls $IVnido $IVmaterna ReggioAsilo ReggioMaterna nido Reggio Parma Padova intnr
sum 

*** REGRESSIONS 1, 4, 7, 10, 13, 16

foreach j in $outcomes {
reg `j' ReggioAsilo nido $controls if(Reggio == 1), rob
gen beta_`j'1 = _b[ReggioAsilo]
gen se_`j'1 = _se[ReggioAsilo]
gen t_`j'1 = abs(_b[ReggioAsilo]/_se[ReggioAsilo])
gen obs_`j'1=r(N)
reg `j' ReggioAsilo nido $controls Padova if((Reggio == 1 & ReggioAsilo == 1) | Reggio == 0), rob
gen beta_`j'4 = _b[ReggioAsilo]
gen se_`j'4 = _se[ReggioAsilo]
gen t_`j'4 = abs(_b[ReggioAsilo]/_se[ReggioAsilo])
gen obs_`j'4=r(N)
reg `j' ReggioAsilo nido $controls Parma Padova, rob
gen beta_`j'7 = _b[ReggioAsilo]
gen se_`j'7 = _se[ReggioAsilo]
gen t_`j'7 = abs(_b[ReggioAsilo]/_se[ReggioAsilo])
gen obs_`j'7=r(N)
reg `j' ReggioMaterna $controls if(Reggio == 1), rob
gen beta_`j'10 = _b[ReggioMaterna]
gen se_`j'10 = _se[ReggioMaterna]
gen t_`j'10 = abs(_b[ReggioMaterna]/_se[ReggioMaterna])
gen obs_`j'10=r(N)
reg `j' ReggioMaterna $controls Padova if((Reggio == 1 & ReggioMaterna == 1) | Reggio == 0), rob
gen beta_`j'13 = _b[ReggioMaterna]
gen se_`j'13 = _se[ReggioMaterna]
gen t_`j'13 = abs(_b[ReggioMaterna]/_se[ReggioMaterna])
gen obs_`j'13=r(N)
reg `j' ReggioMaterna $controls Parma Padova, rob
gen beta_`j'16 = _b[ReggioMaterna]
gen se_`j'16 = _se[ReggioMaterna]
gen t_`j'16 = abs(_b[ReggioMaterna]/_se[ReggioMaterna])
gen obs_`j'16=r(N)
}

preserve
keep beta_* se_* t_* obs_*
keep in 1
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\resultsOLS.dta", replace
restore
drop beta_* se_* t_* obs_*

*** REGRESSIONS 2, 5, 8

probit ReggioAsilo $IVnido $controls if(Reggio == 1)
predict pr_ReggioAsilo // perchè 6 missing??
sum pr_ReggioAsilo
sum pr_ReggioAsilo if(Reggio == 1 & ReggioAsilo == 1)
sum pr_ReggioAsilo if(Reggio == 1 & ReggioAsilo == 0)
sum pr_ReggioAsilo if(Parma == 1)
sum pr_ReggioAsilo if(Padova == 1)

psmatch2 ReggioAsilo if(Reggio == 1), outcome(childHealthPerc) pscore(pr_ReggioAsilo) 
foreach j in $outcomes {
reg `j' ReggioAsilo nido [fweight = _weight], robust
gen beta_`j'2 = _b[ReggioAsilo]
gen se_`j'2 = _se[ReggioAsilo]
gen t_`j'2 = abs(_b[ReggioAsilo]/_se[ReggioAsilo])
gen obs_`j'2 = r(N)
}

drop _pscore _treated _support _weight _childHealthPerc _id _n1 _nn _pdif

psmatch2 ReggioAsilo if((Reggio == 1 & ReggioAsilo == 1)| (Reggio == 0)), outcome(childHealthPerc) pscore(pr_ReggioAsilo) 
foreach j in $outcomes {
reg `j' ReggioAsilo nido Padova [fweight = _weight], robust
gen beta_`j'5 = _b[ReggioAsilo]
gen se_`j'5 = _se[ReggioAsilo]
gen t_`j'5 = abs(_b[ReggioAsilo]/_se[ReggioAsilo])
gen obs_`j'5 = r(N)
}

drop _pscore _treated _support _weight _childHealthPerc _id _n1 _nn _pdif

psmatch2 ReggioAsilo, outcome(childHealthPerc) pscore(pr_ReggioAsilo) 
foreach j in $outcomes {
reg `j' ReggioAsilo nido [fweight = _weight], robust
gen beta_`j'8 = _b[ReggioAsilo]
gen se_`j'8 = _se[ReggioAsilo]
gen t_`j'8 = abs(_b[ReggioAsilo]/_se[ReggioAsilo])
gen obs_`j'8 = r(N)
}

drop _pscore _treated _support _weight _childHealthPerc _id _n1 _nn _pdif

preserve
keep beta_* se_* t_* obs_*
keep in 1
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\resultsPSMasilo.dta", replace
restore
drop beta_* se_* t_* obs_*

*** REGRESSIONS 11, 14, 17

probit ReggioMaterna $IVmaterna $controls if(Reggio == 1)
predict pr_ReggioMaterna // perchè 44 missing??
sum pr_ReggioMaterna
sum pr_ReggioMaterna if(Reggio == 1 & ReggioMaterna == 1)
sum pr_ReggioMaterna if(Reggio == 1 & ReggioMaterna == 0)
sum pr_ReggioMaterna if(Parma == 1)
sum pr_ReggioMaterna if(Padova == 1)

psmatch2 ReggioMaterna if(Reggio == 1), outcome(childHealthPerc) pscore(pr_ReggioMaterna) 
foreach j in $outcomes {
reg `j' ReggioMaterna [fweight = _weight], robust
gen beta_`j'11 = _b[ReggioMaterna]
gen se_`j'11 = _se[ReggioMaterna]
gen t_`j'11 = abs(_b[ReggioMaterna]/_se[ReggioMaterna])
gen obs_`j'11 = r(N)
}

drop _pscore _treated _support _weight _childHealthPerc _id _n1 _nn _pdif

psmatch2 ReggioMaterna if((Reggio == 1 & ReggioMaterna == 1) | Reggio == 0), outcome(childHealthPerc) pscore(pr_ReggioMaterna) 
foreach j in $outcomes {
reg `j' ReggioMaterna Padova [fweight = _weight], robust
gen beta_`j'14 = _b[ReggioMaterna]
gen se_`j'14 = _se[ReggioMaterna]
gen t_`j'14 = abs(_b[ReggioMaterna]/_se[ReggioMaterna])
gen obs_`j'14 = r(N)
}

drop _pscore _treated _support _weight _childHealthPerc _id _n1 _nn _pdif

psmatch2 ReggioMaterna, outcome(childHealthPerc) pscore(pr_ReggioMaterna) 
foreach j in $outcomes {
reg `j' ReggioMaterna Parma Padova [fweight = _weight], robust
gen beta_`j'17 = _b[ReggioMaterna]
gen se_`j'17 = _se[ReggioMaterna]
gen t_`j'17 = abs(_b[ReggioMaterna]/_se[ReggioMaterna])
gen obs_`j'17 = r(N)
}

drop _pscore _treated _support _weight _childHealthPerc _id _n1 _nn _pdif

preserve
keep beta_* se_* t_* obs_*
keep in 1
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\resultsPSMmaterna.dta", replace
restore
drop beta_* se_* t_* obs_*

save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\dataDS.dta", replace

*** REGRESSIONS 3, 6, 9

gen demand = (ReggioAsilo == 1)
gen supply = (ReggioAsilo == 1)
biprobit (supply = score50 Male Age momMaxEdu_Uni_F momMaxEdu_Uni_Miss HighInc_F HighInc_Miss houseOwn_F houseOwn_Miss) (demand = cgAsilo_F distAsiloMunicipal1 distanza2 distanza3 momBornProvince_F dadBornProvince_F momBornProvince_Miss dadBornProvince_Miss distA_MomBorn Male Age momMaxEdu_Uni_F momMaxEdu_Uni_Miss HighInc_F HighInc_Miss houseOwn_F houseOwn_Miss) if(Reggio == 1), partial difficult

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

*** sample 3 (solo Reggio)

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
gen obs_`j'3 = r(N)
}
keep beta_* se_* t_* obs_*
keep in 1
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\resultsDSnido3.dta", replace
restore

*** sample 6 (Reggio vs Parma + Padova)

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
gen obs_`j'6 = r(N)
}
keep beta_* se_* t_* obs_*
keep in 1
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\resultsDSnido6.dta", replace
restore

*** sample 9 (Reggio vs tutto)

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
gen obs_`j'9 = r(N)
}
keep beta_* se_* t_* obs_*
keep in 1
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\resultsDSnido9.dta", replace
restore

*** REGRESSIONS 12, 15, 18

use "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\dataDS.dta", clear

gen demand = (ReggioMaterna == 1)
gen supply = (ReggioMaterna == 1)
biprobit (supply = score50 Male Age momMaxEdu_Uni_F momMaxEdu_Uni_Miss houseOwn_F houseOwn_Miss) (demand = cgAsilo_F distMaternaMunicipal1 momBornProvince_F dadBornProvince_F momBornProvince_Miss dadBornProvince_Miss Male Age momMaxEdu_Uni_F momMaxEdu_Uni_Miss houseOwn_F houseOwn_Miss) if(Reggio == 1), partial difficult

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

*** sample 12 (solo Reggio)

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
gen obs_`j'12 = r(N)
}
keep beta_* se_* t_* obs_*
keep in 1
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\resultsDSmaterna12.dta", replace
restore

*** sample 15 (Reggio vs Parma + Padova)

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
gen obs_`j'15 = r(N)
}
keep beta_* se_* t_* obs_*
keep in 1
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\resultsDSmaterna15.dta", replace
restore

*** sample 18 (Reggio vs tutto)

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
gen obs_`j'18 = r(N)
}
keep beta_* se_* t_* obs_*
keep in 1
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\resultsDSmaterna18.dta", replace
restore




