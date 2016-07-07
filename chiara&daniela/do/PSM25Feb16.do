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

********************************************************************************
*** COHORT 2006 (NATIVES)

use "C:\Users\Pronzato\Dropbox\ReggioChildren\SURVEY_DATA_COLLECTION\data\Reggio.dta", clear

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

gen nido_rc = (nido == 1 & asiloMuni_self == 1 & Reggio == 1)
drop if(nido_rc == 0 & nido == 1 & Reggio == 1)

*** materna RC

tab materna
tab materna, m nol

tab maternaMuni_self if(materna == 1)
tab maternaMuni_self if(materna == 1), nol m

gen materna_rc = (materna == 1 & maternaMuni_self & Reggio == 1)

*** desc 

sum nido nido_rc materna materna_rc
sum nido nido_rc materna materna_rc if(Reggio == 1)

*** controls (DA CAMBIARE)

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

*** desc

sum $controls

*** outcomes 

sum childSDQ_score childHealthPerc

*** REGRESSION 1

reg childSDQ_score nido nido_rc materna_rc Parma Padova $controls
reg childHealthPerc nido nido_rc materna_rc Parma Padova $controls

*** REGRESSION 2

reg childSDQ_score nido nido_rc Parma Padova $controls
reg childHealthPerc nido nido_rc Parma Padova $controls

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
predict pr_nido_rc

*** REGRESSION 3

psmatch2 nido_rc, outcome(childSDQ_score childHealthPerc) pscore(pr_nido_rc)  
reg childSDQ_score nido_rc [fweight = _weight]
reg childSDQ_score nido_rc nido Parma Padova [fweight = _weight]
reg childHealthPerc nido_rc nido Parma Padova [fweight = _weight]

*** data for REGRESSION 4

*** demand & supply estimation 

gen demand = (nido_rc == 1)
gen supply = (nido_rc == 1)
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
keep if (nido_rc == 1)
keep intnr childSDQ_score childHealthPerc nido pr_demand pr_supply Parma Padova Male tertiary tertiary_m owner owner_m CAPI
foreach j in intnr childSDQ_score childHealthPerc nido pr_demand pr_supply Parma Padova Male tertiary tertiary_m owner owner_m CAPI {
ren `j' `j'1
}
gen id = _n
sort id
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\treatment.dta", replace
count
restore

*** possible controls

preserve
keep if (nido_rc == 0) 
keep intnr childSDQ_score childHealthPerc nido pr_demand pr_supply Parma Padova Male tertiary tertiary_m owner owner_m CAPI
foreach j in intnr childSDQ_score childHealthPerc nido pr_demand pr_supply Parma Padova Male tertiary tertiary_m owner owner_m CAPI {
ren `j' `j'0
}
count
expand 140
sort intnr
by intnr: gen id = _n
sort id
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\control.dta", replace
count


*** match treated and controls

use "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\treatment.dta", clear
merge id using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\control.dta"
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

reshape long  childSDQ_score childHealthPerc weight intnr nido Parma Padova Male tertiary tertiary_m owner owner_m CAPI, i(id) j(nido_rc)

count
tab nido_rc
tab weight

/* in case you have more controls for each treated
gsort intnr -nido_rc
drop if(nido_rc == 1 & nido_rc[_n-1] == 1 & intnr == intnr[_n-1])
tab nido_rc
*/

*** REGRESSION 4

reg childSDQ_score nido nido_rc Parma Padova Male tertiary tertiary_m owner owner_m CAPI [fweight = weight]
reg childHealthPerc nido nido_rc Parma Padova Male tertiary tertiary_m owner owner_m CAPI [fweight = weight]

*** data for REGRESSION 5

*** match treated and controls

use "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\treatment.dta", clear
merge id using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\control.dta"
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

reshape long  childSDQ_score childHealthPerc weight intnr nido Parma Padova Male tertiary tertiary_m owner owner_m CAPI, i(id) j(nido_rc)

count
tab nido_rc
tab weight


/* in case you have more controls for each treated
gsort intnr -nido_rc
drop if(nido_rc == 1 & nido_rc[_n-1] == 1 & intnr == intnr[_n-1])
tab nido_rc
*/

*** REGRESSION 5

reg childSDQ_score nido nido_rc Parma Padova Male tertiary tertiary_m owner owner_m CAPI [fweight = weight]
reg childHealthPerc nido nido_rc Parma Padova Male tertiary tertiary_m owner owner_m CAPI [fweight = weight]

*** data for REGRESSION 6

*** match treated and controls

use "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\treatment.dta", clear
merge id using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\control.dta"
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

reshape long  childSDQ_score childHealthPerc weight intnr nido Parma Padova Male tertiary tertiary_m owner owner_m CAPI, i(id) j(nido_rc)

count
tab nido_rc
tab weight


/* in case you have more controls for each treated
gsort intnr -nido_rc
drop if(nido_rc == 1 & nido_rc[_n-1] == 1 & intnr == intnr[_n-1])
tab nido_rc
*/

*** REGRESSION 6

reg childSDQ_score nido nido_rc Parma Padova Male tertiary tertiary_m owner owner_m CAPI [fweight = weight]
reg childHealthPerc nido nido_rc Parma Padova Male tertiary tertiary_m owner owner_m CAPI [fweight = weight]

*** REGRESSION 7

restore

reg childSDQ_score materna_rc Parma Padova $controls
reg childHealthPerc materna_rc Parma Padova $controls

*** DATA FOR REGRESSION 8

*** distance from nido 

sum distMaternaMunicipal1

*** Reggio score

sum score
*gen score2 = score^2
gen low_score = (score <= 19)
gen med_score = (score > 19 & score <= 24.5)

*** propensity score

probit materna_rc low_score med_score distMaternaMunicipal1 grandp_close $controls if(Reggio == 1)
predict pr_materna_rc

*** REGRESSION 8

psmatch2 materna_rc, outcome(childSDQ_score childHealthPerc) pscore(pr_materna_rc)  
reg childSDQ_score materna_rc  Parma Padova [fweight = _weight]
reg childHealthPerc materna_rc  Parma Padova [fweight = _weight]

*** data for REGRESSION 9

*** demand & supply estimation 

drop demand supply
gen demand = (materna_rc == 1)
gen supply = (materna_rc == 1)
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
keep if (materna_rc == 1)
keep intnr childSDQ_score childHealthPerc  pr_demand pr_supply Parma Padova $controls
foreach j in intnr childSDQ_score childHealthPerc  pr_demand pr_supply Parma Padova $controls {
ren `j' `j'1
}
gen id = _n
sort id
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\treatment.dta", replace
count
restore

*** possible controls

preserve
keep if (materna_rc == 0) 
keep intnr childSDQ_score childHealthPerc  pr_demand pr_supply Parma Padova $controls
foreach j in intnr childSDQ_score childHealthPerc  pr_demand pr_supply Parma Padova $controls {
ren `j' `j'0
}
count
expand 155
sort intnr
by intnr: gen id = _n
sort id
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\control.dta", replace
count


*** match treated and controls

use "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\treatment.dta", clear
merge id using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\control.dta"
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

reshape long  childSDQ_score childHealthPerc weight intnr  Parma Padova $controls, i(id) j(materna_rc)

count
tab materna_rc
tab weight

*** REGRESSION 9

reg childSDQ_score  materna_rc Parma Padova $controls [fweight = weight]
reg childHealthPerc  materna_rc Parma Padova $controls [fweight = weight]

*** data for REGRESSION 10

*** match treated and controls

use "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\treatment.dta", clear
merge id using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\control.dta"
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

reshape long  childSDQ_score childHealthPerc weight intnr  Parma Padova $controls, i(id) j(materna_rc)

count
tab materna_rc
tab weight

*** REGRESSION 10

reg childSDQ_score  materna_rc Parma Padova $controls [fweight = weight]
reg childHealthPerc  materna_rc Parma Padova $controls [fweight = weight]

*** data for REGRESSION 11

*** match treated and controls

use "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\treatment.dta", clear
merge id using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\control.dta"
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

reshape long  childSDQ_score childHealthPerc weight intnr  Parma Padova $controls, i(id) j(materna_rc)

count
tab materna_rc
tab weight

*** REGRESSION 11

reg childSDQ_score  materna_rc Parma Padova $controls [fweight = weight]
reg childHealthPerc  materna_rc Parma Padova $controls [fweight = weight]



 













