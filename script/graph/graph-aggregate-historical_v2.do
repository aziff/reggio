/*
Project:		Reggio Evaluation
Authors:		Anna Ziff
Date:			December 9, 2016

This file:		Graph historical survey results in an aggregate way
*/

// macros
global klmReggio 	:	env klmReggio
global git_reggio	:	env git_reggio
global data_reggio	: 	env data_reggio
global output 		= 	"${git_reggio}/output"

local Administrative_range 	S2:AB9
local Pedagogical_range		M8:V14


foreach cat in Administrative /*Pedagogical*/ {

	// bring in data
	cd "${klmReggio}/data_other/Historical_survey"
	import excel using "Reggio_HistoricalSurveyDATA_2016-12-16_az.xlsx", sheet("`cat'") cellrange(``cat'_range') clear firstrow

	// reformat data
	sxpose, clear force 

	if "`cat'" == "Administrative" {
		rename _var2 y1950
		rename _var3 y1960
		rename _var4 y1970
		rename _var5 y1980
		rename _var6 y1990
		rename _var7 y2000

		drop if _var1 == "."
		rename _var1 type
		drop y1950
	}
	else {
		rename _var2 y1960
		rename _var3 y1970
		rename _var4 y1980
		rename _var5 y1990
		rename _var6 y2000

		drop if _var1 == "."
		rename _var1 type
	}
	
	egen tmp_city = fill(1 1 1 2 2 2)
	gen city = ""
	replace city = "Reggio Emilia" 	if tmp_city == 1
	replace city = "Parma"			if tmp_city == 2
	replace city = "Padova"			if tmp_city == 3
	
	foreach var of varlist y* {
		destring(`var'), replace
	}

	drop if y1960 == .
	tempfile abc
	save `abc'
	* Reshape Data to Long*

	forvalues y=1960(10)2000{
		use `abc', clear
		keep type city y`y'
		rename y`y' counts
		gen y = `y'
		tempfile interm`y'
		save `interm`y''
	}
	clear all 
	forvalues y=1960(10)2000{
		append using `interm`y''
	}
	
	replace city = "Reggio" if city == "Reggio Emilia"
	sort city type y
	tempfile master
	save `master'

	// graph
	cd $output
	foreach c in Reggio Parma Padova{
		foreach t in Catholic-Private Municipal State{
			if ("`t'" == "Catholic-Private") local ty = 1
			if ("`t'" == "Municipal") local ty = 2
			if ("`t'" == "State") local ty = 3
			
			local cond off
			if ("`c'"=="Padova"&`ty'==1) local cond
			use `master', clear
			keep if city == "`c'" & type == "`t'"
			
			if _N>0{
				sort y
				gen vallabel = _n
				tostring y, replace force
				labmask vallabel, val(y)
				twoway (bar counts vallabel, barwidth(.8) base(0) lcolor(black)), ///
				xlabel(, valuelabel  noticks labsize(vlarge) angle(45)) xtitle("`t'", size(huge)) ///
				legend(off) ylabel(, nogrid) yscale(`cond' titlegap(*15)) ytitle("Characteristic Count", size(medium)) graphregion(color(white)) ///
				name(`c'`ty')
				
				twoway bar counts vallabel if city == "doesNotExist", xtitle("") ytitle("") yscale(off) xscale(off) fxsize(10) graphregion(color(white))name(blank, replace)
			}
				

		}
	}
	
	graph combine Padova1 Padova2 Padova3, title("Padova") fxsize(120) imargin(0 2 0 0) rows(1) ycommon graphregion(color(white)) name(Padova)
	graph combine blank Parma2 blank, title("Parma") fxsize(70) imargin(0 2 0 0) rows(1) ycommon graphregion(color(white)) name(Parma)
	graph combine Reggio2 Reggio3, title("Reggio Emilia") fxsize(110) imargin(0 2 0 0) rows(1) ycommon graphregion(color(white)) name(Reggio)
	
	graph combine Padova Parma Reggio,  rows(1) imargin(0 0 0 0) ysize(2) ycommon graphregion(color(white))
	
	graph export aggregate`cat'_v2.eps, replace
	
}

