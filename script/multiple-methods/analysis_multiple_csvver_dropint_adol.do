/* --------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - OLS and Diff-in-Diff for Adult Cohorts
* Authors: Jessica Yu Kyung Koh
* Created: 06/16/2016
* Edited:  12/12/2016

* Note: This execution do file performs diff-in-diff estimates and generates tables
        by using "multipleanalysis" command that is programmed in 
		"reggio/script/ols/function/multipleanalysis.do"  
		To understand how the command is coded, please refer to the above do file.
* --------------------------------------------------------------------------- */

clear all

cap file 	close outcomes
cap log 	close


global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio


global here : pwd

use "${data_reggio}/Reggio_reassigned"

* Include scripts and functions
include "${here}/../macros" 
include "${here}/function/reganalysis"
include "${here}/function/aipwanalysis"
include "${here}/function/writematrix"
include "${here}/../ipw/function/aipw"


* ---------------------------------------------------------------------------- *
* 								Preparation 								   *
* ---------------------------------------------------------------------------- *
** Gender condition
local p_con	
local m_con		& Male == 1
local f_con		& Male == 0

** Column names for final table
global maternaMuni30_c			Muni_Age30
global maternaMuni40_c			Muni_Age40
global xmMuniAdult30did_c		DiD
global maternaMuniParma30_c		Parma30
global maternaMuniParma40_c		Parma40
global maternaMuniPadova30_c	Padova30
global maternaMuniPadova40_c	Padova40


** Preparation for IPW
drop if (ReggioAsilo == . | ReggioMaterna == .)

generate D = 0
replace  D = 1 			if (ReggioMaterna == 1)

generate D0 = (D == 0)
generate D1 = (D == 1)
generate D2 = (D == 2)

global bootstrap = 70
set seed 1234

* ANALYSIS
local child_cohorts		Child Migrant
local adol_cohorts		Adolescent
local adult_cohorts		Adult30 Adult40 Adult50

local nido_var			ReggioAsilo
local materna_var		ReggioMaterna

local Child_num 		= 1
local Migrant_num 		= 2
local Adolescent_num 	= 3
local Adult30_num 		= 4
local Adult40_num 		= 5
local Adult50_num 		= 6



* Drop questionnable interviewer
drop if internr == 170 | internr == 171 | internr == 172 | internr == 4018 | internr == 4073
drop if flagType_Linor == "1"


* ---------------------------------------------------------------------------- *
* 					Reggio Muni vs. None:	Adolescent						   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
preserve
keep if (Cohort == 3)

local stype_switch = 1
foreach stype in Other /*Reli*/ {
	
	* Set necessary global variables
	global X					maternaMuni
	global reglist				None BIC Full DidPm DidPv // It => Italians, Mg => Migrants
	global aipwlist				AIPW
	global psmlist				PSM

	global XNone				maternaMuni		
	global XBIC					maternaMuni		
	global XFull				maternaMuni		
	global XPSM					maternaMuni
	global XDidPm				xmMuniReggio maternaMuni Reggio 
	global XDidPv				xmMuniReggio maternaMuni Reggio 

	global controlsNone
	global controlsBIC			${bic_adol_baseline_vars}
	global controlsFull			${adol_baseline_vars}
	global controlsPSM			${bic_adol_baseline_vars}
	global controlsDidPm		${bic_adol_baseline_vars}
	global controlsDidPv		${bic_adol_baseline_vars}

	global ifconditionNone 		(Reggio == 1) & (Cohort == 3)   & (maternaMuni == 1 | materna`stype' == 1)
	global ifconditionBIC		${ifconditionNone}
	global ifconditionFull		${ifconditionNone}
	global ifconditionPSM		${ifconditionNone}
	global ifconditionDidPm		(Reggio == 1 | Parma == 1) & (Cohort == 3)   & (maternaMuni == 1 | materna`stype' == 1)
	global ifconditionDidPv		(Reggio == 1 | Padova == 1) & (Cohort == 3)   & (maternaMuni == 1 | materna`stype' == 1)
	global ifconditionAIPW 	    (Reggio == 1) & (Cohort == 3)   & (maternaMuni == 1 | materna`stype' == 1)

	
	
	foreach type in  M {

		* ----------------------- *
		* For Regression Analysis *
		* ----------------------- *
		* Open necessary files
		cap file close regression_`type'_`stype'
		file open regression_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/reg_adol_`type'_`stype'_drop.csv", write replace

		* Run Multiple Analysis
		di "Estimating `type' for Children: Regression Analysis"
		reganalysis, stype("`stype'") type("`type'") reglist("${reglist}") cohort("adol")
	
		* Close necessary files
		file close regression_`type'_`stype' 
		
		
	}
	
	local stype_switch = 0
}

restore

