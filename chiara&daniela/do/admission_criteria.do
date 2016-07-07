clear all
set more off
capture log close

cd  "/mnt/ide0/share/klmReggio/SURVEY_DATA_COLLECTION/data"
// cd "C:\Users\Titti\Desktop\Torino\Reggio2.0\19feb\STATA"
// cd "F:\Torino\Reggio2.0\19feb\STATA"

// use Reggio12apr2015
use Reggio.dta 

keep if Cohort<3
dropmiss, force
global controls = "Male Age younger_siblings older_siblings cgAge momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni mom_full lone_parent houseOwn childz_BMI IQ_factor cgAge_missing houseOwn_missing childz_BMI_missing"

gen one_out= momBornCity==0 | dadBornCity==0
gen two_out= momBornCity==0 & dadBornCity==0

gen cap_muni_2006=.
replace cap_muni_2006=900/1750 if Padova==1
replace cap_muni_2006=1862/2874 if Parma==1
replace cap_muni_2006=825/1543 if Reggio==1

gen cap_muni_2007=.
replace cap_muni_2007=900/1750 if Padova==1
replace cap_muni_2007=1862/2930 if Parma==1
replace cap_muni_2007=825/1586 if Reggio==1

gen cap_muni_2008=.
replace cap_muni_2008=900/1750 if Padova==1
replace cap_muni_2008=1871/3001 if Parma==1
replace cap_muni_2008=812/1673 if Reggio==1

gen coverage=.
replace coverage=1750/1224 if Padova==1
replace coverage=3001/1054 if Parma==1
replace coverage=1673/1096 if Reggio==1



gen score_adozione=5*(cgRelation==8|cgRelation==9)

gen score_lone=16*(lone_parent==1 & (cgmStatus==2 | cgmStatus==3)) + 14*(lone_parent==1 & cgmStatus==5)

gen fullTime= cgHrsWork>=40 | hhHrsWork>=40

gen score_teacher=11*(cgSES==4 | hhSES==4) + 0.5*fullTime

gen score_fullTime=0.5*fullTime

/*
gen score_ore=7*(cgHrsWork<15 & cgHrsWork>0) + 7*(hhHrsWork>0 & hhHrsWork<15) + 9*(cgHrsWork>=15 & cgHrsWork<=23) + 9*(hhHrsWork>=15 & hhHrsWork<=23) /*
*/ + 10*(cgHrsWork>=24 & cgHrsWork<=28) + 10*(hhHrsWork>=24 & hhHrsWork<=28) + 11*(cgHrsWork>=29 & cgHrsWork<=32) + 11*(hhHrsWork>=29 & hhHrsWork<=32) /*
*/ + 13*(cgHrsWork>=33 & cgHrsWork<=36) + 11*(hhHrsWork>=33 & hhHrsWork<=36) + 14*(cgHrsWork>=37 & cgHrsWork<100) + 14*(hhHrsWork>=37 & hhHrsWork<100) if hhead!=1
replace score_ore=7*(cgHrsWork<15) + 9*(cgHrsWork>=15 & cgHrsWork<=23) /*
*/ + 10*(cgHrsWork>=24 & cgHrsWork<=28) + 11*(cgHrsWork>=29 & cgHrsWork<=32) /*
*/ + 13*(cgHrsWork>=33 & cgHrsWork<=36) + 14*(cgHrsWork>=37 & cgHrsWork<100) if hhead==1
*/

gen score_ore=14.5*(noDad==0)

gen score_migrant=3*(momMigrant==1 & dadMigrant==1 & yrItaly>=2003)

gen score_unemp=8*(momPA_Unemp+dadPA_Unemp==2) + 4*(momPA_Unemp+dadPA_Unemp==1)

gen score_student=8*(momPA==7 | dadPA==7) & score_full==0 & score_ore==0 & score_un==0

/*
gen adozione = 0
forvalues i = 3/10 {
replace  adozione = adozione + 1 if(Relation`i' == 8 | Relation`i' == 9)
}
replace adozione = adozione + 1 if(cgRelation == 8 |  cgRelation == 9)
recode adozione (2 = 1)
gen score_adozione_bis=5*adozione
*/

forvalues i = 3/10 {
format Birthday`i' %td
gen year`i'=year(Birthday`i')
order Birthday`i' year`i'
}

gen score_siblings=0
forvalues i = 3/10 {
replace score_siblings=score_siblings + 1*(Relation`i' == 11 & year`i'>=1989 & year`i'<=1992) + 2*(Relation`i' == 11 & year`i'>=1993 & year`i'<=1999) /*
*/ + 3*(Relation`i' == 11 & year`i'>=2000 & year`i'<=2004) + 4.5*(Relation`i' == 11 & year`i'>=2005 & year`i'<=2008)
}

gen score_nonni=11*(grandDist==7) + 10*(grandDist==6) + 5*(grandDist==5) + 2*(grandDist==2 | grandDist==3 | grandDist==4)

gen score=score_sib+score_unemp+score_ado+score_migr+score_tea+score_full+score_student+score_ore+score_lone+score_nonni
sum score, d
replace score=r(max)+1 if (lone_parent==1 & mommStatus==5) | (lone_parent==1 & dadmStatus==5)

kdensity score if ReggioAsilo==1, addplot(kdensity score if ReggioAsilo==0 & Reggio==1 || kdensity score if Reggio==1 & asiloType==0) /*
*/ ytitle("Density function") xtitle("Score") legend(lab(3 "No childcare") lab(2 "Non municipal childcare") lab(1 "Municipal childcare"))
*distplot line score if ReggioAsilo==1, addplot(distplot line score if ReggioAsilo==0 & Reggio==1 || distplot line score if Reggio==1 & asiloType==0)
graph save score_reggio.gph, replace
graph export score_reggio.png, replace

kdensity score if ReggioAsilo==1, addplot(kdensity score if Parma==1 & asilo_Municipal==1 || kdensity score if Padova==1 & asilo_Municipal==1) /*
*/ ytitle("Density function") xtitle("Score") legend(lab(3 "Padova") lab(2 "Parma") lab(1 "Reggio"))
*distplot line score if ReggioAsilo==1, addplot(distplot line score if ReggioAsilo==0 & Reggio==1 || distplot line score if Reggio==1 & asiloType==0)
graph save score_cities.gph, replace
graph export score_cities.png, replace

kdensity score if ReggioAsilo==1, addplot(kdensity score if ReggioAsilo==0 & Reggio==1 || kdensity score if Parma==1 & asilo_Attend==1 || kdensity score if Padova==1 & asilo_Attend==1) /*
*/ ytitle("Density function") xtitle("Score") legend(lab(4 "Padova- childcare") lab(3 "Parma- childcare") lab(2 "Reggio- non municipal") lab(1 "Reggio- municipal"))
*distplot line score if ReggioAsilo==1, addplot(distplot line score if ReggioAsilo==0 & Reggio==1 || distplot line score if Reggio==1 & asiloType==0)
graph save score_any_cities.gph, replace
graph export score_any_cities.png, replace
