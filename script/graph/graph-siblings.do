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

*********** Plot density for number of sibling
local xtitle		xtitle(Number of Siblings)
local ytitle		ytitle(Proportion, height(5) color(navy))
local legend		legend(label(1 "Work = 1, P = 1") label(2 "Work = 1, P = 0") label(3 "Work = 0, P = 1") label(4 "Work = 0, P = 0") size(small))

local age_4			30
local age_5			40
local age_6			50

foreach cohort in 4 5 6 {
	twoway (kdensity numSiblings if ((momWork_fulltime06 == 1) | (momWork_parttime06 == 1)) & (Cohort == `cohort') & (materna == 1), `region' `xtitle' `ytitle' `legend' color(gs3)) ///
			(kdensity numSiblings if ((momWork_fulltime06 == 1) | (momWork_parttime06 == 1)) & (Cohort == `cohort') & (materna == 0), color(gs10)) ///
			(kdensity numSiblings if ((momWork_fulltime06 == 0) & (momWork_parttime06 == 0)) & (Cohort == `cohort') & (materna == 1), color(purple)) ///
			(kdensity numSiblings if ((momWork_fulltime06 == 0) & (momWork_parttime06 == 0)) & (Cohort == `cohort') & (materna == 0), color(erose))
	graph export "${current}\..\..\output\image\kdensity_numsibling_age`age_`cohort''.eps", replace
}

