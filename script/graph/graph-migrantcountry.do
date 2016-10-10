* ---------------------------------------------------------------------------- *
* Drawing Plots for Country of Origins of Migrants
* Authors: Jessica Yu Kyung Koh
* Created: 10/07/2016
* Edited: 10/07/2016
* ---------------------------------------------------------------------------- *

clear all
set more off

* ---------------------------------------------------------------------------- *
* Set directory
* ---------------------------------------------------------------------------- *
global klmReggio	: 	env klmReggio		
global data_reggio	: 	env data_reggio

global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio

global current : pwd

use "${data_reggio}/Reggio_prepared"
include "${current}/../macros" 

* ---------------------------------------------------------------------------- *
* Plot bar graphs
* ---------------------------------------------------------------------------- *
*********** Locals for plotting
local region				graphregion(color(white))
local xtitle				xtitle(Mother's Years of Education)
local ytitle				ytitle(Proportion of Working Mothers, height(5) color(navy))
local legend				legend(label(1 "Age-30 Cohort") label(2 "Age-40 Cohort") label(3 "Age-50 Cohort") size(small))

*********** Plot bar graphs for counts of each nationality of caregiver for migrant cohort
preserve
keep if Cohort == 2
replace cgNationSEurope = . if cgNationSEurope == 0
replace cgNationAfrica = . if cgNationAfrica == 0
replace cgNationSAmerica = . if cgNationSAmerica == 0
replace cgNationAsia = . if cgNationAsia == 0
replace cgNationWEurope = . if cgNationWEurope == 0
replace cgNationEEurope = . if cgNationEEurope == 0
replace cgNationCarib = . if cgNationCarib == 0

collapse (count) cgNationSEurope cgNationAfrica cgNationSAmerica cgNationAsia cgNationWEurope cgNationEEurope cgNationCarib, by(City)
 

graph bar cgNationSEurope cgNationAfrica cgNationSAmerica cgNationAsia cgNationWEurope cgNationEEurope cgNationCarib, over(City) ///
		 bar(1, color(gs2)) bar(2, color(gs7)) bar(3, color(gs10)) bar(4, color(gs13)) ///
		 legend(size(small) label(1 "Southern Europe") label(2 "Africa") label(3 "South America") label(4 "Asia") ///
							label(5 "Western Europe") label(6 "Eastern Europe") label(7 "Caribbean")) ///
		 ytitle("Number of Caregivers") graphregion(color(white))
graph export "${current}\..\..\output\image\bar_cgNationality.eps", replace		 

restore



