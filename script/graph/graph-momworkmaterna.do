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
*********** Locals for plotting
local region				graphregion(color(white))
local xtitle				xtitle(Mother's Years of Education)
local ytitle				ytitle(Proportion of Working Mothers, height(5) color(navy))
local legend				legend(label(1 "Age-30 Cohort") label(2 "Age-40 Cohort") label(3 "Age-50 Cohort") size(small))

*********** Plot bar graphs for proportion of P = 1 for different work/study status of mothers
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

*********** Plot bar graphs for work/study status of mothers
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


*********** Plot who took care of children if mother is working full-time and the children did not attend preschool
graph hbar (sum) careNoAsiloMom careNoAsiloDad careNoAsiloGra careNoAsiloBsh careNoAsiloBso careNoAsiloBro careNoAsiloFam careNoAsiloOth if (momWork_fulltime06 == 1) & (materna == 0), ///
				over(Cohort) stack  bar(1, color(gs0)) bar(2, color(gs2)) bar(3, color(gs4)) bar(4, color(gs6)) percentages bar(5, color(gs8)) bar(6, color(gs10)) bar(7, color(gs12)) bar(8, color(gs14)) /// 
				legend(size(small) label(1 "Mother") label(2 "Father") label(3 "Grandparents") label(4 "Babysitter, home") ///
				label(5 "Babysitter, out-of-home") label(6 "Sibling") label(7 "Other family") label(8 "Other")) ///
				graphregion(color(white)) 
graph export "${current}\..\..\output\image\bar_caregiver_momft.pdf", replace


*********** Plot mean years of education by cohort, mother work status, preschool choice
collapse (mean) meanmomYearsEdu = momYearsEdu, by(momWork_Yes06 materna Cohort)

label define materna_lab 0 "Not attended" 1 "Attended"
label values materna materna_lab

graph bar meanmomYearsEdu, over(momWork_Yes06) over(materna, label(labsize(small))) over(Cohort) asyvars ///
		 bar(1, color(gs5)) bar(2, color(gs10)) ///
		 legend(size(small) label(1 "Did not work/study") label(2 "Worked/studied")) ///
		 ytitle("Mean Mother's Years of Education") graphregion(color(white))
graph export "${current}\..\..\output\image\bar_momyearsedu_mean.pdf", replace		

restore

*********** Plot density for working mothers
local xtitle				xtitle(Mother's Years of Education)
local ytitle				ytitle(Proportion, height(5) color(navy))
local legend				legend(label(1 "Work = 1, P = 1") label(2 "Work = 1, P = 0") label(3 "Work = 0, P = 1") label(4 "Work = 0, P = 0") size(small))

twoway (kdensity momYearsEdu if ((momWork_fulltime06 == 1) | (momWork_parttime06 == 1)) & (Cohort == 6) & (materna == 1), `region' `xtitle' `ytitle' `legend' color(gs3)) ///
		(kdensity momYearsEdu if ((momWork_fulltime06 == 1) | (momWork_parttime06 == 1)) & (Cohort == 6) & (materna == 0), color(gs10)) ///
		(kdensity momYearsEdu if ((momWork_fulltime06 == 0) & (momWork_parttime06 == 0)) & (Cohort == 6) & (materna == 1), color(purple)) ///
		(kdensity momYearsEdu if ((momWork_fulltime06 == 0) & (momWork_parttime06 == 0)) & (Cohort == 6) & (materna == 0), color(erose))
graph export "${current}\..\..\output\image\kdensity_momeduworkmaterna_age50.pdf", replace

twoway (kdensity momYearsEdu if ((momWork_fulltime06 == 1) | (momWork_parttime06 == 1)) & (Cohort == 5) & (materna == 1), `region' `xtitle' `ytitle' `legend' color(gs3)) ///
		(kdensity momYearsEdu if ((momWork_fulltime06 == 1) | (momWork_parttime06 == 1)) & (Cohort == 5) & (materna == 0), color(gs10)) ///
		(kdensity momYearsEdu if ((momWork_fulltime06 == 0) & (momWork_parttime06 == 0)) & (Cohort == 5) & (materna == 1), color(purple)) ///
		(kdensity momYearsEdu if ((momWork_fulltime06 == 0) & (momWork_parttime06 == 0)) & (Cohort == 5) & (materna == 0), color(erose))
graph export "${current}\..\..\output\image\kdensity_momeduworkmaterna_age40.pdf", replace

twoway (kdensity momYearsEdu if ((momWork_fulltime06 == 1) | (momWork_parttime06 == 1)) & (Cohort == 4) & (materna == 1), `region' `xtitle' `ytitle' `legend' color(gs3)) ///
		(kdensity momYearsEdu if ((momWork_fulltime06 == 1) | (momWork_parttime06 == 1)) & (Cohort == 4) & (materna == 0), color(gs10)) ///
		(kdensity momYearsEdu if ((momWork_fulltime06 == 0) & (momWork_parttime06 == 0)) & (Cohort == 4) & (materna == 1), color(purple)) ///
		(kdensity momYearsEdu if ((momWork_fulltime06 == 0) & (momWork_parttime06 == 0)) & (Cohort == 4) & (materna == 0), color(erose))
graph export "${current}\..\..\output\image\kdensity_momeduworkmaterna_age30.pdf", replace

		

