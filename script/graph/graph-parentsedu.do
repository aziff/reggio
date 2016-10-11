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


* Locals for plotting
egen parentsMaxEdu = rowmax(momMaxEdu dadMaxEdu)

gen parentsMaxEdu_low = (parentsMaxEdu==1) if parentsMaxEdu<. 
gen parentsMaxEdu_middle = (parentsMaxEdu==2) if parentsMaxEdu<.  
gen parentsMaxEdu_HS = (parentsMaxEdu==3) if parentsMaxEdu<. 
gen parentsMaxEdu_Uni = (parentsMaxEdu>3) if parentsMaxEdu<. 

local momedu momMaxEdu_low momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni
local dadedu dadMaxEdu_low dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni
local parentsedu parentsMaxEdu_low parentsMaxEdu_middle parentsMaxEdu_HS parentsMaxEdu_Uni

* Plot bar graph for mothers and fathers
preserve
keep if Cohort == 4 | Cohort == 5 | Cohort == 6


local Cohort4 = "Adult 30"
local Cohort5 = "Adult 40"
local Cohort6 = "Adult 50"
local City1 = "Reggio"
local City2 = "Parma"
local City3 = "Padova"

foreach p in mom dad parents{
	forvalues k = 1/3{
		forvalues c = 4/6{
			if `c' == 4{
				local ylab_cond = ""
			}
			else {
				local ylab_cond = "yscale(off)"
			}
			graph bar (sum) ``p'edu' if ((City == `k') & (Cohort == `c') & (maternaType != 4)), ///
							over(maternaType, relabel(1 "N" 2 "M" 3 "S" 4 "R" /*5 "P"*/)) stack percentages ///
							bar(1, fcolor(gs2) lcolor(black)) bar(2, color(gs7) lcolor(black)) bar(3, color(gs10) lcolor(black)) bar(4, color(white) lcolor(black)) /// 
							legend(size(vsmall) rows(1) label(1 "Less than middle school") label(2 "Middle school") ///
							label(3 "High school") label(4 "University")) ///
							graphregion(color(white)) ylabel(, nogrid) `ylab_cond' title(`Cohort`c'', size(medium)) ///
							name(bar_`p'_city`k'_cohort`c')
			window manage close graph

		}
	}
}

foreach p in mom dad parents{
	forvalues k = 1/3{
		grc1leg 		bar_`p'_city`k'_cohort4 bar_`p'_city`k'_cohort5 bar_`p'_city`k'_cohort6, ///
						ycommon xcommon rows(1) imargin(0 4 0 0) graphregion(color(white)) title(`City`k'', size(medium)) ///
						name(combinedCohort_`p'_`k')
		window manage close graph

	}
}		

grc1leg 			combinedCohort_mom_1 combinedCohort_mom_2 combinedCohort_mom_3, ///
					ycommon xcommon rows(3) imargin(0 0 0 0) graphregion(color(white))
graph export "${current}\..\..\Output\image\bar_momEdu.eps", replace

grc1leg 			combinedCohort_dad_1 combinedCohort_dad_2 combinedCohort_dad_3, ///
					ycommon xcommon rows(3) imargin(0 0 0 0) graphregion(color(white))
graph export "${current}\..\..\Output\image\bar_dadEdu.eps", replace

grc1leg 			combinedCohort_parents_1 combinedCohort_parents_2 combinedCohort_parents_3, ///
					ycommon xcommon rows(3) imargin(0 0 0 0) graphregion(color(white))
graph export "${current}\..\..\Output\image\bar_parentsEdu.eps", replace
