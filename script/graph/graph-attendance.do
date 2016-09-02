* ---------------------------------------------------------------------------- *
* Graphing Attendance for Each School Types Across Cities and Age Cohorts
* Authors: Pietro Biroli, Jessica Yu Kyung Koh
* Created: 09/02/2016
* Edited: 09/02/2016
* ---------------------------------------------------------------------------- *

clear all
set more off

* ---------------------------------------------------------------------------- *
* Preparation
* ---------------------------------------------------------------------------- *
global klmReggio	: 	env klmReggio		
global data_reggio	: 	env data_reggio
global git_reggio   :	env git_reggio

global current : pwd
global output	"${current}/../../output/image"

use "${data_reggio}/Reggio_prepared"
include "${current}/../macros" 

* Generate variables necessary for plotting
recode Cohort (1=2) (2=1), gen(Cohort_born) //to make it look better in the bar graph
label define Cohort_born ///
1 "2006-Imm." ///
2 "2006-It. " ///
3 "1994     " ///
4 "1980-1981" ///
5 "1969-1970" ///
6 "1954-1959" 
label values Cohort_born Cohort_born
tab Cohort Cohort_born

* ---------------------------------------------------------------------------- *
* Asilo (Ages 0-3)
* ---------------------------------------------------------------------------- *
* Plot
graph hbar (sum) asilo_Municipal asilo_State asilo_Religious asilo_Private asilo_NotAttended, ///
				over(Cohort_born, label(angle(10) labsize(3))) over(City) stack  percentages /// 
				legend(size(small) label(1 "Municipal") label(2 "State") label(3 "Religious") label(4 "Private") label(5 "Not Attended")) ///
				graphregion(color(white))

* Export the chart
graph export "${output}/asiloType-Attend.png", replace


* ---------------------------------------------------------------------------- *
* Materna (Ages 3-6)
* ---------------------------------------------------------------------------- *
* Plot
graph hbar (mean) materna_Municipal materna_State materna_Religious materna_Private materna_NotAttended, ///
				over(Cohort_born, label(angle(10) labsize(3))) over(City) stack  percentages /// 
				legend(size(small) label(1 "Municipal") label(2 "State") label(3 "Religious") label(4 "Private") label(5 "Not Attended") ) ///
				graphregion(color(white))

* Export the chart				
graph export "${output}/maternaType-Attend.png", replace




