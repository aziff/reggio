/* --------------------------------------------------------------------------- *
* Project:	Reggio Evaluation
* Authors: 	Anna Ziff
* Created: 	10/16/2016
* This file:	Estimate basic LPM for selection into preschool or both by 
			city and cohort
* --------------------------------------------------------------------------- */
clear all

global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio
global data_reggio = "/mnt/ide0/share/klmReggio/data_survey/data"
global git_reggio  = "/mnt/ide0/home/aziff/projects/reggio"

global code 	 = "${git_reggio}/script/linear-probability"
global outputLPM = "${git_reggio}/Output/"

use "${data_reggio}/Reggio_prepared"
include "${code}/../macros" 

// combine children and adolescents
gen migrant = (Cohort == 2)
replace Cohort = 1 if Cohort == 2

// transform some variables into binary
gen atleast1sibling = (numSibling_0 == 0)
gen atleast2sibling = (numSibling_2 == 1 | numSibling_more == 1)
sum cgFamIncome_val, detail
gen FamIncome_med = (cgFamIncome_val > r(p50))
sum cgPolitics, detail
gen cgPolitics_med = (cgPolitics > r(p50))

// distance variable
foreach g in Asilo Materna {
	gen dist`g'Closest = .
	replace dist`g'Closest = distAsiloMunicipal1
	
	foreach t in Private Religious State {
		cap replace dist`g'Closest = dist`g'`t'1 if dist`g'`t'1 < dist`g'Closest
	}
	
	gen dist`g'Closest_med = .
	
	forvalues c = 1/3 {
		sum dist`g'Closest if City == `c', detail
		replace dist`g'Closest_med = (dist`g'Closest < r(p50)) if City == `c'
	}
}

// variables to consider
local keepvars			momBornProvince ///
				momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni  ///
				dadBornProvince ///
				dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni  ///
				atleast2sibling atleast1sibling Male ///
				FamIncome_med ///
				cgRelig int_cgCatFaith ///
				cgPolitics_med lowbirthweight birthpremature migrant


local child_baseline_vars  	atleast1sibling atleast2sibling ///
				momBornProvince ///
				momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni  ///
				dadBornProvince ///
				dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni  ///
				cgRelig ///
				FamIncome_med cgPolitics_med cgMigrant  ///
				migrant lowbirthweight birthpremature 
				
								
local adol_baseline_vars  	atleast1sibling atleast2sibling ///
				momBornProvince ///
				momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni  ///
				dadBornProvince ///
				dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni  ///
				cgRelig ///
				FamIncome_med cgPolitics_med cgMigrant ///
				lowbirthweight birthpremature  						
								
								
local adult_baseline_vars	atleast1sibling atleast2sibling ///
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
global cgRelig_lab					Caregiver is Religious
global migrant_lab					Non-Italian Child

foreach a in child adol adult {
	foreach v in ``a'_baseline_vars'{
		label var `v' "${`v'_lab}"
		di "${`v'_lab}"
	}
}

// create outcome variables
foreach age in asilo materna {
	gen `age'TNone 	= (`age'Type == 0)
	gen `age'TMuni 	= (`age'Type == 1)
	gen `age'TStat 	= (`age'Type == 2)
	gen `age'TReli 	= (`age'Type == 3)
	// note: not doing private because of low N
}


replace asilo 		= (asilo == 1)
gen both_asil_mat 	= (asilo == 1 & materna == 1)

lab var materna Preschool
lab var both_asil_mat Both

// LPM
local cohort_val = 1
foreach cohort in Child Migrant Adolescent Adult30 Adult40 Adult50 {
	di "cohort:`cohort', `cohort_val'"
	tab Cohort if Cohort == `cohort_val' & City == 1
	if r(N) > 0 {

		global controls ${`cohort'_baseline_vars} 
		
		ivreg2 momWork_fulltime06 (materna = low_score /*distMaternaClosest_med*/) $controls if City == 1 & Cohort == `cohort_val'
		ivreg2 momWork_fulltime06 (both_asil_mat = low_score /*distMaternaClosest_med distAsiloClosest_med*/) $controls if City == 1 & Cohort == `cohort_val'
		//reg materna $controls if Cohort == `cohort_val' & City == `city_val', robust
		//est store `cohort'`city'materna
		
		//reg both_asil_mat $controls if Cohort == `cohort_val' & City == `city_val', robust
		//est store `cohort'`city'both
	}
	/*	
	local cohort_val = `cohort_val' + 1	
	
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
	*/
	
	local cohort_val = `cohort_val' + 1
}



