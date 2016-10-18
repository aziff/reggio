/* --------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - OLS for Adult Cohorts
* Authors: Anna Ziff
* Created: 06/16/2016
* Edited:  08/24/2016

* Note: This execution do file performs diff-in-diff estimates and generates tables
        by using "olsestimate" command that is programmed in 
		"reggio/script/ols/function/olsestimate.do"  
		To understand how the command is coded, please refer to the above do file.
* --------------------------------------------------------------------------- */

clear all

cap file 	close outcomes
cap log 	close

global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio

global code = "${git_reggio}/script/linear-probability"

use "${data_reggio}/Reggio_prepared"

include "${code}/../macros" 

gen atleast1sibling = (numSibling_0 == 0)
gen more2sibling = (numSibling_2 == 1 | numSibling_more == 1)

local child_baseline_vars  	Male lowbirthweight birthpremature ///
								teenMomBirth momBornProvince ///
								momMaxEdu_low momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni  ///
								dadBornProvince ///
								dadMaxEdu_low dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni  ///
								more2sibling atleast1sibling cgCatholic int_cgCatFaith houseOwn cgMigrant ///
								cgFamIncome_val ///
								 momWork_fulltime06 momWork_parttime06 momSchool06 cgPolitics
								
local adol_baseline_vars  		Male lowbirthweight birthpremature ///
								teenMomBirth momBornProvince ///
								momMaxEdu_low momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni  ///
								dadBornProvince ///
								dadMaxEdu_low dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni  ///
								more2sibling atleast1sibling cgCatholic int_cgCatFaith cgMigrant ///
								momWork_fulltime06 momWork_parttime06 momSchool06 cgPolitics		 						
								
								
local adult_baseline_vars		Male ///
								momBornProvince ///
								momMaxEdu_low momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni  ///
								dadBornProvince  ///
								dadMaxEdu_low dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni  ///
								more2sibling atleast1sibling cgRelig ///
								momWork_fulltime06 momWork_parttime06 momSchool06
								
								
global Child_baseline_vars				`child_baseline_vars'							
global Migrant_baseline_vars			`child_baseline_vars' yrCity ageCity
global Adolescent_baseline_vars			`adol_baseline_vars'
global Adult30_baseline_vars 			`adult_baseline_vars'
global Adult40_baseline_vars 			`adult_baseline_vars'
global Adult50_baseline_vars		 	`adult_baseline_vars'
	
* ------------------ *
* Baseline variables *
* ------------------ *
// Preparation

** Gender condition
local p_con	
local m_con		& Male == 1
local f_con		& Male == 0

** Column names for final table
global maternaMuni_c		Muni.
global maternaNone_c		None
global maternaReli_c		Relig.
global maternaPriv_c		Priv.
global maternaStat_c		State
global maternaYes_c			Preschool
global Reggio_c				Reggio Emilia


global X					maternaMuni
global agelist				30 40
global controls				${adult_baseline_vars}
global usegroup				munivsnone
global munivsnone_note		people in Reggio who attended municipal preschools or none
global ifcondition30 		(Reggio == 1) & (Cohort_Adult30 == 1) & (maternaMuni == 1 | maternaNone == 1)
global ifcondition40 		(Reggio == 1) & (Cohort_Adult40 == 1) & (maternaMuni == 1 | maternaNone == 1)

** Create outcome variables
foreach age in asilo materna {
	gen `age'TNone 	= (`age'Type == 0)
	gen `age'TMuni 	= (`age'Type == 1)
	gen `age'TStat 	= (`age'Type == 2)
	gen `age'TReli 	= (`age'Type == 3)
	// note: not doing private because of low N
}

// combine children and adolescents
gen migrant = (Cohort == 2)
replace Cohort = 1 if Cohort == 2

replace asilo 		= (asilo == 1)
gen both_asil_mat 	= (asilo == 1 & materna == 1)

local cohort_val = 1
foreach cohort in Child Migrant Adolescent Adult30 Adult40 Adult50 {
	local city_val = 1
	foreach city in Reggio Parma Padova {

		global controls ${`cohort'_baseline_vars} migrant

		
		reg materna $controls if Cohort == `cohort_val' & City == `city_val'
		est store `cohort'`city'materna
		
		reg both_asil_mat $controls if Cohort == `cohort_val' & City == `city_val'
		est store `cohort'`city'both
		
		local city_val = `city_val' + 1
	}
	
	local cohort_val = `cohort_val' + 1
}
estimates dir
#delimit
	outreg2 
	[ChildrenReggiomaterna 
	AdolescentReggiomaterna
	Adult30Reggiomaterna
	Adult40Reggiomaterna
	Adult50Reggiomaterna] 
	using "${output}/test.tex", 
	replace tex(frag) 
	alpha(.01, .05, .10) sym (***, **, *) dec(5) par(se) r2
	ti(Linear Probability Model);
#delimit cr

