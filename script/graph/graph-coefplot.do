/* --------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - OLS and Diff-in-Diff for Adult Cohorts
* Authors: Jessica Yu Kyung Koh
* Created: 06/16/2016
* Edited:  10/31/2016

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

use "${data_reggio}/Reggio_prepared"

* Include scripts and functions
include "${here}/../macros" 
include "${here}/../psm/function/psmweight"

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


** Preparation for PSM
drop if(ReggioAsilo == . | ReggioMaterna == .)

gen sample1 			= (Reggio == 1)
gen sample_materna2 	= ((Reggio == 1 & ReggioMaterna == 1) 	| (Parma == 1) | (Padova == 1))
gen sample3 			= (Reggio == 1 	| Parma == 1)
gen sample4 			= (Reggio == 1 	| Padova == 1)


				
* ANALYSIS
local adult_cohorts		Adult30 Adult40 Adult50

local nido_var			ReggioAsilo
local materna_var		ReggioMaterna

local Adult30_num 		= 4
local Adult40_num 		= 5
local Adult50_num 		= 6

* Generate maternaMuni for the purpose of DID
generate maternaMuniDid = maternaMuni
	
* Coef
* Cognitive skills and education
global adult_outcome_E					IQ_factor votoMaturita votoUni ///
										highschoolGrad MaxEdu_Uni 

* Employment										
global adult_outcome_W					PA_Empl SES_self HrsTot WageMonth ///
										Reddito_1 Reddito_2 Reddito_3 Reddito_4 Reddito_5 

* Living status										
global adult_outcome_L					mStatus_married_cohab mStatus_div childrenResp all_houseOwn live_parent

* Health									
global adult_outcome_H					Maria /*Smoke*/ Cig BMI BMI_obese BMI_overweight goodHealth HCondition9 SickDays ///
										/*i_RiskFight i_RiskDUI*/ RiskSuspended Drink1Age							

* Noncognitive										
global adult_outcome_N					pos_LocusControl pos_Depression_score Stress StressWork ///
										SatisIncome SatisWork SatisHealth SatisFamily ///
										optimist reciprocity1 reciprocity2 reciprocity3 reciprocity4	

* Social										
global adult_outcome_S					MigrTaste Friends MigrFriend volunteer invFamMeal invFamMeal ///
										votedMunicipal votedRegional votedNational

* Religion
global adult_outcome_R					Faith
	
	

* ---------------------------------------------------------------------------- *
* 					Reggio Muni vs. All:	Adults		 					   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
preserve
keep if (Cohort == 4) | (Cohort == 5) | (Cohort == 6)
drop if asilo == 1 // dropping those who went to infant-toddler centers

* Set necessary global variables
global comparisonlist		None30 BIC30 Full30 DidPm30 DidPv30 PSM30 None40 BIC40 Full40 DidPm40 DidPv40 PSM40

global XNone30				maternaMuni		
global XBIC30				maternaMuni		
global XFull30				maternaMuni		
global XDidPm30				maternaMuniDid	Reggio xmMuniReggio	
global XDidPv30				maternaMuniDid	Reggio xmMuniReggio	
global XPSM30				ReggioMaterna materna

global XNone40				maternaMuni		
global XBIC40				maternaMuni		
global XFull40				maternaMuni		
global XDidPm40				maternaMuniDid	Reggio xmMuniReggio	
global XDidPv40				maternaMuniDid	Reggio xmMuniReggio	
global XPSM40				ReggioMaterna materna

global keepNone30			maternaMuni
global keepBIC30			maternaMuni
global keepFull30			maternaMuni
global keepPSM30			ReggioMaterna
global keepNone40			maternaMuni
global keepBIC40			maternaMuni
global keepFull40			maternaMuni
global keepPSM40			ReggioMaterna

global keepDidPm30			xmMuniReggio
global keepDidPv30			xmMuniReggio
global keepDidPm40			xmMuniReggio
global keepDidPv40			xmMuniReggio
	
global usegroup				munivsother

global controlsNone30
global controlsNone40
global controlsBIC30		${bic_adult_baseline_vars}
global controlsBIC40		${bic_adult_baseline_vars}
global controlsFull30		${adult_baseline_vars}
global controlsFull40		${adult_baseline_vars}
global controlsDidPm30		${bic_adult_baseline_vars}
global controlsDidPm40		${bic_adult_baseline_vars}
global controlsDidPv30		${bic_adult_baseline_vars}
global controlsDidPv40		${bic_adult_baseline_vars}
global controlsPSM30		${bic_adult_baseline_vars} [pweight = weight_Cohort4]
global controlsPSM40		${bic_adult_baseline_vars} [pweight = weight_Cohort5]

global ifconditionNone30 	(Reggio == 1) & (Cohort_Adult30 == 1) 
global ifconditionBIC30		${ifconditionNone30}
global ifconditionFull30	${ifconditionNone30}
global ifconditionDidPm30	(Reggio == 1 | Parma == 1) & (Cohort_Adult30 == 1) 
global ifconditionDidPv30	(Reggio == 1 | Padova == 1) & (Cohort_Adult30 == 1) 
global ifconditionPSM30		(sample_materna2 == 1 & Cohort == 4)

global ifconditionNone40 	(Reggio == 1) & (Cohort_Adult40 == 1) 
global ifconditionBIC40		${ifconditionNone40}
global ifconditionFull40	${ifconditionNone40}
global ifconditionDidPm40	(Reggio == 1 | Parma == 1) & (Cohort_Adult40 == 1) 
global ifconditionDidPv40	(Reggio == 1 | Padova == 1) & (Cohort_Adult40 == 1) 
global ifconditionPSM40		(sample_materna2 == 1 & Cohort == 5)


* Label to properly show them on the plots
label var xmMuniReggio "DiD Estimate"
label var ReggioMaterna "PSM Estimate"
label var maternaMuni "OLS Estimate"

* Now draw coefplots
foreach type in E W L H N S R {
	
	* Compute PSM Weight
	psmweight, yvar("ReggioMaterna") xvars(${adult_baseline_vars}) cohort_num(4) school_type("materna") // For age-30 cohort
	psmweight, yvar("ReggioMaterna") xvars(${adult_baseline_vars}) cohort_num(5) school_type("materna") // For age-40 cohort

	* Run Multiple Analysis
	foreach var in ${adult_outcome_`type'} {
		foreach i in ${comparisonlist} {
			eststo coef`i' : reg `var' ${X`i'} ${controls`i'} if ${ifcondition`i'}, robust

		}
		di "plotting for `var'"
		coefplot (coefBIC30, label(BIC controls, Age-30)) (coefBIC40, label(BIC controls, Age-40) msymbol(diamond))  ///
		         (coefFull30, label(Full controls, Age-30)) (coefFull40, label(Full controls, Age-40) msymbol(diamond)) ///
				 (coefDidPm30, label(DiD with Parma, Age-30)) (coefDidPm40, label(DiD with Parma, Age-40) msymbol(diamond)) (coefDidPv30, label(DiD with Padova, Age-30)) (coefDidPv40, label(DiD with Padova, Age-40) msymbol(diamond)) ///
				 (coefPSM30, label(PSM, Age-30)) (coefPSM40, label(PSM, Age-40) msymbol(diamond)), keep(maternaMuni ReggioMaterna xmMuniReggio) xtitle(``var'_lab') xline(0) graphregion(color(white)) weight(1/@se)
		graph export "${current}\..\output\image\coefplot-`var'-adult.eps", replace		 
	}
}
restore

