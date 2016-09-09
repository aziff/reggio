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

use "${data_reggio}/Reggio_prepared"

* ------------------------------------------- *
* Create Necessary Excel File for Each Cohort *
* ------------------------------------------- *


foreach num in 1 2 3 4 5 6 {

	preserve
	
	* Keep only children's cohort who attended religious school
	di "hi1"
	keep if Cohort == `num' & maternaType == 3

	* Keep necessary variables
	di "hi2"
	keep City Cohort maternaType maternaname_manual maternaType_manualFull 

	* Drop if maternaType_manualFull is written as "No Info" (YKK: Who are these people?)
	di "hi3"
	drop if maternaType_manualFull == "No Info"

	* Generate the count variable
	di "hi4"
	sort maternaname_manual
	by maternaname_manual: generate N_attendee = _N

	* Drop duplicates of the same school
	di "hi5"
	sort maternaname_manual
	quietly by maternaname_manual: gen dup = cond(_N==1,0,_n)
	keep if dup == 1

	* Make into the format that goes into the excel sheet
	generate sort_attendee = -N_attendee
	sort City sort_attendee
	drop dup maternaType sort_attendee 

	* Export 
	export excel using "${git_reggio}\output\description\Reli-preschool-attendance.xlsx", sheet("`name_`num''") firstrow(variables) sheetreplace 
	
	restore
}	







