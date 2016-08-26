/*
Author: Anna Ziff, Jessica Yu Kyung Koh

Purpose:
-- Outcomes description

*/
clear all
cap file 	close outcomes
cap log 	close

global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio

cd 		${klmReggio}/Analysis
include prepare-data

*-* Adjust variables and statistics of interest
#delimit ;

local main_baseline_vars  		Male lowbirthweight birthpremature CAPI
								momAgeBirth momBornProvince
								momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni momMaxEdu_Grad //missing parental edu category: low
								dadAgeBirth dadBornProvince
								dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni dadMaxEdu_Grad
								numSiblings cgRelig houseOwn cgMigrant
								cgReddito_2 cgReddito_3 cgReddito_4 cgReddito_5 cgReddito_6 cgReddito_7; //missing income category: 1
								
								
local adult_baseline_vars		Male CAPI numSiblings
								momBornProvince
								momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni momMaxEdu_Grad //missing parental edu category: low 
								dadBornProvince 
								dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni dadMaxEdu_Grad
								mStatus_married_cohab; // AZ: these are new ones I added!
								
								
local Child_baseline_vars		`main_baseline_vars';
								
local Migrant_baseline_vars		`main_baseline_vars' 
								yrCity ageCity;

local Adolescent_baseline_vars	`main_baseline_vars';

local Adult30_baseline_vars 	`adult_baseline_vars'; 

local Adult40_baseline_vars 	`adult_baseline_vars';

local Adult50_baseline_vars 	`adult_baseline_vars';

local Child_outcome_vars 		IQ_factor likeSchool_child childBMI childSDQ_score;

local Migrant_outcome_vars		IQ_factor likeSchool_child childBMI childSDQ_score;	
	
local Adolescent_outcome_vars 	IQ_factor RiskSuspended Smoke Cig sport 
								BMI LocusControl SDQ_score childSDQ_score Depression_score;
								
local Adult30_outcome_vars		IQ_factor votoMaturita votoUni highschoolGrad 
								PA_Empl SES_self HrsTot Reddito_1 Reddito_2 Reddito_3 Reddito_4 
								Reddito_5 Reddito_6 Reddito_7 Maria Smoke Cig 
								BMI Health SickDays LocusControl Depression_score
								binSatisIncome binSatisWork binSatisHealth binSatisFamily;
								
local Adult40_outcome_vars		IQ_factor votoMaturita votoUni highschoolGrad 
								PA_Empl SES_self HrsTot Reddito_1 Reddito_2 Reddito_3 Reddito_4 
								Reddito_5 Reddito_6 Reddito_7 Maria Smoke Cig 
								BMI Health SickDays LocusControl Depression_score
								binSatisIncome binSatisWork binSatisHealth binSatisFamily;
								
local Adult50_outcome_vars		IQ_factor votoMaturita votoUni highschoolGrad 
								PA_Empl SES_self HrsTot Reddito_1 Reddito_2 Reddito_3 Reddito_4 
								Reddito_5 Reddito_6 Reddito_7 Maria Smoke Cig 
								BMI Health SickDays LocusControl Depression_score
								binSatisIncome binSatisWork binSatisHealth binSatisFamily;

local control_vars				CAPI Age 
								momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni 
								momAgeBirth ///missing cat: low edu
                                momBornProvince 
								cgRelig houseOwn 
								cgReddito_2 cgReddito_3 cgReddito_4 cgReddito_5 cgReddito_6 cgReddito_7; /// missing cat: income below 5,000
                
local cohorts					Child Migrant Adolescent Adult30 Adult40 Adult50;
local cities					Reggio Parma Padova;
local schools					Municipal State Religious Private None;                      

#delimit cr

*-* Table Label for the Variables
local IQ_factor_lab 			IQ Factor
local likeSchool_child_lab		Child Dislikes School
local childBMI_lab				Child BMI
local childSDQ_score_lab		SDQ Score (Mother Reports)
local RiskSuspended_lab			Ever Suspended
local Smoke_lab					Smokes
local Cig_lab					Number of Cigarettes Per Day
local sport_lab					Days of Sports Per Week
local BMI_lab					BMI
local LocusControl_lab			Locus of Control
local SDQ_score_lab				SDQ Score (Self-Reported)
local Depression_score_lab		Depression Score
local votoMaturita_lab			High School Grade
local votoUni_lab				University Grade
local highschoolGrad_lab		Graduate from High School
local PA_Empl_lab				Employed
local SES_self_lab				Self-Employed
local HrsTot_lab				Hours Worked Per Week
local Reddito_1_lab				Income: 5,000 Euros of Less
local Reddito_2_lab				Income: 5,001-10,000 Euros
local Reddito_3_lab				Income: 10,001-25,000 Euros
local Reddito_4_lab				Income: 25,001-50,000 Euros
local Reddito_5_lab				Income: 50,001-100,000 Euros
local Reddito_6_lab				Income: 100,001-250,000 Euros
local Reddito_7_lab				Income: More than 250,000 Euros
local Maria_lab					Tried Marijuana
local Health_lab				Bad Health
local SickDays_lab				Number of Days Sick Past Month
local binSatisIncome_lab		Satisfied with Income
local binSatisWork_lab			Satisfied with Work
local binSatisHealth_lab 		Satisfied with Health 
local binSatisFamily_lab		Satisfied with Family

*-* Short Name for Variables
local IQ_factor_short 				IQ
local likeSchool_child_short		CDS
local childBMI_short				CBMI
local childSDQ_score_short			CSDQ
local RiskSuspended_short			ES
local Smoke_short					SM
local Cig_short						CIG
local sport_short					SPT
local BMI_short						BMI
local LocusControl_short			LOC
local SDQ_score_short				SSDQ
local Depression_score_short		DS
local votoMaturita_short			HSG
local votoUni_short					UG
local highschoolGrad_short			GHS
local PA_Empl_short					EP
local SES_self_short				SEP
local HrsTot_short					HOUR
local Reddito_1_short				INC1
local Reddito_2_short				INC2
local Reddito_3_short				INC3
local Reddito_4_short				INC4
local Reddito_5_short				INC5
local Reddito_6_short				INC6
local Reddito_7_short				INC7
local Maria_short					MAR
local Health_short					BAD
local SickDays_short				SICK
local binSatisIncome_short			SFI
local binSatisWork_short			SFW
local binSatisHealth_short 			SFH
local binSatisFamily_short			SFF

/*
*-* Adding variables
// married
gen mStatus_married_cohab = (mStatus_married == 1) | (mStatus_cohab == 1)
lab var mStatus_married_cohab "Married or cohabitating indicator" */

*-* Regressions
* ---------------------------------------------------------------------------- *
* Regression 1: Reggio (All) vs. Parma/Padova (All)
gen allReggio = (City == 1)

local cohort_i = 1
foreach cohort in `cohorts' {
	matrix `cohort'Save = J(1,3,.)
	
	local var_names
	foreach var in ``cohort'_outcome_vars' {

		local var_names `var_names' "``var'_lab'"
		
		// regression for Reggio (all) vs. everything
		reg `var' allReggio ``cohort'_baseline_vars' if Cohort == `cohort_i' 
			
			
			
			matrix `var'Table = r(table)
			matrix `var'Save = (`var'Table[1,1], `var'Table[2,1], `var'Table[4,1])
			matrix `cohort'Save = `cohort'Save \ `var'Save
		}
		
	matrix rownames `cohort'Save = `var_names' // NOTE: to add column names, define a local and do matrix colnames `cohort'Save = `col_names'
	outtable using "C:\Users\Jessica Yu Kyung\Desktop\test`cohort'.tex", mat(`cohort'Save) replace
	local cohort_i = `cohort_i' + 1		
}









