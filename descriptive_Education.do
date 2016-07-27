* -------------------------------------------------------------------- *
* Tabulating Education Variables
* Author: Jessica Yu Kyung Koh
* Date: 2016/07/27
* -------------------------------------------------------------------- *
clear all

set more off
global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio // AZ: changed $git_reggio to point to GitHub repo

include "${git_reggio}/prepare-data"
include "${git_reggio}/baseline-rename"

set more off

svyset

tabout highschoolType City using "${git_reggio}/Output/check_variables/highschoolgrade.tex", replace ///
	c(mean votoMaturita se) f(2 2) sum svy npos(lab) lay(row) ///
	clab(_ (SE)) ///
	style(tex) bt cl1(2-4) font(bold) ///
	h3(& \multicolumn{3}{c}{Average highschool grade} \\) 

