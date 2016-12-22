*-------------------------------------------------------------------------------
global klmReggio 	:	env klmReggio
global git_reggio	:	env git_reggio
global data_reggio	: 	env data_reggio
global output 		= 	"${git_reggio}/output"
*-------------------------------------------------------------------------------
cd ${klmReggio}/data_other/Demographics_data_working

import excel using "enrollment_vs_totalChildren.xlsx",clear firstrow
drop if enrolled_reggio==.			///Getting rid of source line

rename A vallabel
gen year = substr(vallabel,1,4)
destring year, force replace

order year vallabel
format vallabel %10s
sort year
labmask year, values(vallabel)

foreach c in Reggio Padova{
	local lowerC = lower("`c'")
	gen perc_enrolled_`lowerC' = enrolled_`lowerC'/total_`lowerC'
	
	twoway	line enrolled_`lowerC' year, yaxis(1) lcolor(gs7) lwidth(medthick) || ///
			line total_`lowerC' year, yaxis(1) lcolor(black) lwidth(medthick) || ///
			line perc_enrolled_`lowerC' year, yaxis(2) color(gs7) lcolor(black) lpattern(shortdash) ///
			xtitle("") ///
			legend(label(1 "Number Enrolled in Preschool") label(2 "Total Children 3-5") label(3 "Enrollment Rate") rows(3)) ///
			ylabel(0 5000 10000 15000, nogrid) yscale(titlegap(*15)) ytitle("Count") ///
			ylabel(0 0.5 1 1.5, axis(2)) ytitle("Proportion Enrolled", size(medium) axis(2)) yscale(titlegap(*15) axis(2)) ///
			graphregion(color(white))
			
graph export "${git_reggio}/output/image/enrollment_vs_totalChildren_`c'.eps", replace

}
