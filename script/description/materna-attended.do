/* --------------------------------------------------------------------------- *
* Generating XLS File That Shows # of People Per Each Preschool
* Authors: Jessica Yu Kyung Koh
* Created: 09/08/2016
* Edited:  09/08/2016
* --------------------------------------------------------------------------- */

clear all

cap file 	close outcomes
cap log 	close

* ----------- *
* Preparation *
* ----------- *
global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio

global current : pwd

local name_1 	It. Children
local name_2 	Im. Children
local name_3 	Adolescents
local name_4 	Adult 30
local name_5 	Adult 40
local name_6	Adult 50

* Import school name excel sheet and merge with the Reggio data
import excel "${data_reggio}\Scuole_ParmaReggioPadova_updated_2016-07-22.xlsx", sheet("list") firstrow
rename ShortName_School 	maternaname_manual
merge m:m maternaname_manual using "${data_reggio}/Reggio_prepared"

* Drop if master only
drop if _merge==1
drop _merge


* ------------------------------------------- *
* Create Necessary Excel File for Each Cohort *
* ------------------------------------------- *


foreach num in 1 2 3 4 5 6 {

	preserve
	
	* Keep only children's cohort who attended religious school
	keep if Cohort == `num' & maternaType == 3

	* Keep necessary variables
	keep City Cohort maternaType Name_School maternaType_manualFull 

	* Drop if maternaType_manualFull is written as "No Info" (YKK: Who are these people?)
	drop if maternaType_manualFull == "No Info"
	
	* Generate the count variable
	sort Name_School
	by Name_School: generate N_attendee = _N
	
	* Drop duplicates of the same school
	sort Name_School
	quietly by Name_School: gen dup = cond(_N==1,0,_n)
	keep if dup == 1 | dup == 0

	* Make into the format that goes into the excel sheet
	generate sort_attendee = -(N_attendee)
	sort City sort_attendee
	drop dup maternaType sort_attendee 

	* Export 
	export excel using "${git_reggio}\output\description\Reli-preschool-attendance.xlsx", sheet("`name_`num''") firstrow(variables) sheetreplace 
	
	restore
}	







