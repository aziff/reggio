global klmReggio   : env klmReggio
global data_reggio : env data_reggio
*global git_reggio  : env git_reggio

//include "${klmReggio}/Analysis/prepare-data"
include "~/Desktop/work/repos/reggio/prepare-data"
include "~/Desktop/work/repos/reggio/baseline-rename"

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


*-* To ease display of table

recode maternaType 			(1=1) (2=2) (3=3) (4=4) (0=5)

label define materna_type 	1 Municipal 2 State 3 Religious 4 Private 5 None 

label value maternaType 	materna_type

local materna_name			Materna

local header1				"\textbf{Outcome} & \multicolumn{6}{c}{\textbf{C. Mean}} & & \multicolumn{6}{c}{\textbf{Mean}} \\"
local header2				"\quad \quad Sample & Muni & State & Reli & Priv & None & $ R^2$ & & Muni & State & Reli & Priv & None & $ R^2$ \\"
local header3				"\quad \quad Restriction & \tiny{$\boldsymbol{\gamma_0}$}& \tiny{$\boldsymbol{\gamma_0+\gamma_1}$}& \tiny{$\boldsymbol{\gamma_0+\gamma_2}$}& \tiny{$\boldsymbol{\gamma_0+\gamma_3}$}& \tiny{$\boldsymbol{\gamma_0+\gamma_4}$} & & & \tiny{$\boldsymbol{\gamma_0}$}& \tiny{$\boldsymbol{\gamma_0+\gamma_1}$}& \tiny{$\boldsymbol{\gamma_0+\gamma_2}$}& \tiny{$\boldsymbol{\gamma_0+\gamma_3}$}& \tiny{$\boldsymbol{\gamma_0+\gamma_4}$} \\"

cd "~/Desktop/work/repos/reggio"

		
foreach out_type in E W L H N S{
	file open baseline using "Output/meanOutcome_`out_type'.tex", write replace
	file write baseline "`header1'" _n
	file write baseline "`header2'" _n
	file write baseline "`header3'" _n
	file write baseline "\hline \endhead" _n

	foreach v in `adult_outcome_`out_type'' {
		local vl : variable label `v'	
		
		file write baseline "~\\*[.05cm]" _n
		file write baseline "\textbf{``v'_lab'} \\*[.1cm]" _n
		local cohort_i = 4
		foreach cohort in Adult30 Adult40 Adult50{
			
			
			sum `v' if maternaType == 1 & City == 1 & Cohort == `cohort_i'
			local mean_s = r(mean)
			local mean_s: di %9.2f `mean_s'
		
			file write baseline "\quad \quad `cohort' & & & & & & & & \multicolumn{6}{c}{\highlight{Reference mean = \textbf{`mean_s'}}} \\*[.1cm]" _n
			
			local city_i = 1
			foreach city in `cities' {
		
				file write baseline "\quad \quad \quad \quad `city'"
				
				* Conditional mean
				cap reg `v' ib1.maternaType `adult_baseline_vars_`out_type'' if `city' == 1 & Cohort_`cohort' == 1
				if _rc {
					continue
				}
				
				cap matrix drop cond
				matrix cond = r(table)
				cap matrix drop cons
				matrix cons = cond[1,"_cons"]
				cap matrix drop V
				matrix V = e(V)
				cap matrix drop B
				matrix B = e(b)
				
				local constant = cons[1,1]
				local cond_r_squared = e(r2)
				local cond_N = e(N)
				
				local cons_colNum = colnumb(V,"_cons")
				local se_cons = V[`cons_colNum',`cons_colNum']
			
				local cond_r_squared: di %9.2f `cond_r_squared'
				
				local colName 1b.maternaType 2.maternaType 3.maternaType 4.maternaType 5.maternaType
				
				local num = 1
				foreach tmp_type of local colName {
					local colNum = colnumb(cond,"`tmp_type'")  		// Identifying column # in matrix for each maternaType
					
					local var`num' = B[1,`colNum']
					local cond_mean_var`num' = `constant' + `var`num''
					
					local se`num' = V[`colNum',`colNum'] + `se_cons' + 2*V[`cons_colNum',`colNum']
					local t`num' = `cond_mean_var`num''/sqrt(`se`num'')
					
					local cond_mean_var`num': di %9.2f `cond_mean_var`num''
					
					/*
					if 2*(1-normal(abs(`t`num''))) <= 0.1 {
						local cond_mean_var`num' \textbf{`cond_mean_var`num''}
					}
					*/
					
					local num=`num'+1
				}
						
				local cond_meanMunicipal 	`cond_mean_var1'
				local cond_meanState 		`cond_mean_var2'
				local cond_meanReligious  	`cond_mean_var3'
				local cond_meanPrivate  	`cond_mean_var4'
				local cond_meanNone  		`cond_mean_var5'
	
				local row
					
				* Unconditional mean
				reg `v' i.maternaType if `city' == 1 & Cohort_`cohort' == 1
				local r_squared = e(r2)
				local N_save 	= e(N)

				local r_squared : di %9.2f `r_squared'
					
				cap matrix drop un_cond
				matrix un_cond = r(table)
				cap matrix drop un_cons
				matrix un_cons = un_cond[1,"_cons"]
				cap matrix drop un_V
				matrix un_V = e(V)
				cap matrix drop un_B
				matrix un_B = e(b)
				
				local un_constant = un_cons[1,1]
				local un_cond_r_squared = e(r2)
				local un_cond_N = e(N)
				
				local un_cons_colNum = colnumb(un_V,"_cons")
				local un_se_cons = un_V[`un_cons_colNum',`un_cons_colNum']
			
				local un_r_squared: di %9.2f `un_r_squared'
				
				local colName 1b.maternaType 2.maternaType 3.maternaType 4.maternaType 5.maternaType
				
					local num = 1
					foreach tmp_type of local colName {
						local colNum = colnumb(un_cond,"`tmp_type'")  		// Identifying column # in matrix for each maternaType
					
						local un_var`num' = un_B[1,`colNum']
						local un_cond_mean_var`num' = `un_constant' + `un_var`num''
						
						local un_se`num' = un_V[`colNum',`colNum'] + `un_se_cons' + 2*V[`un_cons_colNum',`colNum']
						local un_t`num' = `un_cond_mean_var`num''/sqrt(`un_se`num'')
						
						local un_cond_mean_var`num': di %9.2f `un_cond_mean_var`num''
					
						/*
						if 2*(1-normal(abs(`un_t`num''))) <= 0.1  {
							local un_cond_mean_var`num' \textbf{`un_cond_mean_var`num''}
						}
						*/
						local num=`num'+1
					}
						
					local un_cond_meanMunicipal 	`un_cond_mean_var1'
					local un_cond_meanState 		`un_cond_mean_var2'
					local un_cond_meanReligious  	`un_cond_mean_var3'
					local un_cond_meanPrivate  		`un_cond_mean_var4'
					local un_cond_meanNone  		`un_cond_mean_var5'

					//local N_save : di %9.0f `N_save'
					//local cond_N : di %9.0f `cond_N'
	
						
					
			local umean `un_cond_meanMunicipal' & `un_cond_meanState' & `un_cond_meanReligious' & `un_cond_meanPrivate' & `un_cond_meanNone'
			local cmean `cond_meanMunicipal' & `cond_meanState' & `cond_meanReligious' & `cond_meanPrivate' & `cond_meanNone'
			
			file write baseline "& `cmean' & `cond_r_squared' & & `umean' & `r_squared' \\*" _n
			local city_i = `city_i' + 1
			}
		file write baseline "\\" _n
		local cohort_i = `cohort_i' + 1
		}
	}
file close baseline
}

