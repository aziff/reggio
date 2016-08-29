/*
Globals and locals for Reggio analysis
*/

#delimit ;

local young_baseline_vars  		Male Age lowbirthweight birthpremature CAPI
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
								
								
local Child_baseline_vars		`young_baseline_vars';
								
local Migrant_baseline_vars		`young_baseline_vars' 
								yrCity ageCity;

local Adolescent_baseline_vars	`young_baseline_vars';

local Adult30_baseline_vars 	`adult_baseline_vars'; 

local Adult40_baseline_vars 	`adult_baseline_vars';

local Adult50_baseline_vars 	`adult_baseline_vars';

local cohorts					Child Migrant Adolescent Adult30 Adult40 Adult50;
local cities					Reggio Parma Padova;
local schools					Municipal State Religious Private None;

# delimit cr

** Baseline variables for each category
foreach cat in E L H N S {
	local adult_baseline_vars_`cat'		Male CAPI numSiblings dadMaxEdu_Uni dadMaxEdu_Grad momMaxEdu_Grad
}


local adult_baseline_vars_W				Male CAPI numSiblings dadMaxEdu_Uni dadMaxEdu_Grad momMaxEdu_Grad i.SES	
									
** BIC-selected baseline variables
local bic_baseline_vars		    		Male CAPI numSiblings dadMaxEdu_Uni dadMaxEdu_Grad momMaxEdu_Grad
											
** Outcomes for each category
local adult_outcome_E					IQ_factor votoMaturita votoUni ///
										highschoolGrad MaxEdu_Uni MaxEdu_Grad

local adult_outcome_W					PA_Empl SES_self HrsTot WageMonth ///
										Reddito_1 Reddito_2 Reddito_3 Reddito_4 Reddito_5 Reddito_6 Reddito_7

local adult_outcome_L					mStatus_married_cohab childrenResp all_houseOwn live_parent 
									
local adult_outcome_H					Maria Smoke Cig BMI goodHealth SickDays ///
										i_RiskFight i_RiskDUI RiskSuspended Drink1Age									
									
local adult_outcome_N					LocusControl Depression_score ///
										binSatisIncome binSatisWork binSatisHealth binSatisFamily ///
										optimist reciprocity1bin reciprocity2bin reciprocity3bin reciprocity4bin		
									
local adult_outcome_S					MigrTaste Friends MigrFriend

