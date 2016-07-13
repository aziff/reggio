clear all
set more off
capture log close

/*
Author: Pietro Biroli (biroli@uchicago.edu)
Purpose: Import the information on school names and addresses that was manually constructed with the help of Geoffrey Wang

This Draft: 14 March 2015

	  [=] Signal questions to be addressed
*/

/*-*-* directory: keep global directory from dataClean_all.do unless otherwise needed
 local dir "/mnt/ide0/share/klmReggio/SURVEY_DATA_COLLECTION/data"
 local dir "/mnt/ide0/home/biroli/ChicaGo/Heckman/ReggioChildren/SURVEY_DATA_COLLECTION/data"
 local dir "C:\Users\Pietro\Documents\ChicaGo\Heckman\ReggioChildren\SURVEY_DATA_COLLECTION\data"
cd "`dir'"
*/

*-* import the manually coded preschool_type
clear all
import excel using "ReggioAll_SchoolNames_manual.xlsx", sheet("ReggioAll_SchoolNames") firstrow clear
//check that there is only one schoolID for each school name [=]
save ReggioAll_SchoolNames_manual, replace

import excel using "ReggioAll_SchoolNames_manual.xlsx", sheet("NoInfo") firstrow clear allstring
destring internr intnr flagType Multiple, replace
append using ReggioAll_SchoolNames_manual
drop if source=="fake"
destring _all, replace
dropmiss, force
save ReggioAll_SchoolNames_manual, replace

* Reconstruct the same variable names
rename Comu Muni // comunale <--> municipale
foreach var in Stat Muni Pubb Reli Priv DK Type flagType {
	rename `var' `var'_self
}
rename name Location_name
rename address Location_address
// rename Type_manual Type_manualFull

* Change the multiple using the manually constructed one
tab *Multiple, miss
replace Multiple = flagMultiple if flagMultiple<. 
drop flagMultiple

* Generate a short preschool type
tab Type_manualFull, miss
gen     Type_manual = .w  if Type_manualFull==""
// replace Type_manual = 12 if strpos(lower(Type_manualFull),"not")>0 //not-in-the-city --> if some info is provided on the type of school it will be over-written
replace Type_manual = 0  if strpos(lower(Type_manualFull),"frequentato")>0
replace Type_manual = 1  if strpos(lower(Type_manualFull),"munic")>0
replace Type_manual = 2  if strpos(lower(Type_manualFull),"stat")>0 // NOTE: those labelled "State (was municipal)" will be labelled as state --> change to municipal for the older cohorts
replace Type_manual = 3  if strpos(lower(Type_manualFull),"relig")>0
replace Type_manual = 4  if strpos(lower(Type_manualFull),"priv")>0 // NOTE this considers also private-affiliated
replace Type_manual = 5  if strpos(lower(Type_manualFull),"spazio")>0
replace Type_manual = 5  if strpos(lower(Type_manualFull),"educator")>0
replace Type_manual = 6  if strpos(lower(Type_manualFull),"autogesti")>0 // NOTE: those labelled "State (was municipal)" will be labelled as state --> change to municipal for the older cohorts
replace Type_manual = 10 if strpos(lower(Type_manualFull),"?")>0 // those that have a ? will always be flagged as unclear
replace Type_manual = 11 if strpos(lower(Type_manualFull),"no info")>0
label define Type_manual 0 "Not Attended" 1 "Municipal" 2 "State" 3 "Religious" 4 "Private" ///
                         5 "Other (spazio/educatore)" 6 "Autogestito" 10 "Unclear" 11 "No Info" 12 "Outside"
label values Type_manual Type_manual
label var Type_manual "Type of school attended (manually constrcuted, simplifying Type_manualFull)"
tab Type_manualFull Type_manual, miss
// If ever been in a municipal in Reggio, replace Type as municipal
replace Type_manual = 1  if strpos(lower(Type2_manual),"munic")>0 & Type_manual!=1 & City=="Reggio" //no change made

gen     NotCity = 0 if (Type_manualFull!="" & Type_manualFull!="Non frequentato" & Type_manualFull!="No Info" ) 
replace NotCity = 1 if strpos(lower(Type_manualFull),"province")>0
replace NotCity = 2 if strpos(lower(Type_manualFull),"outside")>0 
replace NotCity = 3 if strpos(lower(Type_manualFull),"abroad")>0 
label define NotCity 0 "In City" 1 "Province" 2 "Italy" 3 "Abroad" // . ". no school"
label values NotCity NotCity 
tab NotCity, miss
tab NotCity Cohort
tab NotCity City

list intnr Location* if NotCity==1
list intnr Location* name_manual NotCity if NotCity==2
list intnr Location* name_manual NotCity if NotCity==3
* tab Type_manualFull NotCity  if strpos(lower(Type_manualFull),"not")>0 , miss // check

egen temp = mode(internr), by(intnr) // impute interviewer number when needed
replace internr = temp if internr==. 
drop temp

egen temp = mode(source), by(intnr) minmode
replace source = temp if internr==. 
drop temp


reshape wide @Stat_self @Muni_self @Pubb_self @Reli_self @Priv_self @DK_self @Type_self ///
             @Location @Location_name @Location_address flag@Type_self @Multiple /// 
	         @Type_manualFull @Type_manual @Type2_manualFull @NotCity @name_manual @SchoolID_manual ///
		     flag@Accuracy @CommentSchoolName source@ @school_new @Discrepancy, i(intnr) j(school) string 

replace sourcematerna = sourceasilo if sourcematerna=="" & sourceasilo!=""
drop sourceasilo 
rename sourcematerna source_manual

tab *NotCity, miss
//browse intnr Cohort City *Location* flag* *NotCity if asiloNotCity==3 | maternaNotCity==3

foreach var of varlist Cohort City asiloStat_self-asiloMultiple maternaStat_self-maternaMultiple {
	//rename `var' `var'_manual
	drop `var' // these variables are the same from the original data. intnr is sufficient to merge them
}

foreach grade in asilo materna{
	label var `grade'school_new "Name or address refer to this type of school"
	label var `grade'name_manual "Name of the school attended (manually constructed based on name and address)"
	label var `grade'SchoolID_manual "ID of the school attended (manually constructed based on name and address)"
	label var flag`grade'Accuracy "Accuracy of manually assigned school"
	label var `grade'CommentSchool "Comments to the manually assigned school"
	label var `grade'Discrepancy "Name and address of school don't give same information"
}

compress
save ReggioAll_SchoolNames_manual, replace

/*
merge 1:1 intnr using Reggio_all.dta, gen(_mergeManual3) //CHECK all should be matched

* CHECKS
tab Cohort*, miss
tab City*, miss
foreach var in asiloMuni_self asiloDK_self asiloLocation asiloMultiple asiloPriv_self asiloPubb_self asiloReli_self asiloType_self flagasiloType_self /// 
               maternaMuni_self maternaDK_self maternaLocation maternaMultiple maternaPriv_self maternaPubb_self maternaReli_self maternaStat_self maternaType_self flagmaternaType_self {
tab `var' `var'_manual
}
*/
