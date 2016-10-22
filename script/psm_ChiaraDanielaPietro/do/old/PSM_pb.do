clear all
set more off
capture log close

*** ONLY COHORT 2006 - NATIVES
*** ALL OUTCOMES 
*** 11 regressions
* 1) OLS (DUMMY NIDO, DUMMY NIDO REGGIO, MATERNA REGGIO)
*** FOCUS ON "NIDO"
* 2) OLS (DUMMY NIDO, DUMMY NIDO REGGIO)
* 3) PSM 
* 4) PSM (CLOSEST SUPPLY, AND THEN CLOSER DEMAND)
* 5) PSM (CLOSEST DEMAND, AND THEN CLOSER SUPPLY)
* 6) PSM (CLOSEST SUPPLY & DEMAND)
*** FOCUS ON "MATERNA"
* 7) OLS (DUMMY MATERNA)
* 8) PSM 
* 9) PSM (CLOSEST SUPPLY, AND THEN CLOSER DEMAND)
* 10) PSM (CLOSEST DEMAND, AND THEN CLOSER SUPPLY)
* 11) PSM (CLOSEST SUPPLY & DEMAND)

* ssc install psmatch2

global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio

cd ${git_reggio}/chiara&daniela


********************************************************************************
*** COHORT 2006 (NATIVES)
use ${data_reggio}/Reggio.dta, clear

*** only 2006 

keep if Cohort == 1
count

*** DATA FOR REGRESSION 1

*** dummies 

tab asilo
tab asilo, nol m
gen nido = (asilo == 1)

tab asiloMuni_self if(nido == 1)
tab asiloMuni_self if(nido == 1), nol m

gen nido_rc = (nido == 1 & asiloMuni_self == 1 & Reggio == 1) // Better to use ReggioAsilo as the dummy for the treatment group, to be consistent
drop if(nido_rc == 0 & nido == 1 & Reggio == 1) //drop 54 children who went to asilo not-RCH in Reggio Emilia

*** materna RC

tab materna
tab materna, m nol

tab maternaMuni_self if(materna == 1)
tab maternaMuni_self if(materna == 1), nol m

gen materna_rc = (materna == 1 & maternaMuni_self & Reggio == 1)  // Better to use ReggioMaterna as the dummy for the treatment group, to be consistent

*** desc 

sum nido ReggioAsilo materna ReggioMaterna
sum nido ReggioAsilo materna ReggioMaterna if(Reggio == 1)

*** controls
/*** OLD
tab childrenSibIn
tab childrenSibIn, nol m

tab Male
tab Male, nol m

tab lone_parent
tab lone_parent, m nol

tab house
tab house, nol m
gen owner = (house <= 2)
gen owner_m = (house > 4)

gen immigrant = (Cohort == 2)

tab1 momMaxEdu dadMaxEdu
tab1 momMaxEdu dadMaxEdu, m nol
gen tertiary = ((momMaxEdu >= 4 & momMaxEdu <= 9) | (dadMaxEdu >= 4 & dadMaxEdu <= 9))
gen tertiary_m =((momMaxEdu >9 ) & (dadMaxEdu > 9))

tab CAPI
tab CAPI, m nol

global controls = "Male tertiary tertiary_m lone_parent childrenSibIn owner owner_m CAPI"
*/

/* Description of New Controls

Main Controls
CAPI Male Age Age_sq 
momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni ///missing cat: low edu
dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni ///missing cat: low edu
momBornProvince dadBornProvince 
cgRelig houseOwn
cgReddito_2 cgReddito_3 cgReddito_4 cgReddito_5 cgReddito_6 cgReddito_7 /// missing cat: income below 5,000

Right Controls
All controls in addition to the interviewer indicators

Left controls 
Baseline characteristics that might affect childcare enrollment 
(lowbirthweight birthpremature)
*/

// prepare controls (can also include Analysis/prepare-data.do
** Dummy variables for categories in cgIncomeCat_manual
tab cgIncomeCat_manual, miss gen(cgReddito_)
gen cgReddito_miss = (cgIncomeCat_manual >= .) 
drop cgReddito_miss
label var cgReddito_1           "Income below 5k eur"
label var cgReddito_2           "Income 5k-10k eur"
label var cgReddito_3           "Income 10k-25k eur"
label var cgReddito_4           "Income 25k-50k eur"
label var cgReddito_5           "Income 50k-100k eur"
label var cgReddito_6           "Income 100k-250k eur"
label var cgReddito_7           "Income more 250k eur"

** Replace missing with zeros and put missing variable
foreach parent in mom dad {
         foreach categ in MaxEdu mStatus PA {
                  foreach var of varlist `parent'`categ'_* {
                           replace `var' = 0 if `parent'`categ'_miss == 1
                  } 
         }
}

foreach var in momBornProvince dadBornProvince cgRelig houseOwn lowbirthweight {
         gen `var'_miss = (`var' >= .)
         replace `var' = 0 if `var'_miss == 1
}

// look at contorls 
//tab childrenSibIn
//tab childrenSibIn, nol m

tab Male
tab Male, nol m

//tab lone_parent
//tab lone_parent, m nol

//tab house
//tab house, nol m
gen owner = (house <= 2)
gen owner_m = (house > 4)

//gen immigrant = (Cohort == 2)

tab1 momMaxEdu dadMaxEdu
tab1 momMaxEdu dadMaxEdu, m nol
gen tertiary = ((momMaxEdu >= 4 & momMaxEdu <= 9) | (dadMaxEdu >= 4 & dadMaxEdu <= 9))
gen tertiary_m =((momMaxEdu >9 ) & (dadMaxEdu > 9))

tab CAPI
tab CAPI, m nol

global controls = "CAPI Male Age Age_sq momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni momBornProvince dadBornProvince cgRelig houseOwn cgReddito_2 cgReddito_3 cgReddito_4 cgReddito_5 cgReddito_6 cgReddito_7"		
global right 	= "${controls} internr_*"
global left		= "lowbirthweight birthpremature"
//global controls = "Male tertiary tertiary_m lone_parent childrenSibIn owner owner_m CAPI"

*** desc

sum $controls

*** outcomes 

sum childSDQ_score childHealthPerc

*** REGRESSION 1

reg childSDQ_score nido ReggioAsilo ReggioMaterna Parma Padova $controls, robust 
reg childHealthPerc nido ReggioAsilo ReggioMaterna Parma Padova $controls, robust 

*** REGRESSION 2

reg childSDQ_score nido ReggioAsilo Parma Padova $controls, robust 
reg childHealthPerc nido ReggioAsilo Parma Padova $controls, robust 

*** DATA FOR REGRESSION 3

*** distance from nido 

sum distAsiloMunicipal1
gen dist175m = (distAsiloMunicipal1<= .175)

*** distance from grandparents

tab grandDist
tab grandDist, nol m
gen grandp_close = grandDist <= 4

*** Reggio score

sum score
sum score if(Reggio == 1)
gen score2 = score^2

*** propensity score

probit nido score score2 dist175m grandp_close $controls if(Reggio == 1)
predict pr_ReggioAsilo

*** REGRESSION 3

psmatch2 ReggioAsilo, outcome(childSDQ_score childHealthPerc) pscore(pr_ReggioAsilo)  
//reg childSDQ_score ReggioAsilo [fweight = _weight], robust
reg childSDQ_score ReggioAsilo nido Parma Padova [fweight = _weight], robust
reg childHealthPerc ReggioAsilo nido Parma Padova [fweight = _weight], robust

*** data for REGRESSION 4

*** demand & supply estimation 

gen demand = (ReggioAsilo == 1)
gen supply = (ReggioAsilo == 1)
biprobit (supply = score score2) (demand = dist175m grandp_close lone_parent childrenSibIn) if(Reggio == 1), partial difficult

*** predicted probabilities

predict p11, p11
predict p10, p10
gen pr_supply = p11+p10
predict p01, p01
gen pr_demand = p11+p01
sum pr_supply pr_demand

*** treated group

preserve
keep if (ReggioAsilo == 1)
keep intnr childSDQ_score childHealthPerc nido pr_demand pr_supply Parma Padova Male tertiary tertiary_m owner owner_m CAPI
foreach j in intnr childSDQ_score childHealthPerc nido pr_demand pr_supply Parma Padova Male tertiary tertiary_m owner owner_m CAPI {
ren `j' `j'1
}
gen id = _n
sort id
save "treatment.dta", replace
count
restore

*** possible controls

preserve
keep if (ReggioAsilo == 0) 
keep intnr childSDQ_score childHealthPerc nido pr_demand pr_supply Parma Padova Male tertiary tertiary_m owner owner_m CAPI
foreach j in intnr childSDQ_score childHealthPerc nido pr_demand pr_supply Parma Padova Male tertiary tertiary_m owner owner_m CAPI {
ren `j' `j'0
}
count
expand 140
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

*** treated with the most similar control

gsort id diff_supply diff_demand 
by id: gen n = _n
keep if(n <= 1)
drop n id  pr_demand* pr_supply*
gen id = _n
gen weight1 = 1
gen weight0 = 1

reshape long  childSDQ_score childHealthPerc weight intnr nido Parma Padova Male tertiary tertiary_m owner owner_m CAPI, i(id) j(ReggioAsilo)

count
tab ReggioAsilo
tab weight

/* in case you have more controls for each treated
gsort intnr -ReggioAsilo
drop if(ReggioAsilo == 1 & ReggioAsilo[_n-1] == 1 & intnr == intnr[_n-1])
tab ReggioAsilo
*/

*** REGRESSION 4

reg childSDQ_score nido ReggioAsilo Parma Padova Male tertiary tertiary_m owner owner_m CAPI [fweight = weight], robust
reg childHealthPerc nido ReggioAsilo Parma Padova Male tertiary tertiary_m owner owner_m CAPI [fweight = weight], robust

*** data for REGRESSION 5

*** match treated and controls

use "treatment.dta", clear
merge id using "control.dta"
tab _m
drop _m

gen diff_supply = abs(pr_supply1 - pr_supply0)
gen diff_demand = abs(pr_demand1 - pr_demand0)

*** treated with the most similar control

gsort id diff_demand diff_supply  
by id: gen n = _n
keep if(n <= 1)
drop n id  pr_demand* pr_supply*
gen id = _n
gen weight1 = 1
gen weight0 = 1

reshape long  childSDQ_score childHealthPerc weight intnr nido Parma Padova Male tertiary tertiary_m owner owner_m CAPI, i(id) j(ReggioAsilo)

count
tab ReggioAsilo
tab weight


/* in case you have more controls for each treated
gsort intnr -ReggioAsilo
drop if(ReggioAsilo == 1 & ReggioAsilo[_n-1] == 1 & intnr == intnr[_n-1])
tab ReggioAsilo
*/

*** REGRESSION 5

reg childSDQ_score nido ReggioAsilo Parma Padova Male tertiary tertiary_m owner owner_m CAPI [fweight = weight], robust
reg childHealthPerc nido ReggioAsilo Parma Padova Male tertiary tertiary_m owner owner_m CAPI [fweight = weight], robust

*** data for REGRESSION 6

*** match treated and controls

use "treatment.dta", clear
merge id using "control.dta"
tab _m
drop _m

gen diff_supply = abs(pr_supply1 - pr_supply0)
gen diff_demand = abs(pr_demand1 - pr_demand0)

*** treated with the most similar control

gen diff = diff_supply + diff_demand
gsort id diff  
by id: gen n = _n
keep if(n <= 1)
drop n id  pr_demand* pr_supply*
gen id = _n
gen weight1 = 1
gen weight0 = 1

reshape long  childSDQ_score childHealthPerc weight intnr nido Parma Padova Male tertiary tertiary_m owner owner_m CAPI, i(id) j(ReggioAsilo)

count
tab ReggioAsilo
tab weight


/* in case you have more controls for each treated
gsort intnr -ReggioAsilo
drop if(ReggioAsilo == 1 & ReggioAsilo[_n-1] == 1 & intnr == intnr[_n-1])
tab ReggioAsilo
*/

*** REGRESSION 6

reg childSDQ_score nido ReggioAsilo Parma Padova Male tertiary tertiary_m owner owner_m CAPI [fweight = weight], robust
reg childHealthPerc nido ReggioAsilo Parma Padova Male tertiary tertiary_m owner owner_m CAPI [fweight = weight], robust

*** REGRESSION 7

restore

reg childSDQ_score ReggioMaterna Parma Padova $controls, robust
reg childHealthPerc ReggioMaterna Parma Padova $controls, robust

*** DATA FOR REGRESSION 8

*** distance from nido 

sum distMaternaMunicipal1

*** Reggio score

sum score
*gen score2 = score^2
gen low_score = (score <= 19)
gen med_score = (score > 19 & score <= 24.5)

*** propensity score

probit ReggioMaterna low_score med_score distMaternaMunicipal1 grandp_close $controls if(Reggio == 1)
predict pr_ReggioMaterna

*** REGRESSION 8

psmatch2 ReggioMaterna, outcome(childSDQ_score childHealthPerc) pscore(pr_ReggioMaterna)  
reg childSDQ_score ReggioMaterna  Parma Padova [fweight = _weight], robust
reg childHealthPerc ReggioMaterna  Parma Padova [fweight = _weight], robust

*** data for REGRESSION 9

*** demand & supply estimation 

drop demand supply
gen demand = (ReggioMaterna == 1)
gen supply = (ReggioMaterna == 1)
biprobit (supply = low_score med_score) (demand = distMaternaMunicipal1) if(Reggio == 1), partial difficult

*** predicted probabilities

drop p11 p10 p01 pr_supply pr_demand
predict p11, p11
predict p10, p10
gen pr_supply = p11+p10
predict p01, p01
gen pr_demand = p11+p01
sum pr_supply pr_demand

*** treated group

preserve
keep if (ReggioMaterna == 1)
keep intnr childSDQ_score childHealthPerc  pr_demand pr_supply Parma Padova $controls
foreach j in intnr childSDQ_score childHealthPerc  pr_demand pr_supply Parma Padova $controls {
ren `j' `j'1
}
gen id = _n
sort id
save "treatment.dta", replace
count
restore

*** possible controls

preserve
keep if (ReggioMaterna == 0) 
keep intnr childSDQ_score childHealthPerc  pr_demand pr_supply Parma Padova $controls
foreach j in intnr childSDQ_score childHealthPerc  pr_demand pr_supply Parma Padova $controls {
ren `j' `j'0
}
count
expand 155
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

*** treated with the most similar control

gsort id diff_supply diff_demand 
by id: gen n = _n
keep if(n <= 1)
drop n id  pr_demand* pr_supply*
gen id = _n
gen weight1 = 1
gen weight0 = 1

reshape long  childSDQ_score childHealthPerc weight intnr  Parma Padova $controls, i(id) j(ReggioMaterna)

count
tab ReggioMaterna
tab weight

*** REGRESSION 9

reg childSDQ_score  ReggioMaterna Parma Padova $controls [fweight = weight], robust
reg childHealthPerc  ReggioMaterna Parma Padova $controls [fweight = weight], robust

*** data for REGRESSION 10

*** match treated and controls

use "treatment.dta", clear
merge id using "control.dta"
tab _m
drop _m

gen diff_supply = abs(pr_supply1 - pr_supply0)
gen diff_demand = abs(pr_demand1 - pr_demand0)

*** treated with the most similar control

gsort id  diff_demand diff_supply
by id: gen n = _n
keep if(n <= 1)
drop n id  pr_demand* pr_supply*
gen id = _n
gen weight1 = 1
gen weight0 = 1

reshape long  childSDQ_score childHealthPerc weight intnr  Parma Padova $controls, i(id) j(ReggioMaterna)

count
tab ReggioMaterna
tab weight

*** REGRESSION 10

reg childSDQ_score  ReggioMaterna Parma Padova $controls [fweight = weight], robust
reg childHealthPerc  ReggioMaterna Parma Padova $controls [fweight = weight], robust

*** data for REGRESSION 11

*** match treated and controls

use "treatment.dta", clear
merge id using "control.dta"
tab _m
drop _m

gen diff_supply = abs(pr_supply1 - pr_supply0)
gen diff_demand = abs(pr_demand1 - pr_demand0)

*** treated with the most similar control

gen diff = diff_supply + diff_demand
gsort id diff  
by id: gen n = _n
keep if(n <= 1)
drop n id  pr_demand* pr_supply*
gen id = _n
gen weight1 = 1
gen weight0 = 1

reshape long  childSDQ_score childHealthPerc weight intnr  Parma Padova $controls, i(id) j(ReggioMaterna)

count
tab ReggioMaterna
tab weight

*** REGRESSION 11

reg childSDQ_score  ReggioMaterna Parma Padova $controls [fweight = weight], robust
reg childHealthPerc  ReggioMaterna Parma Padova $controls [fweight = weight], robust
