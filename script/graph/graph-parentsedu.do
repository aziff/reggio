* ---------------------------------------------------------------------------- *
* Drawing Density Plots for 
* Authors: Jessica Yu Kyung Koh, Sidharth Moktan
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
* Plot density functions
* ---------------------------------------------------------------------------- *
* Locals for plotting
local momedu momMaxEdu_low momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni
local dadedu dadMaxEdu_low dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni


* Plot bar graph for working mothers
preserve
keep if Cohort == 4 | Cohort == 5 | Cohort == 6


local Cohort4 = "Adult 30"
local Cohort5 = "Adult 40"
local Cohort6 = "Adult 50"
local City1 = "Reggio"
local City2 = "Parma"
local City3 = "Padova"

foreach p in mom dad{
	forvalues k = 1/3{
		forvalues c = 4/6{
			if `c' == 4{
				local ylab_cond = ""
			}
			else {
				local ylab_cond = "yscale(off)"
			}
			graph bar (sum) ``p'edu' if ((City == `k') & (Cohort == `c')), ///
							over(maternaType, relabel(1 "N" 2 "M" 3 "S" 4 "R" 5 "P")) stack percentages ///
							bar(1, color(gs2)) bar(2, color(gs7)) bar(3, color(gs10)) bar(4, color(gs13)) /// 
							legend(size(vsmall) rows(1) label(1 "Less than middle school") label(2 "Middle school") ///
							label(3 "High school") label(4 "University")) ///
							graphregion(color(white)) ylabel(, nogrid) `ylab_cond' title(`Cohort`c'', size(medium)) ///
							saving("support\bar_`p'_city`k'_cohort`c'.gph", replace)
		}
	}
}

cd support

foreach p in mom dad{
	forvalues k = 1/3{
		grc1leg 		bar_`p'_city`k'_cohort4.gph bar_`p'_city`k'_cohort5.gph bar_`p'_city`k'_cohort6.gph, ///
						ycommon xcommon rows(1) imargin(0 4 0 0) graphregion(color(white)) title(`City`k'', size(medium)) ///
						saving("combinedCohort_`p'_`k'.gph", replace)
	}
}		

grc1leg 			combinedCohort_mom_1.gph combinedCohort_mom_2.gph combinedCohort_mom_3.gph, ///
					ycommon xcommon rows(3) imargin(0 0 0 0) graphregion(color(white))
graph export "${current}\..\..\Output\image\bar_momWork.pdf", replace

grc1leg 			combinedCohort_dad_1.gph combinedCohort_dad_2.gph combinedCohort_dad_3.gph, ///
					ycommon xcommon rows(3) imargin(0 0 0 0) graphregion(color(white))
graph export "${current}\..\..\Output\image\bar_dadWork.pdf", replace
