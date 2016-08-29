clear all
set more off
capture log close

/*
Author: Pietro Biroli (biroli@uchicago.edu)
Purpose:
-- Import in stata the data on instruments that was collected by Chiara Baldelli

This Draft: 30 Apr 2015

Input: 	ReggioChildren\Instrumental_Variables\Fees_cap_wl_PD_PR_RE_child_adol.xlsx  --> file manually constructed by Chiara Baldelli
		Distances.dta  --> see distances.do
		
Output:	Instruments.dta

	[=] Signal questions to be addressed
*/

/*** directory
// global dir "C:\Users\Pietro\Documents\ChicaGo\Heckman\ReggioChildren\SURVEY_DATA_COLLECTION\data"
 global dir "/mnt/ide0/share/klmReggio/SURVEY_DATA_COLLECTION/data"
cd "$dir"
*/

import excel "./../../Instrumental_Variables/Fees_cap_wl_PD_PR_RE_child_adol.xlsx", sheet("Foglio1") firstrow

foreach var of varlist _all{
	replace `var' = ".w" if `var'=="n.a."
	replace `var' = "." if `var'=="-"
}

destring _all, replace
sum 
// dropmiss, force --> this makes a lot of difference, a lot are missing

** Create some useful categories
gen City = 1 if strpos(A,"Reggio")>0
replace City = 2 if strpos(A,"Parma")>0
replace City = 3 if strpos(A,"Padova")>0
label define City 1 "Reggio" 2 "Parma" 3 "Padova"
label values City City
tab A City, miss

gen Cohort = 1 if strpos(A,"child")>0
replace Cohort = 3 if strpos(A,"adol")>0
label define Cohort 1 "Children" 2 "Migrants" 3 "Adolescents" 4 "Adult 30" 5 "Adult 40" 6 "Adult 50"
label values Cohort Cohort
tab A Cohort, miss

gen SchoolType = "Muni" if strpos(A,"mun")>0
replace SchoolType = "Stat" if strpos(A,"state")>0
replace SchoolType = "Reli" if strpos(A,"rel")>0
replace SchoolType = "Priv" if strpos(A,"priv")>0
tab A SchoolType, miss

gen School = "asilo" if strpos(A,"ITC")>0
replace School = "materna" if strpos(A,"_pre_")>0
tab A School, miss

gen Year = 1 if strpos(A,"2006")>0 | strpos(A,"2009")>0 //first year of infant-toddler center or preschool for children
replace Year = 1 if strpos(A,"1994")>0 | strpos(A,"1997")>0 //first year of infant-toddler center or preschool for adolescents
replace Year = 2 if strpos(A,"2007")>0 | strpos(A,"2010")>0 
replace Year = 2 if strpos(A,"1995")>0 | strpos(A,"1998")>0 
replace Year = 3 if strpos(A,"2008")>0 | strpos(A,"2011")>0 
replace Year = 3 if strpos(A,"1996")>0 | strpos(A,"1999")>0 
tab A Year, miss

** For the fees, take just the median of all of them -- 
* The different entries usually represent different cost based on income (State/Muni) or different schools (Relig)
egen Fees_med_full = rowmedian(Fees_*_full)
egen Fees_med_part = rowmedian(Fees_*_part)
egen Fees_med = rowmedian(Fees_??) //present only for Religious

save ./../../Instrumental_Variables/Instruments_CB.dta, replace

*----------------------------------------------------------**
* Reshape the data so that each line is city X cohort 

drop Fees_?_* Fees_??_* Fees_??

gen group = "_"+School+SchoolType+"_"+string(Year)

/*
gen group2 = subinstr(A,"Reggio","",1)
replace group2 = subinstr(group2 ,"Parma","",1)
replace group2 = subinstr(group2 ,"Padova","",1)
replace group2 = subinstr(group2 ,"child_","",1)
replace group2 = subinstr(group2 ,"adol_","",1)

tab group2 group
*/

drop A SchoolType School Year
reshape wide Capacity@ Waiting_list@ Fees_med_full@ Fees_med_part@ Fees_med@ ///
	     , i(City Cohort) j(group) string 

expand 2 if Cohort==1, gen(temp) //duplicate the observations: Children and migrants face same prices and constraints
replace Cohort=2 if temp==1 
drop temp	     
sort City Cohort

save Instruments.dta, replace

* Merge with the distances
merge 1:m City Cohort using Distances.dta, gen(_mergeInstrument) keepusing(intnr Postal X_Address Y_Address dist*) 
tab Cohort _mergeInstr

save Instruments.dta, replace
