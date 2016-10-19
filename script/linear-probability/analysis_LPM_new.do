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
global data_reggio = "/mnt/ide0/share/klmReggio/SURVEY_DATA_COLLECTION/data"
global git_reggio  = "/mnt/ide0/home/aziff/projects/reggio"

global code = 	"${git_reggio}/script/linear-probability"
global outputLPM = "/mnt/ide0/home/aziff/projects/reggio/Output/"
use "${data_reggio}/Reggio_prepared"

include "${code}/../macros" 

// transform some variables into binary
gen atleast1sibling = (numSibling_0 == 0)
gen atleast2sibling = (numSibling_2 == 1 | numSibling_more == 1)
sum cgFamIncome_val, detail
gen FamIncome_med = (cgFamIncome_val > r(p50))
sum cgPolitics, detail
gen cgPolitics_med = (cgPolitics > r(p50))

local keepvars			momWork_fulltime06 momWork_parttime06 ///
				momBornProvince ///
				momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni  ///
				dadBornProvince ///
				dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni  ///
				atleast2sibling atleast1sibling Male ///
				FamIncome_med ///
				cgRelig int_cgCatFaith ///
				cgPolitics_med lowbirthweight birthpremature migrant


local child_baseline_vars  	momWork_fulltime06 momWork_parttime06 ///
				atleast2sibling atleast1sibling ///
				momBornProvince ///
				momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni  ///
				dadBornProvince ///
				dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni  ///
				FamIncome_med int_cgCatFaith cgMigrant cgPolitics_med ///
				lowbirthweight birthpremature migrant
				
								
local adol_baseline_vars  	momWork_fulltime06 momWork_parttime06  ///
				atleast2sibling atleast1sibling ///
				momBornProvince ///
				momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni  ///
				dadBornProvince ///
				dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni  ///
				FamIncome_med int_cgCatFaith cgMigrant cgPolitics_med ///
				lowbirthweight birthpremature  						
								
								
local adult_baseline_vars	momWork_fulltime06 momWork_parttime06 ///
				atleast2sibling atleast1sibling ///
				momBornProvince ///
				momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni  ///
				dadBornProvince  ///
				dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni  ///
				cgRelig 
					
								
								
global Child_baseline_vars			`child_baseline_vars'							
global Migrant_baseline_vars			`child_baseline_vars' yrCity ageCity
global Adolescent_baseline_vars			`adol_baseline_vars'
global Adult30_baseline_vars 			`adult_baseline_vars'
global Adult40_baseline_vars 			`adult_baseline_vars'
global Adult50_baseline_vars		 	`adult_baseline_vars'

global atleast2sibling_lab 			Two Siblings or More
global atleast1sibling_lab 			One Sibling or More
global cgCatholic_lab 				Caregiver is Catholic
global int_cgCatFaith_lab			Caregiver is Catholic and Pious
global houseOwn_lab 				Owns Home
global cgMigrant_lab 				Caregiver is a Migrant
global momWork_fulltime06_lab 			Mother Worked Full Time when 6
global momWork_parttime06_lab			Mother Worked Part Time when 6
global lowbirthweight_lab			Low Birthweight
global birthpremature_lab			Premature Birth
global teenMomBirth_lab				Child of Teenage Mother
global momBornProvince_lab			Mother Born in Province
global momMaxEdu_middle_lab			Mother Max. Edu.: Middle Sch.
global momMaxEdu_HS_lab				Mother Max. Edu.: High Sch.
global momMaxEdu_Uni_lab			Mother Max. Edu.: University
global dadBornProvince_lab			Father Born in Province
global dadMaxEdu_middle_lab			Father Max. Edu.: Middle Sch.	
global dadMaxEdu_HS_lab				Father Max. Edu.: High Sch.
global dadMaxEdu_Uni_lab			Father Max. Edu.: University
global cgPolitics_med_lab			Caregiver Politics: Right of the Median
global FamIncome_med_lab			H. Income Above Median
global cgRelig_lab				Caregiver is Religious
global migrant					Non-Italian Child

foreach a in child adol adult {
	foreach v in ``a'_baseline_vars'{
		label var `v' "${`v'_lab}"
		di "${`v'_lab}"
	}
}
	
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

lab var materna Preschool
lab var both_asil_mat Both

local city_val = 1
foreach  city in Reggio Parma Padova {

	local cohort_val = 1
	foreach cohort in Child Migrant Adolescent Adult30 Adult40 Adult50 {
	
		tab Cohort if Cohort == `cohort_val'
		if r(N) > 0 {

			global controls ${`cohort'_baseline_vars} migrant
			di "city: `city'; cohort:`cohort'"
		
			reg materna $controls if Cohort == `cohort_val' & City == `city_val'
			est store `cohort'`city'materna
		
			reg both_asil_mat $controls if Cohort == `cohort_val' & City == `city_val'
			est store `cohort'`city'both
		}
		
		local cohort_val = `cohort_val' + 1
	}
	
	
	
	estimates dir

	cd $outputLPM
	#delimit ;
		outreg2 [Child`city'materna Child`city'both 
		Adolescent`city'materna Adolescent`city'both 
		Adult30`city'materna  Adult30`city'both
		Adult40`city'materna  Adult40`city'both
		Adult50`city'materna  Adult50`city'both] 
		using "LPM_materna_both_`city'.tex", 
		replace tex(frag) 
		alpha(.01, .05, .10) sym (***, **, *) dec(3) par(se) r2
		label keep(`keepvars');
	#delimit cr
	
	local city_val = `city_val' + 1
}



