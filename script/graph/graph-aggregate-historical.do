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


foreach cat in Administrative Pedagogical {

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

	// graph
	cd $output
	# delimit ;
		graph bar y1960 y1970 y1980 y1990 y2000, 
			over(type, label(labsize(small))) 
			over(city) 
			nofill
			graphregion(color(white))
			legend(rows(1) label(1 1960) label(2 1970) label(3 1980) label(4 1990) label(5 2000));
	# delimit cr

	graph export aggregate`cat'.eps, replace

}
