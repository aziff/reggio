/* --------------------------------------------------------------------------- *
* Creating table for number respondents for each interviewer by city/cohort
* Authors: Sidharth Moktan
* Created: 04/27/2017
* Edited:  04/27/2017

* Note: This is supposed to accompany sensitivity analysis in appendix
* --------------------------------------------------------------------------- */
clear all

global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio

global here : pwd

use "${data_reggio}/Reggio_reassigned", replace

* Calculating N and preparing data to export to tex file
gen counter = 1
collapse (rawsum) counter, by(City internr)
decode City, gen(city)
drop City
reshape wide counter, i(internr) j(city) string
rename counterReggio Reggio
rename counterParma Parma
rename counterPadova Padova
order internr Reggio Parma Padova

egen Total = rowtotal(Reggio Parma Padova)

*Exporting to tex file
local N = _N
local N1 = round(`N'/2)			/* This helps split table into two adjacent blocks*/

file open writeTo using "${git_reggio}/output/numRespondents_byInterviewer.tex", write replace
	file write writeTo "\begin{tabular}{*{5}{c} C{.5cm} *{5}{c}} \\" _n
	file write writeTo "\cline{1-5} \cline{7-11} \\[-5pt]" _n
	file write writeTo " Interviewer & Reggio & Parma & Padova & Total && Interviewer & Reggio & Parma & Padova & Total \\" _n
	file write writeTo "\cline{1-5} \cline{7-11}" _n
	
	forvalues i = 1/`N1'{
		foreach var in internr Reggio Parma Padova Total{
			local `var'1 = `var'[`i']
			local `var'2 = `var'[`N1'+`i']
		}
		file write writeTo " `internr1' & `Reggio1' & `Parma1' & `Padova1' & `Total1' && `internr2' & `Reggio2' & `Parma2' & `Padova2' & `Total2' \\[3pt] "_n
	}
	
	file write writeTo "\hline" _n
	file write writeTo "\end{tabular}" _n

file close writeTo
