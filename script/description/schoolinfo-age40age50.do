/* --------------------------------------------------------------------------- *
* Generating XLS File That Shows # of People Per Each Preschool
* Authors: Jessica Yu Kyung Koh
* Created: 09/13/2016
* Edited:  09/13/2016
* Note: The purpose of this do file is to generate a xls file that shows # of
        attendees per each ITC/preschool in our data. We are focusing only on
		age-40 and age-50 cohorts in this do file, as those are the cohorts that
		needs to be double-checked regarding the childcare attendance information
		that they provided. 
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

local asilo_5		Asilo Age-40
local asilo_6		Asilo Age-50
local materna_5		Scuole Age-40
local materna_6		Scuole Age-50

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
* Switch (Turns on if it the loop for "materna" type starts)
local switch = 0

* Loop
foreach type in asilo materna {
	foreach num in 5 6 {

		preserve
		
		* Keep only children's cohort who attended religious school
		keep if Cohort == `num' & `type'_Attend == 1

		* Keep necessary variables
		keep City Cohort `type'Type Name_School `type'Type_manualFull `type'name_manual

		* Drop if maternaType_manualFull is written as "No Info" (YKK: Who are these people?)
		drop if `type'Type_manualFull == "No Info"
		
		* Generate the count variable
		sort `type'name_manual
		by `type'name_manual: generate N_attendee = _N
		
		* Drop duplicates of the same school
		sort `type'name_manual
		quietly by `type'name_manual: gen dup = cond(_N==1,0,_n)
		keep if dup == 1 | dup == 0

		* Make into the format that goes into the excel sheet
		generate sort_attendee = -(N_attendee)
		sort City sort_attendee
		drop dup sort_attendee 
		
		* Order variables
		if `switch' == 0 {
			order City Cohort `type'Type `type'Type_manualFull `type'name_manual 				// asilo does not have long name?
			drop Name_School
		}
		
		if `switch' == 1 {
			order City Cohort `type'Type `type'Type_manualFull `type'name_manual Name_School 	// materna has long name for sure.
			rename Name_School	longname_manual
		}
		
		* Export 
		export excel using "${git_reggio}\output\description\age40-age50-schoolinfo.xlsx", sheet("``type'_`num''") firstrow(variables) sheetreplace 
		
		restore
	}	
	local switch = 1
}






