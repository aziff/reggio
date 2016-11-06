* ---------------------------------------------------------------------------- *
* Drawing Density Plots for 
* Authors: Sidharth Moktan
* Created: 10/07/2016
* Edited: 10/07/2016
* ---------------------------------------------------------------------------- *
clear all
set more off

global klmReggio	: 	env klmReggio		
global data_reggio	: 	env data_reggio

global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio

* ---------------------------------------------------------------------------- *
* Set directory
* ---------------------------------------------------------------------------- *
cd "${klmReggio}/data_other/Demographics_data_working/Sidharth/intermed_output"

foreach y in 1971 1981 2001 2011{
	if("`y'" == "1971") local cond
	if("`y'" != "1971") local cond yscale(off) 
	
	use combined, clear
	keep if source == "allAge" & Variable == "perc" & year == `y'
	replace Name = "<5" if Name == "until 5 years" | Name == "less than 5"
	replace Name = ">75" if Name == "75+"
	replace Name = subinstr(Name," years","",.)
		
	gen bin = _n
	labmask bin, values(Name)
	foreach city in Reggio Parma Padova{
		twoway bar `city' bin if year == `y', name(`city'_`y') `cond' title("`y'") color(gs10) lcolor(black) ///
		xlabel(1 8 16,  valuelabel noticks labsize(small) angle(25)) ytitle("") xtitle("") ylabel(, nogrid) ///
		graphregion(color(white))
		window manage close graph
	}
}
			
foreach city in Reggio Parma Padova{
graph combine `city'_1971 `city'_1981 `city'_2001 `city'_2011, rows(1) imargin (0 5 0 0) ///
	ycommon xcommon graphregion(color(white)) title("`city'") name(`city'1) 
	
	window manage close graph
}
graph combine Reggio1 Parma1 Padova1, rows(3) ycommon xcommon
graph export "${klmReggio}/data_other/Demographics_data_working/Sidharth/intermed_output/age.eps", replace
