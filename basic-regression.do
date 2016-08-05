/*
Author: Anna Ziff, Jessica Yu Kyung Koh

Purpose:
-- Outcomes description

*/

cap file 	close outcomes
cap log 	close

global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio

cd 		${git_reggio}
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

local N 	pos_childSDQ_score pos_childSDQEmot_score pos_childSDQCond_score pos_childSDQHype_score pos_childSDQPeer_score pos_childSDQPsoc_score ///
			pos_SDQ_score pos_SDQEmot_score pos_SDQCond_score pos_SDQHype_score pos_SDQPeer_score pos_SDQPsoc_score ///
			pos_Depression_score pos_LocusControl optimist ///
			reciprocity1bin reciprocity2bin reciprocity3bin reciprocity4bin ///
			binSatisSchool binSatisHealth binSatisFamily binSatisIncome binSatisWork

local E		IQ_score IQ_factor cgIQ_score cgIQ_factor ///
			votoMaturita votoUni ///
			highschoolGrad MaxEdu_Uni MaxEdu_Grad

local W		PA_Empl SES_self HrsTot WageMonth ///
			Reddito_1 Reddito_2 Reddito_3 Reddito_4 Reddito_5 Reddito_6 Reddito_7

local L		mStatus_married_cohab childrenResp all_houseOwn live_parent 
									
local H		childBMI childz_BMI cgBMI BMI z_BMI ///
			Maria Cig goodHealth SickDays ///
			i_RiskFight i_RiskDUI RiskSuspended Drink1Age									
									
local S		MigrTaste Friends MigrFriend
			
		
local categories 	N H E W L H N S
                    

#delimit cr

*-* Table Label for the Variables
local IQ_factor_lab 			IQ Factor
local likeSchool_child_lab		Child Dislikes School
local childBMI_lab				Child BMI
local childSDQ_score_lab		SDQ Score (Mother Reports)
local RiskSuspended_lab			Ever Suspended
local Smoke_lab					Smokes
local Cig_lab					Num. of Cigarettes Per Day
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
local SickDays_lab				Num. of Days Sick Past Month
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

*-* Regressions
* ---------------------------------------------------------------------------- *
* Regression 1: Reggio (All) vs. Parma/Padova (All)
gen allReggio = (City == 1)

local cohort_i = 1
foreach cohort in `cohorts' {
	foreach var_cat in `categories' {
		foreach var in ``var_cat'' {
		
			sum `var' if Cohort == `cohort_i'
			if r(N) > 0 {
				reg `var' allReggio ``cohort'_baseline_vars' if Cohort == `cohort_i' 
				estimates store `var'_`cohort_i'_1
			/*
			mat rslt = r(table)
			local N_all``var'_short'`cohort' = e(N)
			local R2_all``var'_short'`cohort' = e(r2)
			local R2_all``var'_short'`cohort': di %9.2f `R2_all``var'_short'`cohort''
			
			** Generate locals for the output values (1st row: Beta, 2nd row: Standard Error, 4th row: P-value)
			matrix matb_all``var'_short'`cohort' = rslt["b","allReggio"]
			local b_all``var'_short'`cohort' = matb_all``var'_short'`cohort'[1,1]
			local b_all``var'_short'`cohort': di %9.2f `b_all``var'_short'`cohort''
			
			matrix matse_all``var'_short'`cohort' = rslt["se","allReggio"]
			local se_all``var'_short'`cohort' = matse_all``var'_short'`cohort'[1,1]
			local se_all``var'_short'`cohort': di %9.2f `se_all``var'_short'`cohort''
			local se_all``var'_short'`cohort' (`se_all``var'_short'`cohort'' )
			
			matrix matp_all``var'_short'`cohort' = rslt["pvalue","allReggio"]
			local p_all``var'_short'`cohort' = matp_all``var'_short'`cohort'[1,1]
			local p_all``var'_short'`cohort': di %9.2f `p_all``var'_short'`cohort''
			
			if (`p_all``var'_short'`cohort'' <= 0.1) {
				local b_all``var'_short'`cohort' 	\textbf{`b_all``var'_short'`cohort''}
				local se_all``var'_short'`cohort'	\textbf{`se_all``var'_short'`cohort''}
			}
			*/
			}
		}
		/*
		file open basicreg_all`cohort' using "${git_reggio}/Output/Basic_Regression/basicreg_all`cohort'.tex", write replace
		file write basicreg_all`cohort' "\begin{tabular}{lccc}" _n
		file write basicreg_all`cohort' "\toprule" _n
		file write basicreg_all`cohort' " \textbf{Outcome} & \textbf{Reggio All} & \textbf{N} & \textbf{$ R^2$} \\" _n
		file write basicreg_all`cohort' "\midrule" _n	
		foreach var in ``cohort'_outcome_vars' {
			file write basicreg_all`cohort' "``var'_lab' & `b_all``var'_short'`cohort'' & `N_all``var'_short'`cohort'' & `R2_all``var'_short'`cohort'' \\ " _n
			file write basicreg_all`cohort' " & `se_all``var'_short'`cohort'' & \\" _n
		}
		file write basicreg_all`cohort' "\bottomrule" _n
		file write basicreg_all`cohort' "\end{tabular}" _n
		file close basicreg_all`cohort'
		*/
	}
	local cohort_i = `cohort_i' + 1
	
}
* ---------------------------------------------------------------------------- *
* Regression 2: Reggio Preschool vs. Parma/Padova Preschool
local cohort_i = 1
foreach cohort in `cohorts' {
	foreach var in ``cohort'_outcome_vars' {
		// regression for Reggio (municipal) vs. other Reggio
		sum `var' if Cohort == `cohort_i'
		if r(N) > 0 {
			reg `var' allReggio ``cohort'_baseline_vars' if Cohort == `cohort_i' & materna == 1
			estimates store `var'_`cohort_i'_2
			/*
			mat rslt = r(table)
			local N_pre``var'_short'`cohort' = e(N)
			local R2_pre``var'_short'`cohort' = e(r2)
			local R2_pre``var'_short'`cohort': di %9.2f `R2_pre``var'_short'`cohort''
			
			** Generate locals for the output values (1st row: Beta, 2nd row: Standard Error, 4th row: P-value)
			matrix matb_pre``var'_short'`cohort' = rslt["b","allReggio"]
			local b_pre``var'_short'`cohort' = matb_pre``var'_short'`cohort'[1,1]
			local b_pre``var'_short'`cohort': di %9.2f `b_pre``var'_short'`cohort''
			
			matrix matse_pre``var'_short'`cohort' = rslt["se","allReggio"]
			local se_pre``var'_short'`cohort' = matse_pre``var'_short'`cohort'[1,1]
			local se_pre``var'_short'`cohort': di %9.2f `se_pre``var'_short'`cohort''
			local se_pre``var'_short'`cohort' (`se_pre``var'_short'`cohort'' )
			
			matrix matp_pre``var'_short'`cohort' = rslt["pvalue","allReggio"]
			local p_pre``var'_short'`cohort' = matp_pre``var'_short'`cohort'[1,1]
			local p_pre``var'_short'`cohort': di %9.2f `p_pre``var'_short'`cohort''
			
			if (`p_pre``var'_short'`cohort'' <= 0.1) {
				local b_pre``var'_short'`cohort' 	\textbf{`b_pre``var'_short'`cohort''}
				local se_pre``var'_short'`cohort'	\textbf{`se_pre``var'_short'`cohort''}
			}
			*/
		}
	}
	/*
	file open basicreg_pre`cohort' using "${git_reggio}/Output/Basic_Regression/basicreg_pre`cohort'.tex", write replace
	file write basicreg_pre`cohort' "\begin{tabular}{lccc}" _n
	file write basicreg_pre`cohort' "\toprule" _n
	file write basicreg_pre`cohort' " \textbf{Outcome} & \textbf{Reggio Materna} & \textbf{N} & \textbf{$ R^2$} \\" _n
	file write basicreg_pre`cohort' "\midrule" _n	
	foreach var in ``cohort'_outcome_vars' {
		file write basicreg_pre`cohort' "``var'_lab' & `b_pre``var'_short'`cohort'' & `N_pre``var'_short'`cohort'' & `R2_pre``var'_short'`cohort'' \\ " _n
		file write basicreg_pre`cohort' " & `se_pre``var'_short'`cohort'' & \\" _n
	}
	file write basicreg_pre`cohort' "\bottomrule" _n
	file write basicreg_pre`cohort' "\end{tabular}" _n
	file close basicreg_pre`cohort'
	*/
	local cohort_i = `cohort_i' + 1
} 

* ---------------------------------------------------------------------------- *
* Regression 3: Reggio Municipal Preschool vs. Reggio Other
replace allReggio = xmReggioMuni
local cohort_i = 1
foreach cohort in `cohorts' {
	foreach var in ``cohort'_outcome_vars' {

		sum `var' if Cohort == `cohort_i'
		if r(N) > 0 {
			reg `var' allReggio ``cohort'_baseline_vars' if Cohort == `cohort_i' & materna == 1 & City == 1
			estimates store `var'_`cohort_i'_3
			/*
			mat rslt = r(table)
			local N_pre``var'_short'`cohort' = e(N)
			local R2_pre``var'_short'`cohort' = e(r2)
			local R2_pre``var'_short'`cohort': di %9.2f `R2_pre``var'_short'`cohort''
			
			** Generate locals for the output values (1st row: Beta, 2nd row: Standard Error, 4th row: P-value)
			matrix matb_pre``var'_short'`cohort' = rslt["b","allReggio"]
			local b_pre``var'_short'`cohort' = matb_pre``var'_short'`cohort'[1,1]
			local b_pre``var'_short'`cohort': di %9.2f `b_pre``var'_short'`cohort''
			
			matrix matse_pre``var'_short'`cohort' = rslt["se","allReggio"]
			local se_pre``var'_short'`cohort' = matse_pre``var'_short'`cohort'[1,1]
			local se_pre``var'_short'`cohort': di %9.2f `se_pre``var'_short'`cohort''
			local se_pre``var'_short'`cohort' (`se_pre``var'_short'`cohort'' )
			
			matrix matp_pre``var'_short'`cohort' = rslt["pvalue","allReggio"]
			local p_pre``var'_short'`cohort' = matp_pre``var'_short'`cohort'[1,1]
			local p_pre``var'_short'`cohort': di %9.2f `p_pre``var'_short'`cohort''
			
			if (`p_pre``var'_short'`cohort'' <= 0.1) {
				local b_pre``var'_short'`cohort' 	\textbf{`b_pre``var'_short'`cohort''}
				local se_pre``var'_short'`cohort'	\textbf{`se_pre``var'_short'`cohort''}
			}
			*/
		}
	}
	/*
	file open basicreg_pre`cohort' using "${git_reggio}/Output/Basic_Regression/basicreg_pre`cohort'.tex", write replace
	file write basicreg_pre`cohort' "\begin{tabular}{lccc}" _n
	file write basicreg_pre`cohort' "\toprule" _n
	file write basicreg_pre`cohort' " \textbf{Outcome} & \textbf{Reggio Materna} & \textbf{N} & \textbf{$ R^2$} \\" _n
	file write basicreg_pre`cohort' "\midrule" _n	
	foreach var in ``cohort'_outcome_vars' {
		file write basicreg_pre`cohort' "``var'_lab' & `b_pre``var'_short'`cohort'' & `N_pre``var'_short'`cohort'' & `R2_pre``var'_short'`cohort'' \\ " _n
		file write basicreg_pre`cohort' " & `se_pre``var'_short'`cohort'' & \\" _n
	}
	file write basicreg_pre`cohort' "\bottomrule" _n
	file write basicreg_pre`cohort' "\end{tabular}" _n
	file close basicreg_pre`cohort'
	*/
	local cohort_i = `cohort_i' + 1
} 

/*
* ---------------------------------------------------------------------------- *
* Regression 4: Comparison Among Reggio School Types
local cohort_i = 1
foreach cohort in `cohorts' {
	foreach var in ``cohort'_outcome_vars' {
		// regression for Reggio (municipal) vs. other Reggio
		sum `var' if Cohort == `cohort_i'
		if r(N) > 0 {
			reg `var' xmReggioMuni xmReggioReli xmReggioPriv xmReggioStat ``cohort'_baseline_vars' if Cohort == `cohort_i' & City == 1
			
			mat rslt = r(table)
			local N_reggio``var'_short'`cohort' = e(N)
			local R2_reggio``var'_short'`cohort' = e(r2)
			local R2_reggio``var'_short'`cohort': di %9.2f `R2_reggio``var'_short'`cohort''
			
			** Generate locals for the output values (1st row: Beta, 2nd row: Standard Error, 4th row: P-value)
			foreach type in Muni Reli Priv Stat {
				matrix matb_R`type'``var'_short'`cohort' = rslt["b","xmReggio`type'"]
				local b_R`type'``var'_short'`cohort' = matb_R`type'``var'_short'`cohort'[1,1]
				local b_R`type'``var'_short'`cohort': di %9.2f `b_R`type'``var'_short'`cohort''
				
				matrix matse_R`type'``var'_short'`cohort' = rslt["se","xmReggio`type'"]
				local se_R`type'``var'_short'`cohort' = matse_R`type'``var'_short'`cohort'[1,1]
				local se_R`type'``var'_short'`cohort': di %9.2f `se_R`type'``var'_short'`cohort''
				local se_R`type'``var'_short'`cohort' (`se_R`type'``var'_short'`cohort'' )
				
				matrix matp_R`type'``var'_short'`cohort' = rslt["pvalue","xmReggio`type'"]
				local p_R`type'``var'_short'`cohort' = matp_R`type'``var'_short'`cohort'[1,1]
				local p_R`type'``var'_short'`cohort': di %9.2f `p_R`type'``var'_short'`cohort''
				
				if (`p_R`type'``var'_short'`cohort'' <= 0.1) {
					local b_R`type'``var'_short'`cohort' 	\textbf{`b_R`type'``var'_short'`cohort''}
					local se_R`type'``var'_short'`cohort'	\textbf{`se_R`type'``var'_short'`cohort''}
				}
			}
		}
	}
	
	file open basicreg_pre`cohort' using "${git_reggio}/Output/Basic_Regression/basicreg_reggio`cohort'.tex", write replace
	file write basicreg_pre`cohort' "\begin{tabular}{lcccccc}" _n
	file write basicreg_pre`cohort' "\toprule" _n
	file write basicreg_pre`cohort' " \textbf{Outcome} & \textbf{Municipal} & \textbf{Religious} & \textbf{Private} & \textbf{State} & \textbf{N} & \textbf{$ R^2$} \\" _n
	file write basicreg_pre`cohort' "\midrule" _n	
	foreach var in ``cohort'_outcome_vars' {
		file write basicreg_pre`cohort' "``var'_lab' & `b_RMuni``var'_short'`cohort'' & `b_RReli``var'_short'`cohort'' & `b_RPriv``var'_short'`cohort'' & `b_RStat``var'_short'`cohort'' & `N_reggio``var'_short'`cohort'' & `R2_reggio``var'_short'`cohort'' \\ " _n
		file write basicreg_pre`cohort' " & `se_RMuni``var'_short'`cohort'' & `se_RReli``var'_short'`cohort'' & `se_RPriv``var'_short'`cohort'' & `se_RStat``var'_short'`cohort'' & \\" _n
	}
	file write basicreg_pre`cohort' "\bottomrule" _n
	file write basicreg_pre`cohort' "\end{tabular}" _n
	file close basicreg_pre`cohort'
	
	local cohort_i = `cohort_i' + 1
	
} 

*/

// graphing

local cohort_i = 1
foreach cohort in `cohorts' {
	foreach var in ``cohort'_outcome_vars' {
		sum `var' if Cohort == `cohort_i'
		if r(N) > 0 {
			coefplot 	(`var'_`cohort_i'_1, label(All Reggio vs. All Parma/Padova)) 		///
						(`var'_`cohort_i'_2, label(Muni Reggio vs. Preschool Parma/Padova))	///
						(`var'_`cohort_i'_3, label(Muni Reggio vs. Other Reggio)),			///
						drop(_cons ``cohort'_baseline_vars') xline(0)						///
						graphregion(color(white))
		}
	}
}
