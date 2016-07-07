* ---------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - Linear Probability Model (Pooled Ver.)
* Authors: Jessica Yu Kyung Koh
* Created: 08 June 2016
* Edited:  10 June 2016
* ---------------------------------------------------------------------------- *

capture log close
clear all
set more off
set maxvar 32000

* ---------------------------------------------------------------------------- *
* Set directory
global klmReggio	: 	env klmReggio		
global data_reggio	: 	env data_reggio
global git_reggio   : 	env git_reggio

* Prepare the data for the analysis, creating variables and locals
include ${klmReggio}/Analysis/prepare-data.do

cd ${klmReggio}/Analysis/Output/


* Locals for Controls (need to exclude Male because this analysis divide the sample by gender)
   * Note: Make sure controls are all binary variables for the purpose of linear probability model.
** Controls
local XcontrolRes       Male CAPI lowbirthweight birthpremature               
local XcontrolMom		momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni teenMomBirth momBornProvince // missing cat: low edu
local XcontrolDad		dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni teenDadBirth dadBornProvince 
local XcontrolHouse		cgRelig houseOwn cgReddito_2 cgReddito_3 cgReddito_4 cgReddito_5 cgReddito_6 cgReddito_7 // missing cat: income below 5,000
                                                                                                                   
local Xright            `XcontrolRes' `XcontrolMom' `XcontrolDad' `XcontrolHouse'

* Options to only include main_terms
local outregOption	  bracket label dec(3) // 

* Local for gender
local gender0	Female
local gender1	Male

* Create Teenage Mother and Father at Birth variables
generate teenMomBirth = momAgeBirth < 20
generate teenDadBirth = dadAgeBirth < 20
label var teenMomBirth "(Derived) Teenage mother at birth"
label var teenDadBirth "(Derived) Teenage father at birth"

* ---------------------------------------------------------------------------- *
** Run regressions and save the outputs
log using analysis_mlogit, replace 

* Locals
** Basic
local Child_lab		Children
local Migr_lab		Migrants
local Adol_lab		Adolescents
local Adult30_lab	Adults (Age 30)
local Adult40_lab	Adults (Age 40)
local Adult50_lab	Adults (Age 50)

local 0_note		females
local 1_note		males
local Child_note	children
local Migr_note		migrants
local Adol_note		adolescents
local Adult30_note	adults in their 30's
local Adult40_note	adults in their 40's
local Adult50_note	adults in their 50's

** Variables
local Male_lab		Male
local CAPI_lab 					CAPI
local lowbirthweight_lab 		Low Birthweight
local birthpremature_lab     	Premature at Birth          
local momMaxEdu_middle_lab 		Max Education: Middle School
local momMaxEdu_HS_lab 			Max Education: High School
local momMaxEdu_Uni_lab 		Max Education: University
local teenMomBirth_lab 			Teenager at Birth
local momBornProvince_lab 		Born in Province
local dadMaxEdu_middle_lab 		Max Education: Middle School
local dadMaxEdu_HS_lab 			Max Education: High School
local dadMaxEdu_Uni_lab 		Max Education: University
local teenDadBirth_lab 			Teenager at Birth
local dadBornProvince_lab 		Born in Province
local cgRelig_lab 				Caregiver Has Religion
local houseOwn_lab 				Owns House
local cgReddito_2_lab 			Income 5K-10K Euro
local cgReddito_3_lab 			Income 10K-25K Euro
local cgReddito_4_lab 			Income 25K-50K Euro
local cgReddito_5_lab 			Income 50K-100K Euro
local cgReddito_6_lab 			Income 100K-250K Euro
local cgReddito_7_lab  			Income More Than 250K Euro

** Variables_short
local CAPI_short 					CP
local lowbirthweight_short 			LB
local birthpremature_short     		PB          
local momMaxEdu_middle_short 		MMS
local momMaxEdu_HS_short 			MHS
local momMaxEdu_Uni_short 			MUN
local teenMomBirth_short 			MTB
local momBornProvince_short 		MBP
local dadMaxEdu_middle_short 		DMS
local dadMaxEdu_HS_short 			DHS
local dadMaxEdu_Uni_short 			DUN
local teenDadBirth_short 			DTB
local dadBornProvince_short 		DBP
local cgRelig_short 				RL
local houseOwn_short 				OH
local cgReddito_2_short 			I5
local cgReddito_3_short 			I10
local cgReddito_4_short 			I25
local cgReddito_5_short 			I50
local cgReddito_6_short 			IH
local cgReddito_7_short  			IM


/* Asilo (Age 0-3)
local city_val = 1
foreach city in Reggio Parma Padova {

	local cohort_val = 1
	foreach cohort in Child Migr Adol Adult30 Adult40 Adult50  { 


	
		file open lpm`city'`cohort'_a using "${git_reggio}/Output/LPM/lpm_`city'`cohort'_a.tex", write replace
		file write lpm`city'`cohort'_a "\begin{table}[H]" _n
		file write lpm`city'`cohort'_a "\caption{LPM Estimation - `city' - ``cohort'_lab', Asilo}" _n
		file write lpm`city'`cohort'_a "\centering" _n
		file write lpm`city'`cohort'_a "\scalebox{0.7}{" _n
		file write lpm`city'`cohort'_a "\begin{tabular}{lcccc}" _n
		file write lpm`city'`cohort'_a "\toprule" _n
		file write lpm`city'`cohort'_a " & \textbf{None} & \textbf{Municipal} & \textbf{Religious} & \textbf{Private} \\" _n
		file write lpm`city'`cohort'_a "\midrule" _n
	
		foreach type in None Muni Reli Priv {

			di "`cohort'"
			local large_sample_condition largeSample_`age'`cohort'`city' == 1
			
			** Generate large sample (all missing are imputed to zero and converted into dummies)
			quietly reg xa`city'`type'`cohort' `Xright' if (Cohort == `cohort_val') & (City == `city_val') 
			capture gen largeSample_`age'`cohort'`city' = e(sample)	
			tab largeSample_`age'`cohort'`city'

			** Run regressions and store results into latex
			di "Running the regressions for Asilo `type' `city' `type' `cohort'"
			reg xa`city'`type'`cohort' `Xright' if (Cohort == `cohort_val') & (City == `city_val')   
			mat rslt = r(table)	
			local N`city'`type'`cohort' = e(N)
			local R2`city'`type'`cohort' = e(r2)
			local R2`city'`type'`cohort': di %9.2f `R2`city'`type'`cohort''
			
			sum xa`city'`type'`cohort' if (Cohort == `cohort_val') & (City == `city_val') & (xa`city'`type'`cohort' == 1)
			local NN`city'`type'`cohort' = r(N)
		
			local frac`city'`type'`cohort' = `NN`city'`type'`cohort''/`N`city'`type'`cohort''
			local frac`city'`type'`cohort': di %9.2f `frac`city'`type'`cohort''
		
			** Generate locals for the output values (1st row: Beta, 2nd row: Standard Error, 4th row: P-value)
			foreach sub in Res Mom Dad House {
				foreach var in `Xcontrol`sub''  { 
						matrix matxa_b``var'_short'`city'`type'`cohort' = rslt["b","`var'"]
						local xa_b``var'_short'`city'`type'`cohort' = matxa_b``var'_short'`city'`type'`cohort'[1,1]
						local xa_b``var'_short'`city'`type'`cohort': di %9.2f `xa_b``var'_short'`city'`type'`cohort''
						
						matrix matxa_se``var'_short'`city'`type'`cohort' = rslt["se","`var'"]
						local xa_se``var'_short'`city'`type'`cohort' = matxa_se``var'_short'`city'`type'`cohort'[1,1]
						local xa_se``var'_short'`city'`type'`cohort': di %9.2f `xa_se``var'_short'`city'`type'`cohort''
						local xa_se``var'_short'`city'`type'`cohort' (`xa_se``var'_short'`city'`type'`cohort'' )
					
						matrix matxa_pval``var'_short'`city'`type'`cohort' = rslt["pvalue","`var'"]
						local xa_pval``var'_short'`city'`type'`cohort' = matxa_pval``var'_short'`city'`type'`cohort'[1,1]
						local xa_pval``var'_short'`city'`type'`cohort': di %9.2f `xa_pval``var'_short'`city'`type'`cohort''
						di "`var' `xa_pval``var'_short'`city'`type'`cohort''"
						
						if (`xa_pval``var'_short'`city'`type'`cohort'' <= 0.1) { // Boldify (?) the statistically significant result
		
							local xa_b``var'_short'`city'`type'`cohort' 	\textbf{`xa_b``var'_short'`city'`type'`cohort''}
							local xa_se``var'_short'`city'`type'`cohort'	\textbf{`xa_se``var'_short'`city'`type'`cohort''}							
						
						}	
					}
				}						
			}		
	
		file write lpm`city'`cohort'_a "\textbf{Respondent's Baseline Info} \\" _n
		foreach var in `XcontrolRes' {
			if !((`xa_pval``var'_short'`city'None`cohort'' == .) & (`xa_pval``var'_short'`city'Muni`cohort'' == .) & (`xa_pval``var'_short'`city'Reli`cohort'' == .) & (`xa_pval``var'_short'`city'Priv`cohort'' == .)) {
				file write lpm`city'`cohort'_a	"\quad ``var'_lab' & `xa_b``var'_short'`city'None`cohort'' & `xa_b``var'_short'`city'Muni`cohort'' & `xa_b``var'_short'`city'Reli`cohort'' & `xa_b``var'_short'`city'Priv`cohort'' \\" _n
				file write lpm`city'`cohort'_a	"\quad  & `xa_se``var'_short'`city'None`cohort'' & `xa_se``var'_short'`city'Muni`cohort''  & `xa_se``var'_short'`city'Reli`cohort''  & `xa_se``var'_short'`city'Priv`cohort''  \\" _n
	*			file write lpm`city'`cohort'`gender'	"\quad  & (`xa_pval``var'_short'`city'None`cohort'`gender'' ) & (`xa_pval``var'_short'`city'Muni`cohort'`gender'' ) & (`xa_pval``var'_short'`city'Reli`cohort'`gender'' ) & (`xa_pval``var'_short'`city'Priv`cohort'`gender'' ) \\" _n
			}
		}
		file write lpm`city'`cohort'_a "\midrule" _n
		
		file write lpm`city'`cohort'_a "\textbf{Mother's Baseline Info} \\" _n
		foreach var in `XcontrolMom' {
			if !((`xa_pval``var'_short'`city'None`cohort'' == .) & (`xa_pval``var'_short'`city'Muni`cohort'' == .) & (`xa_pval``var'_short'`city'Reli`cohort'' == .) & (`xa_pval``var'_short'`city'Priv`cohort'' == .)) {
				file write lpm`city'`cohort'_a	"\quad ``var'_lab' & `xa_b``var'_short'`city'None`cohort'' & `xa_b``var'_short'`city'Muni`cohort'' & `xa_b``var'_short'`city'Reli`cohort'' & `xa_b``var'_short'`city'Priv`cohort'' \\" _n
				file write lpm`city'`cohort'_a	"\quad  & `xa_se``var'_short'`city'None`cohort'' & `xa_se``var'_short'`city'Muni`cohort''  & `xa_se``var'_short'`city'Reli`cohort''  & `xa_se``var'_short'`city'Priv`cohort''  \\" _n
	*			file write lpm`city'`cohort'`gender'	"\quad  & (`xa_pval``var'_short'`city'None`cohort'`gender'' ) & (`xa_pval``var'_short'`city'Muni`cohort'`gender'' ) & (`xa_pval``var'_short'`city'Reli`cohort'`gender'' ) & (`xa_pval``var'_short'`city'Priv`cohort'`gender'' ) \\" _n
			}
		}
		file write lpm`city'`cohort'_a "\midrule" _n
		
		file write lpm`city'`cohort'_a "\textbf{Father's Baseline Info} \\" _n
		foreach var in `XcontrolDad' {
			if !((`xa_pval``var'_short'`city'None`cohort'' == .) & (`xa_pval``var'_short'`city'Muni`cohort'' == .) & (`xa_pval``var'_short'`city'Reli`cohort'' == .) & (`xa_pval``var'_short'`city'Priv`cohort'' == .)) {
				file write lpm`city'`cohort'_a	"\quad ``var'_lab' & `xa_b``var'_short'`city'None`cohort'' & `xa_b``var'_short'`city'Muni`cohort'' & `xa_b``var'_short'`city'Reli`cohort'' & `xa_b``var'_short'`city'Priv`cohort'' \\" _n
				file write lpm`city'`cohort'_a	"\quad  & `xa_se``var'_short'`city'None`cohort'' & `xa_se``var'_short'`city'Muni`cohort''  & `xa_se``var'_short'`city'Reli`cohort''  & `xa_se``var'_short'`city'Priv`cohort''  \\" _n
	*			file write lpm`city'`cohort'`gender'	"\quad  & (`xa_pval``var'_short'`city'None`cohort'`gender'' ) & (`xa_pval``var'_short'`city'Muni`cohort'`gender'' ) & (`xa_pval``var'_short'`city'Reli`cohort'`gender'' ) & (`xa_pval``var'_short'`city'Priv`cohort'`gender'' ) \\" _n
			}
		}
		file write lpm`city'`cohort'_a "\midrule" _n
		
		file write lpm`city'`cohort'_a "\textbf{Household Baseline Info} \\" _n
		foreach var in `XcontrolHouse' {
			if !((`xa_pval``var'_short'`city'None`cohort'' == .) & (`xa_pval``var'_short'`city'Muni`cohort'' == .) & (`xa_pval``var'_short'`city'Reli`cohort'' == .) & (`xa_pval``var'_short'`city'Priv`cohort'' == .)) {
				file write lpm`city'`cohort'_a	"\quad ``var'_lab' & `xa_b``var'_short'`city'None`cohort'' & `xa_b``var'_short'`city'Muni`cohort'' & `xa_b``var'_short'`city'Reli`cohort'' & `xa_b``var'_short'`city'Priv`cohort'' \\" _n
				file write lpm`city'`cohort'_a	"\quad  & `xa_se``var'_short'`city'None`cohort'' & `xa_se``var'_short'`city'Muni`cohort''  & `xa_se``var'_short'`city'Reli`cohort''  & `xa_se``var'_short'`city'Priv`cohort''  \\" _n
	*			file write lpm`city'`cohort'`gender'	"\quad  & (`xa_pval``var'_short'`city'None`cohort'`gender'' ) & (`xa_pval``var'_short'`city'Muni`cohort'`gender'' ) & (`xa_pval``var'_short'`city'Reli`cohort'`gender'' ) & (`xa_pval``var'_short'`city'Priv`cohort'`gender'' ) \\" _n
			}
		}
		file write lpm`city'`cohort'_a "\midrule" _n
		file write lpm`city'`cohort'_a "Observations & `N`city'None`cohort'' & `N`city'Muni`cohort'' & `N`city'Reli`cohort'' & `N`city'Priv`cohort'' \\" _n
		file write lpm`city'`cohort'_a "Fraction Attending Each Type & `frac`city'None`cohort'' & `frac`city'Muni`cohort'' & `frac`city'Reli`cohort'' & `frac`city'Priv`cohort'' \\" _n
		file write lpm`city'`cohort'_a "\midrule" _n
		file write lpm`city'`cohort'_a "$ R^2$ & `R2`city'None`cohort'' & `R2`city'Muni`cohort'' & `R2`city'Reli`cohort'' & `R2`city'Priv`cohort'' \\" _n
		file write lpm`city'`cohort'_a "\bottomrule" _n
		file write lpm`city'`cohort'_a "\end{tabular}}" _n
		file write lpm`city'`cohort'_a "\end{table}" _n
		file write lpm`city'`cohort'_a "\begin{scriptsize}" _n
		file write lpm`city'`cohort'_a "\noindent\underline{Note:} This table presents the linear probability model estimations for attending each type of Asilo schools, indicated by each column. The samples used in this estimation are those who were ``cohort'_note' at the time of the survey living in `city'. All dependent variables are binary. Observation indicates the number of people included in this sample. Bold number indicates that the p-value is less than or equal to 0.1. Standard errors are reported in parentheses." _n
		file write lpm`city'`cohort'_a "\end{scriptsize}" _n
		file close lpm`city'`cohort'_a 
		
		local cohort_val = `cohort_val' + 1
	}
	local city_val = `city_val' + 1
}	*/




* Materna (Age 3-5)
* Asilo (Age 0-3)
local city_val = 1
foreach city in Reggio Parma Padova {

	local cohort_val = 1
	foreach cohort in Child Migr Adol Adult30 Adult40 Adult50  { 

	
		file open lpm`city'`cohort'_m using "${git_reggio}/Output/LPM/lpm_`city'`cohort'_m.tex", write replace
		file write lpm`city'`cohort'_m "\begin{table}[H]" _n
		file write lpm`city'`cohort'_m "\caption{LPM Estimation `city' - ``cohort'_lab', Materna}" _n
		file write lpm`city'`cohort'_m "\centering" _n
		file write lpm`city'`cohort'_m "\scalebox{0.7}{" _n
		file write lpm`city'`cohort'_m "\begin{tabular}{lccccc}" _n
		file write lpm`city'`cohort'_m "\toprule" _n
		file write lpm`city'`cohort'_m " & \textbf{None} & \textbf{Municipal} & \textbf{Religious} & \textbf{Private} & \textbf{State} \\" _n
		file write lpm`city'`cohort'_m "\midrule" _n
	
		foreach type in None Muni Reli Priv Stat {

			di "`cohort'"
			local large_sample_condition largeSample_`age'`cohort'`city' == 1
			
			** Generate large sample (all missing are imputed to zero and converted into dummies)
			quietly reg xm`city'`type'`cohort' `Xright' if (Cohort == `cohort_val') & (City == `city_val')  
			capture gen largeSample_`age'`cohort'`city' = e(sample)	
			tab largeSample_`age'`cohort'`city'

			** Run regressions and store results into latex
			di "Running the regressions for Materna `type' `city' `type' `cohort'"
			reg xm`city'`type'`cohort' `Xright' if (Cohort == `cohort_val') & (City == `city_val')   
			mat rslt = r(table)	
			local N`city'`type'`cohort' = e(N)
			local R2`city'`type'`cohort' = e(r2)
			local R2`city'`type'`cohort': di %9.2f `R2`city'`type'`cohort''
			
			sum xm`city'`type'`cohort' if (Cohort == `cohort_val') & (City == `city_val') & (xm`city'`type'`cohort' == 1)
			local NN`city'`type'`cohort' = r(N)
		
			local frac`city'`type'`cohort' = `NN`city'`type'`cohort''/`N`city'`type'`cohort''
			local frac`city'`type'`cohort': di %9.2f `frac`city'`type'`cohort''
		
			** Generate locals for the output values (1st row: Beta, 2nd row: Standard Error, 4th row: P-value)
			foreach sub in Res Mom Dad House {
				foreach var in `Xcontrol`sub'' { 
						matrix matxm_b``var'_short'`city'`type'`cohort' = rslt[1,"`var'"]
						local xm_b``var'_short'`city'`type'`cohort' = matxm_b``var'_short'`city'`type'`cohort'[1,1]
						local xm_b``var'_short'`city'`type'`cohort': di %9.2f `xm_b``var'_short'`city'`type'`cohort''
						
						matrix matxm_se``var'_short'`city'`type'`cohort' = rslt[2,"`var'"]
						local xm_se``var'_short'`city'`type'`cohort' = matxm_se``var'_short'`city'`type'`cohort'[1,1]
						local xm_se``var'_short'`city'`type'`cohort': di %9.2f `xm_se``var'_short'`city'`type'`cohort''
						local xm_se``var'_short'`city'`type'`cohort' (`xm_se``var'_short'`city'`type'`cohort'' )
					
						matrix matxm_pval``var'_short'`city'`type'`cohort' = rslt[4,"`var'"]
						local xm_pval``var'_short'`city'`type'`cohort' = matxm_pval``var'_short'`city'`type'`cohort'[1,1]
						local xm_pval``var'_short'`city'`type'`cohort': di %9.2f `xm_pval``var'_short'`city'`type'`cohort''
						
						if (`xm_pval``var'_short'`city'`type'`cohort'' <= 0.1) { // Boldify (?) the statistically significant result
		
							local xm_b``var'_short'`city'`type'`cohort' 	\textbf{`xm_b``var'_short'`city'`type'`cohort''}
							local xm_se``var'_short'`city'`type'`cohort'	\textbf{`xm_se``var'_short'`city'`type'`cohort''}							
						
						}	
					}
				}						
			}		
		
		
	
		file write lpm`city'`cohort'_m "\textbf{Respondent's Baseline Info} \\" _n
		foreach var in `XcontrolRes' {
			if !((`xm_pval``var'_short'`city'None`cohort'' == .) & (`xm_pval``var'_short'`city'Muni`cohort'' == .) & (`xm_pval``var'_short'`city'Reli`cohort'' == .) & (`xm_pval``var'_short'`city'Priv`cohort'' == .) & (`xm_pval``var'_short'`city'Stat`cohort'' == .)) {
				file write lpm`city'`cohort'_m	"\quad ``var'_lab' & `xm_b``var'_short'`city'None`cohort'' & `xm_b``var'_short'`city'Muni`cohort'' & `xm_b``var'_short'`city'Reli`cohort'' & `xm_b``var'_short'`city'Priv`cohort'' & `xm_b``var'_short'`city'Stat`cohort'' \\" _n
				file write lpm`city'`cohort'_m	"\quad  & `xm_se``var'_short'`city'None`cohort'' & `xm_se``var'_short'`city'Muni`cohort''  & `xm_se``var'_short'`city'Reli`cohort''  & `xm_se``var'_short'`city'Priv`cohort'' & `xm_se``var'_short'`city'Stat`cohort'' \\" _n
			}
		}
		file write lpm`city'`cohort'_m "\midrule" _n
		
		file write lpm`city'`cohort'_m "\textbf{Mother's Baseline Info} \\" _n
		foreach var in `XcontrolMom' {
			if !((`xm_pval``var'_short'`city'None`cohort'' == .) & (`xm_pval``var'_short'`city'Muni`cohort'' == .) & (`xm_pval``var'_short'`city'Reli`cohort'' == .) & (`xm_pval``var'_short'`city'Priv`cohort'' == .) & (`xm_pval``var'_short'`city'Stat`cohort'' == .)) {
				file write lpm`city'`cohort'_m	"\quad ``var'_lab' & `xm_b``var'_short'`city'None`cohort'' & `xm_b``var'_short'`city'Muni`cohort'' & `xm_b``var'_short'`city'Reli`cohort'' & `xm_b``var'_short'`city'Priv`cohort'' & `xm_b``var'_short'`city'Stat`cohort'' \\" _n
				file write lpm`city'`cohort'_m	"\quad  & `xm_se``var'_short'`city'None`cohort'' & `xm_se``var'_short'`city'Muni`cohort''  & `xm_se``var'_short'`city'Reli`cohort''  & `xm_se``var'_short'`city'Priv`cohort'' & `xm_se``var'_short'`city'Stat`cohort'' \\" _n
			}
		}
		file write lpm`city'`cohort'_m "\midrule" _n
		
		file write lpm`city'`cohort'_m "\textbf{Father's Baseline Info} \\" _n
		foreach var in `XcontrolDad' {
			if !((`xm_pval``var'_short'`city'None`cohort'' == .) & (`xm_pval``var'_short'`city'Muni`cohort'' == .) & (`xm_pval``var'_short'`city'Reli`cohort'' == .) & (`xm_pval``var'_short'`city'Priv`cohort'' == .) & (`xm_pval``var'_short'`city'Stat`cohort'' == .)) {
				file write lpm`city'`cohort'_m	"\quad ``var'_lab' & `xm_b``var'_short'`city'None`cohort'' & `xm_b``var'_short'`city'Muni`cohort'' & `xm_b``var'_short'`city'Reli`cohort'' & `xm_b``var'_short'`city'Priv`cohort'' & `xm_b``var'_short'`city'Stat`cohort'' \\" _n
				file write lpm`city'`cohort'_m	"\quad  & `xm_se``var'_short'`city'None`cohort'' & `xm_se``var'_short'`city'Muni`cohort''  & `xm_se``var'_short'`city'Reli`cohort''  & `xm_se``var'_short'`city'Priv`cohort'' & `xm_se``var'_short'`city'Stat`cohort'' \\" _n
			}
		}
		file write lpm`city'`cohort'_m "\midrule" _n
		
		file write lpm`city'`cohort'_m "\textbf{Household Baseline Info} \\" _n
		foreach var in `XcontrolHouse' {
			if !((`xm_pval``var'_short'`city'None`cohort'' == .) & (`xm_pval``var'_short'`city'Muni`cohort'' == .) & (`xm_pval``var'_short'`city'Reli`cohort'' == .) & (`xm_pval``var'_short'`city'Priv`cohort'' == .) & (`xm_pval``var'_short'`city'Stat`cohort'' == .)) {
				file write lpm`city'`cohort'_m	"\quad ``var'_lab' & `xm_b``var'_short'`city'None`cohort'' & `xm_b``var'_short'`city'Muni`cohort'' & `xm_b``var'_short'`city'Reli`cohort'' & `xm_b``var'_short'`city'Priv`cohort'' & `xm_b``var'_short'`city'Stat`cohort'' \\" _n
				file write lpm`city'`cohort'_m	"\quad  & `xm_se``var'_short'`city'None`cohort'' & `xm_se``var'_short'`city'Muni`cohort''  & `xm_se``var'_short'`city'Reli`cohort''  & `xm_se``var'_short'`city'Priv`cohort'' & `xm_se``var'_short'`city'Stat`cohort'' \\" _n
			}
		}
		file write lpm`city'`cohort'_m "\midrule" _n
		file write lpm`city'`cohort'_m "Observations & `N`city'None`cohort'' & `N`city'Muni`cohort'' & `N`city'Reli`cohort'' & `N`city'Priv`cohort'' & `N`city'Stat`cohort'' \\" _n
		file write lpm`city'`cohort'_m "Fraction Attending Each Type & `frac`city'None`cohort'' & `frac`city'Muni`cohort'' & `frac`city'Reli`cohort'' & `frac`city'Priv`cohort'' & `frac`city'Stat`cohort'' \\" _n
		file write lpm`city'`cohort'_m "\midrule" _n
		file write lpm`city'`cohort'_m "$ R^2$ & `R2`city'None`cohort'' & `R2`city'Muni`cohort'' & `R2`city'Reli`cohort'' & `R2`city'Priv`cohort'' & `R2`city'Stat`cohort'' \\" _n
		file write lpm`city'`cohort'_m "\bottomrule" _n
		file write lpm`city'`cohort'_m "\end{tabular}}" _n
		file write lpm`city'`cohort'_m "\end{table}" _n
		file write lpm`city'`cohort'_m "\begin{scriptsize}" _n
		file write lpm`city'`cohort'_m "\noindent\underline{Note:} This table presents the linear probability model estimations for attending each type of Materna schools, indicated by each column. The samples used in this estimation are those who were ``cohort'_note' at the time of the survey living in `city'. All dependent variables are binary. Observation indicates the number of people included in this sample. Bold number indicates that the p-value is less than or equal to 0.1. Standard errors are reported in parentheses." _n
		file write lpm`city'`cohort'_m "\end{scriptsize}" _n
		file close lpm`city'`cohort'_m 
		
		local cohort_val = `cohort_val' + 1
	}
	local city_val = `city_val' + 1
}	

log close

	
