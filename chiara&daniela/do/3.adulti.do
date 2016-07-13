clear all
set more off
capture log close

********************************************************************************
*** ADULTI 

use "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\data\Reggio.dta", clear

*** solo 1994 

keep if Cohort >= 4
count

*** definizioni SCUOLE

*** nido generale + nido RC (avevamo deciso di escludere chi ha fatto il nido non RC a Reggio, vero?)

tab asilo
tab asilo, nol m
gen nido = (asilo == 1)
drop if(asilo > 3)

tab asiloMuni_self if(nido == 1)
tab asiloMuni_self if(nido == 1), nol m
drop if(asiloMuni_self == . & nido == 1 & Reggio == 1)

gen nido_rc = (nido == 1 & asiloMuni_self == 1 & Reggio == 1)
drop if(nido_rc == 0 & nido == 1 & Reggio == 1)

*** materna RC

tab materna
tab materna, m nol
drop if(materna > 1)

tab maternaMuni_self if(materna == 1)
tab maternaMuni_self if(materna == 1), nol m
drop if(maternaMuni_self == . & materna == 1 & Reggio == 1)

gen materna_rc = (materna == 1 & maternaMuni_self & Reggio == 1)

*** ciclo RC

gen ciclo_rc = (nido_rc == 1 & materna_rc == 1)
gen uno_rc = (nido_rc == 1 | materna_rc == 1)

*** desc 

sum nido nido_rc materna materna_rc ciclo_rc uno_rc
sum nido nido_rc materna materna_rc ciclo_rc uno_rc if(Reggio == 1 & Cohort == 4)
sum nido nido_rc materna materna_rc ciclo_rc uno_rc if(Reggio == 1 & Cohort == 5)
sum nido nido_rc materna materna_rc ciclo_rc uno_rc if(Reggio == 1 & Cohort == 6)

*** qualche variabile di controllo (pensare a cosa controllare. education & couple sono outcomes...)

tab Male
tab Male, nol m

tab house
tab house, nol m
gen owner = (house <= 2)
gen owner_m = (house > 4)

tab1 momMaxEdu dadMaxEdu
tab1 momMaxEdu dadMaxEdu, m nol
gen tertiary = ((momMaxEdu >= 4 & momMaxEdu <= 9) | (dadMaxEdu >= 4 & dadMaxEdu <= 9))
gen tertiary_m =((momMaxEdu >9 ) & (dadMaxEdu > 9))

tab CAPI
tab CAPI, m nol

gen cohort4 = (Cohort == 4)
gen cohort5 = (Cohort == 5)

global controls = "Male tertiary tertiary_m  owner owner_m CAPI"

*** desc

sum $controls
sum $controls if(Cohort == 4)
sum $controls if(Cohort == 5)
sum $controls if(Cohort == 6)

*** outcomes 

sum Depression_score HealthPerc MigrTaste_cat
sum Depression_score HealthPerc MigrTaste_cat if(Cohort == 4)
sum Depression_score HealthPerc MigrTaste_cat if(Cohort == 5)
sum Depression_score HealthPerc MigrTaste_cat if(Cohort == 6)

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

reg Depression_score ciclo_rc $controls Parma Padova cohort4 if(Cohort <= 5) 
gen beta1 = _b[ciclo_r]
gen se1 = _se[ciclo_r]
gen obs1 = e(N)
reg HealthPerc ciclo_rc $controls Parma Padova cohort4 if(Cohort <= 5), robust 
gen beta2 = _b[ciclo_r]
gen se2 = _se[ciclo_r]
gen obs2 = e(N)
reg MigrTaste_cat ciclo_rc $controls Parma Padova cohort4 if(Cohort <= 5), robust 
gen beta3 = _b[ciclo_r]
gen se3 = _se[ciclo_r]
gen obs3 = e(N)

*** 2) almeno una scuola RC [descrittiva]

reg Depression_score uno_rc $controls Parma Padova cohort4 cohort5
gen beta4 = _b[uno_rc]
gen se4 = _se[uno_rc]
gen obs4 = e(N)
reg HealthPerc uno_rc $controls Parma Padova cohort4 cohort5, robust
gen beta5 = _b[uno_rc]
gen se5 = _se[uno_rc]
gen obs5 = e(N)
reg MigrTaste_cat uno_rc $controls Parma Padova cohort4 cohort5, robust
gen beta6 = _b[uno_rc]
gen se6 = _se[uno_rc]
gen obs6 = e(N)

*** 3) nido, nido RC, materna RC [descrittiva]

reg Depression_score nido_rc materna_rc nido $controls Parma Padova cohort4 if(Cohort <= 5) 
gen beta7 = _b[nido_rc]
gen se7 = _se[nido_rc]
gen obs7 = e(N)
gen beta8 = _b[materna_rc]
gen se8 = _se[materna_rc]
gen obs8 = e(N)
reg HealthPerc nido_rc materna_rc nido $controls Parma Padova cohort4 if(Cohort <= 5), robust
gen beta9 = _b[nido_rc]
gen se9 = _se[nido_rc]
gen obs9 = e(N)
gen beta10 = _b[materna_rc]
gen se10 = _se[materna_rc]
gen obs10 = e(N)
reg MigrTaste_cat nido_rc materna_rc nido $controls Parma Padova cohort4 if(Cohort <= 5) , robust
gen beta11 = _b[nido_rc]
gen se11 = _se[nido_rc]
gen obs11 = e(N)
gen beta12 = _b[materna_rc]
gen se12 = _se[materna_rc]
gen obs12 = e(N)

*** 4) solo materna [endogena] 

reg Depression_score materna_rc $controls cohort4 cohort5 if(Reggio == 1)
gen beta13 = _b[materna_rc]
gen se13 = _se[materna_rc]
gen obs13 = e(N)
reg HealthPerc materna_rc $controls cohort4 cohort5 if(Reggio == 1), robust
gen beta14 = _b[materna_rc]
gen se14 = _se[materna_rc]
gen obs14 = e(N)
reg MigrTaste_cat materna_rc $controls cohort4 cohort5 if(Reggio == 1), robust
gen beta15 = _b[materna_rc]
gen se15 = _se[materna_rc]
gen obs15 = e(N)

*** 5) solo materna [IV] 

ivreg2 Depression_score $controls cohort4 cohort5 (materna_rc = distMaternaMunicipal1) if(Reggio == 1)
gen beta16 = _b[materna_rc]
gen se16 = _se[materna_rc]
gen obs16 = e(N)
ivreg2 HealthPerc $controls cohort4 cohort5 (materna_rc = distMaternaMunicipal1) if(Reggio == 1), robust
gen beta17 = _b[materna_rc]
gen se17 = _se[materna_rc]
gen obs17 = e(N)
ivreg2 MigrTaste_cat $controls cohort4 cohort5 (materna_rc = distMaternaMunicipal1) if(Reggio == 1), robust
gen beta18 = _b[materna_rc]
gen se18 = _se[materna_rc]
gen obs18 = e(N)

*** 6) solo nido [endogeno]

reg Depression_score nido_rc nido $controls Parma Padova cohort4 if(Cohort <= 5)
gen beta19 = _b[nido_rc]
gen se19 = _se[nido_rc]
gen obs19 = e(N)
reg HealthPerc nido_rc nido $controls Parma Padova cohort4 if(Cohort <= 5), robust
gen beta20 = _b[nido_rc]
gen se20 = _se[nido_rc]
gen obs20 = e(N)
reg MigrTaste_cat nido_rc nido $controls Parma Padova cohort4 if(Cohort <= 5), robust
gen beta21 = _b[nido_rc]
gen se21 = _se[nido_rc]
gen obs21 = e(N)

preserve
keep in 1
keep beta* se* obs*
drop sexist
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\coeff.dta", replace
restore

*** 7) solo nido [PSM]

*** COSTRUZIONE DEL DATASET PER IL PSM

keep if(Cohort <= 5)

*** stima domanda & offerta (Pietro, hai calcolato tu il punteggio? con il do che ti avevo mandato?)

gen domanda = (nido_rc == 1)
gen offerta = (nido_rc == 1)
biprobit (offerta = score_reg) (domanda = distAsiloMunicipal1 grandp_close) if(Reggio == 1), partial difficult

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
keep intnr  Depression_score HealthPerc MigrTaste_cat nido pr_domanda pr_offerta materna_rc $controls Parma Padova   
foreach j in intnr  Depression_score HealthPerc MigrTaste_cat nido pr_domanda pr_offerta   materna_rc $controls Parma Padova  {
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
keep intnr  Depression_score HealthPerc MigrTaste_cat nido pr_domanda pr_offerta materna_rc $controls Parma Padova 
foreach j in intnr  Depression_score HealthPerc MigrTaste_cat nido pr_domanda pr_offerta   materna_rc $controls Parma Padova  {
ren `j' `j'0
}
count
expand 86
sort intnr
by intnr: gen id = _n
sort id
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\control.dta", replace
count
restore

*** merge trattamento + controlli [controllare e aggiungere cohort!]

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

reshape long  Depression_score HealthPerc MigrTaste_cat $controls intnr nido Parma Padova, i(id) j(nido_rc)

count
tab nido_rc
gsort intnr -nido_rc
drop if(nido_rc == 1 & nido_rc[_n-1] == 1 & intnr == intnr[_n-1])
tab nido_rc

reg Depression_score nido_rc nido $controls Parma Padova 
gen beta22 = _b[nido_rc]
gen se22 = _se[nido_rc]
gen obs22 = e(N)
reg HealthPerc nido_rc nido $controls Parma Padova, robust
gen beta23 = _b[nido_rc]
gen se23 = _se[nido_rc]
gen obs23 = e(N)
reg MigrTaste_cat nido_rc nido $controls Parma Padova, robust
gen beta24 = _b[nido_rc]
gen se24 = _se[nido_rc]
gen obs24 = e(N)

*** coeff

keep in 1
keep beta* se* obs*
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\coeff.dta"
drop _m
gen id = 1
reshape long beta se obs, i(id) j(n)
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\coefficients.dta", replace


forvalues i = 1/24  {
use "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\coefficients.dta", clear
keep if (n== `i')
xpose, clear
keep in 3/5
ren v1 v`i'
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result`i'.dta", replace
}

*** nido DEPR

use "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result1.dta", clear
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result4.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result7.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result19.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result22.dta"
drop _m
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\nidoDEPRcoho456.dta", replace

*** nido HEALTH

use "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result2.dta", clear
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result5.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result9.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result20.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result23.dta"
drop _m
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\nidoHEALTHcoho456.dta", replace

*** nido MIGR

use "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result3.dta", clear
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result6.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result11.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result21.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result24.dta"
drop _m
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\nidoMIGRcoho456.dta", replace

*** materna DERPE

use "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result8.dta", clear
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result13.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result16.dta"
drop _m
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\maternaDEPRcoho456.dta", replace

*** materna HEALTH

use "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result10.dta", clear
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result14.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result17.dta"
drop _m
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\maternaHEALTHcoho456.dta", replace

*** materna MIGR

use "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result12.dta", clear
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result15.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result18.dta"
drop _m
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\maternaMIGRcoho456.dta", replace

