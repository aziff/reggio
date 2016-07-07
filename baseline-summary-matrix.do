/*
Author: Anna Ziff, Yu Kyung Koh

Purpose:
-- Do the same as baseline-summary but writing directly into LaTeX


Update 6/12/16:
-- No asilo
-- Changing variables for adults to avoid confusion
-- Include aggregation code
*/

cap file close baseline
cap log close

global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio

cd 		$git_reggio
include prepare-data
include "${git_reggio}/baseline-rename"

*-* Adjust variables and statistics of interest
#delimit ;

local main_baseline_vars  		Male Age lowbirthweight birthpremature CAPI
								momAgeBirth momBornProvince
								momMaxEdu_low momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni 
								dadAgeBirth dadBornProvince
								dadMaxEdu_low dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni 
								childrenSibTot cgRelig houseOwn cgMigrant
								cgReddito_1 cgReddito_2 cgReddito_3 cgReddito_4 cgReddito_5 cgReddito_6 cgReddito_7;
								
								
local adult_baseline_vars		Male Age CAPI
								momBornProvince
								momMaxEdu_low momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni 
								dadBornProvince 
								dadMaxEdu_low dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni
								cgRelig;
								
								
local Child_baseline_vars		`main_baseline_vars';
								
local Migrant_baseline_vars		`main_baseline_vars' 
								yrCity ageCity;

local Adolescent_baseline_vars	`main_baseline_vars';

local Adult30_baseline_vars 	`adult_baseline_vars'; 

local Adult40_baseline_vars 	`adult_baseline_vars';

local Adult50_baseline_vars 	`adult_baseline_vars';

** Baseline variables for each category
# delimit cr
foreach cat in E L H N {
	local Adult_baseline_vars_`cat'		Male CAPI numSiblings ///
										momBornProvince  ///
										momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni momMaxEdu_Grad  ///
										dadBornProvince ///
										dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni dadMaxEdu_Grad
}
# delimit ;

local Adult_baseline_vars_W			Male CAPI numSiblings 
									momBornProvince 
									momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni momMaxEdu_Grad  
									dadBornProvince 
									dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni dadMaxEdu_Grad 
									i.SES;
									
** BIC-selected baseline variables
local bic_baseline_vars		    	Male momMaxEdu_Grad dadMaxEdu_Uni dadMaxEdu_Grad CAPI;
											
** Outcomes for each category
local Adult_outcome_E				IQ_factor votoMaturita votoUni 
									highschoolGrad MaxEdu_Uni MaxEdu_Grad;

local Adult_outcome_W				PA_Empl SES_self HrsTot WageMonth 
									Reddito_1 Reddito_2 Reddito_3 Reddito_4 Reddito_5 Reddito_6 Reddito_7;

local Adult_outcome_L				mStatus_married_cohab childrenResp all_houseOwn live_parent;
									
local Adult_outcome_H				Maria Smoke Cig BMI Health SickDays 
									i_RiskFight i_RiskDUI RiskSuspended Drink1Age;								
									
local Adult_outcome_N				LocusControl Depression_score 
									binSatisIncome binSatisWork binSatisHealth binSatisFamily 
									optimist reciprocity1bin reciprocity2bin reciprocity3bin reciprocity4bin;

#delimit cr

*-* To ease display of table

recode maternaType 		(1=1) (2=2) (3=3) (4=4) (0=5)

label define materna_type 	1 Municipal 2 State 3 Religious 4 Private 5 None

label value maternaType materna_type

local materna_name		Materna

local Child_name		"Child"
local Migrant_name		"Migrant"
local Adolescent_name	"Adolescent"
local Adult30_name		"Adult (30s)"
local Adult40_name		"Adult (40s)"
local Adult50_name		"Adult (50s)"

*-* Define programs

// t-tests
capt prog drop ttests

program ttests, eclass
	syntax varlist, by(varname) [ * ]
	marksample to_use
	markout `to_use' `by'
	tempname mu_1 d_p N_1 diff
	
	tab `by'
	
	if r(r) == 2 {
		foreach var of local varlist {
			ttest `var' if `to_use', by(`by') `options'
			mat `Mean' = nullmat(`Mean'), r(mu_1)
			mat `p-value'  = nullmat(`p-value'), r(p)
			mat `N'  = nullmat(`N' ), r(N_1)
			mat `Difference' = nullmat(`Difference'), r(mu_2) - r(mu_1)
		}
	}
	else {
		foreach var of local varlist {
			sum `var' if `to_use' & `by' == 0
			mat `Mean' = nullmat(`Mean'), r(mean)
			mat `p-value' = nullmat(`p-value'), 0.999
			mat `N' = nullmat(`N'), r(N)
			mat `Difference' = nullmat(`Difference'), .
		}
	}
	
    foreach mat in Mean p-value N Difference {
		mat coln ``mat'' = `varlist'
    }
    eret local cmd "ttests"
    foreach mat in Mean p-value N Difference {
		eret mat `mat' = ``mat''
    }
end

// regression conditional and unconditional mean

capt prog drop regs

program regs, eclass
	syntax varlist, control(`control') 
	tempname b p N
	

	foreach var of local varlist {
		reg `var' `bic_baseline_vars'
		mat `b' = nullmat(`b'), r(b)
		mat `p'  = nullmat(`p' ), r(p)
		mat `N'  = nullmat(`N' ), r(N)
	}

	
    foreach mat in b p N {
		mat coln ``mat'' = `varlist'
    }
    eret local cmd "regs"
    foreach mat in b p N {
		eret mat `mat' = ``mat''
    }
end

*-* Construct matrix of summary statistics disaggregated

cd "${git_reggio}/Output/description/"
	
local cohort_i = 1
foreach cohort in `cohorts' {
	
	local city_i = 1
	foreach city in `cities' {
		
		local school_i = 1
		foreach school in Municipal State Religious Private None {
				
			preserve 
					
					keep if Cohort == `cohort_i'
					keep if City == 1 | City == `city_i'
					keep if maternaType == 1 | maternaType == `school_i' 
					tab maternaType City
					tab Cohort
						
					gen compare_group = .
					replace compare_group = 1 if maternaType == 1 & City == 1 
					replace compare_group = 0 if maternaType == `school_i' & City == `city_i' 
						
					tab compare_group
							
						ttests ``cohort'_baseline_vars', by(compare_group)
					
						# delimit ;
						esttab using "`cohort'`city'Baseline.tex",
								replace
								title("``cohort'_name', `city', Baseline Characteristics") 
								label
								booktabs
								nonumbers 
								noobs 	
								cells("Mean(fmt(%9.3f) star p-value(p-value)) Difference N(fmt(%9.0g))")
								;
						# delimit cr
			restore 
					/*
					regs ``cohort'_baseline_vars', control(``cohort'_baseline_vars'))
							
							# delimit ;
							estout using "Output/description/`cohort'`city'OLS.tex",
									replace
									title("``cohort'_name', `city', Simple OLS") 
									label
									booktabs
									nonumbers 
									noobs 	
									cells("Mean(fmt(%9.3f) star pvalue(d_p)) N(fmt(%9.0g)) Conditional(fmt(%9.3f) star pvalue(d_p)) N(fmt(%9.0g))")
									;
							# delimit cr
				*/
		
		local school_i = `school_i' + 1
		}
			
		local city_i = `city_i' + 1
	
	}
	local cohort_i = `cohort_i' + 1
}
asd
*-* Outcomes

local cohort_i = 1
foreach cohort in `cohorts' {
	di "`cohort' `cohort_i'"
	local city_i = 1
	foreach city in `cities' {
		di "`city' `city_i'
		local school_i = 1
		foreach s in `schools' {
		di "`s' `school_i'"
				preserve 
						
					keep if Cohort == `cohort_i'
					keep if City == 1 | City == `city_i'
					
					gen compare_group = .
					replace compare_group = 1 if maternaType == 1 & City == 1 
					replace compare_group = 0 if maternaType == `school_i' & City == `city_i' 
					
					if `cohort_i' > 2 {
						foreach out_type in  E L H N W {
							ttests `Adult_outcome_vars_`out_type'', by(compare_group)
							
							# delimit ;
							esttab using "${git_reggio}/Output/description/`cohort'`city'Outcomes`out_type'.tex",
								replace
								title("``cohort'_name', `city', Baseline Characteristics") 
								label
								booktabs
								nonumbers 
								noobs 	
								cells("Mean(fmt(%9.3f) star pvalue(d_p)) Difference N(fmt(%9.0g))")
								;
							# delimit cr
						}
					}
					else {
						ttests ``cohort'_outcome_vars', by(compare_group)
						
						# delimit ;
						esttab using "${git_reggio}/Output/description/`cohort'`city'Outcomes.tex",
								replace
								title("``cohort'_name', `city', Baseline Characteristics") 
								label
								booktabs
								nonumbers 
								noobs 	
								cells("Mean(fmt(%9.3f) star pvalue(d_p)) Difference N(fmt(%9.0g))")
								;
					# delimit cr
					}
					
					
					
				restore	
		local school_i = `school_i' + 1
		}			
		local city_i = `city_i' + 1
	}
	local cohort_i = `cohort_i' + 1
}
	




/*
// Reggio vs. Parma and Padova
foreach type in asilo materna {
	gen `type'TypeGrouped = `type'Type
	if "`type'" == "asilo" {
		recode `type'TypeGrouped (1=1) (2=2) (3=2) (4=3) 
	}
	else {
		recode `type'TypeGrouped (1=1) (2=2) (3=2) (4=2) (5=3)
	}
	
	local schools_grouped 	Municipal Other None
	
	local cohort_i = 1
	foreach cohort in `cohorts' {
	
	
	file open baseline using "Output/description/agg`cohort'`type'Reggio.tex", write replace
	file write baseline "\begin{tabular}{l c c c c c c}" _n
	file write baseline "\toprule" _n
	file write baseline " & \multicolumn{2}{c}{Municipal} & \multicolumn{2}{c}{Other} & \multicolumn{2}{c}{None} \\" _n
	file write baseline " & Mean & N & Mean & N & Mean & N \\" _n
	file write baseline "\midrule" _n
	
	
		foreach v in `baseline_vars' {
			local row
			
			local group_i = 1
			foreach group in `schools_grouped' {
				sum `v' if City == 1 & `type'TypeGrouped == `group_i' & Cohort == `cohort_i'
				local N_save 	= r(N)
				local mean_save = r(mean)
				
				local N_save 	: di %9.0f `N_save'
				local mean_save : di %9.2f `mean_save'
				local vl 		: variable label `v'
				
				local p_save = 999 // in case the ttest doesn't go through
					preserve 
						
						keep if Cohort == `cohort_i'
						keep if City == 1
						keep if `type'TypeGrouped == 1 | `type'TypeGrouped == `school_i' 
						tab `type'TypeGrouped City
						tab Cohort
						
						gen compare_group = .
						replace compare_group = 1 if `type'TypeGrouped == 1
						replace compare_group = 0 if `type'TypeGrouped == `school_i' 
						
						tab compare_group
						if r(r) == 2 & `N_save' > 0 {
							ttest `v', by(compare_group) unequal welch
							local p_save = r(p)
						}
					
					restore 
				
				// add row to local
				if `group_i' == 1 {
					local row `row' 	`vl' & `mean_save' & `N_save'
				}
				else {
					local row `row'		  & `mean_save' & `N_save' 
				}
				
				// write row
				if `school_i' == 3 {
					local row `row' \\
							
					file write baseline "`row'" _n
				}
		
				
				local school_i = `school_i' + 1
			}
		}
		local cohort_i = `cohort_i' + 1
		file write baseline "\bottomrule" _n
		file write baseline "\end{tabular}" _n
		file close baseline
	}
	
}


