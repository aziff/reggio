/* --------------------------------------------------------------------------- *
* Generating XLS File That Shows # of People Per Each Preschool
* Authors: Jessica Yu Kyung Koh
* Created: 09/13/2016
* Edited:  09/13/2016
* Note: The purpose of this do file is to generate a xls file that shows # of
        attendees per each ITC/preschool in our data. 
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
local materna_1		Scuole Child
local materna_2		Scuole Migr
local materna_3		Scuole Adol
local materna_4		Scuole Age-30
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
local switch = 1

* Loop
foreach type in asilo materna {
	foreach city in Reggio Parma Padova {

		preserve
		
		* Keep only children's cohort who attended religious school
		keep if `city' == 1 & `type'_Attend == 1

		* Keep necessary variables
		keep City Cohort `type'Type Name_School `type'Type_manualFull `type'name_manual ID_School
		* Drop if maternaType_manualFull is written as "No Info" (YKK: Who are these people?)
		drop if `type'Type_manualFull == "No Info"

		* Generate the count variable
		sort City `type'name_manual Cohort
		by City `type'name_manual Cohort : generate N_attendee = _N
		
		
		* Drop duplicates of the same school
		sort City `type'name_manual Cohort
		quietly by City `type'name_manual Cohort: gen dup = cond(_N==1,0,_n)
		keep if dup == 1 | dup == 0 
		
		
		* Make into the format that goes into the excel sheet
		generate sort_attendee = -(N_attendee)
		generate Cohort_neg = -1 * Cohort
		sort City ID_School Cohort_neg sort_attendee
		drop dup sort_attendee Cohort_neg
		
		* Order variables
		if `switch' == 0 {
			order City ID_School `type'name_manual Cohort `type'Type `type'Type_manualFull N_attendee // asilo does not have long name?
			drop Name_School
		}
		
		if `switch' == 1 {
			order City ID_School `type'name_manual Name_School Cohort `type'Type `type'Type_manualFull N_attendee	// materna has long name for sure.
			rename Name_School	longname_manual
		}
		
		* Export 
		export excel using "${git_reggio}\output\description\allcohort-schoolinfo-combined-`type'.xlsx", sheet("`type'_`city'") firstrow(variables) sheetreplace 
		
		restore
	}	
	local switch = 1
}





