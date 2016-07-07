clear all
set more off
capture log close

cd "C:\Users\Titti\Desktop\Torino\Reggio2.0\19feb\STATA"
*cd "F:\Torino\Reggio2.0\19feb\STATA"

use Reggio12apr2015

keep if Cohort<3
dropmiss, force
global controls = "Male Age younger_siblings older_siblings cgAge momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni mom_full lone_parent houseOwn childz_BMI IQ_factor cgAge_missing houseOwn_missing childz_BMI_missing"

* SPEC 1

reg likeSchool asiloDum Reggio dummy $controls Immigrati CAPI [iweight=weight]
lincom asiloDum + dummy

* SPEC 2 

reg likeSchool municipal Reggio interaction $controls Immigrati CAPI [iweight=weight]
lincom municipal + interaction

* SPEC 3

reg likeSchool muni_reggio $controls Immigrati CAPI [iweight=weight]

**********************
* distance from school
**********************

ivreg2 likeSchool $controls Immigrati CAPI (muni_reggio = dist_muni_reggio) [iweight=weight]

*****************************
* choosing the closest school
*****************************

gen diff=second_nido-first_nido
probit closest first_nido second_nido educational $controls Immigrati CAPI 
predict prob_close if closest!=.

kdensity prob_close if muni_reggio==1, addplot(kdensity prob_close if muni_reggio==0 & Reggio==1 || kdensity prob_close if Parma==1 & asiloDum==1 || kdensity prob_close if Padova==1 & asiloDum==1) /*
*/ ytitle("Density function") xtitle("Choosing closest childcare") legend(lab(4 "Padova- Any ") lab(3 "Parma- Any") lab(2 "Reggio- Non municipal") lab(1 "Reggio- Municipal"))
graph save close_cities.gph, replace
graph export close_cities.png, replace
