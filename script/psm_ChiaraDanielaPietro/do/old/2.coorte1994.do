clear all
set more off
capture log close

********************************************************************************
*** COORTE 1994 

use "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\data\Reggio.dta", clear

*** solo 1994 

keep if Cohort == 3
count

*** definizioni SCUOLE

*** nido generale + nido RC (avevamo deciso di escludere chi ha fatto il nido non RC a Reggio, vero?)

tab asilo
tab asilo, nol m
gen nido = (asilo == 1)
drop if(asilo > 3)

tab asiloMuni_self if(nido == 1)
tab asiloMuni_self if(nido == 1), nol m

gen nido_rc = (nido == 1 & asiloMuni_self == 1 & Reggio == 1)
drop if(nido_rc == 0 & nido == 1 & Reggio == 1)

*** materna RC

tab materna
tab materna, m nol
drop if(materna > 1)

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

sum childSDQ_score Depression_score childHealthPerc MigrTaste_cat

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
reg Depression_score ciclo_rc $controls Parma Padova 
gen beta2 = _b[ciclo_r]
gen se2 = _se[ciclo_r]
gen obs2 = e(N)
reg childHealthPerc ciclo_rc $controls Parma Padova, robust 
gen beta3 = _b[ciclo_r]
gen se3 = _se[ciclo_r]
gen obs3 = e(N)
reg MigrTaste_cat ciclo_rc $controls Parma Padova, robust 
gen beta4 = _b[ciclo_r]
gen se4 = _se[ciclo_r]
gen obs4 = e(N)

*** 2) almeno una scuola RC [descrittiva]

reg childSDQ_score uno_rc $controls Parma Padova 
gen beta5 = _b[uno_r]
gen se5 = _se[uno_r]
gen obs5 = e(N)
reg Depression_score uno_rc $controls Parma Padova
gen beta6 = _b[uno_r]
gen se6 = _se[uno_r]
gen obs6 = e(N) 
reg childHealthPerc uno_rc $controls Parma Padova, robust
gen beta7 = _b[uno_r]
gen se7 = _se[uno_r]
gen obs7 = e(N)
reg MigrTaste_cat uno_rc $controls Parma Padova, robust
gen beta8 = _b[uno_r]
gen se8 = _se[uno_r]
gen obs8 = e(N)

*** 3) nido, nido RC, materna RC [descrittiva]

reg childSDQ_score nido_rc materna_rc nido $controls Parma Padova
gen beta9 = _b[nido_rc]
gen se9 = _se[nido_rc]
gen obs9 = e(N)
gen beta10 = _b[materna_rc]
gen se10 = _se[materna_rc]
gen obs10 = e(N)
reg Depression_score nido_rc materna_rc nido $controls Parma Padova 
gen beta11 = _b[nido_rc]
gen se11 = _se[nido_rc]
gen obs11 = e(N)
gen beta12 = _b[materna_rc]
gen se12 = _se[materna_rc]
gen obs12 = e(N)
reg childHealthPerc nido_rc materna_rc nido $controls Parma Padova, robust
gen beta13 = _b[nido_rc]
gen se13 = _se[nido_rc]
gen obs13 = e(N)
gen beta14 = _b[materna_rc]
gen se14 = _se[materna_rc]
gen obs14 = e(N)
reg MigrTaste_cat nido_rc materna_rc nido $controls Parma Padova, robust
gen beta15 = _b[nido_rc]
gen se15 = _se[nido_rc]
gen obs15 = e(N)
gen beta16 = _b[materna_rc]
gen se16 = _se[materna_rc]
gen obs16 = e(N)

*** 4) solo materna [endogena] 

reg childSDQ_score materna_rc $controls if(Reggio == 1)
gen beta17 = _b[materna_rc]
gen se17 = _se[materna_rc]
gen obs17 = e(N)
reg Depression_score materna_rc $controls if(Reggio == 1)
gen beta18 = _b[materna_rc]
gen se18 = _se[materna_rc]
gen obs18 = e(N)
reg childHealthPerc materna_rc $controls if(Reggio == 1), robust
gen beta19 = _b[materna_rc]
gen se19 = _se[materna_rc]
gen obs19 = e(N)
reg MigrTaste_cat materna_rc $controls if(Reggio == 1), robust
gen beta20 = _b[materna_rc]
gen se20 = _se[materna_rc]
gen obs20 = e(N)

*** 5) solo materna [IV] 

ivreg2 childSDQ_score $controls (materna_rc = distMaternaMunicipal1) if(Reggio == 1)
gen beta21 = _b[materna_rc]
gen se21 = _se[materna_rc]
gen obs21 = e(N)
ivreg2 Depression_score $controls (materna_rc = distMaternaMunicipal1) if(Reggio == 1)
gen beta22 = _b[materna_rc]
gen se22 = _se[materna_rc]
gen obs22 = e(N)
ivreg2 childHealthPerc $controls (materna_rc = distMaternaMunicipal1) if(Reggio == 1), robust
gen beta23 = _b[materna_rc]
gen se23 = _se[materna_rc]
gen obs23 = e(N)
ivreg2 MigrTaste_cat $controls (materna_rc = distMaternaMunicipal1) if(Reggio == 1), robust
gen beta24 = _b[materna_rc]
gen se24 = _se[materna_rc]
gen obs24 = e(N)

*** 6) solo nido [endogeno]

reg childSDQ_score nido_rc nido $controls Parma Padova 
gen beta25 = _b[nido_rc]
gen se25 = _se[nido_rc]
gen obs25 = e(N)
reg Depression_score nido_rc nido $controls Parma Padova 
gen beta26 = _b[nido_rc]
gen se26 = _se[nido_rc]
gen obs26 = e(N)
reg childHealthPerc nido_rc nido $controls Parma Padova, robust
gen beta27 = _b[nido_rc]
gen se27 = _se[nido_rc]
gen obs27 = e(N)
reg MigrTaste_cat nido_rc nido $controls Parma Padova, robust
gen beta28 = _b[nido_rc]
gen se28 = _se[nido_rc]
gen obs28 = e(N)

preserve
keep in 1
keep beta* se* obs*
drop sexist
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\coeff.dta", replace
restore

*** 7) solo nido [PSM]

*** COSTRUZIONE DEL DATASET PER IL PSM

*** stima domanda & offerta (Pietro, hai calcolato tu il punteggio? con il do che ti avevo mandato?)

gen domanda = (nido_rc == 1)
gen offerta = (nido_rc == 1)
biprobit (offerta = score_reg) (domanda = distAsiloMunicipal1 lone_parent grandp_close) if(Reggio == 1), partial difficult

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
keep intnr childSDQ_score Depression_score childHealthPerc MigrTaste_cat nido pr_domanda pr_offerta materna_rc $controls Parma Padova  
foreach j in intnr childSDQ_score Depression_score childHealthPerc MigrTaste_cat nido pr_domanda pr_offerta   materna_rc $controls Parma Padova  {
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
keep intnr childSDQ_score Depression_score childHealthPerc MigrTaste_cat nido pr_domanda pr_offerta materna_rc $controls Parma Padova
foreach j in intnr childSDQ_score Depression_score childHealthPerc MigrTaste_cat nido pr_domanda pr_offerta   materna_rc $controls Parma Padova  {
ren `j' `j'0
}
count
expand 129
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
replace n = 2 if(diff_offerta == diff_offerta[_n-1] & diff_domanda == diff_domanda[_n-1] & n[_n-1] == 2)
keep if(n <= 2)
drop n id  pr_domanda* pr_offerta*
gen id = _n
gen weight1 = 1
gen weight0 = 1/2

reshape long  childSDQ_score Depression_score childHealthPerc MigrTaste_cat $controls intnr nido Parma Padova, i(id) j(nido_rc)

count
tab nido_rc
gsort intnr -nido_rc
drop if(nido_rc == 1 & nido_rc[_n-1] == 1 & intnr == intnr[_n-1])
tab nido_rc

reg childSDQ_score nido_rc nido $controls Parma Padova 
gen beta29 = _b[nido_rc]
gen se29 = _se[nido_rc]
gen obs29 = e(N)
reg Depression_score nido_rc nido $controls Parma Padova
gen beta30 = _b[nido_rc]
gen se30 = _se[nido_rc]
gen obs30 = e(N) 
reg childHealthPerc nido_rc nido $controls Parma Padova, robust
gen beta31 = _b[nido_rc]
gen se31 = _se[nido_rc]
gen obs31 = e(N)
reg MigrTaste_cat nido_rc nido $controls Parma Padova, robust
gen beta32 = _b[nido_rc]
gen se32 = _se[nido_rc]
gen obs32 = e(N)

*** coeff

keep in 1
keep beta* se* obs*
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\coeff.dta"
drop _m
gen id = 1
reshape long beta se obs, i(id) j(n)
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\coefficients.dta", replace


forvalues i = 1/32  {
use "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\coefficients.dta", clear
keep if (n== `i')
xpose, clear
keep in 3/5
ren v1 v`i'
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result`i'.dta", replace
}


*** nido SDQ

use "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result1.dta", clear
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result5.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result9.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result25.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result29.dta"
drop _m
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\nidoSDQcoho3.dta", replace

*** nido DEPR

use "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result2.dta", clear
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result6.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result11.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result26.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result30.dta"
drop _m
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\nidoDEPRcoho3.dta", replace

*** nido HEALTH

use "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result3.dta", clear
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result7.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result13.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result27.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result31.dta"
drop _m
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\nidoHEALTHcoho3.dta", replace

*** nido MIGR

use "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result4.dta", clear
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result8.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result15.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result28.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result32.dta"
drop _m
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\nidoMIGRcoho3.dta", replace

*** materna SDQ

use "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result10.dta", clear
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result17.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result21.dta"
drop _m
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\maternaSDQcoho3.dta", replace

*** materna DEPR

use "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result12.dta", clear
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result18.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result22.dta"
drop _m
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\maternaDEPRcoho3.dta", replace

*** materna HEALTH

use "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result14.dta", clear
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result19.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result23.dta"
drop _m
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\maternaHEALTHcoho3.dta", replace

*** materna MIGR

use "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result16.dta", clear
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result20.dta"
drop _m
merge using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\result24.dta"
drop _m
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\maternaMIGRcoho3.dta", replace
