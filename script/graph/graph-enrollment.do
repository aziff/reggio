* -------------------------------------------------- *
* Graphing Enrollment Data Across Cities
* Jessica Yu Kyung Koh
* Date: 01/13/2017
* -------------------------------------------------- *

clear all

set more off
global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio // AZ: changed $git_reggio to point to GitHub repo
global current	   : pwd

import excel using "${git_reggio}/data/enrollment-data/Preschool_enroll.xlsx", firstrow

* Clean
destring enroll_num_Parma, replace
destring enroll_per_Parma, replace
destring Municipal_Parma, replace
destring State_Parma, replace
destring Private_Parma, replace

* Set macros for graphs
local region				graphregion(color(white))
local xtitle				xtitle(Year)
local ytitle1				ytitle(Count)
local ytilte2				ytitle(Percentage (%))
local legend				legend(label(1 "Reggio") label(2 "Padova") label(3 "Parma"))


* Graphing Num of students enrolled
twoway (line enroll_num_Reggio Year, `region' `xtitle' `ytitle1' `legend' lcolor(gs3)) ///
			(line enroll_num_Padova Year, lcolor(gs3) lpattern(dash)) ///
			(dot enroll_num_Parma Year) 
			
graph export using "${current}/../../output/image/enroll_num_graph.eps", replace
		
* Graphing percentage of 3-5 enrolled
twoway (line enroll_per_Reggio Year, `region' `xtitle' `ytitle2' `legend' lcolor(gs3)) ///
			(line enroll_per_Padova Year, lcolor(gs3) lpattern(dash)) ///
			(dot enroll_per_Parma Year) 
			
graph export using "${current}/../../output/image/enroll_per_graph.eps", replace

* Graphing percentage of kids enrolled in municipal preschools
twoway (line Municipal_Reggio Year, `region' `xtitle' `ytitle2' `legend' lcolor(gs3)) ///
			(line Municipal_Padova Year, lcolor(gs3) lpattern(dash)) ///
			(dot Municipal_Parma Year) 
			
graph export using "${current}/../../output/image/enroll_per_muni_graph.eps", replace

* Graphing percentage of kids enrolled in state preschools
twoway (line State_Reggio Year, `region' `xtitle' `ytitle2' `legend' lcolor(gs3)) ///
			(line State_Padova Year, lcolor(gs3) lpattern(dash)) ///
			(dot State_Parma Year) 
			
graph export using "${current}/../../output/image/enroll_per_state_graph.eps", replace

* Graphing percentage of kids enrolled in private preschools
twoway (line Private_Reggio Year, `region' `xtitle' `ytitle2' `legend' lcolor(gs3)) ///
			(line Private_Padova Year, lcolor(gs3) lpattern(dash)) ///
			(dot Private_Parma Year) 
			
graph export using "${current}/../../output/image/enroll_per_priv_graph.eps", replace
