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
graph export "${current}\..\..\output\image\kdensity_momeduwork.pdf", replace

