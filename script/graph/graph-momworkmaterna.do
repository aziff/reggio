* ---------------------------------------------------------------------------- *
* Drawing Plots for Mother Works and Preschool Choices
* Authors: Jessica Yu Kyung Koh
* Created: 10/05/2016
* Edited: 10/05/2016
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
* Locals for plotting
local region				graphregion(color(white))
local xtitle				xtitle(Mother's Years of Education)
local ytitle				ytitle(Proportion of Working Mothers, height(5) color(navy))
local legend				legend(label(1 "Age-30 Cohort") label(2 "Age-40 Cohort") label(3 "Age-50 Cohort") size(small))

* Plot bar graphs for proportion of P = 1 for different work/study status of mothers
preserve
keep if Cohort == 4 | Cohort == 5 | Cohort == 6
generate materna_count = 1
replace materna_count = . if materna == 0
collapse (mean) meanmaterna = materna (count) n = materna_count, by(momWorking06 Cohort)

graph bar meanmaterna, over(momWorking06) over(Cohort) asyvars ///
		 bar(1, color(gs2)) bar(2, color(gs7)) bar(3, color(gs10)) bar(4, color(gs13)) ///
		 legend(size(small) label(1 "Worked full-time") label(2 "Worked part-time") label(3 "Was a student") label(4 "Did not work/study")) ///
		 ytitle("Proportion of Sending Child to Preschool") graphregion(color(white))
graph export "${current}\..\..\output\image\bar_momworkpreschool_mean.pdf", replace		 

graph bar n, over(momWorking06) over(Cohort) asyvars ///
		 bar(1, color(gs2)) bar(2, color(gs7)) bar(3, color(gs10)) bar(4, color(gs13)) ///
		 legend(size(small) label(1 "Worked full-time") label(2 "Worked part-time") label(3 "Was a student") label(4 "Did not work/study")) ///
		 ytitle("Number of Cases of Sending Child to Preschool") graphregion(color(white))
graph export "${current}\..\..\output\image\bar_momworkpreschool_count.pdf", replace		 

restore
ddd

* Plot bar graphs for work/study status of mothers
preserve
keep if Cohort == 4 | Cohort == 5 | Cohort == 6
graph hbar (sum) momWork_fulltime06 momWork_parttime06 momSchool06 momWork_No06 if (materna == 1), ///
				over(Cohort) stack  percentages bar(1, color(gs2)) bar(2, color(gs7)) bar(3, color(gs10)) bar(4, color(gs13)) /// 
				legend(size(small) label(1 "Worked full-time") label(2 "Worked part-time") label(3 "Was a student") label(4 "Did not work/study")) ///
				graphregion(color(white)) title("Proportion of Work/Study Status of Mothers (Preschool = 1)", size(medlarge))
graph export "${current}\..\..\output\image\bar_mompreschoolyes.pdf", replace

graph hbar (sum) momWork_fulltime06 momWork_parttime06 momSchool06 momWork_No06 if (materna == 0), ///
				over(Cohort) stack  percentages bar(1, color(gs2)) bar(2, color(gs7)) bar(3, color(gs10)) bar(4, color(gs13)) /// 
				legend(size(small) label(1 "Worked full-time") label(2 "Worked part-time") label(3 "Was a student") label(4 "Did not work/study")) ///
				graphregion(color(white)) title("Proportion of Work/Study Status of Mothers (Preschool = 0)", size(medlarge))
graph export "${current}\..\..\output\image\bar_mompreschoolno.pdf", replace

restore
