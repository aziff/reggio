clear all
set more off
capture log close

********************************************************************************
*** COORTE 2006 

use "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\data\Reggio.dta", clear

*** solo 2006 (immigrati dentro? pesati?)

keep if Cohort == 1
count

*** definizioni SCUOLE

*** nido generale + nido RC (avevamo deciso di escludere chi ha fatto il nido non RC a Reggio, vero?)

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

*** ciclo RC

gen ciclo_rc = (nido_rc == 1 & materna_rc == 1)
gen uno_rc = (nido_rc == 1 | materna_rc == 1)

*** desc 

sum nido nido_rc materna materna_rc ciclo_rc uno_rc
sum nido nido_rc materna materna_rc ciclo_rc uno_rc if(Reggio == 1)

*** qualche variabile di controllo

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

global controls = "Male immigrant tertiary tertiary_m lone_parent childrenSibIn owner owner_m CAPI"

*** desc

sum $controls

*** outcomes 

sum childSDQ_score childHealthPerc

*** var IV distanza dalla materna municipale  

sum distMaternaMunicipal1

*** var PSM distanza dal nido municipale 

sum distAsiloMunicipal1

*** var PSM nonni

tab grandDist
tab grandDist, nol m
gen grandp_close = (grandDist <= 4)

*** var PSM punteggio

sum score
sum score if(Reggio == 1)
gen score_reg = score*Reggio

*** 1) tutto il ciclo RC [descrittiva]

reg childSDQ_score ciclo_rc $controls Parma Padova 
gen beta1 = _b[ciclo_r]
gen se1 = _se[ciclo_r]
gen obs1 = e(N)
reg childHealthPerc ciclo_rc $controls Parma Padova, robust 
gen beta2 = _b[ciclo_r]
gen se2 = _se[ciclo_r]
gen obs2 = e(N)

*** 2) almeno una scuola RC [descrittiva]

reg childSDQ_score uno_rc $controls Parma Padova
gen beta3 = _b[uno_r]
gen se3 = _se[uno_r]
gen obs3 = e(N) 
reg childHealthPerc uno_rc $controls Parma Padova, robust
gen beta4 = _b[uno_r]
gen se4 = _se[uno_r]
gen obs4 = e(N) 

*** 3) nido, nido RC, materna RC [descrittiva]

reg childSDQ_score nido_rc materna_rc nido $controls Parma Padova 
gen beta5 = _b[nido_r]
gen se5 = _se[nido_r]
gen obs5 = e(N) 
gen beta6 = _b[materna_r]
gen se6 = _se[materna_r]
gen obs6 = e(N) 
reg childHealthPerc nido_rc materna_rc nido $controls Parma Padova 
gen beta7 = _b[nido_r]
gen se7 = _se[nido_r]
gen obs7 = e(N)
gen beta8 = _b[materna_r]
gen se8 = _se[materna_r]
gen obs8 = e(N) 

*** 4) solo materna [endogena] 

reg childSDQ_score materna_rc $controls if(Reggio == 1)
gen beta9 = _b[materna_r]
gen se9 = _se[materna_r]
gen obs9 = e(N)
reg childHealthPerc materna_rc $controls if(Reggio == 1), robust
gen beta10 = _b[materna_r]
gen se10 = _se[materna_r]
gen obs10 = e(N)

*** 5) solo materna [IV] 

ivreg2 childSDQ_score $controls (materna_rc = distMaternaMunicipal1) if(Reggio == 1)
gen beta11 = _b[materna_r]
gen se11 = _se[materna_r]
gen obs11 = e(N)
ivreg2 childHealthPerc $controls (materna_rc = distMaternaMunicipal1) if(Reggio == 1), robust
gen beta12 = _b[materna_r]
gen se12 = _se[materna_r]
gen obs12 = e(N)

*** 6) solo nido [endogeno]

reg childSDQ_score nido_rc nido $controls Parma Padova 
gen beta13 = _b[nido_r]
gen se13 = _se[nido_r]
gen obs13 = e(N)
reg childHealthPerc nido_rc nido $controls Parma Padova, robust
gen beta14 = _b[nido_r]
gen se14 = _se[nido_r]
gen obs14 = e(N)

preserve
keep in 1
keep beta* se* obs*
drop sexist
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\coeff.dta", replace
restore

*** 7) solo nido [PSM]

*** COSTRUZIONE DEL DATASET PER IL PSM

*** stima domanda & offerta (Pietro, hai calcolato tu il punteggio? con il do che ti avevo mandato?)
*** (il punteggio mi era sempre venuto significativo, da lavorarci)

gen domanda = (nido_rc == 1)
gen offerta = (nido_rc == 1)
biprobit (offerta = score_reg) (domanda = distAsiloMunicipal1 lone_parent grandp_close immi) if(Reggio == 1), partial difficult

*** prediction pr(offerta) e pr(domanda)

drop score_reg
ren score score_reg
predict p11, p11
predict p10, p10
gen pr_offerta = p11+p10
predict p01, p01
gen pr_domanda = p11+p01
sum pr*

*** gruppo di trattamento

preserve
keep if (nido_rc == 1)
keep intnr childSDQ_score childHealthPerc nido pr_domanda pr_offerta materna_rc $controls Parma Padova score_reg  distAsiloMunicipal1 grandp_close  
foreach j in intnr childSDQ_score childHealthPerc nido pr_domanda pr_offerta   materna_rc $controls Parma Padova score_reg  distAsiloMunicipal1  grandp_close  {
ren `j' `j'1
}
gen id = _n
sort id
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\treatment.dta", replace
count
restore

*** possibili controlli

preserve
keep if (nido_rc == 0) 
keep intnr childSDQ_score childHealthPerc nido pr_domanda pr_offerta materna_rc $controls Parma Padova 
foreach j in intnr childSDQ_score childHealthPerc nido pr_domanda pr_offerta   materna_rc $controls Parma Padova  {
ren `j' `j'0
}
count
expand 140
sort intnr
by intnr: gen id = _n
sort id
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\control.dta", replace
count
restore

*** merge trattamento + controlli

use "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\treatment.dta", clear
merge id using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\control.dta"
tab _m
drop _m

*** differenza nella pr(offerta) e pr(domanda)

gen diff_offerta = abs(pr_offerta1 - pr_offerta0)
gen diff_domanda = abs(pr_domanda1 - pr_domanda0)

*** match con due controlli + simili

gsort id diff_offerta diff_domanda
by id: gen n = _n
*replace n = 2 if(diff_offerta == diff_offerta[_n-1] & diff_domanda == diff_domanda[_n-1] & n[_n-1] == 2)
keep if(n <= 2)
drop n id  pr_domanda* pr_offerta*
gen id = _n
gen weight1 = 1
gen weight0 = 1/2

reshape long  childSDQ_score childHealthPerc $controls intnr nido Parma Padova, i(id) j(nido_rc)

count
tab nido_rc
gsort intnr -nido_rc
drop if(nido_rc == 1 & nido_rc[_n-1] == 1 & intnr == intnr[_n-1])
tab nido_rc

*** reg

reg childSDQ_score nido_rc nido $controls Parma Padova
gen beta15 = _b[nido_r]
gen se15 = _se[nido_r]
gen obs15 = e(N) 
reg childHealthPerc nido_rc nido $controls Parma Padova , robust
gen beta16 = _b[nido_r]
gen se16 = _se[nido_r]
gen obs16 = e(N) 

*** coeff

keep in 1
keep beta* se* obs*
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\coeff.dta"
drop _m
gen id = 1
reshape long beta se obs, i(id) j(n)
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\coefficients.dta", replace


forvalues i = 1/16  {
use "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\coefficients.dta", clear
keep if (n== `i')
xpose, clear
keep in 3/5
ren v1 v`i'
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result`i'.dta", replace
}


*** nido SDQ

use "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result1.dta", clear
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result3.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result5.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result13.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result15.dta"
drop _m
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\nidoSDQcoho1.dta", replace

*** nido HEALTH

use "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result2.dta", clear
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result4.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result7.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result14.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result16.dta"
drop _m
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\nidoHEALTHcoho1.dta", replace

*** materna SDQ

use "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result6.dta", clear
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result9.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result11.dta"
drop _m
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\maternaSDQcoho1.dta", replace

*** materna HEALTH

use "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result8.dta", clear
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result10.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result12.dta"
drop _m
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\maternaHEALTHcoho1.dta", replace
