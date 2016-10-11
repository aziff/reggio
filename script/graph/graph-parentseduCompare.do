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

gen dadMoreEduc = (dadMaxEdu>momMaxEdu)
gen dadMoreEduc_HS = (dadMaxEdu>momMaxEdu & dadMaxEdu <= 3)
gen dadMoreEduc_Uni = (dadMaxEdu>momMaxEdu & dadMaxEdu == 4)
gen dadMoreEduc_Grad = (dadMaxEdu>momMaxEdu & dadMaxEdu > 4)


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


forvalues c = 4/6{
	if `c' == 4{
		local ylab_cond = ""
	}
	else {
		local ylab_cond = "yscale(off)"
	}
	graph bar (mean) /*dadMoreEduc*/ dadMoreEduc_HS dadMoreEduc_Uni dadMoreEduc_Grad if (Cohort == `c'), stack ///
					ytitle("Proportion of individuals with father more educated than mother") ///
					bar(1, color(gs3) lcolor(black)) bar(2, color(gs7) lcolor(black)) bar(3, color(white) lcolor(black)) ///
					over(City, relabel(1 "Reggio" 2 "Parma" 3 "Padova") label(angle(45))) ///
					legend(size(vsmall) cols(1) label(1 "dadEdu > momEdu | dadEdu = High School or less") label(2 "dadEdu > momEdu | dadEdu = University") label(3 "dadEdu > momEdu | dadEdu = Grad School or more")) ///
					graphregion(color(white)) ylabel(, nogrid) `ylab_cond' title(`Cohort`c'', size(large)) ///
					name(bar_cohort`c')
	window manage close graph
}

grc1leg 		bar_cohort4 bar_cohort5 bar_cohort6, ///
				ycommon xcommon rows(1) imargin(4 4 0 0) graphregion(color(white))
graph export "${current}\..\..\Output\image\bar_parentsEduCompare.eps", replace




