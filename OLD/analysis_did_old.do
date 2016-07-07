* ---------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - Diff-in-Diff for Adult Cohorts
* Authors: Jessica Yu Kyung Koh
* Created: 16 June 2016
* Edited:  16 June 2016
* ---------------------------------------------------------------------------- *
cap file 	close outcomes
cap log 	close

global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio

include ${klmReggio}/Analysis/prepare-data

* ---------------------------------------------------------------------------- *
* Create locals
#delimit ;								
								
local adult_baseline_vars		Male CAPI numSiblings
								momBornProvince
								momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni momMaxEdu_Grad //missing parental edu category: low 
								dadBornProvince 
								dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni dadMaxEdu_Grad
								SES_worker SES_teacher SES_professional;
					
local Adult30_baseline_vars 	`adult_baseline_vars'; 

local Adult40_baseline_vars 	`adult_baseline_vars';

local Adult50_baseline_vars 	`adult_baseline_vars';
								
local adult_outcome_E				IQ_factor votoMaturita votoUni highschoolGrad MaxEdu_Uni MaxEdu_Grad
									PA_Empl SES_self HrsTot WageMonth
									Reddito_1 Reddito_2 Reddito_3 Reddito_4 Reddito_5 Reddito_6 Reddito_7;

local adult_outcome_L				mStatus_married_cohab childrenResp all_houseOwn live_parent; 
									
local adult_outcome_H				Maria Smoke Cig BMI Health SickDays 
									i_RiskFight i_RiskDUI RiskSuspended Drink1Age;									
									
local adult_outcome_N				LocusControl Depression_score
									binSatisIncome binSatisWork binSatisHealth binSatisFamily
									optimist reciprocity1bin reciprocity2bin reciprocity3bin reciprocity4bin;					
									
                
local cohorts					Child Migrant Adolescent Adult30 Adult40 Adult50;
local cities					Reggio Parma Padova;
local schools					Municipal State Religious Private None;                      

#delimit cr

* Label
local IQ_factor_lab 			IQ Factor
local votoMaturita_lab			High School Grade
local votoUni_lab				University Grade
local highschoolGrad_lab		Graduate from High School
local MaxEdu_Uni_lab			Max Edu: University
local MaxEdu_Grad_lab			Max Edu: Graduate School
local PA_Empl_lab				Employed
local SES_self_lab				Self-Employed
local HrsTot_lab				Hours Worked Per Week
local WageMonth_lab				Monthly Wage
local Reddito_1_lab				H. Income: 5,000 Euros of Less
local Reddito_2_lab				H. Income: 5,001-10,000 Euros
local Reddito_3_lab				H. Income: 10,001-25,000 Euros
local Reddito_4_lab				H. Income: 25,001-50,000 Euros
local Reddito_5_lab				H. Income: 50,001-100,000 Euros
local Reddito_6_lab				H. Income: 100,001-250,000 Euros
local Reddito_7_lab				H. Income: More than 250,000 Euros

local mStatus_married_cohab_lab Married or Cohabitating
local childrenResp_lab			Num. of Children in House
local all_houseOwn_lab			Own House
local live_parent_lab			Live With Parents

local Maria_lab					Tried Marijuana
local Smoke_lab					Smokes
local Cig_lab					Num. of Cigarettes Per Day
local BMI_lab					BMI
local Health_lab				Bad Health
local SickDays_lab				Num. of Days Sick Past Month
local i_RiskDUI_lab				Drove Under Influence 
local i_RiskFight_lab			Engaged in A Fight 
local RiskSuspended_lab			Ever Suspended from School
local Drink1Age_lab				Age At First Drink

local LocusControl_lab			Locus of Control
local Depression_score_lab		Depression Score
local binSatisIncome_lab		Satisfied with Income
local binSatisWork_lab			Satisfied with Work
local binSatisHealth_lab 		Satisfied with Health 
local binSatisFamily_lab		Satisfied with Family
local optimist_lab				Optimistic Look on Life
local reciprocity1bin_lab		Return Favor 
local reciprocity2bin_lab		Put Someone in Difficulty
local reciprocity3bin_lab		Help Someone Kind To Me
local reciprocity4bin_lab 		Insult Back


*-* Short Name for Variables
local IQ_factor_short 			IQ
local votoMaturita_short		HSG
local votoUni_short				UNG
local highschoolGrad_short		GHS
local MaxEdu_Uni_short			UNI
local MaxEdu_Grad_short			GSC
local PA_Empl_short				EMP
local SES_self_short			SEM
local HrsTot_short				HWW
local WageMonth_short			WAG
local Reddito_1_short			HI1
local Reddito_2_short			HI2
local Reddito_3_short			HI3
local Reddito_4_short			HI4
local Reddito_5_short			HI5
local Reddito_6_short			HI6
local Reddito_7_short			HI7

local mStatus_married_cohab_short MC
local childrenResp_short		 NCH
local all_houseOwn_short		 OWN
local live_parent_short			 LWP

local Maria_short				MAR
local Smoke_short				SMO
local Cig_short					CIG
local BMI_short					BMI
local Health_short				BHEL
local SickDays_short			SICK
local i_RiskDUI_short			DUI
local i_RiskFight_short			FIG
local RiskSuspended_short		SFS
local Drink1Age_short			DAG

local LocusControl_short		LC
local Depression_score_short	DS
local binSatisIncome_short		SI
local binSatisWork_short		SW
local binSatisHealth_short 		SH 
local binSatisFamily_short		SF
local optimist_short			OPT
local reciprocity1bin_short		RC1 
local reciprocity2bin_short		RC2
local reciprocity3bin_short		RC3
local reciprocity4bin_short 	RC4


* ---------------------------------------------------------------------------- *
* Preparation 

** Keep only the adult cohorts
keep if (Cohort == 4) | (Cohort == 5) | (Cohort == 6)

** Gender condition
local p_con	
local m_con		& Male == 1
local f_con		& Male == 0

** Create dummy for school types
generate maternaNone = (maternaType == 0)
generate maternaMuni = (maternaType == 1)
generate maternaStat = (maternaType == 2)
generate maternaReli = (maternaType == 3)
generate maternaPriv = (maternaType == 4)

** Create interaction terms between school type and adult age cohort (except maternaMuni and age 50)
foreach type in None Stat Reli Priv {
	foreach age in Adult30 Adult40 {
		generate xm`type'`age' = materna`type' * Cohort_`age'
	}
}

** Create interaction terms between school type and city (except Reggio and maternaMuni)
foreach type in None Stat Reli Priv {
	foreach city in Parma Padova {
		generate xm`type'`city' = materna`type' * `city'
	}
}


* ---------------------------------------------------------------------------- *
* Regression: Fix City
* ---------------------------------------------------------------------------- *
local X		Cohort_Adult30 Cohort_Adult40 maternaNone maternaStat maternaReli maternaPriv ///
			xmNoneAdult30 xmStatAdult30 xmReliAdult30 xmPrivAdult30 ///
			xmNoneAdult40 xmStatAdult40 xmReliAdult40 xmPrivAdult40 

local 30_l 		Cohort_Adult30 
local 40_l		Cohort_Adult40 
local N_l		maternaNone 
local S_l		maternaStat 
local R_l		maternaReli 
local P_l		maternaPriv 
local 30N_l		xmNoneAdult30 
local 30S_l		xmStatAdult30 
local 30R_l		xmReliAdult30 
local 30P_l		xmPrivAdult30 
local 40N_l		xmNoneAdult40 
local 40S_l		xmStatAdult40 
local 40R_l		xmReliAdult40 
local 40P_l		xmPrivAdult40 	
			
			
foreach g in p m f  {
	foreach o in E L H N {
		foreach city in Reggio Parma Padova {
			foreach var in `adult_outcome_`o'' {
				* Estimate
				sum `var' if `city' == 1 ``g'_con'
				if r(N) > 0 {
					reg `var' `X' `adult_baseline_vars' if `city' == 1 ``g'_con'
					mat rslt = r(table)
					local N_R``var'_short'`o'_`g'`city' = e(N)
					local R2_R``var'_short'`o'_`g'`city' = e(r2)
					local R2_R``var'_short'`o'_`g'`city': di %9.2f `R2_R``var'_short'`o'_`g'`city''
					
					** Generate locals for the output values (1st row: Beta, 2nd row: Standard Error, 4th row: P-value)
					foreach i in 30 40 N S R P 30N 30S 30R 30P 40N 40S 40R 40P {
						matrix matb_R``var'_short'`o'_`g'`city'_`i' = rslt["b","``i'_l'"]
						local b_R``var'_short'`o'_`g'`city'_`i' = matb_R``var'_short'`o'_`g'`city'_`i'[1,1]
						local b_R``var'_short'`o'_`g'`city'_`i': di %9.2f `b_R``var'_short'`o'_`g'`city'_`i''
						
						matrix matse_R``var'_short'`o'_`g'`city'_`i' = rslt["se","``i'_l'"]
						local se_R``var'_short'`o'_`g'`city'_`i' = matse_R``var'_short'`o'_`g'`city'_`i'[1,1]
						local se_R``var'_short'`o'_`g'`city'_`i': di %9.2f `se_R``var'_short'`o'_`g'`city'_`i''
						local se_R``var'_short'`o'_`g'`city'_`i' (`se_R``var'_short'`o'_`g'`city'_`i'' )
						
						matrix matp_R``var'_short'`o'_`g'`city'_`i' = rslt["pvalue","``i'_l'"]
						local p_R``var'_short'`o'_`g'`city'_`i' = matp_R``var'_short'`o'_`g'`city'_`i'[1,1]
						local p_R``var'_short'`o'_`g'`city'_`i': di %9.2f `p_R``var'_short'`o'_`g'`city'_`i''
						
						if (`p_R``var'_short'`o'_`g'`city'_`i'' <= 0.1) {
							local b_R``var'_short'`o'_`g'`city'_`i' 	\textbf{`b_R``var'_short'`o'_`g'`city'_`i''}
							local se_R``var'_short'`o'_`g'`city'_`i'	\textbf{`se_R``var'_short'`o'_`g'`city'_`i''}
						}
					}					
				}		
			}
			
		* Make LaTeX table for Single Dummies
		file open d_`type'_`o'`g' using "${git_reggio}/Output/DiD/single`city'_`o'`g'.tex", write replace
		file write d_`type'_`o'`g' "\begin{tabular}{L{6.2cm} C{1.8cm} C{1.8cm} C{1.8cm} C{1.8cm} C{1.8cm} C{1.8cm} C{0.3cm} C{0.3cm}}" _n
		file write d_`type'_`o'`g' "\toprule" _n
		file write d_`type'_`o'`g' " \textbf{Outcome} & \textbf{Age 30 Muni} & \textbf{Age 40 Muni} & \textbf{Age 50 None} & \textbf{Age 50 Stat} & \textbf{Age 50 Reli} & \textbf{N} & \textbf{$ R^2$} \\" _n
		file write d_`type'_`o'`g' "\midrule" _n	
		foreach var in `adult_outcome_`o'' {
			file write d_`type'_`o'`g' "``var'_lab' & `b_R``var'_short'`o'_`g'`city'_30' & `b_R``var'_short'`o'_`g'`city'_40' & `b_R``var'_short'`o'_`g'`city'_N' & `b_R``var'_short'`o'_`g'`city'_S' & `b_R``var'_short'`o'_`g'`city'_R'  & `N_R``var'_short'`o'_`g'`city'' &  `R2_R``var'_short'`o'_`g'`city'' \\ " _n
			file write d_`type'_`o'`g' " & `se_R``var'_short'`o'_`g'`city'_30' & `se_R``var'_short'`o'_`g'`city'_40' & `se_R``var'_short'`o'_`g'`city'_N' & `se_R``var'_short'`o'_`g'`city'_S' & `se_R``var'_short'`o'_`g'`city'_R'  & \\" _n
		}
		file write d_`type'_`o'`g' "\bottomrule" _n
		file write d_`type'_`o'`g' "\end{tabular}" _n
		file close d_`type'_`o'`g'
		
		
		* Make LaTeX table for Diff-in-Diff
	    file open did_`type'_`o'`g' using "${git_reggio}/Output/DiD/did`city'_`o'`g'.tex", write replace
		file write did_`type'_`o'`g' "\begin{tabular}{lcccccccc}" _n
		file write did_`type'_`o'`g' "\toprule" _n
		file write did_`type'_`o'`g' " & \multicolumn{3}{c}{\textbf{Comparing with Age 30 Cohort}} & \multicolumn{3}{c}{\textbf{Comparing with Age 40 Cohort}} & \\" _n
		file write did_`type'_`o'`g' "\cmidrule(lr){2-4} \cmidrule(lr){5-7} " _n
		file write did_`type'_`o'`g' " \textbf{Outcome} & \textbf{(1)} & \textbf{(2)} & \textbf{(3)} & \textbf{(4)} & \textbf{(5)} & \textbf{(6)} & \textbf{N} & \textbf{$ R^2$} \\" _n
		file write did_`type'_`o'`g' "\midrule" _n	
		foreach var in `adult_outcome_`o'' {
			file write did_`type'_`o'`g' "``var'_lab' & `b_R``var'_short'`o'_`g'`city'_30N' & `b_R``var'_short'`o'_`g'`city'_30S' & `b_R``var'_short'`o'_`g'`city'_30R' & `b_R``var'_short'`o'_`g'`city'_40N' & `b_R``var'_short'`o'_`g'`city'_40S' & `b_R``var'_short'`o'_`g'`city'_40R' & `N_R``var'_short'`o'_`g'`city'' &  `R2_R``var'_short'`o'_`g'`city'' \\ " _n
			file write did_`type'_`o'`g' " & `se_R``var'_short'`o'_`g'`city'_30N' & `se_R``var'_short'`o'_`g'`city'_30S' & `se_R``var'_short'`o'_`g'`city'_30R' & `se_R``var'_short'`o'_`g'`city'_40N' & `se_R``var'_short'`o'_`g'`city'_40S' & `se_R``var'_short'`o'_`g'`city'_40R' & \\" _n
		}
		file write did_`type'_`o'`g' "\bottomrule" _n
		file write did_`type'_`o'`g' "\end{tabular}" _n
		file close did_`type'_`o'`g'
		}
	}
}

* ---------------------------------------------------------------------------- *
* Regression: Fix Cohort
* ---------------------------------------------------------------------------- *
local X		Parma Padova maternaNone maternaStat maternaReli maternaPriv ///
			xmNoneParma xmStatParma xmReliParma xmPrivParma ///
			xmNonePadova xmStatPadova xmReliPadova xmPrivPadova

local M_l 		Parma
local V_l		Padova 
local N_l		maternaNone 
local S_l		maternaStat 
local R_l		maternaReli 
local P_l		maternaPriv 
local MN_l		xmNoneParma
local MS_l		xmStatParma
local MR_l		xmReliParma 
local MP_l		xmPrivParma
local VN_l		xmNonePadova 
local VS_l		xmStatPadova 
local VR_l		xmReliPadova 
local VP_l		xmPrivPadova 	
			
			
foreach g in p m f  {
	foreach o in E L H N {
		foreach cohort in Adult30 Adult40 Adult50 {
			foreach var in `adult_outcome_`o'' {
				* Estimate
				sum `var' if Cohort_`cohort' == 1 ``g'_con'
				if r(N) > 0 {
					reg `var' `X' `adult_baseline_vars' if Cohort_`cohort' == 1 ``g'_con'
					mat rslt = r(table)
					local N_R``var'_short'`o'_`g'`cohort' = e(N)
					local R2_R``var'_short'`o'_`g'`cohort' = e(r2)
					local R2_R``var'_short'`o'_`g'`cohort': di %9.2f `R2_R``var'_short'`o'_`g'`cohort''
					
					** Generate locals for the output values (1st row: Beta, 2nd row: Standard Error, 4th row: P-value)
					foreach i in M V N S R P MN MS MR MP VN VS VR VP {
						matrix matb_R``var'_short'`o'_`g'`cohort'_`i' = rslt["b","``i'_l'"]
						local b_R``var'_short'`o'_`g'`cohort'_`i' = matb_R``var'_short'`o'_`g'`cohort'_`i'[1,1]
						local b_R``var'_short'`o'_`g'`cohort'_`i': di %9.2f `b_R``var'_short'`o'_`g'`cohort'_`i''
						
						matrix matse_R``var'_short'`o'_`g'`cohort'_`i' = rslt["se","``i'_l'"]
						local se_R``var'_short'`o'_`g'`cohort'_`i' = matse_R``var'_short'`o'_`g'`cohort'_`i'[1,1]
						local se_R``var'_short'`o'_`g'`cohort'_`i': di %9.2f `se_R``var'_short'`o'_`g'`cohort'_`i''
						local se_R``var'_short'`o'_`g'`cohort'_`i' (`se_R``var'_short'`o'_`g'`cohort'_`i'' )
						
						matrix matp_R``var'_short'`o'_`g'`cohort'_`i' = rslt["pvalue","``i'_l'"]
						local p_R``var'_short'`o'_`g'`cohort'_`i' = matp_R``var'_short'`o'_`g'`cohort'_`i'[1,1]
						local p_R``var'_short'`o'_`g'`cohort'_`i': di %9.2f `p_R``var'_short'`o'_`g'`cohort'_`i''
						
						if (`p_R``var'_short'`o'_`g'`cohort'_`i'' <= 0.1) {
							local b_R``var'_short'`o'_`g'`cohort'_`i' 	\textbf{`b_R``var'_short'`o'_`g'`cohort'_`i''}
							local se_R``var'_short'`o'_`g'`cohort'_`i'	\textbf{`se_R``var'_short'`o'_`g'`cohort'_`i''}
						}
					}					
				}		
			}
			
		* Make LaTeX table for Single Dummies
		file open d_`type'_`o'`g' using "${git_reggio}/Output/DiD/single`cohort'_`o'`g'.tex", write replace
		file write d_`type'_`o'`g' "\begin{tabular}{L{6.2cm} C{1.8cm} C{1.8cm} C{1.8cm} C{1.8cm} C{1.8cm} C{1.8cm} C{0.3cm} C{0.3cm}}" _n
		file write d_`type'_`o'`g' "\toprule" _n
		file write d_`type'_`o'`g' " \textbf{Outcome} & \textbf{Parma Muni} & \textbf{Padova Muni} & \textbf{Reggio None} & \textbf{Reggio Stat} & \textbf{Reggio Reli} & \textbf{N} & \textbf{$ R^2$} \\" _n
		file write d_`type'_`o'`g' "\midrule" _n	
		foreach var in `adult_outcome_`o'' {
			file write d_`type'_`o'`g' "``var'_lab' & `b_R``var'_short'`o'_`g'`cohort'_M' & `b_R``var'_short'`o'_`g'`cohort'_V' & `b_R``var'_short'`o'_`g'`cohort'_N' & `b_R``var'_short'`o'_`g'`cohort'_S' & `b_R``var'_short'`o'_`g'`cohort'_R'  & `N_R``var'_short'`o'_`g'`cohort'' &  `R2_R``var'_short'`o'_`g'`cohort'' \\ " _n
			file write d_`type'_`o'`g' " & `se_R``var'_short'`o'_`g'`cohort'_M' & `se_R``var'_short'`o'_`g'`cohort'_V' & `se_R``var'_short'`o'_`g'`cohort'_N' & `se_R``var'_short'`o'_`g'`cohort'_S' & `se_R``var'_short'`o'_`g'`cohort'_R'  & \\" _n
		}
		file write d_`type'_`o'`g' "\bottomrule" _n
		file write d_`type'_`o'`g' "\end{tabular}" _n
		file close d_`type'_`o'`g'
		
		
		* Make LaTeX table for Diff-in-Diff
	    file open did_`type'_`o'`g' using "${git_reggio}/Output/DiD/did`cohort'_`o'`g'.tex", write replace
		file write did_`type'_`o'`g' "\begin{tabular}{lcccccccc}" _n
		file write did_`type'_`o'`g' "\toprule" _n
		file write did_`type'_`o'`g' " & \multicolumn{3}{c}{\textbf{Comparing with Parma}} & \multicolumn{3}{c}{\textbf{Comparing with Padova}} & \\" _n
		file write did_`type'_`o'`g' "\cmidrule(lr){2-4} \cmidrule(lr){5-7} " _n
		file write did_`type'_`o'`g' " \textbf{Outcome} & \textbf{(1)} & \textbf{(2)} & \textbf{(3)} & \textbf{(4)} & \textbf{(5)} & \textbf{(6)} & \textbf{N} & \textbf{$ R^2$} \\" _n
		file write did_`type'_`o'`g' "\midrule" _n	
		foreach var in `adult_outcome_`o'' {
			file write did_`type'_`o'`g' "``var'_lab' & `b_R``var'_short'`o'_`g'`cohort'_MN' & `b_R``var'_short'`o'_`g'`cohort'_MS' & `b_R``var'_short'`o'_`g'`cohort'_MR' & `b_R``var'_short'`o'_`g'`cohort'_VN' & `b_R``var'_short'`o'_`g'`cohort'_VS' & `b_R``var'_short'`o'_`g'`cohort'_VR' & `N_R``var'_short'`o'_`g'`cohort'' &  `R2_R``var'_short'`o'_`g'`cohort'' \\ " _n
			file write did_`type'_`o'`g' " & `se_R``var'_short'`o'_`g'`cohort'_MN' & `se_R``var'_short'`o'_`g'`cohort'_MS' & `se_R``var'_short'`o'_`g'`cohort'_MR' & `se_R``var'_short'`o'_`g'`cohort'_VN' & `se_R``var'_short'`o'_`g'`cohort'_VS' & `se_R``var'_short'`o'_`g'`cohort'_VR' & \\" _n
		}
		file write did_`type'_`o'`g' "\bottomrule" _n
		file write did_`type'_`o'`g' "\end{tabular}" _n
		file close did_`type'_`o'`g'
		}
	}
}
