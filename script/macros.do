* ---------------------------------------------------------------------------- *
* Globals and locals for Reggio analysis
* Authors: Reggio Team
* Edited: 2016/08/23
* ---------------------------------------------------------------------------- * 

#delimit ;

* --------- *
* Directory *
* --------- *
global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio
global current 	   : pwd
global output	"${current}/../output"


* -------------- *
* Classification *
* -------------- *
local cohorts					Child Migrant Adolescent Adult30 Adult40 Adult50;
local cities					Reggio Parma Padova;
local schools					Municipal State Religious Private None;
	
* ------------------ *
* Baseline variables *
* ------------------ *
local child_baseline_vars  		Male lowbirthweight birthpremature CAPI
								momAgeBirth momBornProvince
								momMaxEdu_low momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni 
								dadAgeBirth dadBornProvince
								dadMaxEdu_low dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni 
								numSiblings cgCatholic int_cgCatFaith houseOwn cgMigrant
								cgReddito_1 cgReddito_2 cgReddito_3 cgReddito_4 cgReddito_5 cgReddito_6 cgReddito_7;  
								// We assume that household income abd family house ownership for children cohorts can be considered as "baseline"
								
local adol_baseline_vars  		Male lowbirthweight birthpremature CAPI
								momAgeBirth momBornProvince
								momMaxEdu_low momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni 
								dadAgeBirth dadBornProvince
								dadMaxEdu_low dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni 
								numSiblings cgCatholic int_cgCatFaith cgMigrant;								
								
								
local adult_baseline_vars		Male CAPI
								momBornProvince
								momMaxEdu_low momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni 
								dadBornProvince 
								dadMaxEdu_low dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni 
								numSiblings cgRelig;
								
								
local Child_baseline_vars		`child_baseline_vars';								
local Migrant_baseline_vars		`child_baseline_vars' yrCity ageCity;
local Adolescent_baseline_vars	`adol_baseline_vars';
local Adult30_baseline_vars 	`adult_baseline_vars'; 
local Adult40_baseline_vars 	`adult_baseline_vars';
local Adult50_baseline_vars 	`adult_baseline_vars';

# delimit cr

* Baseline variables for each category
foreach cat in E L H N S {
	local adult_baseline_vars_`cat'		Male CAPI numSiblings dadMaxEdu_Uni dadMaxEdu_Grad momMaxEdu_Grad
}


local adult_baseline_vars_W				Male CAPI numSiblings dadMaxEdu_Uni dadMaxEdu_Grad momMaxEdu_Grad i.SES	
									
* BIC-selected baseline variables 
local bic_baseline_vars		    		Male CAPI numSiblings dadMaxEdu_Uni dadMaxEdu_Grad momMaxEdu_Grad



* -------------------------- *											
* Outcomes for each category *
* -------------------------- *
* Cognitive skills and education
local adult_outcome_E					IQ_factor votoMaturita votoUni ///
										highschoolGrad MaxEdu_Uni MaxEdu_Grad

* Employment										
local adult_outcome_W					PA_Empl SES_self HrsTot WageMonth ///
										Reddito_1 Reddito_2 Reddito_3 Reddito_4 Reddito_5 Reddito_6 Reddito_7

* Living status										
local adult_outcome_L					mStatus_married_cohab mStatus_div childrenResp all_houseOwn live_parent

* Health									
local adult_outcome_H					Maria Smoke Cig BMI goodHealth SickDays ///
										i_RiskFight i_RiskDUI RiskSuspended Drink1Age							

* Noncognitive										
local adult_outcome_N					LocusControl Depression_score Stress StressWork ///
										binSatisIncome binSatisWork binSatisHealth binSatisFamily ///
										optimist reciprocity1bin reciprocity2bin reciprocity3bin reciprocity4bin		

* Social										
local adult_outcome_S					MigrTaste Friends MigrFriend volunteer invFamMeal childinvFamMeal ///
										votedMunicipal votedRegional votedNational

* Religion
local adult_outcome_R					Faith


** Label
global IQ_factor_lab 				IQ Factor
global votoMaturita_lab				High School Grade
global votoUni_lab					University Grade
global highschoolGrad_lab			Graduate from High School
global MaxEdu_Uni_lab				Max Edu: University
global MaxEdu_Grad_lab				Max Edu: Graduate School

global PA_Empl_lab					Employed
global SES_self_lab					Self-Employed
global HrsTot_lab					Hours Worked Per Week
global WageMonth_lab				Monthly Wage
global Reddito_1_lab				H. Income: 5,000 Euros of Less
global Reddito_2_lab				H. Income: 5,001-10,000 Euros
global Reddito_3_lab				H. Income: 10,001-25,000 Euros
global Reddito_4_lab				H. Income: 25,001-50,000 Euros
global Reddito_5_lab				H. Income: 50,001-100,000 Euros
global Reddito_6_lab				H. Income: 100,001-250,000 Euros
global Reddito_7_lab				H. Income: More than 250,000 Euros

global mStatus_married_cohab_lab 	Married or Cohabitating
global childrenResp_lab				Num. of Children in House
global all_houseOwn_lab				Own House
global live_parent_lab				Live With Parents

global Maria_lab					Tried Marijuana
global Smoke_lab					Smokes
global Cig_lab						Num. of Cigarettes Per Day
global BMI_lab						BMI
global goodHealth_lab				Good Health
global SickDays_lab					Num. of Days Sick Past Month
global i_RiskDUI_lab				Drove Under Influence 
global i_RiskFight_lab				Engaged in A Fight 
global RiskSuspended_lab			Ever Suspended from School
global Drink1Age_lab				Age At First Drink

global LocusControl_lab				Locus of Control
global Depression_score_lab			Depression Score

global pos_LocusControl_lab			Locus of Control - positive
global pos_Depression_score_lab		Depression Score - positive

global binSatisIncome_lab			Satisfied with Income
global binSatisWork_lab				Satisfied with Work
global binSatisHealth_lab 			Satisfied with Health 
global binSatisFamily_lab			Satisfied with Family
global optimist_lab					Optimistic Look in Life
global reciprocity1bin_lab			Return Favor 
global reciprocity2bin_lab			Put Someone in Difficulty
global reciprocity3bin_lab			Help Someone Kind To Me
global reciprocity4bin_lab 			Insult Back

global MrgrTaste_lab				Favorable to Migrants
global Friends_lab					Number of Friends
global MigrFriend_lab				Has Migrant Friends

									
