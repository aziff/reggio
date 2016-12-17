* --------------------------------------------------------------------------- *
* Incorporating new school assignment information by Sylvi and Linor
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
import excel using "${git_reggio}/data/school-info/merged_ReggioAll_SchoolNames_manual.xlsx", sheet(Sheet1) firstrow clear allstring

destring intnr, replace

* ---------------------------------------- *
* Clean and generate new school categories *
* ---------------------------------------- *
* Keep only the new variables
keep intnr Type_manualFull Type_manualFull_v2 school_new school_new_v2

* Only keep the people who are modified
drop if school_new_v2 == "" & Type_manualFull_v2 == ""

* Generate a new school column
generate school_Linor = school_new_v2
replace school_Linor = school_new if school_new_v2 == ""
order intnr school_new school_new_v2 school_Linor

* Drop old school columns
drop school_new school_new_v2

* Generate a new schooltype column
generate schooltype_Linor = Type_manualFull_v2
replace schooltype_Linor = Type_manualFull if Type_manualFull_v2 == ""

* Drop old schooltype columns
drop Type_manualFull Type_manualFull_v2


* -------------------------------------------------------------- *
* Generate columns that are consistent with Reggio_prepared data *
* -------------------------------------------------------------- *
generate materna = 0
replace materna = 1 if school_Linor == "materna"

generate asilo = 0 
replace asilo = 1 if school_Linor == "asilo"

generate maternaType_manualFull_Linor = schooltype_Linor if materna == 1
generate asiloType_manualFull_Linor = schooltype_Linor if asilo == 1

* Questionnable individual drop
drop if intnr == 53487100 & maternaType_manualFull_Linor == "autogestito"

* Check duplicates (who went to both asilo and preschool)
duplicates tag intnr, gen(dup_id)
sort intnr
drop schooltype_Linor school_Linor

* Collect id's that have duplicate observation
levelsof intnr if dup_id == 1, local(dupintnr)

foreach id in `dupintnr' {

	* Case 1: (materna == 0) & (asilo == 1)
	di "For id: `id'"
	levelsof maternaType_manualFull_Linor if intnr == `id' & materna == 1, local(mtype`id')
	replace maternaType_manualFull_Linor = `mtype`id'' if intnr == `id' & materna == 0

	replace materna = 1 if materna == 0 & intnr == `id'
}

* Drop the duplicates as we now have columns for all materna and asilo filled out
drop if (asilo == 0) & (dup_id == 1) 

drop materna asilo dup_id
* -------------------------- *
* Merge with Reggio_prepared *
* -------------------------- *

merge 1:1 intnr using "${data_reggio}/Reggio_prepared"

* Drop if the people are now included in the original Reggio_prepared data
drop if _merge == 1
drop _merge

order intnr maternaType maternaType_manualFull_Linor asiloType asiloType_manualFull_Linor

* -------------------------------------- *
* Do the replacement based on new column *
* -------------------------------------- *
label var maternaType_manualFull_Linor 	"Preschools reassigned by Linor. If empty, no change"
label var asiloType_manualFull_Linor		"Aslio Schools reassigned by Linor. If empty, no change"

* I need to reconstruct maternaType later

replace maternaMuni = 1 if maternaType_manualFull_Linor == "municipal"
replace maternaAffi = 1 if maternaType_manualFull_Linor == "municipal or municipal affiliated" | maternaType_manualFull_Linor == "municipal-affiliated" | maternaType_manualFull_Linor == "municipal-affiliated (nido-scuola)" | maternaType_manualFull_Linor == "autogestito"
replace maternaStat = 1 if maternaType_manualFull_Linor == "state" | maternaType_manualFull_Linor == "state (was municipal until 1990)"
replace maternaReli = 1 if maternaType_manualFull_Linor == "Not-Reggio, province, Religious-fism" | maternaType_manualFull_Linor == "Religious-fism"

* To capture individuals who might not have assigned as asilo before
* YK will work on more specific categorization later.
 
replace asilo = 1 if asiloType_manualFull_Linor != ""

capture drop maternaType_manualFull_verL asiloType_manualFull_verL
rename maternaType_manualFull_Linor maternaType_manualFull_verL
rename asiloType_manualFull_Linor asiloType_manualFull_verL

save "${data_reggio}/Reggio_reassigned", replace
