/* --------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - Step-Down for Children Cohort 
* Authors: Jessica Yu Kyung Koh
* Created: 06/16/2016
* Edited:  02/14/2017

* Note: This execution do file performs diff-in-diff estimates and generates tables
        by using "multipleanalysis" command that is programmed in 
		"reggio/script/ols/function/multipleanalysis.do"  
		To understand how the command is coded, please refer to the above do file.
* --------------------------------------------------------------------------- */

clear all

cap file 	close outcomes
cap log 	close

* Capture install commands 
cap which rwolf
if _rc ssc install rwolf
cap which psmatch2
if _rc ssc install psmatch2

global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio


global here : pwd

use "${data_reggio}/Reggio_reassigned"

* Include scripts and functions
include "${here}/../macros" 
include "${here}/function/sdreganalysis"
include "${here}/function/sdivanalysis"
include "${here}/function/sdaipwanalysis"
include "${here}/function/sdpsmanalysis"
include "${here}/function/sdkernelanalysis"
include "${here}/function/writematrix"
include "${here}/function/rwolfpsm"
include "${here}/function/rwolfaipw"
include "${here}/function/rwolfkernel"
include "${here}/function/rwolfiv"
include "${here}/../ipw/function/aipw"


* ---------------------------------------------------------------------------- *
* 								Preparation 								   *
* ---------------------------------------------------------------------------- *
** Preparation for IPW
drop if (ReggioAsilo == . | ReggioMaterna == .)

generate D = 0
replace  D = 1 			if (ReggioMaterna == 1)

generate D0 = (D == 0)
generate D1 = (D == 1)
generate D2 = (D == 2)

global bootstrap = 70
set seed 1234



**Manipulating instruments to prepare for ivregress**
*Reggio Score Instrument*
gen score25 = (score <= r(p25))
gen score50 = (score > r(p25) & score <= r(p50))
gen score75 = (score > r(p50) & score <= r(p75))

label var score25 "25th pct of RA admission score"
label var score50 "50th pct of RA admission score"
label var score75 "75th pct of RA admission score"

*Creating distance squared*
foreach st in Municipal Private Religious State{
	gen distMaterna`st'1_sq = distMaterna`st'1^2
}

*Cost Instrument* 
/* Decided not to use because we get very little 
variation in cost. Cost is designed to vary by parent's income, but
we don't have a complete income variable (missing data). Further, our 
cost data doesn't capture variation in cost by school, only by school-type

local maternaCost
foreach t in Muni /*Reli Stat*/{
	rename Fees_med_full_materna`t'_3 effective_medianFee_materna`t'
	local maternaCost `maternaCost' effective_medianFee_materna`t'
} 			/*_3, _2 and _1 correspond to ages 3, 2 and 1 respectively */

local asiloCost
foreach  t in Muni Reli{
	rename Fees_med_full_asilo`t'_1 effective_medianFee_asilo`t'
	local asiloCost `asiloCost' effective_medianFee_asilo`t'
} 			/*_3, _2 and _1 correspond to ages 3, 2 and 1 respectively */
*/


* ---------------------------------------------------------------------------- *
* 					Reggio Muni vs. None:	Children 						   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
preserve
keep if (Cohort == 3)  //| (Cohort == 2)  check if I need to include migrant cohort

local stype_switch = 1
foreach stype in Other {
	
	* Set necessary global variables
	global ivlist				IV
	global endog				maternaMuni
	global controlsIV			${bic_adol_baseline_vars}
	global ifconditionIV	 	(Reggio == 1) & (Cohort == 3)   & (maternaMuni == 1 | materna`stype' == 1)

	global IVinstruments		score ///
								distMaternaMunicipal1 distMaternaPrivate1 distMaternaReligious1 distMaternaState1 ///
								distMaternaMunicipal1_sq distMaternaPrivate1_sq distMaternaReligious1_sq distMaternaState1_sq
	
	
	foreach type in  M CN S H B {

		* ----------------------- *
		* For Regression Analysis *
		* ----------------------- *
		* Open necessary files
		file open iv_`type'_`stype' using "${git_reggio}/output/multiple-methods/stepdown/csv/iv_adol_`type'_`stype'_sd.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Children: Regression Analysis"
		sdivanalysis, stype("`stype'") type("`type'") ivlist("${ivlist}") cohort("adol")
	
		* Close necessary files
		file close iv_`type'_`stype' 
		
	
	
	}
	
	local stype_switch = 0
}

restore

