global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio // AZ: changed $git_reggio to point to GitHub repo

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
	local adult_baseline_vars_`cat'		Male CAPI numSiblings dadMaxEdu_Uni dadMaxEdu_Grad momMaxEdu_Grad
}


local adult_baseline_vars_W			Male CAPI numSiblings dadMaxEdu_Uni dadMaxEdu_Grad momMaxEdu_Grad i.SES	
									
** BIC-selected baseline variables
local bic_baseline_vars		    	Male CAPI numSiblings dadMaxEdu_Uni dadMaxEdu_Grad momMaxEdu_Grad
											
** Outcomes for each category
local adult_outcome_E				IQ_factor votoMaturita votoUni ///
									highschoolGrad MaxEdu_Uni MaxEdu_Grad

local adult_outcome_W				PA_Empl SES_self HrsTot WageMonth ///
									Reddito_1 Reddito_2 Reddito_3 Reddito_4 Reddito_5 Reddito_6 Reddito_7

local adult_outcome_L				mStatus_married_cohab childrenResp all_houseOwn live_parent 
									
local adult_outcome_H				Maria Smoke Cig BMI goodHealth SickDays ///
									i_RiskFight i_RiskDUI RiskSuspended Drink1Age									
									
local adult_outcome_N				pos_LocusControl pos_Depression_score ///
									binSatisIncome binSatisWork binSatisHealth binSatisFamily ///
									optimist reciprocity1bin reciprocity2bin reciprocity3bin reciprocity4bin		
									
local adult_outcome_S				MigrTaste Friends MigrFriend


#delimit cr

local m_condition					keep if Male == 1
local f_condition					keep if Male == 0
local p_condition

local m_name						Males
local f_name						Females
local p_name						Pooled
local S_name						Social 
local N_name						Non-cognitive
local H_name						Health
local L_name						Household and Family
local W_name						Employment
local E_name						Education

local Adult30_name	 				Adult 30
local Adult40_name					Adult 40
local Adult50_name					Adult 50


*-* To ease display of table

recode maternaType 			(1=1) (2=2) (3=3) (4=4) (0=5)

label define materna_type 	1 Municipal 2 State 3 Religious 4 Private 5 None 

label value maternaType 	materna_type

local materna_name			Materna

local header1				"\textbf{Outcome} & \multicolumn{6}{c}{\textbf{C. Mean}} & & \multicolumn{6}{c}{\textbf{Mean}} \\"
local header2				"\quad \quad Sample & Muni & State & Reli & Priv & None & $ R^2$ & & Muni & State & Reli & Priv & None & $ R^2$ \\"
local header3				"\quad \quad Restriction & \tiny{$\boldsymbol{\gamma_0}$}& \tiny{$\boldsymbol{\gamma_0+\gamma_1}$}& \tiny{$\boldsymbol{\gamma_0+\gamma_2}$}& \tiny{$\boldsymbol{\gamma_0+\gamma_3}$}& \tiny{$\boldsymbol{\gamma_0+\gamma_4}$} & & & \tiny{$\boldsymbol{\gamma_0}$}& \tiny{$\boldsymbol{\gamma_0+\gamma_1}$}& \tiny{$\boldsymbol{\gamma_0+\gamma_2}$}& \tiny{$\boldsymbol{\gamma_0+\gamma_3}$}& \tiny{$\boldsymbol{\gamma_0+\gamma_4}$} \\"

cd "$git_reggio"

cap log close
log using "Output/OLS/checkOLS", replace	

foreach sex in m f p {
	preserve
	``sex'_condition'
	
	foreach out_type in E W L H N S {

/*
		file open baseline using "Output/meanOutcome_`out_type'`sex'.tex", write replace
		file write baseline "`header1'" _n
		file write baseline "`header2'" _n
		file write baseline "`header3'" _n
		file write baseline "\hline \endhead" _n
	*/	
		file open ols using "Output/OLS/OLStable_`out_type'`sex'.tex", write replace
		file write ols "\begin{longtable}{L{8em} c c c c c c c p{1em} c c c c c c c}" _n
		file write ols "\caption{OLS Estimated Coefficients, ``out_type'_name' Outcomes, ``sex'_name'}\label{OLS-`out_type'-`sex'} \\" _n
		file write ols "\toprule" _n
		file write ols " & \multicolumn{7}{c}{\textbf{Conditional}} & & \multicolumn{7}{c}{\textbf{Unconditional}} \\" _n
		file write ols " & Muni$ ^*$ & State & Reli & Priv & None & $ R^2$ & $ N$ & & Muni$ ^*$ & State & Reli & Priv & None & $ R^2$ & $ N$ \\" _n
		file write ols "\midrule \endhead" _n
		file write ols "\bottomrule \\" _n
		file write ols "\multicolumn{16}{L{21.5cm}}{\textbf{Note:} \OLS}" _n
		file write ols "\endfoot" _n

		foreach v in `adult_outcome_`out_type'' {
	
			local vl : variable label `v'	
		
			/*
			file write baseline "~\\*[.05cm]" _n
			file write baseline "\textbf{``v'_lab'} \\*[.1cm]" _n
			*/
			
			file write ols "\textbf{``v'_lab'} \\*" _n
		
			local cohort_i = 4
			foreach cohort in Adult30 Adult40 Adult50 {
			
			
				sum `v' if maternaType == 1 & City == 1 & Cohort == `cohort_i'
				local mean_s = r(mean)
				local mean_s: di %9.2f `mean_s'
		
				*file write baseline "\quad \quad \textbf{``cohort'_name'} & & & & & & & & \multicolumn{6}{c}{\highlight{Reference mean = \textbf{`mean_s'}}} \\*[.1cm]" _n
				file write ols 		"\quad \quad \textbf{``cohort'_name'} & & & & & & & & & & & & & & & \\* " _n
				
				local city_i = 1
				foreach city in `cities' {
		
					*file write baseline "\quad \quad \quad `city'"
					file write ols 		"\quad \quad \quad `city'"
						
					foreach mean_type in cond un_cond {
				
						* Conditional mean
						if "`mean_type'" == "cond" {
							cap reg `v' ib1.maternaType `adult_baseline_vars_`out_type'' if `city' == 1 & Cohort_`cohort' == 1
							matrix list r(table)
							if _rc {
								continue
							}
						}
						* Unconditional mean
						else {
							reg `v' ib1.maternaType if `city' == 1 & Cohort_`cohort' == 1
							matrix list r(table)
						}
					
						// extract values
						cap matrix drop `mean_type'
						matrix `mean_type' = r(table)
						
						cap matrix drop `mean_type'_cons
						matrix `mean_type'_cons = `mean_type'[1,"_cons"]
					
						cap matrix drop `mean_type'_V
						matrix `mean_type'_V = e(V)
					
						cap matrix drop `mean_type'_B
						matrix `mean_type'_B = e(b)
					
						local `mean_type'_constant 	= `mean_type'_cons[1,1]
					
						local `mean_type'_r_squared = e(r2)
						local `mean_type'_r_squared: di %9.2f ``mean_type'_r_squared'
					
						local `mean_type'_N = e(N)
						local `mean_type'_N: di %9.0f ``mean_type'_N'
					
						// s.e. of contstant
						local `mean_type'_cons_colNum 	= colnumb(`mean_type'_V,"_cons")
					
						local `mean_type'_se_cons 		= `mean_type'_V[``mean_type'_cons_colNum',``mean_type'_cons_colNum']
						local `mean_type'_p_cons		= `mean_type'[4,``mean_type'_cons_colNum']
						
						
			
						// compute estimated coefficients
						local colName 1b.maternaType 2.maternaType 3.maternaType 4.maternaType 5.maternaType
				
						local num = 1
						foreach tmp_type of local colName {
				
							local colNum = colnumb(`mean_type',"`tmp_type'")  		// Identifying column # in matrix for each maternaType
					
							local `mean_type'_var`num' 		= `mean_type'_B[1,`colNum']
							local `mean_type'_mean_var`num' = ``mean_type'_constant' + ``mean_type'_var`num''
						
						
					
							// s.e. and t-score of each estimate
							local `mean_type'_variance`num' = `mean_type'_V[`colNum',`colNum'] + ``mean_type'_se_cons' + 2*`mean_type'_V[``mean_type'_cons_colNum',`colNum']
							local `mean_type'_se`num' 		= sqrt(``mean_type'_variance`num'')
							local `mean_type'_t`num' 		= ``mean_type'_mean_var`num''/``mean_type'_se`num''
							local `mean_type'_p`num'		= `mean_type'[4,`colNum']
						
							// significance comparing to municipal
							if "`city'" == "Reggio" & `num' == 1 {
								local Reggio_`mean_type'_mean_var1 	= ``mean_type'_mean_var1'
								local Reggio_`mean_type'_se1 		= ``mean_type'_se1'
								local Reggio_`mean_type'_N 			= ``mean_type'_N'
							}
						
							local `mean_type'_mean_var`num'	: di %9.2f ``mean_type'_mean_var`num''
							local `mean_type'_var`num'		: di %9.3f ``mean_type'_var`num''
							local `mean_type'_p`num'		: di %9.3f ``mean_type'_p`num''
							local `mean_type'_se`num'		: di %9.3f ``mean_type'_se`num''
							
							if ``mean_type'_mean_var`num'' == -0.00 {
								local `mean_type'_mean_var`num' = 0.00
							}
							
							if ``mean_type'_p`num'' <= 0.1 {
								local `mean_type'_var`num' $ \mathbf{``mean_type'_var`num''}$
							}
						
							else {
								if `Reggio_`mean_type'_mean_var1' < . & ``mean_type'_mean_var`num'' < . {
									# delimit ;
									ttesti 	`Reggio_`mean_type'_N' 
										`Reggio_`mean_type'_mean_var1' 
										`Reggio_`mean_type'_se1'
										``mean_type'_N' 
										``mean_type'_mean_var`num'' 
										``mean_type'_se`num'', unequal welch;
									# delimit cr
								
									if r(p) <= 0.1 {
										local `mean_type'_mean_var`num' \textbf{``mean_type'_mean_var`num''}
									}
								}
							}
						
						
							/* // this is if significance is to show that the means are signficant
							if 2*(1-normal(abs(``mean_type'_t`num''))) <= 0.1 {
								local `mean_type'_mean_var`num' \textbf{``mean_type'_mean_var`num''}
							}
							*/
					
							local num=`num'+1
						}
					
					
					local `mean_type'_se_cons 	: di %9.2f ``mean_type'_se_cons'
					local `mean_type'_p_cons 	: di %9.2f ``mean_type'_p_cons'
						
					local `mean_type'_meanMunicipal 	``mean_type'_mean_var1'
					local `mean_type'_meanState 		``mean_type'_mean_var2'
					local `mean_type'_meanReligious  	``mean_type'_mean_var3'
					local `mean_type'_meanPrivate  		``mean_type'_mean_var4'
					local `mean_type'_meanNone  		``mean_type'_mean_var5'
	
					local row
					
					}
					
				*local umean `un_cond_meanMunicipal' & `un_cond_meanState' & `un_cond_meanReligious' & `un_cond_meanPrivate' & `un_cond_meanNone'
				*local cmean `cond_meanMunicipal' & `cond_meanState' & `cond_meanReligious' & `cond_meanPrivate' & `cond_meanNone'
				
				local u_coeff `un_cond_meanMunicipal' & `un_cond_var2' & `un_cond_var3' & `un_cond_var4' & `un_cond_var5'
				local c_coeff `cond_meanMunicipal' & `cond_var2' & `cond_var3' & `cond_var4' & `cond_var5'
				
				local u_se $ (`un_cond_se_cons')$ & $ (`un_cond_se2')$ & $ (`un_cond_se3')$ & $ (`un_cond_se4')$ & $ (`un_cond_se5')$
				local c_se $ (`cond_se_cons')$ & $ (`cond_se2')$ & $ (`cond_se3')$ & $ (`cond_se4')$ & $ (`cond_se5')$
				
				local u_p [`un_cond_p_cons'] & [`un_cond_p2'] & [`un_cond_p3'] & [`un_cond_p4'] & [`un_cond_p5']
				local c_p [`cond_p_cons']  & [`cond_p2'] & [`cond_p3'] & [`cond_p4'] & [`cond_p5']
			
				*file write baseline "& `cmean' & `cond_r_squared' & & `umean' & & `un_cond_r_squared' \\*" _n
				file write ols		"& `c_coeff' & `cond_r_squared' & `cond_N' & & `u_coeff' & `un_cond_r_squared' & `un_cond_N'  \\*" _n
				file write ols		"\quad \quad \quad \quad s.e.& `c_se' & & & & `u_se' & &  \\*" _n
				file write ols		"\quad \quad \quad \quad $ p$ & `c_p' & & & & `u_p' & &  \\[1em]" _n
				local city_i = `city_i' + 1
				}
			*file write baseline "\\" _n
			file write ols "~\\[1em]" _n
			local cohort_i = `cohort_i' + 1
			}
			
			*file write ols "\midrule" _n
		}
	
	*file close baseline
	*file write ols "\bottomrule" _n
	file write ols "\end{longtable}"
	file close ols
	}
restore
}
log close
