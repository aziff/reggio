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

include "${git_reggio}/prepare-data"
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

local cohorts					Child Migrant Adolescent Adult30 Adult40 Adult50;
local cities					Reggio Parma Padova;
local schools					Municipal State Religious Private None;

# delimit cr
** Baseline variables for each category
foreach cat in E L H N S {
	local adult_baseline_vars_`cat'		Male CAPI numSiblings dadMaxEdu_HS dadMaxEdu_Uni numSibling_1
}


local adult_baseline_vars_W			Male CAPI numSiblings dadMaxEdu_HS dadMaxEdu_Uni numSibling_1 i.SES	
									
** BIC-selected baseline variables
local bic_baseline_vars		    	Male momMaxEdu_Grad dadMaxEdu_Uni dadMaxEdu_Grad CAPI
											
** Outcomes for each category
local adult_outcome_E				IQ_factor votoMaturita votoUni ///
									highschoolGrad MaxEdu_Uni MaxEdu_Grad

local adult_outcome_W				PA_Empl SES_self HrsTot WageMonth ///
									Reddito_1 Reddito_2 Reddito_3 Reddito_4 Reddito_5 Reddito_6 Reddito_7

local adult_outcome_L				mStatus_married_cohab childrenResp all_houseOwn live_parent 
									
local adult_outcome_H				Maria Smoke Cig BMI goodHealth SickDays ///
									i_RiskFight i_RiskDUI RiskSuspended Drink1Age									
									
local adult_outcome_N				LocusControl Depression_score ///
									binSatisIncome binSatisWork binSatisHealth binSatisFamily ///
									optimist reciprocity1bin reciprocity2bin reciprocity3bin reciprocity4bin		
									
local adult_outcome_S				MigrTaste Friends MigrFriend


	
#delimit cr

*-* To ease display of table

recode maternaType 			(1=1) (2=2) (3=3) (4=4) (0=5)

label define materna_type 	1 Municipal 2 State 3 Religious 4 Private 5 None 

label value maternaType 	materna_type

local materna_name			Materna


local tabular 	"\begin{tabular}{l c c c c c c c c c c c c}"
local header	"& \multicolumn{2}{c}{Municipal} & \multicolumn{2}{c}{State} & \multicolumn{2}{c}{Religious} & \multicolumn{2}{c}{Private} & \multicolumn{2}{c}{None} & R-sq. & C. R-sq. \\"
local meanN		"& \scriptsize Mean & \scriptsize C. Mean & \scriptsize Mean & \scriptsize C. Mean & \scriptsize Mean & \scriptsize C. Mean & \scriptsize Mean & \scriptsize C. Mean & \scriptsize Mean & \scriptsize C. Mean & & \\"

*-* Construct matrix of summary statistics disaggregated
/*
cd ${git_reggio}
	
local cohort_i = 1
foreach cohort in `cohorts' {
	
	local city_i = 1
	foreach city in `cities' {
			
		file open baseline using "Output/description/baseline`city'`cohort'.tex", write replace
		file write baseline "`tabular'" _n
		file write baseline "\toprule" 	_n
		file write baseline "`header'" 	_n
		file write baseline "`meanN'"	_n
		file write baseline "\midrule" 	_n
			
		log using "Output/description/log/check`city'`cohort'", replace
		foreach v in ``cohort'_baseline_vars' {
			local row
				
			local school_i = 1
			foreach s in `schools' {
				
				sum `v' if maternaType == `school_i' & City == `city_i' & Cohort == `cohort_i'
				
				* Unconditional mean
				reg `v' i.maternaType
				local r_squared = e(r2)
				
					local N_save 	= r(N)
					local mean_save = r(mean)

					local p_save = 999 // in case the ttest doesn't go through
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
						if r(r) == 2 & `N_save' > 0 {
							ttest `v', by(compare_group) unequal welch
							local p_save = r(p)
						}
					
					restore 
					
				* Conditional mean
				reg `v' ib1.maternaType `bic_baseline_vars'
				cap matrix drop cond
				matrix cond = r(table)
				local constant = cond[1,6]
				local cond_r_squared = e(r2)
				local cond_N = e(N)
				
				local tmp_counter = 1
				foreach tmp_type in Municipal State Religious Private None {
					local `tmp_type' = cond[1,`tmp_counter']
				
					local cond_mean`tmp_type' = `constant' + ``tmp_type''
					local p`tmp_type' = cond[4,`tmp_counter']
					
					local tmp_counter = `tmp_counter' + 1
					
				}
					
				// get var label
				local vl 	: variable label `v'
					
				// reformat statistics
				foreach l in mean min max p50 sd p {
					local `l'_save : di %9.2f ``l'_save'
				}
				foreach l in  r_squared cond_r_squared cond_meanMunicipal cond_meanState cond_meanReligious cond_meanPrivate cond_meanNone {
					local `l' : di %9.2f ``l''
				}
				
				local N_save : di %9.0f `N_save'
				local cond_N : di %9.0f `cond_N'
						
				if `N_save' == 0 {
					local N_save .
				}
					
				if `p_save' <= 0.1 {
					local mean_save \textbf{`mean_save'}
				}
				
				foreach tmp_type in Municipal State Religious Private None {
					if `p`tmp_type'' <= 0.1 {
						local p`tmp_type' \textbf{`p`tmp_type''}
					}
				}
					
				// save to row 
				if `school_i' == 1 {
					local row `row' 	`vl' & `mean_save' & `N_save' & `cond_mean`school'' 
				}
				else {
					local row `row' 	& `mean_save' & `N_save' & `cond_mean`school''
				}
					
					
				// write row
				if `school_i' == 5 {
					local row `row' & `r_squared' & `cond_r_squared' & `cond_N' \\
							
					file write baseline "`row'" _n
				}
						
			local school_i = `school_i' + 1 
			}
				
		}
		log close
			
		file write baseline "\bottomrule" _n
		file write baseline "\end{tabular}" _n
		file close baseline
		local city_i = `city_i' + 1
	
	}
	local cohort_i = `cohort_i' + 1
}
*/

*-* Construct matrix of outcomes, disaggregated

cd "${klmReggio}/Analysis/"

local cohort_i = 4
foreach cohort in Adult30 Adult40 Adult50 {
	
	local city_i = 1
	foreach city in `cities' {
			
		foreach out_type in E W L H N S {
		
			file open baseline using "Output/description/OLS`city'`cohort'`out_type'.tex", write replace
			file write baseline "`tabular'" _n
			file write baseline "\toprule" 	_n
			file write baseline "`header'" 	_n
			file write baseline "`meanN'"	_n
			file write baseline "\midrule" 	_n
		
			
			foreach v in `adult_outcome_`out_type'' {
			
				* Conditional mean
				cap reg `v' ib1.maternaType `adult_baseline_vars_`out_type'' if `city' == 1 & Cohort_`cohort' == 1
				if _rc {
					continue
				}
				cap matrix drop cond
				matrix cond = r(table)
				cap matrix drop cons
				matrix cons = cond[1,"_cons"]
				local constant = cons[1,1]
				local cond_r_squared = e(r2)
				local cond_N = e(N)
				
*----------------------------------------------------------------------------------------------------------------------------------
* Begin Sid edit
*----------------------------------------------------------------------------------------------------------------------------------	
				
				local cond_r_squared: di %9.2f `cond_r_squared'
				
				local colName 1b.maternaType 2.maternaType 3.maternaType 4.maternaType 5.maternaType
				
				local num = 1
				foreach tmp_type of local colName{
					local colNum = colnumb(cond,"`tmp_type'")  		// Identifying column # in matrix for each maternaType
					
					local var`num' = cond[1,`colNum']
					local cond_mean_var`num' = `constant' + `var`num''
					local p_var`num' = cond[4,`colNum']
					
					local cond_mean_var`num': di %9.2f `cond_mean_var`num''
					
					if `p_var`num'' <= 0.1{
						local cond_mean_var`num' \textbf{`cond_mean_var`num''}
					}
					
					local num=`num'+1
				}
						
				
				local cond_meanMunicipal `cond_mean_var1'
				local cond_meanState `cond_mean_var2'
				local cond_meanReligious  `cond_mean_var3'
				local cond_meanPrivate  `cond_mean_var4'
				local cond_meanNone  `cond_mean_var5'
				
*----------------------------------------------------------------------------------------------------------------------------------				
* End Sid edit			
*-------------------------------------------------------------------------------------------------------------------------------------
				local row
				
				local school_i = 1
				foreach s in `schools' {
				
					sum `v' if maternaType == `school_i' & `city' == 1 & Cohort_`cohort' == 1
			
					local mean_save = r(mean)
					
					* Unconditional mean
					reg `v' i.maternaType if `city' == 1 & Cohort_`cohort' == 1
					local r_squared = e(r2)
					local N_save 	= e(N)

					local p_save = 999 // in case the ttest doesn't go through
					preserve 
						
						keep if Cohort_`cohort' == 1
						keep if City == 1 | `city' == 1
						keep if maternaType == 1 | maternaType == `school_i' 
						tab maternaType City
						tab Cohort
						
						gen compare_group = .
						replace compare_group = 1 if maternaType == 1 & City == 1 
						replace compare_group = 0 if maternaType == `school_i' & `city' == 1
						
						tab compare_group
						if r(r) == 2 & `N_save' > 0 & `N_save' != . {
							capture ttest `v', by(compare_group) unequal welch
							if _rc {
								restore
								local school_i = `school_i' + 1 
								continue
							}
							local p_save = r(p)
						}
					
					restore 
					
					// get var label
					local vl 	: variable label `v'
					
					// reformat statistics
					foreach l in mean min max p50 sd p {
						local `l'_save : di %9.2f ``l'_save'
					}
					local r_squared : di %9.2f `r_squared'
				
					local N_save : di %9.0f `N_save'
					local cond_N : di %9.0f `cond_N'
						
					if `N_save' == 0 {
						local N_save .
					}
						
					if `p_save' <= 0.1 {
						local mean_save \textbf{`mean_save'}
					}
					
					// save to row 
					if `school_i' == 1 {
						local row `row' 	``v'_lab' & `mean_save'  & `cond_mean`s'' 
					}
					else {
						local row `row' 	& `mean_save' & `cond_mean`s''
					}
					
					// write row
					if `school_i' == 5 {
						local row `row' & `r_squared' & `cond_r_squared'  \\
										
						file write baseline "`row'" _n
					}
						
				local school_i = `school_i' + 1 
				}
				
			}
			file write baseline "\bottomrule" _n
			file write baseline "\end{tabular}" _n
			file close baseline

		}
		local city_i = `city_i' + 1
	}
	local cohort_i = `cohort_i' + 1
}
