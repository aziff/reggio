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
cd "${klmReggio}/data_other/Demographics_data_working"

foreach vv in allAge demographic_balance economic_activity educational_attainment election{
	include "${klmReggio}/data_other/Demographics_data_working/Sidharth/script/`vv'"
	destring Reggio Parma Padova year, replace
	gen source = "`vv'"
	tempfile `vv'
	save ``vv''
}
clear
foreach x in allAge demographic_balance economic_activity educational_attainment election{
	append using ``x''
}

cd "${klmReggio}/data_other/Demographics_data_working/Sidharth/intermed_output"
saveold combined, replace
