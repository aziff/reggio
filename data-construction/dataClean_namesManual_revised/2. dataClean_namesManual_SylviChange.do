* --------------------------------------------------------------------------- *
* Incorporating new school assignment information by Sylvi
* Author: Jessica Yu Kyung Koh
* Date:   12/16/2016
* --------------------------------------------------------------------------- *

* Set macro
clear all

global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio

global here : pwd


* Bring in data
import excel using "${git_reggio}/data/school-info/SK-PADOVA-SOMEPARMA-DATA-CHECK_merged_ReggioAll_SchoolNames_manual.xlsx", sheet(Sheet1) firstrow clear allstring

destring intnr, replace

* ---------------------------------------- *
* Clean and generate new school categories *
* ---------------------------------------- *
* Keep only the new variables
keep intnr Type_manualFull Type_manualFull_v2 school_new school_new_v2

* Only keep the people who are modified
drop if school_new_v2 == "" & Type_manualFull_v2 == ""

* Generate a new school column
generate school_Sylvi = school_new_v2
replace school_Sylvi = school_new if school_new_v2 == ""
order intnr school_new school_new_v2 school_Sylvi

* Drop old school columns
drop school_new school_new_v2

* Generate a new schooltype column
generate schooltype_Sylvi = Type_manualFull_v2
replace schooltype_Sylvi = Type_manualFull if Type_manualFull_v2 == ""

* Drop old schooltype columns
drop Type_manualFull Type_manualFull_v2




* -------------------------------------------------------------- *
* Generate columns that are consistent with Reggio_prepared data *
* -------------------------------------------------------------- *
generate materna = 0
replace materna = 1 if school_Sylvi == "materna"

generate asilo = 0 
replace asilo = 1 if school_Sylvi == "asilo"

generate maternaType_manualFull_Sylvi = schooltype_Sylvi if materna == 1
generate asiloType_manualFull_Sylvi = schooltype_Sylvi if asilo == 1

* Questionnable individual drop
drop if maternaType_manualFull_Sylvi == "drop"

* Check duplicates (who went to both asilo and preschool)
duplicates tag intnr, gen(dup_id)
sort intnr
drop school_Sylvi schooltype_Sylvi

sort intnr materna
by intnr materna: gen dup_materna = cond(_N==1,0,_n)
drop if dup_materna == 2
replace dup_id = 0 if dup_materna == 1
drop dup_materna


* Collect id's that have duplicate observation
levelsof intnr if dup_id == 1, local(dupintnr)

foreach id in `dupintnr' {

	* Case 1: (materna == 0) & (asilo == 1)
	di "For id: `id'"
	levelsof maternaType_manualFull_Sylvi if intnr == `id' & materna == 1, local(mtype`id')
	replace maternaType_manualFull_Sylvi = `mtype`id'' if intnr == `id' & materna == 0

	replace materna = 1 if materna == 0 & intnr == `id'
}

* Drop the duplicates as we now have columns for all materna and asilo filled out
drop if (asilo == 0) & (dup_id == 1) 

drop materna asilo dup_id


* -------------------------- *
* Merge with Reggio_prepared *
* -------------------------- *

merge 1:1 intnr using "${data_reggio}/Reggio_reassigned"

* Drop if the people are now included in the original Reggio_prepared data
drop if _merge == 1
drop _merge

order intnr maternaType maternaType_manualFull_Sylvi asiloType asiloType_manualFull_Sylvi

* -------------------------------------- *
* Do the replacement based on new column *
* -------------------------------------- *
label var maternaType_manualFull_Sylvi 	"Preschools reassigned by Sylvi. If empty, no change"
label var asiloType_manualFull_Sylvi		"Aslio Schools reassigned by Sylvi. If empty, no change"

* I need to reconstruct maternaType later

replace maternaMuni = 1 if maternaType_manualFull_Sylvi == "municipal"
replace maternaAffi = 1 if maternaType_manualFull_Sylvi == "muni-other" 
replace maternaStat = 1 if maternaType_manualFull_Sylvi == "statale" | maternaType_manualFull_Sylvi == "? state/autogestito?"
replace maternaReli = 1 if maternaType_manualFull_Sylvi == "religious" | maternaType_manualFull_Sylvi == "Religious-fism-affiliated"
replace maternaAuto = 0 if maternaType_manualFull_Sylvi == "unknown"
replace materna = 1 if maternaType_manualFull_Sylvi == "unknown"

replace maternaType = 1 if maternaMuni == 1
replace maternaType = 2 if maternaStat == 1
replace maternaType = 3 if maternaReli == 1
replace maternaType = 4 if maternaPriv == 1
replace maternaType = 5 if maternaAffi == 1
replace maternaType = 6 if maternaAuto == 1

* To capture individuals who might not have assigned as asilo before
* YK will work on more specific categorization later.

* Recode asilo
replace asiloType = 4 if asiloType_manualFull_Sylvi == "private"
replace asiloType = 6 if asiloType_manualFull_Sylvi == "unknown"					   
replace asiloType = 6 if Cohort == 5 & (City == 2 | City == 3) & asiloType == 1 // Parma and Padova did not have municipal

*lab define Type_val 0 "No Preschool" 1 "Municipal" 2 "State" 3 "Religious" 4 "Private" 5 "Municipal-Affiliated" 6 "Other"
label values asiloType Type_val

capture drop maternaType_manualFull_verS asiloType_manualFull_revised2
rename maternaType_manualFull_Sylvi maternaType_manualFull_revised2
rename asiloType_manualFull_Sylvi asiloType_manualFull_revised2


** Generate non-maternaMuni
capture drop maternaOther
generate maternaOther = (maternaMuni != 1) & (maternaNone != 1)
lab var maternaOther "dv: Went to non-municipal preschool"

*drop asiloNone asiloMuni asiloStat asiloReli asiloPriv asiloOther asiloAffi asiloAuto

generate asiloNone = (asiloType == 0)
generate asiloMuni = (asiloType == 1)
generate asiloStat = (asiloType == 2)
generate asiloReli = (asiloType == 3)
generate asiloPriv = (asiloType == 4)
generate asiloAffi = (asiloType == 5)
generate asiloAuto = (asiloType == 6)

generate asiloOther = (asiloMuni !=1) & (asiloNone != 1)
label var asiloOther "dv: Went to non-municipal asilo"



* ------------------------------------------- *
* Recode data based on historical information *
* ------------------------------------------- *
/* 	Reggio: No municipal and state for age-50
			No state for age-40
	Parma: 	No municipal and state for age-50 and age-40
	Padova: No municipal and state for age-50 and age-40
*/

* Reggio
replace maternaType = 6 if (maternaType == 1) & (Reggio == 1) & (Cohort == 6)
replace maternaType = 6 if (maternaType == 2) & (Reggio == 1) & (Cohort == 6)

* Parma
replace maternaType = 6 if (maternaType == 1) & (Parma == 1) & (Cohort == 6)
replace maternaType = 6 if (maternaType == 2) & (Parma == 1) & (Cohort == 6)
replace maternaType = 6 if (maternaType == 1) & (Parma == 1) & (Cohort == 5)
replace maternaType = 6 if (maternaType == 2) & (Parma == 1) & (Cohort == 5)

* Padova
replace maternaType = 6 if (maternaType == 1) & (Padova == 1) & (Cohort == 6)
replace maternaType = 6 if (maternaType == 2) & (Padova == 1) & (Cohort == 6)
replace maternaType = 6 if (maternaType == 1) & (Padova == 1) & (Cohort == 5)
replace maternaType = 6 if (maternaType == 2) & (Padova == 1) & (Cohort == 5)


** Create interaction terms between school type and adult age cohort (except maternaMuni and age 50)
foreach type in None Muni Affi Stat Reli Priv Yes {
	foreach age in Adult30 Adult40 Adult50 {
		replace xm`type'`age' = materna`type' * Cohort_`age'
	}
}

** Create interaction terms between school type and city (except Reggio and maternaMuni)
foreach type in None Muni Affi Stat Reli Priv Yes {
	foreach city in Parma Padova Reggio {
		replace xm`type'`city' = materna`type' * `city'
	}
}

** Create interaction terms between school type and city (except Reggio and maternaMuni)
foreach type in None Muni Affi Stat Reli Priv Other {
	foreach city in Parma Padova Reggio {
		capture drop variable xa`type'`city'
		generate xa`type'`city' = asilo`type' * `city'
	}
}

save "${data_reggio}/Reggio_reassigned", replace
