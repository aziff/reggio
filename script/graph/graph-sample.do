/*
Project:		Reggio Evaluation
Author:			Anna Ziff
Date:			10/10/16
File:			Graph response rate and visually show sample size
*/

// macros
global klmReggio 	: env klmReggio
global git_reggio 	: env git_reggio
global output		= "${git_reggio}/writeup/draft/output"
global data			= "${klmReggio}/SURVEY_DATA_COLLECTION/data"

cd $data
use Reggio, clear

gen muni = (maternaType == 1)

collapse (count) intnr, by(City Cohort muni)

sort City Cohort
by City Cohort: egen totnum = sum(intnr)

gen ref0 = 0
gen REcohort = Cohort
gen PRcohort = Cohort + 7
gen PDcohort = PRcohort + 7

// graph options
local region		graphregion(color(white))
local yaxis			ytitle(Count) ytick(0(50)300) ylabel(0(50)300,glcolor(gs10) glwidth(vthin) angle(0))
local noyaxis		ylabel(0(50)300,glcolor(gs10) glwidth(vthin) noticks nolabels) ytitle("")
local xaxis			xlabel(1 "Children" 2 "Migrants" 3 "Adolescents" 4 "Adults 30s" 5 "Adults 40s" 6 "Adults 50s", angle(45)) xtitle("")
local legend		legend(off)
local REbarlook		fcolor(white) lcolor(black) lwidth(thin) barw(0.8)
local PRbarlook		color(gs3) lcolor(black) barw(0.8)
local PDbarlook		color(gs8) lcolor(black) barw(0.8)
local REMunibarlook color(black) lcolor(black) barw(0.8)
local addtext		text(3 325 "Reggio Emilia")

#delimit ;
twoway (rbar ref0 totnum Cohort if City ==  1, `REbarlook')
		(rbar ref0 intnr Cohort if City == 1 & muni == 1, `REMunibarlook'), 
				`legend' 
				`yaxis'
				`xaxis'
				`region'
				title(Reggio Emilia, color(black) size(medium))
				name(RE, replace);
		
twoway (rbar ref0 totnum Cohort if City ==  2, `PRbarlook'),
				`legend' 
				`noyaxis'
				`xaxis'
				`region'
				title(Parma, color(black) size(medium))
				name(PR, replace); 
				
twoway (rbar ref0 totnum Cohort if City ==  3, `PDbarlook'),
				`legend' 
				`noyaxis'
				`xaxis'
				`region'
				title(Padova, color(black) size(medium))
				name(PD, replace);

graph combine RE PR PD, graphregion(color(white)) rows(1) ycommon;

#delimit cr

cd $output
graph export "sample.eps", replace
