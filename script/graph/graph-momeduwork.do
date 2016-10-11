* ---------------------------------------------------------------------------- *
* Drawing Density Plots for 
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
* Plot density functions
* ---------------------------------------------------------------------------- *
* Locals for plotting
local region				graphregion(color(white))

local xtitle				xtitle(Mother's Years of Education)
local ytitle				ytitle(Proportion of Working Mothers, height(5) color(navy))
local legend				legend(label(1 "Age-30 Cohort") label(2 "Age-40 Cohort") label(3 "Age-50 Cohort") size(small))

** Plot density for working mothers
twoway (kdensity momYearsEdu if ((momWork_fulltime06 == 1) | (momWork_parttime06 == 1)) & (Cohort == 4), `region' `xtitle' `ytitle' `legend' color(navy)) ///
		(kdensity momYearsEdu if ((momWork_fulltime06 == 1) | (momWork_parttime06 == 1)) & (Cohort == 5), color(maroon)) ///
		(kdensity momYearsEdu if ((momWork_fulltime06 == 1) | (momWork_parttime06 == 1)) & (Cohort == 6), color(green)) 
graph export "${current}\..\..\output\image\kdensity_momeduwork.eps", replace


** Plot histogram for working mothers
twoway (histogram momYearsEdu if ((momWork_fulltime06 == 1) | (momWork_parttime06 == 1)) & (Cohort == 4), `region' `xtitle' `ytitle' `legend' color(gs4)) ///
		(histogram momYearsEdu if ((momWork_fulltime06 == 1) | (momWork_parttime06 == 1)) & (Cohort == 5), fcolor(none) lcolor(black)) ///
		(histogram momYearsEdu if ((momWork_fulltime06 == 1) | (momWork_parttime06 == 1)) & (Cohort == 6), color(gs12)) 
graph export "${current}\..\..\output\image\histogram_momeduwork.eps", replace


* Plot bar graph for working mothers
preserve
keep if Cohort == 4 | Cohort == 5 | Cohort == 6

graph hbar (sum) momMaxEdu_low momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni if ((momWork_fulltime06 == 1) | (momWork_parttime06 == 1)), ///
				over(Cohort) stack  percentages bar(1, color(gs2)) bar(2, color(gs7)) bar(3, color(gs10)) bar(4, color(gs13)) /// 
				legend(size(small) label(1 "Less than middle school") label(2 "Middle school") label(3 "High school") label(4 "University")) ///
				graphregion(color(white))
graph export "${current}\..\..\output\image\bar_momeduwork.eps", replace

restore
